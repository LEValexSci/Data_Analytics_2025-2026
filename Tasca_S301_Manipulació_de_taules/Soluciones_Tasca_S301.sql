#########################################
/* Tasca S3.01. Manipulació de taules */
#########################################
-- Descripció
/* En aquest sprint se simula una situació empresarial en la qual hauràs de realitzar diverses manipulacions a les taules d’una base de dades. A més, treballaràs amb índexs i vistes per optimitzar consultes i organitzar la informació.
	Continuaràs treballant amb la base de dades que conté informació d’un marketplace, un entorn similar a Amazon on diverses empreses venen els seus productes a través d’un canal en línia. En aquesta activitat, començaràs a treballar amb dades relacionades amb targetes de crèdit.
	Afegeix les taules al model segons correspongui:
		Nivell 1: Taula "credit_card"
		Nivell 3 : Taula "user" */

####################
	-- Nivell 1    
####################
-- Exercici 1
	-- La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit. La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i "company"). Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit". Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.

	#creamos la tabla 'credit_card' con los campos i parametros, consultant la estructura de 'transaction' i que tipo de datos tenemos que cargar. Tambien consultamos las practicas buenas de definir este tipo de campos.
	CREATE TABLE IF NOT EXISTS credit_card (
		id VARCHAR(15) PRIMARY KEY,
		iban VARCHAR(34),
		pan VARCHAR(19),
		pin VARCHAR(6),
		cvv VARCHAR(4),
		expiring_date VARCHAR(8)
	);

	# populate the table with data from 'datos_introducir_sprint3_credit' by INSERT
	
	# tenemos que crear la relacio dentre 'transaction' y 'credit_card'
	ALTER TABLE transaction
	ADD CONSTRAINT fk_transaction_credit_card
	FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);
			-- ALTER TABLE transaction DROP FOREIGN KEY fk_transaction_credit_card;
	
	-- Exercici 2
		-- El departament de Recursos Humans ha identificat un error en el número de compte associat a la targeta de crèdit amb ID CcU-2938. La informació que ha de mostrar-se per a aquest registre és: TR323456312213576817699999. Recorda mostrar que el canvi es va realitzar.
		# visualize the content related to the user with ID = CcU-2938
        SELECT * FROM credit_card WHERE id = 'CcU-2938';
			# resultado: CcU-2938	TR301950312213576817638661	5424465566813633	3257	984	10/30/22
        
        # update iban with new value 'TR323456312213576817699999' for the user with ID = CcU-2938
		UPDATE credit_card
		SET iban = 'TR323456312213576817699999'
		WHERE id = 'CcU-2938';

		# comprobar el resultado del cambio por el user with ID = CcU-2938
        SELECT * FROM credit_card WHERE id = 'CcU-2938';

	-- Exercici 3
		-- En la taula "transaction" ingressa una nova transacció amb la següent informació:
        # Add new row using INSERT in 'transaction' table
			/* Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
			credit_card_id	CcU-9999
			company_id	b-9999
			user_id	9999
			lat	829.999
			longitude	-117.999
			amount	111.11
			declined	0 */
        INSERT INTO transaction (id, credit_card_id, company_id, user_id, 
								lat, longitude, amount, declined) 
				VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 
						'b-9999', '9999', '829.999', '-117.999', '111.11', '0');
            
            /* DELETE FROM transaction WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';
            select * from transaction ; -- where  id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD'; */
            # returns Error Code 1452 meaning there is missing the value for 'company_id' which is the FK in relation to the table 'company', and 'credit_card_id' which is the foreign key in relation with 'credit_card' table.
            # we have to introduce the value 'b-9999' as `id` in 'company' table.
				INSERT INTO company (id, company_name, phone, email, country, website) 
					VALUES ('b-9999', NULL, NULL, NULL, NULL, NULL);
			# we have to introduce the value 'CcU-9999' as `id` in 'credit_card' table.
				INSERT INTO credit_card (id, iban, pan, pin, cvv, expiring_date) 
					VALUES ('CcU-9999', NULL, NULL, NULL, NULL, NULL);
                #repeat the INSERT
                # check the view
                select * from transaction where company_id = 'b-9999';
	-- Exercici 4
		-- Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. Recorda mostrar el canvi realitzat.
        # 
        ALTER TABLE credit_card DROP COLUMN pan;
        
        # visualizing the changes - absent 'pan' column
        select * from credit_card;

####################
	-- Nivell 2    
####################
	-- Exercici 1
		-- Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.
		DELETE FROM transaction 
        WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';
			
            # INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined) VALUES ('000447FE-B650-4DCF-85DE-C7ED0EE1CAAD', 'CcS-5019', 'b-2370', '438', '41.59720554463741', '12.22175994259365', '2016-12-21 20:07:18', '155.63', '0');
            # check the change
            SELECT * FROM transaction 
            WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';
	-- Exercici 2
		-- La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.
        #
        CREATE OR REPLACE VIEW VistaMarketing AS
        SELECT company.company_name AS 'Nom de la companyia', 
				company.phone AS 'Telèfon de contacte', 
				company.country 'País de residència', 
                ROUND(AVG(transaction.amount),2) AS Mitjana
        FROM company
        JOIN transaction
        ON company.id = transaction.company_id
        WHERE transaction.declined = 0
        GROUP BY company.company_name, company.phone, company.country
        ORDER BY Mitjana;
		# visualising the View
        select * from vistamarketing;
	-- Exercici 3
		-- Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"
        SELECT * 
        FROM vistamarketing
        WHERE `País de residència` = 'Germany';
        
