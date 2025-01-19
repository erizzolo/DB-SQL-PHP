SELECT "DROP DATABASE IF EXISTS Company;" AS "Eliminazione database eventualmente esistente";
DROP DATABASE IF EXISTS Company;

SELECT "CREATE DATABASE IF NOT EXISTS Company;" AS "Creazione database vuoto";
CREATE DATABASE IF NOT EXISTS Company;

SELECT "USE Company;" AS "Impostazione database di default (per evitare database.table...)";
USE Company;

SELECT "CREATE TABLE project (...);" AS "Creazione nuova tabella project";
CREATE TABLE project (
    -- primary key field(s)
    name VARCHAR(30) COMMENT "Nome",
    -- mandatory fields
    budget DECIMAL(10,2) NOT NULL COMMENT "Budget up to 99.999.999,99",
    -- optional fields (NULL can be omitted)
    release_date DATE NULL DEFAULT NULL COMMENT "Data di rilascio",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (name),
    -- DOMAIN (optional)
    CHECK(budget > 0.00)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT "Table for entity Project";

SELECT "CREATE TABLE branch (...);" AS "Creazione nuova tabella branch";
CREATE TABLE branch (
    -- primary key field(s)
    city VARCHAR(30) COMMENT "city",
    -- mandatory fields
    number VARCHAR(10) NOT NULL COMMENT "number",
    street VARCHAR(30) NOT NULL COMMENT "street",
    postcode VARCHAR(5) NOT NULL COMMENT "postcode",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (city)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT "Table for entity Branch";

SELECT "CREATE TABLE employee (...);" AS "Creazione nuova tabella employee";
CREATE TABLE employee (
    -- primary key field(s)
    code INT AUTO_INCREMENT COMMENT "matricola",
    -- mandatory fields
    surname VARCHAR(30) NOT NULL COMMENT "surname",
    salary DECIMAL(8,2) NOT NULL COMMENT "salary",
    birthdate DATE NOT NULL COMMENT "nascita",
    -- derived (computed) fields
    age INT AS (DATEDIFF(NOW(), birthdate) / 365) VIRTUAL COMMENT "age wrongly computed...",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT "Table for entity Employee";

SELECT "CREATE TABLE department (...);" AS "Creazione nuova tabella department";
CREATE TABLE department (
    -- primary key field(s)
    name VARCHAR(20) COMMENT "Department name",
    branch VARCHAR(30) COMMENT "city branch",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (name, branch),
    -- FOREIGN KEYS (optional)
    CONSTRAINT PartOfBranch FOREIGN KEY(branch) REFERENCES branch(city)
        ON UPDATE CASCADE ON DELETE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT "Table for entity Department";

SELECT "CREATE TABLE phone (...);" AS "Creazione nuova tabella phone";
CREATE TABLE phone (
    -- primary key field(s)
    number VARCHAR(10) COMMENT "phone number",
    department VARCHAR(20) COMMENT "Department name",
    branch VARCHAR(30) COMMENT "department city branch",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (number, department, branch), -- if a number can be shared between departments
    -- PRIMARY KEY (number), -- if a number is unique to a department
    -- FOREIGN KEYS (optional)
    CONSTRAINT BelongsToDepartment FOREIGN KEY(department, branch) REFERENCES department(name, branch)
        ON UPDATE CASCADE ON DELETE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT "Table for multiple attribute Phone of entity Department";

SELECT "CREATE TABLE partecipation (...);" AS "Creazione nuova tabella partecipation";
CREATE TABLE partecipation (
    -- primary key field(s)
    employee INT COMMENT "1. Partecipating employee code",
    project VARCHAR(30) COMMENT "2. Project name",
    -- mandatory fields
    start DATE NOT NULL COMMENT "4. Starting date",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (employee, project),
    -- FOREIGN KEYS (optional)
    CONSTRAINT RealEmployee FOREIGN KEY(employee) REFERENCES employee(code)
        ON UPDATE CASCADE ON DELETE NO ACTION,
    CONSTRAINT RealProject FOREIGN KEY(project) REFERENCES project(name)
        ON UPDATE CASCADE ON DELETE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT "Table for association Partecipation";

SELECT "ALTER TABLE employee (...);" AS "Modifica tabella employee";
ALTER TABLE employee
    ADD COLUMN department VARCHAR(20) NULL COMMENT "1. Member of Department name",
    ADD COLUMN branch VARCHAR(30) NULL COMMENT "1. Member Department branch",
    ADD COLUMN start DATE NULL COMMENT "2. Membership start date",
    -- CONSTRAINTS:
    ADD CONSTRAINT membershipDepartment FOREIGN KEY(department, branch) REFERENCES department(name, branch)
        ON UPDATE CASCADE ON DELETE NO ACTION,
    -- OPTIONAL FOREIGN KEY MEANINGFUL: (both NULL or none NULL)
    ADD CONSTRAINT DepartmentBranchNULLS CHECK(ISNULL(department) = ISNULL(branch)),
    -- Optional Relationship mandatory attribute MEANINGFUL: (NULL if no partecipation)
    ADD CONSTRAINT NoStarDateIfNoMembership CHECK(ISNULL(department) = ISNULL(start));

SELECT "ALTER TABLE department (...);" AS "Modifica tabella department";
ALTER TABLE department
    ADD COLUMN manager INT NOT NULL COMMENT "1. Manager employee code",
    -- CONSTRAINTS:
    ADD CONSTRAINT RealManager FOREIGN KEY(manager) REFERENCES employee(code)
        ON UPDATE CASCADE ON DELETE NO ACTION,
    ADD CONSTRAINT OnlyOneDepartmentPerManager UNIQUE(manager);
