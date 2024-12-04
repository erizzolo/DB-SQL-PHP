-- Da A76-27 Banca Restructured
SELECT "DROP DATABASE IF EXISTS Banca;" AS "Eliminazione database eventualmente esistente";
DROP DATABASE IF EXISTS Banca;

SELECT "CREATE DATABASE IF NOT EXISTS Banca;" AS "Creazione database vuoto";
CREATE DATABASE IF NOT EXISTS Banca;

SELECT "USE Banca;" AS "Impostazione database di default (per evitare database.table...)";
USE Banca;

SELECT "CREATE TABLE filiale (...);" AS "Creazione nuova tabella filiale";
CREATE TABLE filiale (
    -- primary key field(s)
    codice VARCHAR(10) COMMENT "Codice alfanumerico",
    -- mandatory fields
    nome VARCHAR(50) NOT NULL COMMENT "nome filiale",
    citta VARCHAR(50) NOT NULL COMMENT "città filiale",-- tabella?
    -- optional fields (NULL can be omitted)
    -- derived (computed) fields
    -- non gestito per ora...
    -- patrimonio DECIMAL(15,2) NOT NULL DEFAULT 0.0 COMMENT "Patrimonio in € fino a 9.999.999.999.999,99",-- 10 mila miliardi...
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (codice)
    -- DOMAIN (optional)
    -- CHECK(patrimonio >= 0.00)
) COMMENT "Table for entity filiale";

SHOW CREATE TABLE filiale\G

SELECT "CREATE TABLE cliente (...);" AS "Creazione nuova tabella cliente";
CREATE TABLE cliente (
    -- primary key field(s)
    id INT AUTO_INCREMENT COMMENT "chiave surrogata",
    -- mandatory fields
    codice_fiscale VARCHAR(16) COMMENT "codice fiscale, UNIQUE!",
    -- dati anagrafici
    nome VARCHAR(50) NOT NULL COMMENT "nome cliente",
    cognome VARCHAR(50) NOT NULL COMMENT "cognome cliente",
    data_nascita DATE NOT NULL COMMENT "data di nascita cliente",
    luogo_nascita VARCHAR(50) NOT NULL COMMENT "luogo di nascita cliente",
    -- recapiti
    indirizzo VARCHAR(50) NOT NULL COMMENT "indirizzo cliente",
    citta VARCHAR(50) NOT NULL COMMENT "città cliente",
    telefono VARCHAR(50) NOT NULL COMMENT "telefono cliente",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (id),
    -- CANDIDATE KEYS (optional)
    UNIQUE (codice_fiscale)
) COMMENT "Table for entity cliente";

SHOW CREATE TABLE cliente\G

SELECT "CREATE TABLE conto (...);" AS "Creazione nuova tabella conto";
CREATE TABLE conto (
    -- primary key field(s)
    numero VARCHAR(20) COMMENT "numero del conto",
    -- mandatory fields
    saldo DECIMAL(12,2) NOT NULL COMMENT "saldo in € fino a 9.999.999.999,99",-- 10 miliardi?
    filiale VARCHAR(10) NOT NULL COMMENT "filiale che gestisce il conto",
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (numero),
    -- FOREIGN KEYS (optional)
    CONSTRAINT gestione FOREIGN KEY(filiale) REFERENCES filiale(codice)
        ON UPDATE CASCADE ON DELETE NO ACTION
) COMMENT "Table for entity conto";

SHOW CREATE TABLE conto\G

SELECT "CREATE TABLE prestito (...);" AS "Creazione nuova tabella prestito";
CREATE TABLE prestito (
    -- primary key field(s)
    codice VARCHAR(20) COMMENT "codice del prestito",
    -- mandatory fields
    importo DECIMAL(12,2) NOT NULL COMMENT "importo in € fino a 9.999.999.999,99",-- 10 miliardi?
    filiale VARCHAR(10) NOT NULL COMMENT "filiale che ha concesso il prestito",
    ufficio VARCHAR(50) NOT NULL COMMENT "ufficio che ha concesso il prestito",
    impiegato VARCHAR(50) NOT NULL COMMENT "impiegato che ha concesso il prestito",
    apertura DATE NOT NULL COMMENT "data in cui è stato concesso il prestito",
    estinzione DATE NOT NULL COMMENT "data in cui dovrebbe essere estinto il prestito",-- NULL?
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (codice),
    -- FOREIGN KEYS (optional)
    CONSTRAINT concessione FOREIGN KEY(filiale) REFERENCES filiale(codice)
        ON UPDATE CASCADE ON DELETE NO ACTION,
    -- DOMAIN (optional)
    CHECK(importo >= 0.00),
    CONSTRAINT PeriodoEstinzione CHECK(estinzione > apertura)
) COMMENT "Table for entity prestito";

SHOW CREATE TABLE prestito\G

SELECT "CREATE TABLE intestazione (...);" AS "Creazione nuova tabella intestazione";
CREATE TABLE intestazione (
    -- primary key field(s)
    conto VARCHAR(20) COMMENT "conto",
    cliente INT COMMENT "id cliente",-- NO AUTO_INCREMENT HERE !!!
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (conto, cliente),
    -- FOREIGN KEYS (optional)
    CONSTRAINT IntestazioneConto FOREIGN KEY(conto) REFERENCES conto(numero),
    CONSTRAINT IntestazioneCliente FOREIGN KEY(cliente) REFERENCES cliente(id)
) COMMENT "Table for N-M association between entities Conto & Cliente";

SHOW CREATE TABLE intestazione\G

SELECT "CREATE TABLE sottoscrizione (...);" AS "Creazione nuova tabella sottoscrizione";
CREATE TABLE sottoscrizione (
    -- primary key field(s)
    prestito VARCHAR(20) COMMENT "prestito",
    cliente INT COMMENT "id cliente",-- NO AUTO_INCREMENT HERE !!!
    -- CONSTRAINTS:
    -- PRIMARY KEY: implies NOT NULL
    PRIMARY KEY (prestito, cliente),
    -- FOREIGN KEYS (optional)
    CONSTRAINT SottoscrizionePrestito FOREIGN KEY(prestito) REFERENCES prestito(codice),
    CONSTRAINT SottoscrizioneCliente FOREIGN KEY(cliente) REFERENCES cliente(id)
) COMMENT "Table for N-M association between entities Prestito & Cliente";

SHOW CREATE TABLE sottoscrizione\G
