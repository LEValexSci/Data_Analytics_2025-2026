#####################
	-- Nivell 1 --
#####################
	# la base de datos 'transactions' contiene dos tablas: 'company' y 'transaction'
    # la tabla 'company' es una tabla de dimensiones i incluye 6 campos
		SELECT COUNT(DISTINCT(id)) FROM company;
		# 'id' el identificador de una empresa en formato "b-\d\d\d\d", \d - digit
        SELECT COUNT(DISTINCT(company_name)) FROM company;
        # 'company_name' el nombre de la empresa
        SELECT COUNT(DISTINCT(phone)) FROM company;
        # 'phone' el numero de telefon de la empresa en formato "\d\d \d\d \d\d \d\d \d\d", \d - digit
        SELECT COUNT(DISTINCT(email)) FROM company;
        # 'email' el email de la empresa en formato "^[a-zA-Z0-9_.±]+@[a-zA-Z0-9-]+.[a-zA-Z0-9-.]+$"
        SELECT COUNT(DISTINCT(country)) FROM company;
        # 'country' el pais donde la empresa es registrada
        SELECT COUNT(DISTINCT(website)) FROM company;
        # 'website' el URL de pagina web de la empresa.
	# la tabla 'transaction' es de transacciones realizadas de clientes para hacer comparas de las diferentes empresas con una tarjeta de credito.
		SELECT COUNT(DISTINCT(id)) FROM transaction;
        # 'id' es el identificador de una transaccion (100000 de transacciones)
        SELECT COUNT(DISTINCT(credit_card_id)) FROM transaction;
		# 'credit_card_id' es el identificador de una tarjeta de credit de un cliente (5000 tarjetas)
        SELECT COUNT(DISTINCT(company_id)) FROM transaction;
		# 'company_id' es el identificador de una empresa (100 empresas) des de qual los usuarios han hecho las compras
        SELECT COUNT(DISTINCT(user_id)) FROM transaction;
		# 'user_id' es el identificator de los usuarios qien hacen mas compras (5000 usuarios) --> cada usuario tiene solo una tarjeta
        SELECT COUNT(DISTINCT(lat)) FROM transaction;
		# 'lat' es la latitude donde se han hecha la compra (94272 valores)
        SELECT COUNT(DISTINCT(longitude)) FROM transaction;
		# 'longitude' es la logitut donde se han hecha la compra (95285 valores)
        SELECT COUNT(DISTINCT(timestamp)) FROM transaction;
		# 'timestamp' es el tiempo i la fecha de una transaccion (99986 valores)
		SELECT COUNT(DISTINCT(amount)) FROM transaction;
        # 'amount' es el importe de la transaccion
        SELECT COUNT(DISTINCT(declined)) FROM transaction;
		# 'declined' se refiere a la estado de denegacion (0) o acceptacion (1) de transaccion

#################
-- Exercici 2 -- 
#################
	-- Utilitzant JOIN realitzaràs les següents consultes:
		-- Llistat dels països que estan generant vendes.
			SELECT DISTINCT(company.country) AS PAIS
			FROM company
			JOIN transaction
			ON company.id = transaction.company_id
			ORDER BY PAIS;
		-- Des de quants països es generen les vendes.
			SELECT COUNT(DISTINCT(company.country)) AS NombrePaïsos
			FROM company
			JOIN transaction
			ON company.id = transaction.company_id
			ORDER BY NombrePaïsos;
		-- Identifica la companyia amb la mitjana més gran de vendes
			SELECT company.company_name AS Empresa, ROUND(AVG(transaction.amount), 2) AS Mitjana
			FROM transaction
			JOIN company
			ON transaction.company_id = company.id
			# se consideran solo las transacciones realizadas
			WHERE transaction.declined = 0
			GROUP BY company.company_name
			HAVING Mitjana = (
				SELECT MAX(Mitjanas.Mitjana) AS MitjanaMaxima
				FROM (
				# tenemos que calcular las Mitjanas por cada empresa
					SELECT ROUND(AVG(transaction.amount), 2) AS Mitjana
					FROM transaction
					JOIN company
					ON transaction.company_id = company.id
                # se consideran solo las transacciones realizadas
					WHERE transaction.declined = 0
					GROUP BY company.company_name
					) AS Mitjanas
				);

#################
-- Exercici 3 --
#################
	-- Utilitzant només subconsultes (sense utilitzar JOIN):
		-- Mostra totes les transaccions realitzades per empreses d'Alemanya.
			SELECT t.id, t.credit_card_id, t.company_id, c.company_name, c.country, 
					t.user_id, t.lat, t.longitude, t.timestamp, t.amount, t.declined
			FROM company AS c, 
				transaction AS t
			WHERE c.id = t.company_id
				AND c.country = 'Germany'
			ORDER BY c.company_name;

		-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
			SELECT DISTINCT(company.company_name) AS Empresa
			FROM company, transaction
			WHERE company.id = transaction.company_id
				AND transaction.amount > (
					SELECT AVG(transaction.amount) AS MitjanaEmpresa
					FROM transaction
					WHERE transaction.declined = 0
					);
                # RESULTADO: cada impresa han realizat al menos una transacción superior a la mitjana de totes les transaccions.
                
		-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
			# Crec que les empreses sense transaccions són aquelles que figuren a la taula company però que no apareixen a la taula transaction. 
            SELECT company.company_name
            FROM company
            WHERE company.id NOT IN (
				SELECT DISTINCT(transaction.company_id) AS Empresa
				FROM transaction
				WHERE declined = 0
				);
			# Sembla que el resultat hauria de ser NULL, perquè no hi ha diferències entre la llista d'empreses registrades a la taula 'company' i les que han mostrat activitat. En aquest cas, l'script és general.
            
