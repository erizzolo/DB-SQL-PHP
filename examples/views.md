# Views (viste logiche)

Una *view* è una query (istruzione ```SELECT ...```) memorizzata con un nome univoco ed equivalente ad una tabella *virtuale* che non memorizza direttamente dati ma li recupera quando necessario da altre tabelle e/o views.

Nel momento di creazione della view l'istruzione ```SELECT ...``` viene controllata sintatticamente, ma non eseguita; l'istruzione sarà eseguita soltanto quando necessario, ovvero quando la view sarà utilizzata in una istruzione ```INSERT```, ```SELECT```, ```UPDATE``` o ```DELETE```.

> Si noti che quando una view viene utilizzata in una istruzione di modifica dei dati (```INSERT```, ```UPDATE``` o ```DELETE```) saranno effettivamente modificate le tabelle sottostanti.
> 
>  Si noti anche che non tutte le view possono essere utilizzate per la modifica dei dati; ciò dipende dalle clausole presenti nella istruzione ```SELECT ...``` associata.

Nel seguito si proporranno esempi relativi al database di esempio *classicmodels*.

## Creazione
L'istruzione di creazione di una view, nella forma più semplice, è la seguente:
```SQL
CREATE VIEW <view_name> AS
<istruzione SELECT...>;
```
Sono possibili opzioni facoltative sulle quali si tornerà in seguito.

## Scopi
Le views sono utilizzate per:
* calcolare espressioni non banali
* semplificare query complesse
* controllare l'accesso ai dati
* imporre vincoli non banali

### Calcolo di espressioni non banali
Alcuni dati calcolati, che dipendono dai valori di una riga di una tabella, possono essere aggiunti alla tabella stessa come colonne *generate* (virtuali o memorizzate).

Ma le espressioni di calcolo delle colonne generate non consentono l'istruzione ``SELECT`` e quindi le possibilità di calcolo sono limitate.

Tale limitazione non esiste ovviamente in una istruzione ``SELECT``, nella cui lista di espressioni possono comparire subquery anche complesse.

Si consideri l'esempio seguente:

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

L'utilizzo delle view in questo caso consente di rendere i dati calcolati accessibili anche a sviluppatori "inesperti", in maniera uniforme ed agevolmente modificabile qualora la procedura di calcolo cambiasse.

```SQL
-- 10. Elenco di tutti i clienti con relativi saldi (somma dei pagamenti, importo complessivo degli ordini e loro differenza)
CREATE OR REPLACE VIEW customersBalance AS
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

In tal modo, i dati saranno semplicemente disponibili (e filtrabili in base ai campi calcolati!); ad esempio:
```SQL
SELECT *
FROM customersBalance
WHERE saldo < 0;
```
> Si noti che in assenza della view la condizione di filtro *saldo < 0* avrebbe richiesto la riscrittura delle subqueries di calcolo del saldo!

### Semplificazione di query complesse
Si consideri la query dell'esempio precedente, relativamente complessa.

Si può notare che il calcolo del saldo non è altro che la differenza delle due subqueries precedenti.

Si può quindi semplificare la scrittura della view procedendo in due fasi.

Nella prima fase si rendono disponibili gli importi degli ordini e dei pagamenti:
```SQL
CREATE OR REPLACE VIEW customersOrdersPayments AS
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
    ) AS ordini
FROM customers c;
```

Nella seconda fase si aggiunge il saldo, basandoci sulla view precedente:
```SQL
CREATE OR REPLACE VIEW customersBalance AS
SELECT c.*,
    pagamenti - ordini AS saldo
FROM customersOrdersPayments c;
```

Otteniamo una view esattamente equivalente alla precedente, ma più semplice da gestire, comprendere e modificare.

Si noti che interrogando questa view, per il clienti che non hanno effettuato ordini o pagamenti, alcuni importi risultano NULL: è però sufficiente modificare la prima view per correggere il problema.

Se si volesse, ad esempio, considerare solo l'importo degli ordini già spediti sarebbe possibile anche in questo caso modificare solo la prima view.

Ad esempio:
```SQL
CREATE OR REPLACE VIEW customersOrdersPayments AS
SELECT c.*,
    IFNULL(
        (
            SELECT SUM(amount)
            FROM payments p
            WHERE p.customerNumber = c.customerNumber
        ),
        0
    ) AS pagamenti,
    IFNULL(
        (
            SELECT SUM(quantityOrdered * priceEach)
            FROM orderdetails
                JOIN orders o USING (orderNumber)
            WHERE o.customerNumber = c.customerNumber
                AND o.shippedDate IS NOT NULL
        ),
        0
    ) AS ordini
