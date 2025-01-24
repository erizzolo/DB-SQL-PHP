# Triggers

Un *trigger* è una sequenza di istruzioni associata ad eventi di **modifica dei dati di una tabella**.

Nel seguito si proporranno esempi relativi al database di esempio *classicmodels*.
## Creazione
L'istruzione di creazione di un trigger, nella forma più semplice, è la seguente:
```SQL
CREATE TRIGGER <trigger_name>
    <tempistica> <evento> ON <table_name>
    FOR EACH ROW
    <istruzioni>;
```
Sono possibili opzioni facoltative per aspetti di sicurezza e per l'ordine di attivazione dei trigger.

Dove:
* *trigger_name* è il nome del trigger, che lo identifica (univoco nel database): ad esempio per ``DROP TRIGGER <trigger_name>``
* *tempistica* è la relazione temporale (``AFTER|BEFORE``) con l'evento che attiva il trigger
* *evento* è l'evento di modifica dei dati (``INSERT|UPDATE|DELETE``) che attiva il trigger
* *table_name* è la tabella sulla quale accade l'evento di modifica
* *istruzioni* sono le istruzioni che saranno eseguite

> Si noti che le istruzioni di un trigger, oltre in generale a qualunque istruzione SQL (``SELECT, UPDATE, INSERT, DELETE, ...``), possono contenere costrutti di controllo tipici di un linguaggio di programmazione (``IF, ELSE, WHILE, CALL, ...``).

> All'interno dei trigger si hanno a disposizione le due versioni della riga interessata dalla modifica, tramite le keyword ``NEW`` e ``OLD``, che ovviamente si riferiscono rispettivamente alle versioni successiva e precedente la modifica stessa.

## Scopi
I triggers sono utilizzati per:
* mantenere aggiornati (coerenti) dati calcolati con espressioni non banali
* imporre vincoli non banali

### Aggiornamento dati non banali
Alcuni dati calcolati, che dipendono dai valori di una riga di una tabella, possono essere aggiunti alla tabella stessa come colonne *generate* (virtuali o memorizzate).

Ma le espressioni di calcolo delle colonne generate non consentono l'istruzione ``SELECT`` e quindi le possibilità di calcolo sono limitate.

Tale limitazione non esiste ovviamente per le istruzioni dei triggers, che di fatto possono implementare qualunque algoritmo.

Si presenta ora un caso semplice (nel quale i triggers non sarebbero necessari) per poi presentare casi più complessi nei quali i vantaggi dei triggers diventano sempre più significativi.

#### Dato dipendente da altri nella stessa riga

Si desidera aggiungere alla tabella orderdetails l'importo totale della riga di dettaglio.
Sarebbe ovviamente possibile farlo così:
```SQL
ALTER TABLE orderdetails
    ADD COLUMN totalPrice DECIMAL(10,2) AS (quantityOrdered * priceEach) VIRTUAL;
```
ma si desidera mostrare come rendere disponibile il dato tramite triggers.

In primo luogo si aggiunge alla tabella la colonna che conterrà il dato (necessariamente memorizzato):

```SQL
ALTER TABLE orderdetails
    ADD COLUMN totalPrice DECIMAL(10,2) NOT NULL DEFAULT 0;
```

Poi si aggiungono i trigger per tutti gli eventi che influiscono sul dato calcolato:

(inserimento e aggiornamento, ovviamente non ci interessa il caso di cancellazione)
```SQL
CREATE TRIGGER newDetail
    BEFORE INSERT ON orderdetails
    FOR EACH ROW
    SET NEW.totalPrice = NEW.quantityOrdered * NEW.priceEach;
```
```SQL
CREATE TRIGGER changeDetail
    BEFORE UPDATE ON orderdetails
    FOR EACH ROW
    SET NEW.totalPrice = NEW.quantityOrdered * NEW.priceEach;
```
Questo è sufficiente a rendere il dato calcolato coerente con i dati da cui esso deriva.

> Si noti che in questo caso si è intervenuti "prima" dell'effettiva modifica per assegnare il dato corretto.

#### Dato dipendente da altri in righe/tabelle diverse

Si desidera aggiungere alla tabella orders l'importo totale dell'ordine (somma degli importi delle righe di dettaglio).
Sarebbe ovviamente possibile farlo così:
```SQL
CREATE OR REPLACE VIEW ordersWithTotal AS
SELECT o.*,
    (
        SELECT SUM(quantityOrdered * priceEach)
        FROM orderdetails od
        WHERE od.orderNumber = o.orderNumber
    ) AS total
FROM orders o;
```
ma ciò significa rieseguire la somma ogni volta che ci interessa il totale dell'ordine.

In primo luogo si aggiunge alla tabella la colonna che conterrà il dato (necessariamente memorizzato):

```SQL
ALTER TABLE orders
    ADD COLUMN total DECIMAL(10,2) NOT NULL DEFAULT 0;
```

