/*CREATE DATABASE S4_database;*/
USE S4_database;

-- Nivell 1
-- Creamos la tabla american_users
CREATE TABLE IF NOT EXISTS american_users (
	id VARCHAR(255) NULL,
    name VARCHAR(255) NULL,
    surname VARCHAR(255) NULL,
    phone VARCHAR(255) NULL,
    email VARCHAR(255) NULL,
    birth_date VARCHAR(255) NULL,
    country VARCHAR(255) NULL,
    city VARCHAR(255) NULL,
    postal_code VARCHAR(255) NULL,
    address VARCHAR(255) NULL
);

-- Añadimos los datos a la tabla
LOAD DATA
INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\S4\\american_users.csv"
INTO TABLE american_users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

-- Hacemos cambios a la tabla american_users;
ALTER TABLE american_users
MODIFY COLUMN id INT PRIMARY KEY UNIQUE NOT NULL;

SELECT * FROM american_users;
/*ALTER TABLE american_users
DROP PRIMARY KEY;
SHOW COLUMNS FROM american_users;
SHOW CREATE TABLE american_users;
SHOW KEYS FROM american_users;*/

-- Creamos la tabla european_users
CREATE TABLE IF NOT EXISTS european_users (
	id VARCHAR(255) NULL,
    name VARCHAR(255) NULL,
    surname VARCHAR(255) NULL,
    phone VARCHAR(255) NULL,
    email VARCHAR(255) NULL,
    birth_date VARCHAR(255) NULL,
    country VARCHAR(255) NULL,
    city VARCHAR(255) NULL,
    postal_code VARCHAR(255) NULL,
    address VARCHAR(255) NULL
);

-- Añadimos los datos a la tabla
LOAD DATA
INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\S4\\european_users.csv"
INTO TABLE european_users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

-- Hacemos cambios a la tabla european_users;
ALTER TABLE european_users
MODIFY COLUMN id INT PRIMARY KEY UNIQUE NOT NULL;

SELECT * FROM european_users;

-- Confirmamos que los id de las tablas american_user and european_user son diferentes
SELECT *
FROM american_users
WHERE id IN (SELECT id FROM european_users);

-- Combinamos las dos tablas en la tabla users
CREATE TABLE IF NOT EXISTS users AS
SELECT * FROM american_users
UNION 
SELECT * FROM european_users;

-- Hacemos cambios a la tabla users;
ALTER TABLE users
MODIFY COLUMN id INT PRIMARY KEY UNIQUE NOT NULL;

SELECT * FROM users;

-- Creamos la tabla credit_cards
CREATE TABLE IF NOT EXISTS credit_cards (
	id VARCHAR(255) NULL,
    user_id VARCHAR(255) NULL,
    iban VARCHAR(255) NULL,
    pan VARCHAR(255) NULL,
    pin VARCHAR(255) NULL,
    cvv VARCHAR(255) NULL,
    track1 VARCHAR(255) NULL,
    track2 VARCHAR(255) NULL,
    expiring_date VARCHAR(255) NULL
);

-- Añadimos los datos a la tabla
LOAD DATA
INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\S4\\credit_cards.csv"
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

-- Hacemos cambios a la tabla credit_cards;
ALTER TABLE credit_cards
MODIFY COLUMN id VARCHAR(255) PRIMARY KEY UNIQUE NOT NULL, 
MODIFY COLUMN user_id INT;

-- Añadimos foreign key con users
ALTER TABLE credit_cards
ADD CONSTRAINT fk_user
FOREIGN KEY (user_id)
REFERENCES users(id);

SELECT * FROM credit_cards;

-- Creamos la tabla companies
CREATE TABLE IF NOT EXISTS companies (
	company_id VARCHAR(255) NULL,
    company_name VARCHAR(255) NULL,
    phone VARCHAR(255) NULL,
    email VARCHAR(255) NULL,
    country VARCHAR(255) NULL,
    website VARCHAR(255) NULL
);

-- Añadimos los datos a la tabla
LOAD DATA
INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\S4\\companies.csv"
INTO TABLE companies
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

-- Hacemos cambios a la tabla companies;
ALTER TABLE companies
MODIFY COLUMN company_id VARCHAR(255) PRIMARY KEY UNIQUE NOT NULL;

SELECT * FROM companies;

-- Creamos la tabla transactions
CREATE TABLE IF NOT EXISTS transactions (
	id VARCHAR(255) NULL,
    card_id VARCHAR(255) NULL,
    business_id VARCHAR(255) NULL,
    timestamp VARCHAR(255) NULL,
    amount VARCHAR(255) NULL,
    declined VARCHAR(255) NULL,
    product_ids VARCHAR(255) NULL,
    user_id VARCHAR(255) NULL,
    lat VARCHAR(255) NULL,
    longitude VARCHAR(255) NULL
);