####################
	-- Nivell 3    
####################

	-- Exercici 1
		-- La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip va realitzar modificacions en la base de dades, però no recorda com les va realitzar. Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama:
        select * from transaction;
        select * from credit_card;
        select * from company;
        
        # I consider the differences in comparison to the version of database I have, including present/absent tables, relationships, columns, changes in column names and their types. Everithing is documented below. The version of the database I have named as 'db1' and it's schema 'db1_schema', while the database of my colleague - 'db2' and 'db2_schema' respectively.
        # 1 - according to db2_schema, there is one more table, named 'data_user'. It was created with:
			CREATE TABLE IF NOT EXISTS user (
				id CHAR(10) PRIMARY KEY,
				name VARCHAR(100),
				surname VARCHAR(100),
				phone VARCHAR(150),
				email VARCHAR(150),
				birth_date VARCHAR(100),
				country VARCHAR(150),
				city VARCHAR(150),
				postal_code VARCHAR(100),
				address VARCHAR(255)
			);
            # populate the table with the values from 'datos introducir sprint3 user.sql'
            # before creating the relationship between 'user' and 'transaction' tables, we should check if there are no differences between 'id' and 'user_id' values correspondingly.
				SELECT COUNT(DISTINCT user_id) FROM transaction; #returns 5001 rows
                SELECT COUNT(id) FROM user; #returns 5000 rows
                #checking which 'id' value is different
					SELECT transaction.user_id
					FROM transaction
					WHERE transaction.user_id NOT IN (select id from user WHERE id IS NOT NULL);
						# returned id=9999, long query? ~104 sec
				#we have to add id=9999 to 'user' table to ensure consistency between ids
                INSERT INTO user (id, name, surname, phone, email, birth_date, country, city, 
									postal_code, address) 
						VALUES ('9999', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
            # user 'id' is a foreign key in relation with 'transaction' table. So, we add corresponding contsraint, understanding that the relationship between them is 1:N 
				ALTER TABLE transaction
				ADD CONSTRAINT fk_transaction_user
				FOREIGN KEY (user_id) REFERENCES user(id);
                # returns Error Code 3780, because there is incongruence between 'id' type in 'transaction' and 'user' tables [INT and CHAR(10), correspondingly], as indicated in the guidelines and the files 'estructura datos user.sql' and 'estructura dades.sql'. That means, that my colleague changed user 'id' in 'user' table from CHAR(10) to INT (I would not make this change, because leading 0's can be lost, it breaks the rules of data consistency).
					ALTER TABLE user MODIFY id INT;
                # than apply again foreign key rule.

            # changed table name from 'user' to 'data_user'
				ALTER TABLE user RENAME data_user;
            # 'email' field renamed to 'personal_email'
				ALTER TABLE user RENAME COLUMN `email` TO `personal_email`;

      # 2 - table 'company' is missing the 'website' column
			# deleted 'website' field
				ALTER table company DROP COLUMN website;
      
      # 3 - table 'transaction' has changed 'credit_card_id' field property from VARCHAR(15) to VARCHAR(20)
            ALTER TABLE transaction MODIFY credit_card_id VARCHAR(20);
		
      # 4 - table 'credit_card' 
		# has the field 'fecha_actual' DATA type was added.
            ALTER TABLE credit_card ADD COLUMN `fecha_actual` DATE;
		# iban VARCHAR(34) to VARCHAR(50)
			ALTER TABLE credit_card MODIFY iban VARCHAR(50);
        # pin VARCHAR(6) to VARCHAR(4)
			ALTER TABLE credit_card MODIFY pin VARCHAR(4);
        # cvv VARCHAR(4) to INT
			ALTER TABLE credit_card MODIFY cvv INT;
        # expiring_date VARCHAR(8) to VARCHAR(20)
			ALTER TABLE credit_card MODIFY expiring_date VARCHAR(20);
            
      # generate db1_schema to sheck if it shows like db2_schema.
      
      select * from user;
      
	-- Exercici 2
		-- L'empresa també us demana crear una vista anomenada "InformeTecnico" que contingui la següent informació:
			-- ID de la transacció
            -- Nom de l'usuari/ària
            -- Cognom de l'usuari/ària
            -- IBAN de la targeta de crèdit usada.
            -- Nom de la companyia de la transacció realitzada.
            
            # versio con columnas en Catala
            CREATE OR REPLACE VIEW InformeTecnico_cat AS
            SELECT 
				transaction.id AS 'ID de la transacció', 
				CONCAT(data_user.name, ' ', data_user.surname) AS "Nom i cognom de l'usuari/ària", 
				credit_card.iban AS "IBAN de la targeta de crèdit usada", 
                company.company_name AS "Nom de la companyia de la transacció realitzada",
                CAST(transaction.timestamp AS DATE) AS 'Fecha',
                transaction.declined AS 'Estat de la transacció'
            FROM transaction
            JOIN data_user
				ON transaction.user_id = data_user.id
			JOIN credit_card
				ON transaction.credit_card_id = credit_card.id
			JOIN company
				ON transaction.company_id = company.id;
                
		-- Assegureu-vos d'incloure informació rellevant de les taules que coneixereu i utilitzeu àlies per canviar de nom columnes segons calgui.
        
		-- Mostra els resultats de la vista, ordena els resultats de forma descendent en funció de la variable ID de transacció.
        SELECT * 
        FROM InformeTecnico_cat
        ORDER BY `ID de la transacció` DESC;