Poi si aggiungono i trigger per tutti gli eventi che influiscono sul dato calcolato:

(inserimento, aggiornamento e cancellazione di righe di dettaglio)
```SQL
CREATE TRIGGER newOrderDetail
    AFTER INSERT ON orderdetails
    FOR EACH ROW
    UPDATE orders SET total = total + NEW.totalPrice
        WHERE orders.orderNumber = NEW.orderNumber;
```
```SQL
CREATE TRIGGER cancelOrderDetail
    AFTER DELETE ON orderdetails
    FOR EACH ROW
    UPDATE orders SET total = total - OLD.totalPrice
        WHERE orders.orderNumber = OLD.orderNumber;
```
```SQL
CREATE TRIGGER changeOldOrderDetail
    AFTER UPDATE ON orderdetails
    FOR EACH ROW
    UPDATE orders SET total = total - OLD.totalPrice
        WHERE orders.orderNumber = OLD.orderNumber;
```
```SQL
CREATE TRIGGER changeNewOrderDetail
    AFTER UPDATE ON orderdetails
    FOR EACH ROW
    UPDATE orders SET total = total + NEW.totalPrice
        WHERE orders.orderNumber = NEW.orderNumber;
```
Questo è sufficiente a rendere il dato calcolato coerente con i dati da cui esso deriva.

Naturalmente gli ultimi due triggers si possono combinare in un unico trigger che effettua entrambi gli aggiornamenti:
```SQL
DELIMITER //
CREATE TRIGGER changeOrderDetail
    AFTER UPDATE ON orderdetails
    FOR EACH ROW
    BEGIN
        UPDATE orders SET total = total - OLD.totalPrice
            WHERE orders.orderNumber = OLD.orderNumber;
        UPDATE orders SET total = total + NEW.totalPrice
            WHERE orders.orderNumber = NEW.orderNumber;
    END;
//
DELIMITER ;
```
> In questo caso si è dovuto cambiare il delimitatore delle istruzioni per evitare ambiguità.

> Si noti che in questo caso si è intervenuti "dopo" l'effettiva modifica per assegnare il dato corretto.

> Si noti che, in generale, è possibile considerare un aggiornamento come combinazione di:
> * eliminazione della versione precedente l'aggiornamento
> * inserimento della versione successiva all'aggiornamento

Si consideri l'ulteriore esempio seguente:

```SQL
-- 10. Elenco di tutti i clienti con relativi saldi (somma dei pagamenti, importo complessivo degli ordini e loro differenza)
SELECT c.*,
    (
        SELECT SUM(amount)
        FROM payments p
        WHERE p.customerNumber = c.customerNumber
    ) AS pagamenti,
    (
        SELECT SUM(quantityOrdered * priceEach)
        FROM orderdetails
            JOIN orders o USING (orderNumber)
        WHERE o.customerNumber = c.customerNumber
    ) AS ordinato,
    (
        (
            SELECT SUM(amount)
            FROM payments p
            WHERE p.customerNumber = c.customerNumber
        ) - (
            SELECT SUM(quantityOrdered * priceEach)
            FROM orderdetails
                JOIN orders o USING (orderNumber)
            WHERE o.customerNumber = c.customerNumber
        )
    ) AS saldo
FROM customers c;
```

L'utilizzo dei trigger in questo caso consente di rendere i dati calcolati accessibili anche a sviluppatori "inesperti", in maniera uniforme, agevolmente modificabile qualora la procedura di calcolo cambiasse ed efficiente in quanto si evitano esecuzioni multiple delle procedure di calcolo ad ogni accesso (a differenza delle view).

In primo luogo si aggiungono alla tabella le colonne che conterranno i dati (necessariamente memorizzati):

```SQL
ALTER TABLE customers
    ADD COLUMN pagamenti DECIMAL(10,2) NOT NULL DEFAULT 0,
    ADD COLUMN ordinato DECIMAL(10,2) NOT NULL DEFAULT 0,
    ADD COLUMN saldo DECIMAL(10,2) NOT NULL DEFAULT 0;
```

Poi si aggiungono i trigger per tutti gli eventi che influiscono sui dati calcolati.

