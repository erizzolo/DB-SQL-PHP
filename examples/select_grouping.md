# ```SELECT``` statement: grouping
L'utilizzo di funzioni di *aggregazione* ([*aggregate functions*](https://mariadb.com/kb/en/aggregate-functions/)) nelle espressioni dell'istruzione ```SELECT``` consente di effettuare su gruppi di righe calcoli che restituiscono un unico valore per ciascun gruppo.

In questo documento considereremo soltanto alcune delle possibilità ed utilizzeremo il DB sakila per gli esempi.

## Aggregate functions with no ```GROUP BY``` clause
Se si usano funzioni di aggregazione senza specificare la clausola ```GROUP BY``` tutte le righe selezionate sono considerate parte di un unico gruppo.

Ad esempio:

```SELECT AVG(actor_id), COUNT(*) FROM actor;```

il risultato sarà:
| AVG(actor_id) | COUNT(*) |
| ------------- | -------- |
| 100.5000      | 200      |

La funzione ```AVG``` restituisce la media aritmetica dei valori dell'espressione fra parentesi, mentre ```COUNT(*)``` restituisce il numero di righe presenti: sappiamo dunque che il numero di righe presenti nella tabella *actor* è 200 e che il valore medio di *actor_id* (cosa non molto significativa, lo ammetto) è 100.5.

Questo può essere utile ma spesso ci interessa raggruppare le righe usando criteri diversi, ed elaborare i diversi gruppi presenti separatamente.

## ```GROUP BY``` clause

Per specificare il criterio di raggruppamento si usa la clausola ```GROUP BY``` che è costituita da:
* la keyword ```GROUP BY```
* una lista di espressioni i cui valori distinguono i gruppi

Ad esempio:

```SELECT first_name, COUNT(*) AS frequency FROM actor GROUP BY first_name;```

Ci permette di contare il numero di attori che hanno un certo *first_name*: per ogni diverso valore dell'espressione *first_name* sarà creato un gruppo e per ciascun gruppo saranno valutate le espressioni ```first_name``` e ```COUNT(*)```.

Le espressioni della clausola ```GROUP BY``` non sono limitate a nomi di colonne; ad esempio:

```SELECT SUBSTR(first_name, 1, 1) AS Initial, COUNT(*) AS frequency FROM actor GROUP BY Initial;```

```SELECT SUBSTR(first_name, 1, 1) AS Initial, COUNT(*) AS frequency FROM actor GROUP BY SUBSTR(first_name, 1, 1);```

ci forniscono il conteggio di attori il cui *first_name* inizia con le diverse lettere.
> Si noti che l'iniziale **Q** non è presente!

La seguente query ci fornirebbe indicazioni sulla presenza di casi di omonimia:

```SELECT CONCAT(first_name,' ', last_name) AS name, COUNT(*) FROM actor GROUP BY first_name, last_name;```

L'output però è di difficile lettura, perché sono presenti tante righe con conteggio pari a 1 corrispondenti ai casi di non omonimia e quindi non interessanti.

> Si noti che per selezionare i gruppi che ci interessano **NON** si può usare la clausola ```WHERE```, che entra in gioco per selezionare le righe e quindi **prima** che siano formati i gruppi.

Ci serve una clausola per filtrare i gruppi!

## ```HAVING``` clause

Per specificare il criterio di selezione dei gruppi si usa la clausola ```HAVING```, molto simile alla ```WHERE```, che è costituita da:
* la keyword ```HAVING```
* una condizione che dev'essere verificata affinché la riga di output relativa al gruppo sia inclusa nel risultato

Ad esempio, per i casi di omonimia:

```SELECT CONCAT(first_name,' ', last_name) AS name, COUNT(*) FROM actor GROUP BY first_name, last_name HAVING COUNT(*) > 1;```

ci dice che l'unico caso di omonimia è quello delle 2 SUSAN DAVIS.

## ```WITH ROLLUP``` clause

La clausola ```WITH ROLLUP``` ci fornisce delle ulteriori righe con dei gruppi aggiuntivi, basati su zero o più delle espressioni specificate nella clausola ```GROUP BY``` (quelle non significative vengono visualizzate come ```NULL```).

Ad esempio:

```SELECT first_name, last_name, COUNT(*) FROM actor GROUP BY first_name, last_name WITH ROLLUP;```

ci consente di vedere anche quanti attori ci sono con uno specifico *first_name* (indipendentemente dal *last_name*: *first_name*, NULL) e quanti attori ci sono in totale (indipendentemente dal *first_name* e dal *last_name*: NULL, NULL).

La seguente query ci consente di sapere il totale dei pagamenti, suddiviso/raggruppato per anno, mese, giorno, nonché i totali parziali per mese, anno ed il totale generale:

```SELECT YEAR(payment_date) AS anno, MONTH(payment_date) AS mese, DAY(payment_date) AS giorno, SUM(amount) AS totale FROM payment GROUP BY anno, mese, giorno WITH ROLLUP;```

> Si noti che la clausola ```GROUP BY``` **implica** un ordinamento, come se fosse implicitamente specificata una clausola ```ORDER BY``` con la medesima lista di espressioni.
>
> È comunque possibile indicare esplicitamente una clausola ```ORDER BY``` con una diversa lista di espressioni, ma in questo caso non è possibile usare contemporaneamente la clausola ```WITH ROLLUP```; ad. es:
>
> ```SELECT YEAR(payment_date) AS anno, MONTH(payment_date) AS mese, DAY(payment_date) AS giorno, SUM(amount) AS totale FROM payment GROUP BY anno, mese, giorno ORDER BY totale;```
## Aggregate functions
Le più utilizzate funzioni di aggregazione sono:
* ```COUNT```: conteggio (vedi dettaglio)
* ```MIN```: valore minimo
* ```MAX```: valore massimo
* ```SUM```: somma dei valori
* ```AVG```: valore medio (media aritmetica)
* ```GROUP_CONCAT```: concatenazione di stringhe

## ```COUNT``` function
La funzione ```COUNT``` permette di contare:
* le righe: ```COUNT(*)```
* i valori non ```NULL```: ```COUNT(espressione)```
* i diversi valori non ```NULL```: ```COUNT(DISTINCT espressione)```
