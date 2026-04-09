DROP TABLE IF EXISTS drugs_es_raw CASCADE;
CREATE TABLE drugs_es_raw (
    "Nº Registro" VARCHAR(50),
	"Medicamento" TEXT,
	"Laboratorio" VARCHAR(255),
	"Fecha Aut." VARCHAR(20),
    "Estado" VARCHAR(20),
    "Fecha Estado" VARCHAR(20),
	"Cód. ATC" VARCHAR(20),
    "Principios Activos" TEXT,
    "Nº P. Activos" INTEGER,
	"¿Comercializado?" VARCHAR(20),
	"¿Triangulo Amarillo?" VARCHAR(20),
	"Observaciones" TEXT,
	"¿Sustituible?" TEXT,
	"¿Afecta conducción?" VARCHAR(20),
	"¿Problemas de suministro?" VARCHAR(20)
);

COPY drugs_es_raw FROM './raw_data/Medicamentos.csv' CSV HEADER DELIMITER ',';

SELECT * FROM drugs_es_raw LIMIT 5;
SELECT COUNT(DISTINCT "Principios Activos") FROM drugs_es_raw;
SELECT COUNT(DISTINCT "Nº Registro"), COUNT(DISTINCT "Medicamento") FROM drugs_es_raw;
SELECT COUNT(DISTINCT "¿Sustituible?") FROM drugs_es_raw;

