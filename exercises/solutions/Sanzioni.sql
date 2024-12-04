-- Da A76-27 Sanzioni
SELECT "DROP DATABASE IF EXISTS Sanzioni;" AS "Eliminazione database eventualmente esistente";
DROP DATABASE IF EXISTS Sanzioni;

SELECT "CREATE DATABASE IF NOT EXISTS Sanzioni;" AS "Creazione database vuoto";
CREATE DATABASE IF NOT EXISTS Sanzioni;

SELECT "USE Sanzioni;" AS "Impostazione database di default (per evitare database.table...)";
USE Sanzioni;

SELECT "CREATE TABLE automobilista (...);" AS "Creazione nuova tabella automobilista";
CREATE TABLE automobilista (
    -- primary key field(s)
    id INT AUTO_INCREMENT COMMENT "chiave surrogata",
    -- mandatory fields
    codice_fiscale VARCHAR(16) NOT NULL COMMENT "codice fiscale, UNIQUE!",
    -- dati anagrafici
    nome VARCHAR(50) NOT NULL COMMENT "nome automobilista",
    cognome VARCHAR(50) NOT NULL COMMENT "cognome automobilista",
    data_nascita DATE NOT NULL COMMENT "data di nascita automobilista",
    luogo_nascita VARCHAR(50) NOT NULL COMMENT "luogo di nascita automobilista",
    -- recapiti
    indirizzo VARCHAR(50) NOT NULL COMMENT "indirizzo automobilista",
    citta VARCHAR(50) NOT NULL COMMENT "città automobilista",
    cap VARCHAR(50) NOT NULL COMMENT "CAP automobilista",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (id),
    -- CANDIDATE KEYS (optional)
    UNIQUE (codice_fiscale)
) COMMENT "Table for entity automobilista";

SHOW CREATE TABLE automobilista\G

SELECT "CREATE TABLE agente (...);" AS "Creazione nuova tabella agente";
CREATE TABLE agente (
    -- primary key field(s)
    matricola INT COMMENT "matricola agente",
    -- mandatory fields
    nome VARCHAR(50) NOT NULL COMMENT "nome agente",
    cognome VARCHAR(50) NOT NULL COMMENT "cognome agente",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (matricola)
) COMMENT "Table for entity agente";

SHOW CREATE TABLE agente\G

SELECT "CREATE TABLE veicolo (...);" AS "Creazione nuova tabella veicolo";
CREATE TABLE veicolo (
    -- primary key field(s)
    targa VARCHAR(50) COMMENT "targa veicolo",
    -- mandatory fields
    marca VARCHAR(50) NOT NULL COMMENT "marca veicolo",
    modello VARCHAR(50) NOT NULL COMMENT "modello veicolo",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (targa)
) COMMENT "Table for entity veicolo";

SHOW CREATE TABLE veicolo\G

SELECT "CREATE TABLE infrazione (...);" AS "Creazione nuova tabella infrazione";
CREATE TABLE infrazione (
    -- primary key field(s)
    codice VARCHAR(10) COMMENT "Codice alfanumerico",
    -- mandatory fields
    denominazione VARCHAR(50) NOT NULL COMMENT "denominazione infrazione",
    data_ora DATETIME NOT NULL COMMENT "istante infrazione",
    importo DECIMAL(6,2) NOT NULL COMMENT "importo infrazione",
    -- external identifier(s) relationship rilevazione
    agente INT NOT NULL COMMENT "agente che ha rilevato l'infrazione",
    -- external identifier(s) relationship contestazione
    veicolo VARCHAR(50) NOT NULL COMMENT "veicolo che ha commesso l'infrazione",
    -- external identifier(s) relationship responsabilità
    responsabile INT NULL COMMENT "eventuale responsabile dell'infrazione",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (codice),
    -- FOREIGN KEYS
    -- relationship rilevazione
    CONSTRAINT rilevazione  FOREIGN KEY(agente) REFERENCES agente(matricola),
    -- relationship contestazione
    CONSTRAINT contestazione FOREIGN KEY(veicolo) REFERENCES veicolo(targa),
    -- relationship responsabilità
    CONSTRAINT responsabilita FOREIGN KEY(responsabile) REFERENCES automobilista(id),
    -- DOMAIN (optional)
    CONSTRAINT DaPagare CHECK(importo > 0.00)
) COMMENT "Table for entity infrazione";

SHOW CREATE TABLE infrazione\G

SELECT "CREATE TABLE proprieta (...);" AS "Creazione nuova tabella proprieta";
CREATE TABLE proprieta (
    -- primary key field(s)
    veicolo VARCHAR(50) COMMENT "veicolo posseduto",
    proprietario INT COMMENT "id proprietario",-- NO AUTO_INCREMENT HERE !!!
    -- optional fields (NULL can be omitted)
    quota DECIMAL(5,2) COMMENT "Optional quota percentage in [0, 100]", -- See BR !!!
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (veicolo, proprietario),
    -- FOREIGN KEYS (optional)
    CONSTRAINT Proprieta FOREIGN KEY(veicolo) REFERENCES veicolo(targa),
    CONSTRAINT Propietario FOREIGN KEY(proprietario) REFERENCES automobilista(id),
    -- DOMAIN (optional)
    CONSTRAINT Quota CHECK(quota BETWEEN 0.00 AND 100.00) -- sum 100 is a bit complex now...
) COMMENT "Table for N-M association between entities veicolo & automobilista";

SHOW CREATE TABLE proprieta\G

