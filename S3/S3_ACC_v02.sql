-- Creamos la base de datos
CREATE DATABASE IF NOT EXISTS transactions;
USE transactions;

SELECT *
FROM transaction
LIMIT 3;

SELECT *
FROM company
LIMIT 3;

SHOW KEYS 
FROM transaction;

-- Nivell 1
-- Exercici 1

-- Creamos la tabla credit_card
CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(15) PRIMARY KEY UNIQUE NOT NULL,
    iban VARCHAR(100) NOT NULL,
    pan VARCHAR(100) NOT NULL,
    pin VARCHAR(20) NOT NULL,
    cvv VARCHAR(20) NOT NULL,
    expiring_date VARCHAR(50) NOT NULL
);

-- Añadimos información de dades_introduir_credit

-- Confirmamos que no existe una credit cards en transaction que no este en credit_card
SELECT *
FROM transaction
WHERE credit_card_id NOT IN (SELECT DISTINCT(id)
							FROM credit_card);
                            
-- Relación entre transaction y credit_card
/*ALTER TABLE transaction 
ADD CONSTRAINT fk_credit_card
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);*/

-- Exercici 2
UPDATE credit_card
SET iban='TR323456312213576817699999'
WHERE id='CcU-2938';

-- Confirmamos el cambio
SELECT * 
FROM credit_card
WHERE id='CcU-2938';

-- Exercici 3
/*ALTER TABLE transaction
DROP FOREIGN KEY fk_credit_card;*/
-- Info. tabla transaction
SHOW COLUMNS FROM transaction;
SHOW CREATE TABLE transaction;
SHOW KEYS FROM transaction;

-- Insertamos nueva compañia
INSERT IGNORE INTO company(id) 
VALUES ('b-9999');

SELECT * 
FROM company 
WHERE id = 'b-9999';

-- Insertamos nueva tarjeta de credito
INSERT IGNORE INTO credit_card(id,iban,pan,pin,cvv,expiring_date) 
VALUES ('CcU-9999','XX999999999999999999999999','9999999999999999','9999','999','12/12/25');

SELECT * 
FROM credit_card 
WHERE id = 'CcU-9999';

-- Insertamos transaccion
INSERT IGNORE INTO transaction(id,credit_card_id,company_id,user_id,
						lat,longitude,amount,declined)
VALUES('108B1D1D-5B23-A76C-55EF-C568E49A99DD','CcU-9999','b-9999',9999,
        829.999,-117.999,111.11,0);

SELECT * 
FROM transaction
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';

-- Exercici 4
ALTER TABLE credit_card
DROP COLUMN pan;

SHOW COLUMNS FROM credit_card;

-- Nivell 2
-- Exercici 1
SELECT *
FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

DELETE IGNORE FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

SELECT *
FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- Exercici 2
-- ANY_VALUE()
CREATE OR REPLACE VIEW VistaMarketing AS
SELECT company_name AS compañía,GROUP_CONCAT(DISTINCT(phone)) AS teléfono,
	GROUP_CONCAT(DISTINCT(country)) AS país_residéncia,ROUND(AVG(amount),2) AS media_compra
FROM company AS c
INNER JOIN transaction AS t
ON c.id = t.company_id
WHERE declined=0
GROUP BY company_name;

SELECT * 
FROM VistaMarketing
ORDER BY media_compra DESC;

-- Exercici 3
SELECT * 
FROM VistaMarketing
WHERE país_residéncia = 'Germany'
ORDER BY media_compra DESC;

-- Nivell 3
-- Exercici 1
SHOW COLUMNS FROM transaction;
SHOW KEYS FROM transaction;

-- Eliminamos columna website de company
ALTER TABLE company
DROP COLUMN website;
SHOW COLUMNS FROM company;

-- cambiamos nombre tabla user a data_user
/*ALTER TABLE user 
RENAME TO data_user;*/
-- cambiamos tipo columna id de char(10) a int
ALTER TABLE data_user
MODIFY COLUMN id INT;
-- cambiamos nombre de la columna email a personal_email
ALTER TABLE data_user
RENAME COLUMN email TO personal_email;
-- Confirmamos que no existe una user en transaction que no este en data_user
SELECT *
FROM transaction
WHERE user_id NOT IN (SELECT DISTINCT(id)
							FROM data_user);
-- insertamos usuario faltante
INSERT IGNORE INTO data_user(id) 
VALUES ('9999');
SELECT * 
FROM data_user
WHERE id = '9999';
-- Relación entre transaction y data_user
/*ALTER TABLE transaction 
ADD CONSTRAINT fk_data_user
FOREIGN KEY (user_id)
REFERENCES data_user(id);*/
SHOW COLUMNS FROM data_user;

SHOW COLUMNS FROM credit_card;
-- cambiamos tipo columna iban de varchar(100) a varchar(50)
ALTER TABLE credit_card
MODIFY COLUMN iban VARCHAR(50);
-- cambiamos tipo columna pin de varchar(20) a varchar(4)
ALTER TABLE credit_card
MODIFY COLUMN pin VARCHAR(4);
-- cambiamos tipo columna cvv de varchar(20) a INT
ALTER TABLE credit_card
MODIFY COLUMN cvv INT;
-- cambiamos tipo columna expiring_date de varchar(50) a varchar(255)
ALTER TABLE credit_card
MODIFY COLUMN expiring_date VARCHAR(255);
-- añadimos columna fecha_actual
ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE;
-- para modificar columna id, primero eliminamos la conexion con transaction
/*ALTER TABLE transaction
DROP FOREIGN KEY fk_credit_card;*/
-- cambiamos columna id y credit_card_id de varchar(15) varchar(20) en credit_card y transaction
ALTER TABLE credit_card
MODIFY COLUMN id VARCHAR(20);
ALTER TABLE transaction
MODIFY COLUMN credit_card_id VARCHAR(20);
-- Relación entre transaction y credit_card
/*ALTER TABLE transaction 
ADD CONSTRAINT fk_credit_card
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);*/

-- Exercici 2
-- ANY_VALUE()
CREATE OR REPLACE VIEW InformeTecnico AS
SELECT t.id AS ID_transaccion, name AS nombre_usuario, surname AS apellido_usuario,
		iban, company_name AS compania, c.country AS pais_compania, 
        d.country AS pais_usuario, amount AS cantidad , declined AS rechazado
FROM transaction AS t
INNER JOIN data_user AS d
ON t.user_id = d.id
INNER JOIN credit_card AS cc
ON t.credit_card_id = cc.id
INNER JOIN company AS c
ON t.company_id = c.id;

SELECT * 
FROM InformeTecnico
ORDER BY ID_transaccion DESC;