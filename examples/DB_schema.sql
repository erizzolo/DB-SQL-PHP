-- Template script for database schema creation
-- Replace db_name with real database name
SELECT "DROP DATABASE IF EXISTS db_name;" AS "Eliminazione database eventualmente esistente";
DROP DATABASE IF EXISTS db_name;
SELECT "CREATE DATABASE IF NOT EXISTS db_name;" AS "Creazione database vuoto";
CREATE DATABASE IF NOT EXISTS db_name;
SELECT "USE db_name;" AS "Impostazione database di default (per evitare database.table...)";
USE db_name;
-- Template of table creation instruction
-- Replace table_name with real table name
SELECT "CREATE TABLE table_name (...);" AS "Creazione nuova tabella table_name";
CREATE TABLE table_name (
    -- primary key field(s)
    k1 INT COMMENT "First key field",
    k2 VARCHAR(20) COMMENT "Second key field",
    -- mandatory fields
    a1 DATE NOT NULL COMMENT "Mandatory date field",
    a2 DOUBLE NOT NULL DEFAULT 1.0 COMMENT "Mandatory double field",
    a3 ENUM('White', 'Black', 'Gray') NOT NULL COMMENT "Mandatory enum field",
    -- optional fields (NULL can be omitted)
    o1 DATE NULL DEFAULT '2000-01-01' COMMENT "Optional date field",
    o2 DOUBLE NULL COMMENT "Optional double field",
    o3 SET('Tasty', 'Spicy', 'Healthy', 'Cheap', 'Vegan') NULL DEFAULT NULL COMMENT "Optional set field",
    -- derived (computed) fields
    d1 TINYINT AS (WEEKDAY(a1)) VIRTUAL COMMENT "Simple function, computed when needed",
    d2 DOUBLE AS (EXP(o2) + LOG(o2)) PERSISTENT COMMENT "Complex function, computed and stored when changed",
    -- invisible (not shown with *) fields
    i1 TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP() INVISIBLE COMMENT "Row update timestamp",
    -- external identifier(s) relationship 1
    f1_k1 INT NOT NULL COMMENT "Mandatory participation",
    f1_k2 VARCHAR(20) NOT NULL COMMENT "Mandatory participation",
    -- external identifiers relationship 2
    f2_k1 INT NULL COMMENT "Optional participation",
    f2_k2 CHAR(3) NULL COMMENT "Optional participation",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (k1, k2),
    -- CANDIDATE KEYS (optional)
    UNIQUE (a1, a2),
    -- FOREIGN KEYS (optional)
    -- CONSTRAINT nomeVincolo1 FOREIGN KEY(f1_k1,f1_k2) REFERENCES other_table(k1,k2)
    --  ON UPDATE <ACTION> ON DELETE <ACTION>,
    -- where ACTION = RESTRICT | NO ACTION | CASCADE | SET NULL
    CONSTRAINT parent FOREIGN KEY(f1_k1, f1_k2) REFERENCES table_name(k1, k2)
        ON UPDATE CASCADE ON DELETE NO ACTION,
    -- CONSTRAINT nomeVincolo2 FOREIGN KEY(f2_k1,f2_k2) REFERENCES other_table(k1,k2)
    --  ON UPDATE <ACTION> ON DELETE <ACTION>,
    -- DOMAIN (optional)
    CONSTRAINT Last120Years CHECK(a1 > '1900-01-01'),
    -- TUPLE (optional)
    CHECK(a1 > '1900-01-01' OR a3 = 'Gray'),
    -- OPTIONAL FOREIGN KEY MEANINGFUL: (both NULL or none NULL)
    -- CONSTRAINT NoMixUp CHECK(f2_k1 IS NULL = f2_k2 IS NULL) doesn't work!!!
    -- CONSTRAINT NoMixUp CHECK((f2_k1 IS NULL) = (f2_k2 IS NULL)) -- parentheses needed!!!
    CONSTRAINT NoMixUp CHECK(ISNULL(f2_k1) = ISNULL(f2_k2)) -- much better: obvious parentheses
);

SELECT "EXPLAIN table_name;" AS "Visualizzazione sintetica della tabella";
EXPLAIN table_name;

SELECT "SHOW CREATE TABLE table_name;" AS "Visualizzazione dell'istruzione di creazione della tabella";
SHOW CREATE TABLE table_name;

-- other tables ...
-- if circular references constraints...
ALTER TABLE table_name
    ADD CONSTRAINT nomeVincolo2 FOREIGN KEY(f2_k1,f2_k2) REFERENCES other_table(k1,k2)
    ON UPDATE SET NULL ON DELETE CASCADE;


-- Template of view creation instruction
-- Replace view_name with real view name
CREATE OR REPLACE VIEW view_name AS
    SELECT i1 AS hidden
        FROM table_name
--      WITH CASCADED CHECK OPTION
        ;

-- other things ... triggers, procedures, ...

-- Insertion example
INSERT INTO table_name
    VALUES(1, 'One', '2021-10-31', PI(), 'White', DEFAULT, NULL, 'Vegan', NULL, NULL, 1, 'One', NULL, DEFAULT);
INSERT INTO table_name(k1, k2, a1, a2, a3, d1, d2, i1, f1_k1, f1_k2, f2_k1, f2_k2)
    VALUES(2, 'Two', '2021-10-31', 2.718281828459045, 'Black', NULL, NULL, '2021-10-31T19:06:05', 1, 'One', NULL, DEFAULT);
