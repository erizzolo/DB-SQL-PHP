-- Da A77-30 Compagnia aerea Restructured
SELECT "DROP DATABASE IF EXISTS Compagnia;" AS "Eliminazione database eventualmente esistente";
DROP DATABASE IF EXISTS Compagnia;

SELECT "CREATE DATABASE IF NOT EXISTS Compagnia;" AS "Creazione database vuoto";
CREATE DATABASE IF NOT EXISTS Compagnia;

SELECT "USE Compagnia;" AS "Impostazione database di default (per evitare database.table...)";
USE Compagnia;

SELECT "CREATE TABLE aeromobile (...);" AS "Creazione nuova tabella aeromobile";
CREATE TABLE aeromobile (
    -- primary key field(s)
    codice VARCHAR(10) COMMENT "codice interno alfanumerico",
    -- mandatory fields
    nome VARCHAR(50) NOT NULL COMMENT "nome",
    produttore VARCHAR(50) NOT NULL COMMENT "produttore",
    modello VARCHAR(50) NOT NULL COMMENT "modello",
    anno YEAR NOT NULL COMMENT "anno di produzione YYYY",
    -- optional fields from children entities
    capacita INT NOT NULL COMMENT "capacita in kg se cargo",
    posti INT NOT NULL COMMENT "numero passeggeri se di linea",
    -- derived (computed) fields
    tipo ENUM('Cargo','Linea') AS (IF(ISNULL(posti),'Cargo','Linea')) VIRTUAL COMMENT "tipo aeromobile",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (codice),
    -- TUPLE (optional)
    CONSTRAINT CargoXORLinea CHECK(ISNULL(capacita) != ISNULL(posti))
) COMMENT "Table for entity aeromobile";

SHOW CREATE TABLE aeromobile\G

SELECT "CREATE TABLE motore (...);" AS "Creazione nuova tabella motore";
CREATE TABLE motore (
    -- primary key field(s)
    descrizione VARCHAR(50) COMMENT "descrizione motore",
    aeromobile VARCHAR(10) COMMENT "Aeromobile di installazione",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (descrizione, aeromobile),
    -- FOREIGN KEYS (optional)
    CONSTRAINT Installazione FOREIGN KEY(aeromobile) REFERENCES aeromobile(codice)
) COMMENT "Table for multiple attribute motore of entity Aeromobile";

SHOW CREATE TABLE motore\G

SELECT "CREATE TABLE personale (...);" AS "Creazione nuova tabella personale";
CREATE TABLE personale (
    -- primary key field(s)
    id INT AUTO_INCREMENT COMMENT "chiave surrogata",
    -- mandatory fields
    -- dati anagrafici
    nome VARCHAR(50) NOT NULL COMMENT "nome personale",
    cognome VARCHAR(50) NOT NULL COMMENT "cognome personale",
    data_nascita DATE NOT NULL COMMENT "data di nascita personale",
    luogo_nascita VARCHAR(50) NOT NULL COMMENT "luogo di nascita personale",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (id)
) COMMENT "Table for entity personale";

SHOW CREATE TABLE personale\G

SELECT "CREATE TABLE aeroporto (...);" AS "Creazione nuova tabella aeroporto";
-- from https://openflights.org/data.php
CREATE TABLE aeroporto (
    -- primary key field(s)
    id_aeroporto INT AUTO_INCREMENT COMMENT "Unique OpenFlights identifier for this airport.", -- sa tanto di chiave surrogata
    -- mandatory fields
    name VARCHAR(50) NOT NULL COMMENT "Name of airport. May or may not contain the City name.",
    city VARCHAR(50) NOT NULL COMMENT "Main city served by airport. May be spelled differently from Name.",
    country VARCHAR(50) NOT NULL COMMENT "Country or territory where airport is located. See Countries to cross-reference to ISO 3166-1 codes.",
    IATA VARCHAR(3) NULL COMMENT "3-letter IATA code. Null if not assigned/unknown.",
    ICAO VARCHAR(4) NULL COMMENT "4-letter ICAO code. Null if not assigned.",
    latitudine DOUBLE NOT NULL COMMENT "Decimal degrees, usually to six significant digits. Negative is South, positive is North.",
    longitudine DOUBLE NOT NULL COMMENT "Decimal degrees, usually to six significant digits. Negative is West, positive is East.",
    altitude INT NOT NULL COMMENT "In feet.",
    timezone DECIMAL(3,1) NOT NULL COMMENT "Hours offset from UTC. Fractional hours are expressed as decimals, eg. India is 5.5.",
    ora_legale VARCHAR(1) NOT NULL COMMENT "Daylight  savings time. One of E (Europe), A (US/Canada), S (South America), O (Australia), Z (New Zealand), N (None) or U (Unknown). See also: Help: Time",
    tz_timezone VARCHAR(50) NOT NULL COMMENT 'Timezone in "tz" (Olson) format, eg. "America/Los_Angeles".',
    tipo VARCHAR(50) NOT NULL COMMENT 'Type of the airport. Value "airport" for air terminals, "station" for train stations, "port" for ferry terminals and "unknown" if not known. In airports.csv, only type=airport is included.',
    source VARCHAR(50) NOT NULL COMMENT 'Source of this data. "OurAirports" for data sourced from OurAirports, "Legacy" for old data not matched to OurAirports (mostly DAFIF), "User" for unverified user contributions. In airports.csv, only source=OurAirports is included.',
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (id_aeroporto),
    -- CANDIDATE KEYS (optional)
    UNIQUE (IATA),
    UNIQUE (ICAO)
);

SHOW CREATE TABLE aeroporto\G
