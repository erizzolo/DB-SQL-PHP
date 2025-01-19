-- Schema con vincolo circolare...
SELECT "USE Company;" AS "Impostazione database di default (per evitare database.table...)";
USE Company;

SELECT "INSERT INTO project (...);" AS "Inserimento in tabella project";
INSERT INTO project
VALUES ('ECLIPSE', 100.50, NULL),
    ('TRAVEL TO MARS', 1000.50, '2050-01-01'),
    ('BACK HOME', 0.01, NULL);
SELECT * FROM project;

SELECT "INSERT INTO branch (...);" AS "Inserimento in tabella branch";
INSERT INTO branch
VALUES ('MIRANO', '42/A', 'Via Matteotti', '30030'),
    ('MIRA', '14', 'Via Sauro', '30034');
SELECT * FROM branch;

SELECT "INSERT INTO employee & department (...);" AS "Inserimento in tabella employee / department";

SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;

INSERT INTO employee
VALUES (NULL, 'Rizzolo', '1000.00', '2000-01-01', DEFAULT, 'MIRANO', 'Computer Science', '2005-09-01');
SET @MANAGER_ID = LAST_INSERT_ID();
INSERT INTO department
VALUES ('MIRANO', 'Computer Science', @MANAGER_ID);

SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;

SELECT * FROM employee;
SELECT * FROM department;

SELECT "INSERT INTO employee & department (...);" AS "Inserimento in tabella employee / department";

SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;

INSERT INTO employee
VALUES (NULL, 'Rizzolo', '1000.00', '2000-01-01', DEFAULT, 'MIRANO', 'Computer Science', '2005-09-01');
SET @MANAGER_ID = LAST_INSERT_ID();
INSERT INTO department
VALUES ('MIRANO', 'Computer Science', @MANAGER_ID);

SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;

SELECT * FROM employee;
SELECT * FROM department;