--###############--
-- create normalised tables
	-- dim_atc
	DROP TABLE IF EXISTS dim_atc CASCADE;
	CREATE TABLE dim_atc (
		atc_id SERIAL PRIMARY KEY,
		atc_code VARCHAR(20) NOT NULL UNIQUE
	);
	INSERT INTO dim_atc (atc_code)
		SELECT DISTINCT "Cód. ATC"
		FROM drugs_es_raw
		WHERE "Cód. ATC" IS NOT NULL;
	SELECT * FROM dim_atc LIMIT 5;
	SELECT COUNT(*) FROM dim_atc LIMIT 5; -- 2364 records

	-- dim_drug
	DROP TABLE IF EXISTS dim_drug CASCADE;
	CREATE TABLE dim_drug (
		drug_id SERIAL PRIMARY KEY,
		registry_id VARCHAR(50) NOT NULL UNIQUE,
		drug_name VARCHAR(255) NOT NULL
	);
	INSERT INTO dim_drug (registry_id, drug_name)
		SELECT "Nº Registro", "Medicamento"
		FROM drugs_es_raw
		WHERE "Nº Registro" IS NOT NULL;
	SELECT * FROM dim_drug LIMIT 5;
	SELECT COUNT(*) FROM dim_drug LIMIT 5; -- 26607 records
	
	-- dim_active_compound
	DROP TABLE IF EXISTS dim_active_compound CASCADE;
	CREATE TABLE dim_active_compound (
		compound_id SERIAL PRIMARY KEY,
		compound_name TEXT NOT NULL UNIQUE,
		compound_numbers INTEGER,
		drug_id INTEGER REFERENCES dim_drug(drug_id)
	);
	INSERT INTO dim_active_compound (compound_name, compound_numbers)
		SELECT DISTINCT "Principios Activos", "Nº P. Activos"
		FROM drugs_es_raw;
	SELECT * FROM dim_active_compound LIMIT 5;
	SELECT COUNT(*) FROM dim_active_compound LIMIT 5; -- 4072 records
	
	-- dim_manufacturer
	DROP TABLE IF EXISTS dim_manufacturer CASCADE;
	CREATE TABLE dim_manufacturer (
		manufacturer_id SERIAL PRIMARY KEY,
		manufacturer_name VARCHAR(500) NOT NULL UNIQUE
	);
	INSERT INTO dim_manufacturer (manufacturer_name)
		SELECT DISTINCT "Laboratorio"
		FROM drugs_es_raw
		WHERE "Laboratorio" IS NOT NULL;
	SELECT * FROM dim_manufacturer LIMIT 5;
	SELECT COUNT(*) FROM dim_manufacturer LIMIT 5; -- 1190 records

	-- dim_status
	DROP TABLE IF EXISTS dim_status CASCADE;
	CREATE TABLE dim_status (
	    status_id SERIAL PRIMARY KEY,
	    status_name VARCHAR(50) NOT NULL UNIQUE
	);
	INSERT INTO dim_status (status_name)
		SELECT DISTINCT "Estado" 
		FROM drugs_es_raw 
		WHERE "Estado" IS NOT NULL;
	SELECT * FROM dim_status LIMIT 5;
	SELECT COUNT(*) FROM dim_status LIMIT 5; -- 3 records

	-- BRIDGE bridge_drugs_observations
	DROP TABLE IF EXISTS bridge_drugs_observations CASCADE;
	CREATE TABLE bridge_drugs_observations (
	    id SERIAL PRIMARY KEY,
		registry_id VARCHAR(50) UNIQUE,
	    observation_categories TEXT
	);
	INSERT INTO bridge_drugs_observations (registry_id, observation_categories)
		SELECT DISTINCT "Nº Registro", TRIM("Observaciones")
		FROM drugs_es_raw
		WHERE "Observaciones" IS NOT NULL;
	SELECT * FROM bridge_drugs_observations;
	SELECT COUNT(*) FROM bridge_drugs_observations; -- 26607 records

	-- dim_observations
	DROP TABLE IF EXISTS dim_observations CASCADE;
	CREATE TABLE dim_observations (
	    observation_id SERIAL PRIMARY KEY,
	    observation_category TEXT NOT NULL UNIQUE
	);
	INSERT INTO dim_observations (observation_category)
		SELECT DISTINCT TRIM(split_categories) AS observation_category
		FROM (
			SELECT unnest(string_to_array(observation_categories, '.')) AS split_categories
			FROM bridge_drugs_observations
			WHERE observation_categories IS NOT NULL
		) AS splits
		WHERE TRIM(split_categories) != '' AND TRIM(split_categories) IS NOT NULL -- to remove empty spaces after splitting categories
		ORDER BY observation_category;
	SELECT * FROM dim_observations;
	SELECT COUNT(*) FROM dim_observations; -- 8 records

	-- bridge_observations_to_categories
	DROP TABLE IF EXISTS bridge_observations_to_categories CASCADE;
	CREATE TABLE bridge_observations_to_categories (
		id SERIAL PRIMARY KEY,
		registry_id VARCHAR(50) REFERENCES bridge_drugs_observations(registry_id),
		bridge_obs_id INTEGER REFERENCES bridge_drugs_observations(id),
		observation_id INTEGER REFERENCES dim_observations(observation_id),
		UNIQUE (bridge_obs_id, observation_id)
	);
	INSERT INTO bridge_observations_to_categories (registry_id, bridge_obs_id, observation_id)
		SELECT
			bridge_drugs_observations.registry_id,
			bridge_drugs_observations.id AS bridge_obs_id,
			dim_observations.observation_id
		FROM bridge_drugs_observations
		CROSS JOIN unnest(string_to_array(bridge_drugs_observations.observation_categories, '.')) AS split_obs
		JOIN dim_observations ON TRIM(split_obs) = dim_observations.observation_category
		WHERE bridge_drugs_observations.observation_categories IS NOT NULL 
			AND TRIM(split_obs) != '' 
			AND TRIM(split_obs) IS NOT NULL;
	SELECT * FROM bridge_observations_to_categories LIMIT 5;
	SELECT COUNT(*) FROM bridge_observations_to_categories; --29362 records
	
	-- dim_substitute
	DROP TABLE IF EXISTS dim_substitute CASCADE;
	CREATE TABLE dim_substitute (
	    substitute_id SERIAL PRIMARY KEY,
	    substitute_category TEXT NOT NULL UNIQUE
	);
	INSERT INTO dim_substitute (substitute_category)
		SELECT DISTINCT "¿Sustituible?"
		FROM drugs_es_raw
		WHERE "¿Sustituible?" IS NOT NULL;
	SELECT * FROM dim_substitute LIMIT 5;
	SELECT COUNT(*) FROM dim_substitute LIMIT 5; -- 3 records
	
	-- fact_medicamentos
	DROP TABLE IF EXISTS fact_medicamentos CASCADE;
	CREATE TABLE fact_medicamentos (
	    id SERIAL PRIMARY KEY,
	    drug_id INTEGER REFERENCES dim_drug(drug_id),
	    manufacturer_id INTEGER REFERENCES dim_manufacturer(manufacturer_id),
	    atc_id INTEGER REFERENCES dim_atc(atc_id),
	    status_id INTEGER REFERENCES dim_status(status_id),
	    observation_id INTEGER REFERENCES dim_observations(observation_id),
	    substitute_id INTEGER REFERENCES dim_substitute(substitute_id),
	    
	    -- Degenerate/business keys
	    nr_register VARCHAR(50),
	    
	    -- Facts/measures
	    authorisation_date DATE,
	    status_date DATE,
	    nr_active_compounds INTEGER,
	    
	    -- Boolean flags
	    is_commercialised BOOLEAN,
	    is_yellow_triangle BOOLEAN,
	    is_driving_affected BOOLEAN,
	    is_supply_issue BOOLEAN
	);
	INSERT INTO fact_medicamentos (
	    drug_id, manufacturer_id, atc_id, status_id,
	    observation_id, substitute_id, nr_register,
	    authorisation_date, status_date, nr_active_compounds,
	    is_commercialised, is_yellow_triangle, 
	    is_driving_affected, is_supply_issue
	)
	SELECT 
	    dd.drug_id,
	    dm.manufacturer_id,
	    da.atc_id,
	    ds.status_id,
	    dbo.observation_id,
	    dsub.substitute_id,
	    r."Nº Registro",
	    
	    -- SAFE date conversion (NULL if fails)
	    NULLIF(r."Fecha Aut.", '')::DATE,
	    NULLIF(r."Fecha Estado", '')::DATE,
	    
	    r."Nº P. Activos",
	    
	    -- Safe boolean conversion (handles 'Sí', 'Si', 'SÍ', etc.)
	    UPPER(TRIM(r."¿Comercializado?")) IN ('SÍ', 'SI', 'S'),
	    UPPER(TRIM(r."¿Triangulo Amarillo?")) IN ('SÍ', 'SI', 'S'),
	    UPPER(TRIM(r."¿Afecta conducción?")) IN ('SÍ', 'SI', 'S'),
	    UPPER(TRIM(r."¿Problemas de suministro?")) IN ('SÍ', 'SI', 'S')
		FROM drugs_es_raw r
		LEFT JOIN dim_drug dd ON r."Nº Registro" = dd.registry_id
		LEFT JOIN dim_manufacturer dm ON r."Laboratorio" = dm.manufacturer_name
		LEFT JOIN dim_atc da ON r."Cód. ATC" = da.atc_code
		LEFT JOIN dim_status ds ON r."Estado" = ds.status_name
		LEFT JOIN dim_observations dbo ON r."Observaciones" = dbo.observation_category
		LEFT JOIN dim_substitute dsub ON r."¿Sustituible?" = dsub.substitute_category;

	-- 5. Verify
	SELECT COUNT(*) FROM fact_medicamentos;
	SELECT * FROM fact_medicamentos LIMIT 10;
	


CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
SELECT * FROM drugs_es_raw 
--WHERE similarity("Medicamento", 'VERZENIOS 50 MG COMPRIMIDOS') > 0.55
WHERE "Medicamento" % 'VERZENIOS 50 MG COMPRIMIDOS'
ORDER BY similarity("Medicamento", 'VERZENIOS 50 MG COMPRIMIDOS') DESC
LIMIT 1;


SELECT *, trim(regexp_replace("Medicamento", '\s+', ' ', 'g')) AS cleaned_column
FROM drugs_es_raw
ORDER BY "Principios Activos";



/*#################################################*/
/* use './medicamentos_full.csv' to include data about the coverage of the drug treatment by national insurance */
-- Drop/create staging table 
DROP TABLE IF EXISTS drug_seguro_raw CASCADE;
CREATE TABLE drug_seguro_raw (
    codigo_nacional VARCHAR(50),
    principio_activo TEXT,
    nombre_medicamento TEXT,
    situacion_financiacion VARCHAR(100),
    tipo_medicamento VARCHAR(50),
    mas_info TEXT
);

-- Load CSV (adjust path/delimiter as needed)
COPY drug_seguro_raw FROM './raw_data/medicamentos_full.csv' CSV HEADER DELIMITER ',';

SELECT COUNT(*) FROM drug_seguro_raw;
SELECT * FROM drug_seguro_raw LIMIT 5;


