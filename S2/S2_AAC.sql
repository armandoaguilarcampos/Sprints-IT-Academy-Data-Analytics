    -- Creamos la base de datos
    CREATE DATABASE IF NOT EXISTS transactions;
    USE transactions;

    -- Creamos la tabla company
    CREATE TABLE IF NOT EXISTS company (
        id VARCHAR(15) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );


    -- Creamos la tabla transaction
    CREATE TABLE IF NOT EXISTS transaction (
        id VARCHAR(255) PRIMARY KEY,
        credit_card_id VARCHAR(15) REFERENCES credit_card(id),
        company_id VARCHAR(20), 
        user_id INT REFERENCES user(id),
        lat FLOAT,
        longitude FLOAT,
        timestamp TIMESTAMP,
        amount DECIMAL(10, 2),
        declined BOOLEAN,
        FOREIGN KEY (company_id) REFERENCES company(id) 
    );
    
    USE transactions;

-- Insertamos datos de company y transaction

# Nivell 1
# Exercici 1
-- Visualizamos tablas company y transaction

SELECT * 
FROM company 
ORDER BY id DESC 
LIMIT 10;

SELECT * 
FROM transaction 
ORDER BY id DESC
LIMIT 10;

SELECT COUNT(DISTINCT(id)) 
FROM company;

SELECT COUNT(DISTINCT(country))
FROM company;

SELECT COUNT(DISTINCT(id)), COUNT(DISTINCT(credit_card_id)), 
COUNT(DISTINCT(company_id)), COUNT(DISTINCT(user_id)),
COUNT(DISTINCT(lat)), COUNT(DISTINCT(longitude)), COUNT(DISTINCT(timestamp))
FROM transaction;

SELECT COUNT(declined) AS no_rechazada, (100000-COUNT(declined)) AS rechazada
FROM transaction
WHERE declined = 0;

# Exercici 2
SELECT DISTINCT(country) as países
FROM company AS c
RIGHT JOIN transaction AS t
ON c.id=t.company_id
WHERE declined=0;

SELECT COUNT(DISTINCT(country)) AS número_países
FROM company AS c
RIGHT JOIN transaction AS t
ON c.id=t.company_id
WHERE declined=0;

SELECT company_name AS compañía, ROUND(AVG(amount),2) AS media_ventas
FROM company AS c
RIGHT JOIN transaction AS t
ON c.id=t.company_id
WHERE declined=0
GROUP BY company_name
ORDER BY media_ventas DESC
LIMIT 1;

# Exercici 3
SELECT * 
FROM transaction
WHERE company_id IN (SELECT id 
					FROM company 
					WHERE country='Germany');
                    

SELECT company_name AS compañía
FROM company
WHERE id IN (SELECT DISTINCT(company_id) 
			FROM transaction
			WHERE amount > (SELECT AVG(amount) 
							FROM transaction 
							WHERE declined=0));
                            
SELECT company_name AS compañía
FROM company 
WHERE id NOT IN (SELECT DISTINCT(company_id)
				FROM transaction
				WHERE declined=0);

SELECT COUNT(DISTINCT(company_id))
				FROM transaction
				WHERE declined=0;
                
# Nivell 2
# Exercici 1
SELECT DATE(timestamp) AS fecha, SUM(amount) AS total_ventas
FROM transaction
WHERE declined = 0
GROUP BY fecha
ORDER BY total_ventas DESC
LIMIT 5;

#Exercici 2
SELECT country AS país, ROUND(AVG(amount),2) AS promedio_ventas
FROM company AS c
INNER JOIN transaction AS t
ON c.id=t.company_id
WHERE declined = 0
GROUP BY país
ORDER BY promedio_ventas DESC;

#Exercici 3
SELECT * 
FROM transaction AS t
LEFT JOIN company AS c
ON t.company_id=c.id
WHERE country = (SELECT country 
				FROM company
				WHERE company_name='Non Institute');
                
SELECT * 
FROM transaction
WHERE company_id IN (SELECT id
				FROM company 
				WHERE country = (SELECT country 
								FROM company
								WHERE company_name='Non Institute'));

#Nivell 3
#Exercici 1
SELECT company_name AS nombre, phone AS teléfono, country AS país, 
	DATE(timestamp) AS fecha, amount AS cantidad
FROM transaction AS t
LEFT JOIN company AS c
ON t.company_id=c.id
WHERE (amount BETWEEN 350 AND 400) AND 
	(DATE(timestamp) IN ('2015-04-29','2018-7-20','2024-03-13'))
ORDER BY cantidad DESC;

#Exercici 2
SELECT company_name AS compañía, COUNT(amount) AS cantidad_transacciones,
	IF(COUNT(amount)>400, "sí", "no") AS más_de_400_transacciones
FROM company AS c
RIGHT JOIN transaction AS t
ON c.id=t.company_id
WHERE declined=0
GROUP BY compañía;