Per quanto riguarda i pagamenti:
```SQL
CREATE TRIGGER newPayment
    AFTER INSERT ON payments
    FOR EACH ROW
    UPDATE customers c SET pagamenti = pagamenti + NEW.amount, saldo = saldo - NEW.amount
        WHERE c.customerNumber = NEW.customerNumber;
```
```SQL
CREATE TRIGGER cancelPayment
    AFTER DELETE ON payments
    FOR EACH ROW
    UPDATE customers c SET pagamenti = pagamenti - OLD.amount, saldo = saldo + OLD.amount
        WHERE c.customerNumber = OLD.customerNumber;
```
```SQL
CREATE TRIGGER changeOldPayment
    AFTER UPDATE ON payments
    FOR EACH ROW
    UPDATE customers c SET pagamenti = pagamenti - OLD.amount, saldo = saldo + OLD.amount
        WHERE c.customerNumber = OLD.customerNumber;
```
```SQL
CREATE TRIGGER changeNewPayment
    AFTER UPDATE ON payments
    FOR EACH ROW
    UPDATE customers c SET pagamenti = pagamenti + NEW.amount, saldo = saldo - NEW.amount
        WHERE c.customerNumber = NEW.customerNumber;
```
Naturalmente gli ultimi due triggers si possono combinare in un unico trigger che effettua entrambi gli aggiornamenti:
```SQL
DELIMITER //
CREATE TRIGGER changePayment
    AFTER UPDATE ON payments
    FOR EACH ROW
    BEGIN
        UPDATE customers c SET pagamenti = pagamenti - OLD.amount, saldo = saldo + OLD.amount
            WHERE c.customerNumber = OLD.customerNumber;
        UPDATE customers c SET pagamenti = pagamenti + NEW.amount, saldo = saldo - NEW.amount
            WHERE c.customerNumber = NEW.customerNumber;
    END;
//
DELIMITER ;
```
> In questo caso si è dovuto cambiare il delimitatore delle istruzioni per evitare ambiguità.

**Si lascia per esercizio al lettore la scrittura dei triggers relativi agli ordini.**

> Se sono presenti i triggers precedenti, è sufficiente intervenire sull'aggiornamento degli ordini.

> In questo caso, la modifica in orderdetails attiva un trigger che provoca una modifica in orders, la quale attiva un trigger che provoca una modifica in customers...: **ATTENZIONE a NON creare cicli...**

### Imposizione di vincoli non banali
Alcune condizioni di vincolo, che dipendono dai valori di una riga di una tabella, possono essere aggiunte alla tabella stessa come espressioni ``CHECK``.

Ma le espressioni utilizzate nella clausola ``CHECK`` non consentono l'istruzione ``SELECT`` e quindi le possibilità sono limitate.

Tale limitazione non esiste ovviamente per le istruzioni dei triggers, che di fatto possono implementare qualunque algoritmo.

Qualora il trigger rilevi che una condizione di vincolo non è soddisfatta, può generare un errore che interrompe/annulla l'esecuzione delle istruzioni, compresa quella che lo ha attivato (specialmente con la tempistica ``BEFORE``).

Si presenta ora un caso semplice (nel quale i triggers non sarebbero necessari) per poi presentare casi più complessi nei quali i vantaggi dei triggers diventano sempre più significativi.

#### Condizione dipendente da dati nella stessa riga

In questo caso è in genere possibile utilizzare una clausola ``CHECK``, ma si presenta un esempio di utilizzo dei triggers.

Si supponga di voler porre un limite superiore all'importo di un ordine (colonna total): total <= 1000000.00 (un milione).

Si potrebbe ovviamente imporre così:

```SQL
ALTER TABLE orders
    ADD CONSTRAINT totalExceedingLimit CHECK(total <= 1000000.00);
```
Ma si vuole imporre tramite triggers, quindi lo si elimina:
```SQL
ALTER TABLE orders
    DROP CONSTRAINT totalExceedingLimit;
```

Poi si aggiungono i trigger che in caso di modifica (tranne cancellazione) verifica se il vincolo è soddisfatto ed in caso contrario generano un errore:
```SQL
DELIMITER //
CREATE TRIGGER newOrderLimit
    BEFORE INSERT ON orders
    FOR EACH ROW
    BEGIN
        IF NOT (NEW.total < 1000000.00) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order total exceeds limit of 1000000.00';
        END IF;
    END;
//
DELIMITER ;
```
```SQL
DELIMITER //
CREATE TRIGGER changeOrderLimit
    BEFORE UPDATE ON orders
    FOR EACH ROW
    BEGIN
        IF NOT (NEW.total < 1000000.00) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order total exceeds limit of 1000000.00';
        END IF;
    END;
//
DELIMITER ;
```
Questo è sufficiente ad imporre il vincolo a tutte le righe inserite/modificate (NON a quelle già esistenti, il che è talvolta desiderabile...).

#### Condizione dipendente da dati in altre righe/tabelle

In questo caso **NON** è in genere possibile utilizzare una clausola ``CHECK``, ma si può imporre il vincolo tramite una view.

È comunque possibile utilizzare i triggers, come nell'esempio precedente.

## Triggers e transazioni

Tipicamente le istruzioni dei trigger e le istruzioni che ne provocano l'attivazione costituiscono un'unica transazione, e quindi il fallimento di una sola di esse provoca il fallimento dell'intera transazione.

Questo ovviamente vale quando gli storage engines coinvolti forniscono supporto alle transazioni.
