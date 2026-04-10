/*##########################################################################################*/
/*##########################################################################################*/
/* Load RAW DATA
/* important to keep staging table as it is, so no column changes are done at this stage */
Includes description of the drugs 
	*formulation* - se relaciona con la composición química y la vía de administración
	*presentation* - la forma física y el empaque comercial 
	*/
/*##########################################################################################*/
/* 1. File with drug names and ATC codes from 'Presentaciones.csv'. */
	-- 'drugs_presentation_es_raw' includes "Presentación" filed which corresponds to {*formulation* + *presentation*}
	-- "Nº Registro" field is needed to make relationship with data from 'Medicamentos.csv'
	-- "Cod. Nacional" field is needed to make relationship with data from 'medicamentos_full.csv'
DROP TABLE IF EXISTS drugs_presentation_es_raw CASCADE;
CREATE TABLE drugs_presentation_es_raw (
    "Nº Registro" VARCHAR(50),
	"Cod. Nacional" VARCHAR(50),
	"Presentación" TEXT,
	"Laboratorio" VARCHAR(255),
	"Fecha Aut." VARCHAR(20),
    "Estado" VARCHAR(20),
    "Fecha Estado" VARCHAR(20),
	"Cód. ATC" VARCHAR(20),
    "Principios Activos" TEXT,
	"¿Comercializado?" VARCHAR(20),
	"¿Triangulo Amarillo?" VARCHAR(20),
	"Observaciones" TEXT,
	"¿Sustituible?" TEXT,
	"¿Afecta conducción?" VARCHAR(20),
	"¿Problemas de suministro?" VARCHAR(20)
);

COPY drugs_presentation_es_raw 
	FROM 'F:/_LearningMaterials/__--Portofolio--__/ITA_project/__esDrugs/Presentaciones.csv'
	CSV HEADER DELIMITER ',';
	/* copy drugs_es_raw FROM './raw_data/Presentaciones.csv' CSV HEADER DELIMITER ','; */

SELECT * FROM drugs_presentation_es_raw LIMIT 5;
SELECT COUNT(DISTINCT "Nº Registro") AS nr_uniq_regcodes, 						-- 26607
	COUNT(DISTINCT "Cod. Nacional") AS nr_uniq_national_code,					-- 67202
	COUNT(DISTINCT "Presentación") AS nr_drugs,									-- 65498
	COUNT(DISTINCT "Laboratorio") AS nr_manufaturers,							-- 1190
	COUNT(DISTINCT "Estado") AS nr_statuses,									-- 3
	COUNT(DISTINCT "Cód. ATC") AS nr_unique_atc_codes,							-- 2364
	COUNT(DISTINCT "Principios Activos") AS nr_active_compound,					-- 4072
	COUNT(DISTINCT "¿Comercializado?") AS nr_if_commercialised,					-- 2
	COUNT(DISTINCT "¿Triangulo Amarillo?") AS nr_is_yellowlable,				-- 2
	COUNT(DISTINCT "Observaciones") AS nr_observation_categories,				-- 14
	COUNT(DISTINCT "¿Sustituible?") AS nr_substitutes,							-- 3
	COUNT(DISTINCT "¿Afecta conducción?") AS nr_is_affecting_driving,			-- 2
	COUNT(DISTINCT "¿Problemas de suministro?") AS nr_logistics_problems		-- 2
FROM drugs_presentation_es_raw;

/*##########################################################################################*/
/* 2. File with drug names and ATC codes from 'Medicamentos.csv'.
Includes description of the drugs as 
	*formulation* in "Principios Activos" field
	*presentation* in "Medicamento" field, but not in the same way as "Presentación" from 'drugs_presentation_es_raw'
	*/
	-- 'drugs_formulation_es_raw' includes "Presentación" filed which corresponds to {*formulation* + *presentation*}
