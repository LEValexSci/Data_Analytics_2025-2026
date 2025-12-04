###########################################
/* Tasca S4.01. Creació de Base de Dades */
###########################################
-- Descripció
	-- Partint d'alguns arxius CSV dissenyaràs i crearàs la teva base de dades.

####################
	-- Nivell 1    
####################
/* Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, almenys 4 taules de les quals puguis realitzar les següents consultes:*/

	# Creamos la base de datos
		CREATE DATABASE IF NOT EXISTS user_sales;
		USE user_sales;

    # Creamos la tabla 'american_users'
		# field names: id, name, surname, phone, email, birth_date, country, city, postal_code, address
		CREATE TABLE IF NOT EXISTS american_users (
			id VARCHAR(15) PRIMARY KEY,
			name VARCHAR(255),
			surname VARCHAR(255),
			phone VARCHAR(15),
			email VARCHAR(100),
			birth_date VARCHAR(100),
			country VARCHAR(100),
			city VARCHAR(255),
			postal_code VARCHAR(255),
			address VARCHAR(255)
		);

	# Creamos la tabla 'companies'
		# field names: company_id, company_name, phone, email, country, website
		CREATE TABLE IF NOT EXISTS companies (
			company_id VARCHAR(15) PRIMARY KEY,
			company_name VARCHAR(255),
			phone VARCHAR(15),
			email VARCHAR(100),
			country VARCHAR(100),
			website VARCHAR(255)
		);

	# Creamos la tabla 'credit_cards'
		# field names: id, user_id, iban, pan, pin, cvv, track1, track2, expiring_date
		CREATE TABLE IF NOT EXISTS credit_cards (
			id VARCHAR(15) PRIMARY KEY,
			user_id VARCHAR(15),
			iban VARCHAR(34),
			pan VARCHAR(19),
			pin VARCHAR(6),
			cvv VARCHAR(4),
			track1 VARCHAR(255),
			track2 VARCHAR(255),
			expiring_date VARCHAR(8)
		);

	# Creamos la tabla 'european_users'
		# field names: id, name, surname, phone, email, birth_date, country, city, postal_code, address
		CREATE TABLE IF NOT EXISTS european_users (
			id VARCHAR(15) PRIMARY KEY,
			name VARCHAR(255),
			surname VARCHAR(255),
			phone VARCHAR(15),
			email VARCHAR(100),
			birth_date VARCHAR(100),
			country VARCHAR(100),
			city VARCHAR(255),
			postal_code VARCHAR(255),
			address VARCHAR(255)
		);

    # Creamos la tabla 'products'
		# field names: id, product_name, price, colour, weight, warehouse_id
		CREATE TABLE IF NOT EXISTS products (
			id VARCHAR(15) PRIMARY KEY,
			product_name VARCHAR(255),
			price VARCHAR(15),
			colour VARCHAR(15),
			weight DECIMAL(2,1),
			warehouse_id VARCHAR(255)
		);

	# Creamos la tabla 'transactions'
		# field names: id, card_id, business_id, timestamp, amount, declined, product_ids, user_id, lat, longitude
		CREATE TABLE IF NOT EXISTS transactions (
			id VARCHAR(255) PRIMARY KEY,
			card_id VARCHAR(15),
			business_id VARCHAR(15),
			timestamp TIMESTAMP,
			amount DECIMAL(10, 2),
			declined BOOLEAN,
			product_ids VARCHAR(255),
			user_id VARCHAR(15),
			lat FLOAT,
			longitude FLOAT
		);
		
        # verify the tables and their structure
        SELECT 
		  TABLE_NAME, COLUMN_NAME, DATA_TYPE, 
		  COLUMN_TYPE, IS_NULLABLE, COLUMN_KEY, 
		  COLUMN_DEFAULT 
		FROM 
		  information_schema.columns 
		WHERE 
		  table_schema = 'user_sales' 
		ORDER BY 
		  TABLE_NAME, ORDINAL_POSITION;

        ##### loading data
        SHOW VARIABLES LIKE 'secure_file_priv';
        SHOW GLOBAL VARIABLES LIKE 'local_infile';
        SET GLOBAL local_infile = 1; -- done by Editing connection to the database
        
        -- podemos usar el atributo LOCAL
		LOAD DATA LOCAL
		INFILE 'F:/_LearningMaterials/BarcelonaActiva/dataTables/american_users.csv'
		INTO TABLE american_users 
		FIELDS TERMINATED BY ','
		ENCLOSED BY '"'
		IGNORE 1 ROWS;
			-- select * from american_users;
        LOAD DATA LOCAL
		INFILE 'F:/_LearningMaterials/BarcelonaActiva/dataTables/companies.csv'
		INTO TABLE companies 
		FIELDS TERMINATED BY ','
		ENCLOSED BY '"'
		IGNORE 1 ROWS;
			-- select * from companies;
		LOAD DATA LOCAL
		INFILE 'F:/_LearningMaterials/BarcelonaActiva/dataTables/credit_cards.csv'
		INTO TABLE credit_cards 
		FIELDS TERMINATED BY ','
		ENCLOSED BY '"'
		IGNORE 1 ROWS;
        
        LOAD DATA LOCAL
		INFILE 'F:/_LearningMaterials/BarcelonaActiva/dataTables/european_users.csv'
		INTO TABLE european_users 
		FIELDS TERMINATED BY ','
		ENCLOSED BY '"'
		IGNORE 1 ROWS;

		LOAD DATA LOCAL
		INFILE 'F:/_LearningMaterials/BarcelonaActiva/dataTables/products.csv'
		INTO TABLE products 
		FIELDS TERMINATED BY ','
		ENCLOSED BY '"'
		IGNORE 1 ROWS;

		LOAD DATA LOCAL
		INFILE 'F:/_LearningMaterials/BarcelonaActiva/dataTables/transactions.csv'
		INTO TABLE transactions 
		FIELDS TERMINATED BY ';'
		ENCLOSED BY '"'
		IGNORE 1 ROWS;
			select * from transactions limit 2;
            
	# to show data model diagram and describe
    # create 'users' table
		# add new column 'Region' to 'european_users' with 'European' value
			ALTER TABLE european_users ADD COLUMN Region VARCHAR(20) DEFAULT 'European';

        # add new column 'Region' to 'american_users' with 'American' value
			ALTER TABLE american_users ADD COLUMN Region VARCHAR(20) DEFAULT 'American';

		# Unite the tables
			CREATE TABLE users
				SELECT * FROM european_users
                UNION
                SELECT * FROM american_users;
			ALTER TABLE users ADD PRIMARY KEY (id);
            # para comprobar el resultado visualizem la table por el order de fecha de nacimiento, para ver si hai l'agente de las diverses regiones
            SELECT * FROM users ORDER BY birth_date;
            
		# declaramos las llaves foranas 
            ALTER TABLE transactions
				ADD CONSTRAINT fk_transactions_users
				FOREIGN KEY (user_id) REFERENCES users(id);
			ALTER TABLE transactions
				ADD CONSTRAINT fk_transactions_companies
				FOREIGN KEY (business_id) REFERENCES companies(company_id);
			ALTER TABLE transactions
				ADD CONSTRAINT fk_transactions_credit_cards
				FOREIGN KEY (card_id) REFERENCES credit_cards(id);
			
		# analitsem la eschema recibida
        
        