-- Financing status dimension
DROP TABLE IF EXISTS dim_financiacion CASCADE;
CREATE TABLE dim_financiacion (
    financiacion_id SERIAL PRIMARY KEY,
    situation_category VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO dim_financiacion (situation_category)
SELECT DISTINCT 
    COALESCE(situacion_financiacion, 'Sin información') -- used to replace with 'Sin información' if the value is NULL
FROM drug_seguro_raw;
SELECT * FROM dim_financiacion;

-- Bridge: bridge_financiacion_match
	-- link codigo_nacional → registry_id via fuzzy name matching
DROP TABLE IF EXISTS bridge_financiacion_match CASCADE;
CREATE TABLE bridge_financiacion_match (
    id SERIAL PRIMARY KEY,
    codigo_nacional VARCHAR(50),
    registry_id VARCHAR(50) REFERENCES dim_drug(registry_id),
    nombre_medicamento TEXT,
    medicamento_original TEXT,
    similarity_score NUMERIC,
    financiacion_id INTEGER REFERENCES dim_financiacion(financiacion_id)
);

-- Populate RAW data first
INSERT INTO bridge_financiacion_match (
    codigo_nacional, registry_id, nombre_medicamento, medicamento_original,
    similarity_score, financiacion_id
)
SELECT 
    drug_seguro_raw.codigo_nacional,
    drug_seguro_raw.nombre_medicamento,
    r."Medicamento",
    r."Nº Registro",
    
    GREATEST(
        CASE 
			WHEN UPPER(TRIM(drug_seguro_raw.nombre_medicamento)) = UPPER(TRIM(r."Medicamento")) THEN 1.0 
			ELSE 0 END,
        CASE 
			WHEN drug_seguro_raw.nombre_medicamento ~* ('^' || regexp_replace(UPPER(r."Medicamento"), '[\\(\\)\\[\\]\\{\\}]', '', 'g') || '.*') THEN 0.95 
			ELSE 0 END,
        (1.0 - LEVENSHTEIN(LEFT(UPPER(TRIM(drug_seguro_raw.nombre_medicamento)), 20), LEFT(UPPER(TRIM(r."Medicamento")), 20))::numeric / 20)
    ),
    
    df.financiacion_id
FROM drug_seguro_raw
CROSS JOIN LATERAL (
    SELECT "Nº Registro", "Medicamento"
    FROM drugs_es_raw 
	-- optimisation to eliminate unnecessary matches 
    WHERE LENGTH("Medicamento") >= LENGTH(drug_seguro_raw.nombre_medicamento) * 0.7
      AND LENGTH("Medicamento") <= LENGTH(drug_seguro_raw.nombre_medicamento) * 1.5
    ORDER BY 
        CASE 
			WHEN UPPER(TRIM(drug_seguro_raw.nombre_medicamento)) = UPPER(TRIM("Medicamento")) THEN 0 END DESC,
        CASE 
			WHEN drug_seguro_raw.nombre_medicamento ~* ('^' || regexp_replace(UPPER("Medicamento"), '[\\(\\)\\[\\]\\{\\}]', '', 'g') || '.*') THEN 1 END DESC,
        LEVENSHTEIN(LEFT(UPPER(TRIM(drug_seguro_raw.nombre_medicamento)), 20), LEFT(UPPER(TRIM("Medicamento")), 20))
    LIMIT 1
) r
JOIN dim_financiacion df ON drug_seguro_raw.situacion_financiacion = df.situation_category
WHERE r."Nº Registro" IS NOT NULL;

--CORECT???
CREATE EXTENSION IF NOT EXISTS pg_trgm;
-- Create trigram indexes (speeds up fuzzy matching 100x) for faster fuzzy search
	-- trigram - 3-character chunk
	-- GIN = "Generalized Inverted Index"
CREATE INDEX IF NOT EXISTS idx_medicamento_trgm ON drugs_es_raw USING GIN ("Medicamento" gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_medicamento_length ON drugs_es_raw ("Medicamento");

-- Analyze for optimal planning
ANALYZE drugs_es_raw;
ANALYZE drug_seguro_raw;

-- TRUNCATE existing data
TRUNCATE bridge_financiacion_match;

-- FAST INSERT using trigram similarity (seconds instead of minutes)
INSERT INTO bridge_financiacion_match (
    codigo_nacional, nombre_medicamento, medicamento_original,
    registry_id, similarity_score, financiacion_id
)
WITH ranked_matches AS (
    SELECT 
        dsr.codigo_nacional,
        dsr.nombre_medicamento,
        r."Medicamento",
        r."Nº Registro",
        similarity(LOWER(dsr.nombre_medicamento), LOWER(r."Medicamento")) AS trigram_sim,
        word_similarity(LOWER(dsr.nombre_medicamento), LOWER(r."Medicamento")) AS word_sim,
        df.financiacion_id,
        
        -- Combined score
        GREATEST(
            similarity(LOWER(dsr.nombre_medicamento), LOWER(r."Medicamento")),
            word_similarity(LOWER(dsr.nombre_medicamento), LOWER(r."Medicamento")),
            CASE WHEN UPPER(TRIM(dsr.nombre_medicamento)) = UPPER(TRIM(r."Medicamento")) THEN 1.0 ELSE 0 END
        ) AS final_score,
        
        ROW_NUMBER() OVER (
            PARTITION BY dsr.codigo_nacional 
            ORDER BY 
                CASE WHEN UPPER(TRIM(dsr.nombre_medicamento)) = UPPER(TRIM(r."Medicamento")) THEN 0 END DESC,
                similarity(LOWER(dsr.nombre_medicamento), LOWER(r."Medicamento")) DESC,
                LEVENSHTEIN(LEFT(UPPER(TRIM(dsr.nombre_medicamento)), 15), LEFT(UPPER(TRIM(r."Medicamento")), 15))
        ) AS rn
        
    FROM drug_seguro_raw dsr
    JOIN drugs_es_raw r ON similarity(LOWER(dsr.nombre_medicamento), LOWER(r."Medicamento")) > 0.3  -- Fast pre-filter
    JOIN dim_financiacion df ON dsr.situacion_financiacion = df.situation_category
    WHERE LENGTH(r."Medicamento") BETWEEN LENGTH(dsr.nombre_medicamento)*0.6 AND LENGTH(dsr.nombre_medicamento)*1.8
)
SELECT 
    codigo_nacional, nombre_medicamento, "Medicamento",
    "Nº Registro", final_score, financiacion_id
FROM ranked_matches 
WHERE rn = 1  -- Best match only
  AND final_score >= 0.6;  -- Reasonable threshold;

SELECT COUNT(*) FROM bridge_financiacion_match;
SELECT 
    ROUND(final_score, 3) as score,
    match_confidence,
    COUNT(*) 
FROM bridge_financiacion_match 
GROUP BY 1,2 
ORDER BY 1 DESC 
LIMIT 10;
-- ##############################################################################################
SELECT DISTINCT mf.codigo_nacional, mf.nombre_medicamento
FROM stg_medicamentos_full mf
LEFT JOIN bridge_financiacion_match bfm ON mf.codigo_nacional = bfm.codigo_nacional
WHERE bfm.codigo_nacional IS NULL
LIMIT 10;