FROM customers c;
```

La modifica si riflette automaticamente sulla seconda view.

### Controllo dell'accesso ai dati
Sovente lo stesso database è utilizzato da più applicazioni rivolte a diverse categorie di utenti.
Nell'esempio di classicmodels, potrebbero esserci:
* clienti che vogliono consultare il listino o lo stato dei propri ordini
* venditori che inseriscono gli ordini e i prodotti
* magazzinieri che modificano alcuni dati di ordini e prodotti
* altro...

Sebbene le autorizzazioni possano essere gestite a livello applicativo, imporre dei limiti tramite il database garantisce una maggiore sicurezza ed una semplificazione della logica dell'applicazione.

Si possono quindi creare delle views specifiche per determinate categorie di utenti applicativi, con operazioni e dati limitate a seconda delle esigenze.

Ad esempio, per i clienti che desiderano consultare il listino è sufficiente l'accesso ad una view come la seguente anziché all'intera tabella products:
```SQL
CREATE OR REPLACE VIEW productsForCustomer AS
SELECT productCode,
    productName,
    productLine,
    productScale,
    productDescription,
    (quantityInStock > 0) AS available,
    MSRP
FROM products
GROUP BY productCode;
```
> Si noti che in questo caso è stata utilizzata la clausola ``GROUP BY``, che non ha effetto sul risultato essendo productCode primary key, allo scopo di rendere la view utilizzabile solo per la lettura e non per la modifica; la cosa ovviamente potrebbe essere gestita tramite i privilegi utente. 

### Imposizione di vincoli non banali

Alcuni vincoli, che dipendono dai valori di una riga di una tabella, possono essere aggiunti alla tabella stessa tramite la clausola ``CHECK(espresione)``.

Ma le espressioni di calcolo della clausola ``CHECK`` non consentono l'istruzione ``SELECT`` e quindi le possibilità sono limitate.

Tale limitazione non esiste ovviamente nella clausola ``WHERE`` di una istruzione ``SELECT``, che può verificare la validità di un vincolo anche tramite subquery complesse.

Usando la clausola ``WITH CHECK OPTION`` nella creazione della view, la clausola ``WHERE`` presente agisce come un vincolo per le operazioni di modifica dei dati tramite la view.

Ad esempio, la view:
```SQL
CREATE OR REPLACE VIEW validdetails AS
SELECT d.*
FROM orderdetails d
WHERE quantityOrdered <= (
        SELECT quantityInStock
        FROM products p
        WHERE p.productCode = d.productCode
    )
WITH CHECK OPTION;
```
consente operazioni di modifica dei dati della tabella sottostante (orderdetails) ma solo se le operazioni non violano il vincolo (implicitamente) presente nella clausola ``WHERE``.

> Si noti però che il vincolo può essere violato (oltre che agendo direttamente sulla tabella orderdetails) modificando i dati delle tabelle da cui il vincolo dipende (nell'esempio, products.quantityInStock).

## Note su alcune opzioni facoltative
### Opzione ``ALGORITHM``
Tramite l'opzione ``ALGORITHM`` si può chiedere al DBMS di implementare la view in modo specifico.

Tipicamente si usa il valore di default *UNDEFINED* che permette al DBMS di scegliere (in modo ottimizzato) l'implementazione.
### Opzione ``DEFINER``
Tramite l'opzione ``DEFINER`` si può indicare al DBMS quale profilo utente ha definito la view.

Tipicamente si usa in combinazione con la successiva opzione.
### Opzione ``SQL SECURITY``
Tramite l'opzione ``SQL SECURITY`` si può indicare al DBMS quali privilegi considerare per l'utilizzo della view.
Sono disponibili i valori:
* ``DEFINER``: privilegi dell'utente indicato tramite l'opzione ``DEFINER``
* ``INVOKER``: privilegi dell'utente che esegue l'istruzione che utilizza la view

## Osservazioni finali
Si noti che l'utilizzo di view non è in genere particolarmente penalizzante dal punto di vista delle prestazioni, benchè contengano dati calcolati in modo complesso, qualora questi dati non siano richiesti dall'istruzione che viene eseguita.

Si può verificare, ad esempio, con una view come la seguente:
```SQL
CREATE OR REPLACE VIEW performance AS
SELECT p.*,
    SLEEP(1) AS delay
FROM products p;
```
dove la funzione SLEEP è usata per simulare un calcolo particolarmente complesso.
L'esecuzione di una ``SELECT`` tramite la view è rallentata solo se si richiede il valore di delay:
```SQL
SELECT delay
FROM performance; -- 112 rows in set (1 min 52.013 sec)
```
altrimenti no:
```SQL
SELECT productCode,
    productLine,
    quantityInStock
FROM performance; -- 112 rows in set (0.001 sec)
```