-- Exercici 1
	-- Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.
		# opcion con las dos tablas de usuarios
		SELECT id, name, surname 
			FROM american_users
			WHERE american_users.id IN (
				SELECT user_id
				FROM transactions    
				GROUP BY user_id
				HAVING COUNT(id)>80
				)
		UNION 
		SELECT id, name, surname 
			FROM european_users
			WHERE european_users.id IN (
				SELECT user_id
				FROM transactions    
				GROUP BY user_id
				HAVING COUNT(id)>80
				);
		# opcion con las tabla sintetica 'users'
        SELECT id, name, surname
			FROM users
            WHERE users.id IN (
				SELECT user_id
				FROM transactions    
				GROUP BY user_id
				HAVING COUNT(id)>80
            );
    
-- Exercici 2
	-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.
    SELECT credit_cards.iban, ROUND(AVG(transactions.amount), 2) AS Mitjana, 
		 COUNT(transactions.id) AS NrTrans 
	FROM transactions
    JOIN credit_cards
		ON transactions.card_id = credit_cards.id
	JOIN companies
		ON transactions.business_id = companies.company_id
	WHERE companies.company_name = 'Donec Ltd'
		AND transactions.declined = 0
    GROUP BY credit_cards.iban
    HAVING NrTrans > 1
    ;