-- Añadimos los datos a la tabla
LOAD DATA
INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\S4\\transactions.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ';'
IGNORE 1 ROWS;

-- Hacemos cambios a la tabla transactions;
ALTER TABLE transactions
MODIFY COLUMN id VARCHAR(255) PRIMARY KEY UNIQUE NOT NULL,
MODIFY COLUMN amount DECIMAL(10,2),
MODIFY COLUMN declined TINYINT(1),
MODIFY COLUMN user_id INT;

-- Añadimos foreign key con card_id
ALTER TABLE transactions
ADD CONSTRAINT fk_credit_cards
FOREIGN KEY (card_id)
REFERENCES credit_cards(id);

-- Añadimos foreign key con companies
ALTER TABLE transactions
ADD CONSTRAINT fk_companies_transactions
FOREIGN KEY (business_id)
REFERENCES companies(company_id);

-- Añadimos foreign key con users
ALTER TABLE transactions
ADD CONSTRAINT fk_user_transactions
FOREIGN KEY (user_id)
REFERENCES users(id);

SELECT * FROM transactions;

-- Exercici 1
SELECT user_id, name, surname, country, COUNT(amount) AS num_transa
FROM transactions AS t
INNER JOIN users AS u
ON t.user_id = u.id
WHERE declined = 0
GROUP BY user_id
HAVING num_transa > 80
ORDER BY num_transa DESC;

-- Exercici 2
SELECT iban, ROUND(AVG(amount),2) AS media_cantidad
FROM transactions AS t
LEFT JOIN credit_cards AS cc
ON t.card_id = cc.id
LEFT JOIN companies AS c
ON t.business_id = c.company_id
WHERE company_name = 'Donec Ltd' AND declined = 0
GROUP BY iban
ORDER BY media_cantidad DESC;

-- Nivell 2
-- Exercici 1
CREATE TABLE IF NOT EXISTS credit_cards_state AS
SELECT card_id, IF(SUM(declined)=3,'inactiva','activa') AS estado
FROM (SELECT card_id, DATE(timestamp), declined,
	-- Utilizamos una función de ventana
	ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY DATE(timestamp) DESC) AS last_days
	FROM transactions) AS declined_date
WHERE last_days <= 3
GROUP BY card_id;

SELECT COUNT(card_id) AS tarjetas_activas
FROM credit_cards_state
WHERE estado = 'activa';

-- Nivell 3
-- Creamos la tabla products
CREATE TABLE IF NOT EXISTS products (
	id VARCHAR(255) NULL,
    product_name VARCHAR(255) NULL,
    price VARCHAR(255) NULL,
    colour VARCHAR(255) NULL,
    weight VARCHAR(255) NULL,
    warehouse_id VARCHAR(255) NULL
);

-- Añadimos los datos a la tabla
LOAD DATA
INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\S4\\products.csv"
INTO TABLE products
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

-- Hacemos cambios a la tabla products;
ALTER TABLE products
MODIFY COLUMN id INT PRIMARY KEY UNIQUE NOT NULL;

SELECT * FROM products;

-- Creamos tabla que relaciona productos con transacciones, transaction_product
CREATE TABLE IF NOT EXISTS transaction_product AS
-- Usamos una CTE recursiva
WITH RECURSIVE list_products AS (
SELECT id, TRIM(SUBSTRING_INDEX(product_ids, ',', 1)) AS product_id,
SUBSTRING(product_ids, LENGTH(SUBSTRING_INDEX(product_ids, ',', 1)) + 2) AS rest_product_ids
FROM transactions

UNION ALL

SELECT id, TRIM(SUBSTRING_INDEX(rest_product_ids, ',', 1)),
SUBSTRING(rest_product_ids, LENGTH(SUBSTRING_INDEX(rest_product_ids, ',', 1)) + 2)
FROM list_products
WHERE rest_product_ids <> ''
)
SELECT id AS transaction_id, CAST(product_id AS UNSIGNED) AS product_id
FROM list_products
ORDER BY id;

-- Hacemos cambios a la tabla transaction_product;
ALTER TABLE transaction_product
MODIFY COLUMN product_id INT;

-- Añadimos foreign key con transactions
ALTER TABLE transaction_product
ADD CONSTRAINT fk_tp_t
FOREIGN KEY (transaction_id)
REFERENCES transactions(id);

-- Añadimos foreign key con products
ALTER TABLE transaction_product
ADD CONSTRAINT fk_tp_p
FOREIGN KEY (product_id)
REFERENCES products(id);

-- Exercici 1
SELECT product_id, product_name, COUNT(transaction_id) AS num_ventas
FROM transaction_product AS tp
LEFT JOIN products AS p
ON tp.product_id = p.id
GROUP BY product_id
ORDER BY num_ventas DESC;