DROP TABLE IF EXISTS drugs_formulation_es_raw CASCADE;
CREATE TABLE drugs_formulation_es_raw (
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

COPY drugs_formulation_es_raw 
	FROM 'F:/_LearningMaterials/__--Portofolio--__/ITA_project/__esDrugs/Medicamentos.csv'
	CSV HEADER DELIMITER ',';
	/* copy drugs_es_raw FROM './raw_data/Medicamentos.csv' CSV HEADER DELIMITER ','; */

SELECT * FROM drugs_formulation_es_raw LIMIT 5;
SELECT COUNT(DISTINCT "Nº Registro") AS nr_uniq_regcodes, 						-- 26607
	COUNT(DISTINCT "Medicamento") AS nr_uniq_drug_formul,						-- 24667
	COUNT(DISTINCT "Laboratorio") AS nr_manufaturers,							-- 1190
	COUNT(DISTINCT "Estado") AS nr_statuses,									-- 3
	COUNT(DISTINCT "Cód. ATC") AS nr_unique_atc_codes,							-- 2364
	COUNT(DISTINCT "Principios Activos") AS nr_active_compound,					-- 4072
	COUNT(DISTINCT "¿Comercializado?") AS nr_if_commercialised,					-- 2
	COUNT(DISTINCT "¿Triangulo Amarillo?") AS nr_is_yellowlable,				-- 2
	COUNT(DISTINCT "Observaciones") AS nr_observation_categories,				-- 14
	COUNT(DISTINCT "¿Sustituible?") AS nr_substitutes,							-- 3
	COUNT(DISTINCT "¿Afecta conducción?") AS nr_is_affecting_driving,			-- 2
	COUNT(DISTINCT "¿Problemas de suministro?") AS nr_logistics_problems		-- 2
FROM drugs_formulation_es_raw;

/*##########################################################################################*/
/* 3. File with drug names and insurance coverage status from 'medicamentos_full.csv'.
Includes description of the drugs as 
	*formulation* in "Principio activo o asociación*" field
	*presentation* in "Nombre del medicamento" field, but not in the same way as in previous tables
	*/
	-- 'drugs_coverage_es_raw' includes 'Situación de financiación' field which describes coverage status
DROP TABLE IF EXISTS drugs_coverage_es_raw CASCADE;
CREATE TABLE drugs_coverage_es_raw (
    "Código nacional" VARCHAR(50),
	"Principio activo o asociación*" TEXT,
	"Nombre del medicamento" TEXT,
	"Situación de financiación" VARCHAR(50),
    "Tipo de medicamento" VARCHAR(20),
    "Más Información" VARCHAR(255)
);

COPY drugs_coverage_es_raw 
	FROM 'F:/_LearningMaterials/__--Portofolio--__/ITA_project/__esDrugs/medicamentos_full.csv'
	CSV HEADER DELIMITER ',';
	/* copy drugs_es_raw FROM './raw_data/medicamentos_full.csv' CSV HEADER DELIMITER ','; */

SELECT * FROM drugs_coverage_es_raw LIMIT 5;
SELECT COUNT(DISTINCT "Código nacional") AS nr_uniq_regcodes, 							-- 50857
	COUNT(DISTINCT "Principio activo o asociación*") AS nr_uniq_drug_formul,			-- 2299
	COUNT(DISTINCT "Nombre del medicamento") AS nr_uniq_drug_names,						-- 50362
	COUNT(DISTINCT "Situación de financiación") AS nr_statuses,							-- 6
	COUNT(DISTINCT "Tipo de medicamento") AS nr_drug_types								-- 7
FROM drugs_coverage_es_raw;
/*##########################################################################################*/

/*##########################################################################################*/
-- create BRIDGE tables
--###############--
/* bridge_drugs_observations */ ✅
--###############--
	-- BRIDGE bridge_drugs_observations
	DROP TABLE IF EXISTS bridge_drugs_observations CASCADE;
	CREATE TABLE bridge_drugs_observations (
	    id SERIAL PRIMARY KEY,
		registry_id VARCHAR(50) UNIQUE,
	    observation_categories TEXT
	);
	INSERT INTO bridge_drugs_observations (registry_id, observation_categories)
		SELECT DISTINCT "Nº Registro", TRIM("Observaciones")
		FROM drugs_presentation_es_raw
		WHERE "Observaciones" IS NOT NULL;
	SELECT * FROM bridge_drugs_observations;
	SELECT COUNT(*) FROM bridge_drugs_observations; -- 26607 records

--###############--
/* bridge_active_compounds */ ✅
--###############--
	DROP TABLE IF EXISTS bridge_active_compounds CASCADE;
	CREATE TABLE bridge_active_compounds (
	    id SERIAL PRIMARY KEY,
		registry_id VARCHAR(50), 
		national_code VARCHAR(50),
		atc_code VARCHAR(20),
		
		presentation_form TEXT,
		active_compounds_presentations TEXT,
		
		formulation_form TEXT,
		active_compounds_formulation TEXT,

		drug_name TEXT,
		active_compounds_drug TEXT
	);
	INSERT INTO bridge_active_compounds (registry_id, national_code, atc_code, 
				presentation_form, active_compounds_presentations, 
				formulation_form, active_compounds_formulation, 
				drug_name, active_compounds_drug)
	SELECT 
		dp."Nº Registro", dp."Cod. Nacional", dp."Cód. ATC",
		dp."Presentación", dp."Principios Activos",
		df."Medicamento", df."Principios Activos",
		dc."Nombre del medicamento", dc."Principio activo o asociación*"
		FROM drugs_presentation_es_raw AS dp
		LEFT JOIN drugs_formulation_es_raw AS df
			ON dp."Nº Registro" = df."Nº Registro"
		LEFT JOIN drugs_coverage_es_raw AS dc
			ON dp."Cod. Nacional" = dc."Código nacional";
	SELECT * FROM bridge_active_compounds LIMIT 5;


/*##########################################################################################*/
-- create DIMENSION tables
--###############--
/* drugs_formulation_es_raw */
--###############--
	-- dim_atc ✅
	DROP TABLE IF EXISTS dim_atc CASCADE;
	CREATE TABLE dim_atc (
		atc_id SERIAL PRIMARY KEY,
		atc_code VARCHAR(20) NOT NULL UNIQUE
	);
	INSERT INTO dim_atc (atc_code)
		SELECT DISTINCT "Cód. ATC"
		FROM drugs_formulation_es_raw
		WHERE "Cód. ATC" IS NOT NULL;
	SELECT * FROM dim_atc LIMIT 5;
	SELECT COUNT(*) FROM dim_atc; -- 2364 records
-- -----------------------------------------------------------------------------------------
-- dim_active_compound ✅
	DROP TABLE IF EXISTS dim_active_compound CASCADE;
	CREATE TABLE dim_active_compound (
		compound_id SERIAL PRIMARY KEY,
		compound_name TEXT NOT NULL UNIQUE,
		compound_numbers INTEGER
	);
	INSERT INTO dim_active_compound (compound_name, compound_numbers)
		SELECT DISTINCT "Principios Activos", "Nº P. Activos"
		FROM drugs_formulation_es_raw;
	SELECT * FROM dim_active_compound LIMIT 5;
	SELECT COUNT(*) FROM dim_active_compound; -- 4072 records
-- -----------------------------------------------------------------------------------------
	-- dim_active_comp_formulation ✅
	DROP TABLE IF EXISTS dim_active_comp_formulation CASCADE;
	CREATE TABLE dim_active_comp_formulation (
		registry_code VARCHAR(50) NOT NULL UNIQUE,
		active_comp_formul TEXT
	);
	INSERT INTO dim_active_comp_formulation (registry_code, active_comp_formul)
		SELECT DISTINCT "Nº Registro", "Principios Activos"
		FROM drugs_formulation_es_raw
		WHERE "Nº Registro" IS NOT NULL;
	SELECT * FROM dim_active_comp_formulation LIMIT 5;
	SELECT COUNT(*) FROM dim_active_comp_formulation; -- 26607 records
-- -----------------------------------------------------------------------------------------
-- dim_active_comp_presentation ✅
	DROP TABLE IF EXISTS dim_active_comp_presentation CASCADE;
	CREATE TABLE dim_active_comp_presentation (
		national_code VARCHAR(50) NOT NULL UNIQUE,
		active_comp_present TEXT
	);
	INSERT INTO dim_active_comp_presentation (national_code, active_comp_present)
		SELECT DISTINCT "Cod. Nacional", "Principios Activos"
		FROM drugs_presentation_es_raw
		WHERE "Cod. Nacional" IS NOT NULL;
	SELECT COUNT(*) FROM dim_active_comp_presentation; -- 67202 records	
	SELECT * FROM dim_active_comp_presentation LIMIT 5;

-- -----------------------------------------------------------------------------------------	
	-- dim_manufacturer ✅
	DROP TABLE IF EXISTS dim_manufacturer CASCADE;
	CREATE TABLE dim_manufacturer (
		manufacturer_id SERIAL PRIMARY KEY,
		manufacturer_name VARCHAR(500) NOT NULL UNIQUE
	);
	INSERT INTO dim_manufacturer (manufacturer_name)
		SELECT DISTINCT "Laboratorio"
		FROM drugs_formulation_es_raw
		WHERE "Laboratorio" IS NOT NULL;
	SELECT * FROM dim_manufacturer LIMIT 5;
	SELECT COUNT(*) FROM dim_manufacturer LIMIT 5; -- 1190 records
-- -----------------------------------------------------------------------------------------
	-- dim_status ✅
	DROP TABLE IF EXISTS dim_status CASCADE;
	CREATE TABLE dim_status (
	    status_id SERIAL PRIMARY KEY,
	    status_name VARCHAR(50) NOT NULL UNIQUE
	);
	INSERT INTO dim_status (status_name)
		SELECT DISTINCT "Estado" 
		FROM drugs_formulation_es_raw 
		WHERE "Estado" IS NOT NULL;
	SELECT * FROM dim_status LIMIT 5;
	SELECT COUNT(*) FROM dim_status; -- 3 records
-- -----------------------------------------------------------------------------------------
	-- dim_observations ✅
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
-- -----------------------------------------------------------------------------------------
	-- dim_coverage ✅
	DROP TABLE IF EXISTS dim_coverage CASCADE;
	CREATE TABLE dim_coverage (
	    type_id SERIAL PRIMARY KEY,
	    coverage_type VARCHAR(50)
	);
	INSERT INTO dim_coverage (coverage_type)
		SELECT DISTINCT "Situación de financiación"
		FROM drugs_coverage_es_raw 
		WHERE "Situación de financiación" IS NOT NULL;
	SELECT * FROM dim_coverage LIMIT 5;
	SELECT COUNT(*) FROM dim_coverage; -- 6 records
-- -----------------------------------------------------------------------------------------
--###############--
/* bridge_presentation_compound */ ✅
--###############--
	DROP TABLE IF EXISTS bridge_presentation_compound;
	CREATE TABLE bridge_presentation_compound (
	    id SERIAL PRIMARY KEY,
		national_code VARCHAR(50),
		registry_code VARCHAR(50),
	    compound_id INTEGER
	);
	INSERT INTO bridge_presentation_compound (national_code, registry_code, compound_id)
	SELECT DISTINCT
	    dp."Cod. Nacional",
		dp."Nº Registro",
	    dac.compound_id
	FROM drugs_presentation_es_raw dp
	JOIN drugs_formulation_es_raw df
	    ON dp."Nº Registro" = df."Nº Registro"
	JOIN dim_active_compound dac
	    ON df."Principios Activos" = dac.compound_name;
	SELECT * FROM bridge_presentation_compound LIMIT 5;
	SELECT COUNT(*) FROM bridge_presentation_compound;		-- 67202



/*##########################################################################################*/
-- create FACT tables
--###############--
	DROP TABLE IF EXISTS fact_drugs CASCADE;

	CREATE TABLE fact_drugs (
	    fact_id SERIAL PRIMARY KEY,
	
	    -- Degenerate dimensions (optional but useful)
	    registry_code VARCHAR(50),
	    national_code VARCHAR(50),
	
	    -- Foreign keys to dimensions
	    atc_id INTEGER,
	    compound_id INTEGER,
	    manufacturer_id INTEGER,
	    status_id INTEGER,
	    coverage_id INTEGER,
	
	    -- Flags / attributes (can stay in fact if low cardinality)
	    is_commercialised BOOLEAN,
	    is_yellow_flag BOOLEAN,
	    is_substitutable BOOLEAN,
	    affects_driving BOOLEAN,
	    supply_issues BOOLEAN
	);
	INSERT INTO fact_drugs (
	    registry_code,
	    national_code,
	    atc_id,
		compound_id,
	    manufacturer_id,
	    status_id,
	    coverage_id,
	    is_commercialised,
	    is_yellow_flag,
	    is_substitutable,
	    affects_driving,
	    supply_issues
	)
	
	SELECT
	    dp."Nº Registro",
	    dp."Cod. Nacional",
	
	    da.atc_id,
	    dac.compound_id,
	    dm.manufacturer_id,
	    ds.status_id,
	    dcov.type_id,
	
	    -- Boolean transformations
	    CASE WHEN dp."¿Comercializado?" = 'Sí' THEN TRUE ELSE FALSE END,
	    CASE WHEN dp."¿Triangulo Amarillo?" = 'Sí' THEN TRUE ELSE FALSE END,
	    CASE WHEN dp."¿Sustituible?" = 'Sí' THEN TRUE ELSE FALSE END,
	    CASE WHEN dp."¿Afecta conducción?" = 'Sí' THEN TRUE ELSE FALSE END,
	    CASE WHEN dp."¿Problemas de suministro?" = 'Sí' THEN TRUE ELSE FALSE END
	
	FROM drugs_presentation_es_raw dp
	
	LEFT JOIN drugs_formulation_es_raw df
	    ON dp."Nº Registro" = df."Nº Registro"
	
	LEFT JOIN drugs_coverage_es_raw dcr
	    ON dp."Cod. Nacional" = dcr."Código nacional"
	
	-- Join dimensions
	LEFT JOIN dim_atc da
	    ON dp."Cód. ATC" = da.atc_code
	
	LEFT JOIN dim_active_compound dac
	    ON df."Principios Activos" = dac.compound_name
	
	LEFT JOIN dim_manufacturer dm
	    ON dp."Laboratorio" = dm.manufacturer_name
	
	LEFT JOIN dim_status ds
	    ON dp."Estado" = ds.status_name
	
	LEFT JOIN dim_coverage dcov
	    ON dcr."Situación de financiación" = dcov.coverage_type;

	ALTER TABLE fact_drugs
		ADD CONSTRAINT fk_atc FOREIGN KEY (atc_id) REFERENCES dim_atc(atc_id);
	
	ALTER TABLE bridge_presentation_compound 
		ADD CONSTRAINT fk_compound FOREIGN KEY (compound_id) REFERENCES dim_active_compound(compound_id);
	ALTER TABLE bridge_presentation_compound 
		ADD CONSTRAINT fk_registry FOREIGN KEY (registry_code) REFERENCES dim_active_comp_formulation(registry_code);
	ALTER TABLE bridge_presentation_compound 
		ADD CONSTRAINT fk_nationalcode FOREIGN KEY (national_code) REFERENCES dim_active_comp_presentation(national_code);
	
	ALTER TABLE fact_drugs
		ADD CONSTRAINT fk_manufacturer FOREIGN KEY (manufacturer_id) REFERENCES dim_manufacturer(manufacturer_id);
	
	ALTER TABLE fact_drugs
		ADD CONSTRAINT fk_status FOREIGN KEY (status_id) REFERENCES dim_status(status_id);
	
	ALTER TABLE fact_drugs
		ADD CONSTRAINT fk_coverage FOREIGN KEY (coverage_id) REFERENCES dim_coverage(type_id);


SELECT * FROM fact_drugs LIMIT 5;
SELECT COUNT(*) FROM fact_drugs;