####################
	-- Nivell 2    
####################
	-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les tres últimes transaccions han estat declinades aleshores és inactiu, si almenys una no és rebutjada aleshores és actiu. Partint d’aquesta taula respon:
		CREATE TABLE card_status 
			SELECT fechas.card_id AS card_id,
				CASE WHEN SUM(fechas.declined) = 3 THEN 'inactiva'
					ELSE 'activa'
					END AS 'Status'
				FROM (
					SELECT t1.card_id, t1.timestamp, t1.declined
						FROM transactions t1
						WHERE (
						  SELECT COUNT(*)
						  FROM transactions t2
						  WHERE t2.card_id = t1.card_id
							AND t2.timestamp > t1.timestamp
						) < 3
					) AS fechas
				GROUP BY fechas.card_id;
    SELECT * FROM card_status;

-- Exercici 1
	-- Quantes targetes estan actives?
	SELECT COUNT(card_id)
		FROM card_status
        WHERE status = 'activa';
        
		# o
	SELECT 
		SUM(CASE WHEN status = 'activa' THEN 1 ELSE 0 END) 'Activa',
        SUM(CASE WHEN status = 'inactiva' THEN 1 ELSE 0 END) 'Inactiva'
	FROM card_status;

####################
	-- Nivell 3    
####################
	-- Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, tenint en compte que des de transaction tens product_ids. Genera la següent consulta:
       CREATE TABLE transactions_products
			SELECT
			  t.id AS transaction_id,
			  jsontab.product_id AS product_id
			FROM transactions AS t,
			  JSON_TABLE(
				CONCAT('[', REPLACE(REPLACE(t.product_ids, ' ', ''), ',', ','), ']'),
				"$[*]" COLUMNS (
				  product_id INT PATH "$"
				)
			  ) AS jsontab;
           
           	# 'REPLACE' form is 'REPLACE(str, find_string, replace_with)', in our case 'str' = t.product_ids, 'find_string' = ' ' (blank space), 'replace_with' = '' (no space). As the result each record converts in array without spaces, separated by commas.
           
           ALTER TABLE transactions_products ADD PRIMARY KEY (transaction_id, product_id);
           ALTER TABLE transactions_products MODIFY COLUMN transaction_id VARCHAR(255);
           ALTER TABLE transactions_products MODIFY COLUMN product_id VARCHAR(255);
          
          ALTER TABLE transactions_products
				ADD CONSTRAINT fk_transactionProducts_transactions
                FOREIGN KEY (transaction_id) REFERENCES transactions(id);
			
			ALTER TABLE transactions_products
				ADD CONSTRAINT fk_transactionsProducts_products
				FOREIGN KEY (product_id) REFERENCES products(id);
		
        #check schema
        
-- Exercici 1
	-- Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
	SELECT CAST(t_p.product_id AS UNSIGNED) AS product_id, products.product_name AS product, 
		COUNT(t_p.product_id) AS nrSales
	FROM transactions_products AS t_p
    JOIN transactions ON t_p.transaction_id = transactions.id
    JOIN products ON t_p.product_id = products.id
        WHERE transactions.declined = 0
		GROUP BY product_id
        ORDER BY product_id;