#####################
	-- Nivell 2 --
#####################

#################
-- Exercici 1 --
#################
	-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.
    SELECT CAST(transaction.timestamp AS DATE) AS Date, SUM(transaction.amount) AS TotalPerDay
    FROM transaction
    GROUP BY Date
    ORDER BY TotalPerDay DESC
    LIMIT 5;

#################
-- Exercici 2 --
#################    
	-- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
	# The level of sales per country can be considered in two ways: as number of sales and as the amount of sales
    # Option 1 - by average amount of sales by country
    SELECT company.country AS Pais, ROUND(AVG(transaction.amount), 2) AS MitjanaPerPais
	FROM company
	JOIN transaction
	ON company.id = transaction.company_id
	WHERE transaction.declined = 0
	GROUP BY Pais
	ORDER BY MitjanaPerPais DESC;

    # Option 2 - by number of transactions per company and average number of transactions per country    
		SELECT Vendes.Pais, ROUND(AVG(Vendes.NrVendes), 1) AS MitjanaVendes
        FROM (
        	SELECT company.id AS Empresa, COUNT(transaction.amount) AS NrVendes, company.country AS Pais
			FROM company
            JOIN transaction
            ON company.id = transaction.company_id
            WHERE transaction.declined = 0
            GROUP BY company.id
            HAVING NrVendes > 0
            ) AS Vendes
		GROUP BY Vendes.Pais
        ORDER BY MitjanaVendes DESC;

#################
-- Exercici 3 --
#################
	-- En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.
    # Mostra el llistat aplicant JOIN i subconsultes.
		SELECT t.id, t.credit_card_id, t.company_id, t.user_id, t.lat, t.longitude, t.timestamp, t.amount, t.declined
    		FROM company
            JOIN transaction AS t
            ON company.id = t.company_id
    		WHERE company.country IN (
    			SELECT DISTINCT(company.country) AS pais
    			FROM company
    			WHERE company.company_name = 'Non Institute'
    			)
                AND company.company_name != 'Non Institute';
            
			# la lista de las empresas : Sed Nunc Ltd, Non Magna LLC, Enim Condimentum Ltd, Ac Libero Inc., Amet Faucibus Ut Foundation, Interdum Feugiat Sed Associates, Viverra Donec Foundation, Orci Adipiscing Limited
        
    # Mostra el llistat aplicant solament subconsultes.
		SELECT t.id, t.credit_card_id, t.company_id, t.user_id, t.lat, t.longitude, t.timestamp, t.amount, t.declined
		FROM company, transaction AS t
		WHERE company.country IN (
			SELECT DISTINCT(company.country) AS pais
			FROM company
			WHERE company.company_name = 'Non Institute'
			)
            AND company.company_name != 'Non Institute'
            AND t.company_id = company.id;

#####################
	-- Nivell 3 --
#####################

#################
-- Exercici 1 --
#################
	-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 350 i 400 euros i en alguna d'aquestes dates: 29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024. Ordena els resultats de major a menor quantitat.
    SELECT company.company_name, company.phone, company.country, CAST(transaction.timestamp AS DATE) AS Fecha, transaction.amount
	FROM company
	JOIN transaction
	ON company.id = transaction.company_id
	WHERE transaction.amount > 350 AND transaction.amount < 400
		AND CAST(transaction.timestamp AS DATE) IN ('2015-04-29', '2018-07-20', '2024-03-13')
    ORDER BY transaction.amount DESC;
#################
-- Exercici 2 --
#################
	-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 400 transaccions o menys.
    # Varianta 1 - una combinació de JOIN i subconsultes, més comprensible i per etapas
	SELECT nrTrans.id AS id, nrTrans.empresa,
		# Crea una columna NivellTransaccions d'acord amb l'especificació, aplicant un valor limite de 400 i assignant l'empresa a una de les classes segons el nombre de transaccions.
		CASE 
			WHEN nrTrans.NrTransactions >= 400 THEN 'Més de 400 transaccions'
            WHEN nrTrans.NrTransactions < 400 THEN 'Menys de 400 transaccions'
			END AS NivellTransaccions
    FROM (
		# subconsulta para recontar el numero de transacciones por cada empresa
		SELECT company.id AS ID, company.company_name AS Empresa, COUNT(transaction.id) AS NrTransactions
		FROM company
		JOIN transaction
		ON company.id = transaction.company_id
        GROUP BY company.id
		) AS nrTrans
	ORDER BY nrTrans.ID;

	# Varianta 2 - utilitzar l'agregació COUNT en CASE, més concís
	SELECT company.id AS ID, company.company_name AS Empresa,
		# Crea una columna NivellTransaccions d'acord amb l'especificació, aplicant un valor limite de 400 i assignant l'empresa a una de les classes segons el nombre de transaccions.
		CASE 
			WHEN COUNT(transaction.id) >= 400 THEN 'Més de 400 transaccions'
			ELSE 'Menys de 400 transaccions'
			END AS NivellTransaccions
    FROM company
    JOIN transaction
    ON company.id = transaction.company_id
    GROUP BY company.id
    ORDER BY ID;