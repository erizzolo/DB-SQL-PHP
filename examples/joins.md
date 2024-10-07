# Joins
Le operazioni di *join* permettono di estrarre dati da più tabelle collegando logicamente le righe delle diverse tabelle, tipicamente secondo le regole *strutturali* del database ma anche secondo regole particolari.

In genere, separando la logica *strutturale* del database dalle condizioni specifiche della *singola query*, rendono le query più leggibili e più facilmente modificabili, rendendo minore la possibilità di errori.

Molto spesso l'utilizzo di *subqueries* può essere evitato tramite l'utilizzo di opprtune espressioni di *join*.

Vi sono tre tipi di *join*, di cui sono fondamentali gli ultimi due:

* **CROSS**: equivale al prodotto cartesiano
* **INNER**: di gran lunga il più usato
* **OUTER**: quando interessano dati senza corrispondenza

> Si utilizzeranno i seguenti simboli:
>
> LT: (left table) tabella a sinistra del *join*
>
> RT: (right table) tabella a destra del *join*
>
> L: numero di righe in LT
>
> R: numero di righe in RT
 
La sintassi generale è del tipo:
```LT <tipo join> RT```.
> Si noti che LT e RT possono essere la stessa tabella!
## ```CROSS JOIN```
È il *join* meno utilizzato, perché non produce altro che il prodotto cartesiano delle due tabelle, ovvero una tabella con **L x R** righe formate dalla concatenazione di una riga di LT ed una di RT, per tutte le combinazioni possibili.

L'espressione ```LT CROSS JOIN RT``` equivale a ```LT, RT```.

Si utilizza **solo** in casi particolari, perché le combinazioni sono nella maggior parte dei casi **non significative**.

Ad esempio:

```SELECT first.*, second.* FROM actor first CROSS JOIN actor second;```

Produce un elenco di tutte le possibili coppie (ordinate) di attori, anche quelle di un attore con se stesso!

## ```INNER JOIN```
È il *join* più utilizzato, perché permette di specificare le condizioni per cui una riga di LT ed una di RT formano una combinazioni logicamente valida.

Produce una tabella con righe formate dalla concatenazione di una riga di LT ed una di RT ma solo le combinazioni che soddisfano la condizione di validità.

L'espressione è tipicamente ```LT JOIN RT <condizione>```.
> Si noti che la keyword ```INNER``` si può omettere.
> 
> Si noti che la ```<condizione>``` è facoltativa e se omessa equivale a ```TRUE``` (ovvero il *join* equivale ad un ```CROSS JOIN```).

La ```<condizione>``` si può specificare in diversi modi:
* ```ON (espressione logica)```: seleziona le combinazioni per cui *espressione logica* è vera.
* ```USING (lista attributi)```: equivale a ```ON ((LT.lista attributi) = (RT.lista attributi))``` ovvero all'uguaglianza della lista di attributi nelle due righe.
* usando la keyword ```NATURAL```: ```LT NATURAL JOIN RT``` equivale a ```LT JOIN RT USING(attributi comuni a LT e RT)```.

Ci sono lievi differenze nel risultato: ad esempio, usando ```USING``` o ```NATURAL``` gli attributi utilizzati compaiono una volta sola.

> Personalmente, preferisco ```ON``` perché è più generale, anche se in alcuni casi ```USING``` risulta più comodo.
> 
> Sconsiglio invece il ```NATURAL```: provare con il db sakila per credere ...

L'utilizzo tipico è quello di collegare dati di più tabelle: usando i valori della **primary key** di una tabella e quelli della **foreign key** dell'altra tabella.
Quindi la condizione diventa (assumendo che il campo di collegamento sia la primary key di LT e la corrispondente foreign key di RT):

```LT JOIN RT ON(LT.primary_key = RT.foreign_key)```

oppure (assumendo che il campo di collegamento sia la primary key di RT e la corrispondente foreign key di LT):

```LT JOIN RT ON(RT.primary_key = LT.foreign_key)```.

Ad esempio, per le tabelle city e country:
```SQL
SHOW CREATE TABLE country;
... PRIMARY KEY (country_id) ...
SHOW CREATE TABLE city;
... FOREIGN KEY (country_id) REFERENCES country (country_id) ...
```

Il tipico *join* sarà:

```SQL
SELECT city, country
    FROM city JOIN country USING(country_id);
```

ovvero

```SQL
SELECT city, country
    FROM country JOIN city USING(country_id);
```

che produce qualcosa del genere:
| city   | country        |
| ------ | -------------- |
| Kabul  | Afghanistan    |
| Batna  | Algeria        |
| Bchar  | Algeria        |
| Skikda | Algeria        |
| Tafuna | American Samoa |
| ...    | ...            |

Ad una espressione di *join* si può aggiungere un altro *join* e così via per collegare più tabelle.

Ad esempio, per le tabelle film, film_actor ed actor:
```SQL
SHOW CREATE TABLE film;
... PRIMARY KEY (film_id) ...
SHOW CREATE TABLE actor;
... PRIMARY KEY (actor_id) ...
SHOW CREATE TABLE film_actor;
... FOREIGN KEY (actor_id) REFERENCES actor (actor_id) ...
... FOREIGN KEY (film_id) REFERENCES film (film_id) ...
```

Il tipico *join* sarà:

```SQL
SELECT title, last_name, first_name
    FROM film
        JOIN film_actor USING(film_id)
        JOIN actor USING(actor_id);
```

che produce qualcosa del genere (film e attori che vi hanno recitato):
| title                 | last_name | first_name |
| --------------------- | --------- | ---------- |
| ACADEMY DINOSAUR      | GUINESS   | PENELOPE   |
| ANACONDA CONFESSIONS  | GUINESS   | PENELOPE   |
| ANGELS LIFE           | GUINESS   | PENELOPE   |
| ...                   | ...       | ...        |
| ADAPTATION HOLES      | WAHLBERG  | NICK       |
| APACHE DIVINE         | WAHLBERG  | NICK       |
| BABY HALL             | WAHLBERG  | NICK       |
| ...                   | ...       | ...        |

L'```INNER JOIN``` può ovviamente essere usato anche in altri casi particolari.

Ad esempio:
```SQL
SELECT first.*, second.*
    FROM actor first
        JOIN actor second ON(first.actor_id > second.actor_id);
```
Produce un elenco di tutte le possibili coppie di attori, escludendo quelle di un attore con se stesso!

## ```OUTER JOIN```
È un *join* meno utilizzato ma utile perché consente di includere le righe di una tabella (LT o RT) anche quando questa non forma nessuna combinazione valida: ovvero, oltre alle righe prodotte dall'```INNER JOIN```, vi sono delle righe aggiuntive con valori ```NULL``` per la tabella ove mancano corrispondenze.

Vi sono tre casi:
* ```LT LEFT JOIN RT```: seleziona tutte le righe di LT aggiungendo se necessario una di riga di RT con valori ```NULL```.
* ```LT RIGHT JOIN RT```: seleziona tutte le righe di RT aggiungendo se necessario una di riga di LT con valori ```NULL```.
* ```LT FULL JOIN RT```: seleziona tutte le righe di RT e di LT aggiungendo se necessario la riga mancante con valori ```NULL```.
> MariaDB non fornisce supporto al ```FULL JOIN```!

Viene spesso usato quando si vogliono includere le righe cui manca una corrispondenza, e talvolta proprio per queste.

> Si noti che la keyword ```OUTER``` si può omettere.
> 
> Si noti che la ```<condizione>``` è **obbligatoria**.

Ad esempio, per elencare i film con i relativi attori, includendo i film in cui non ha recitato nessun attore:
```SQL
SELECT title, IFNULL(GROUP_CONCAT(CONCAT(last_name, ' ', first_name), ', '), 'N/A') AS cast
    FROM film
        LEFT JOIN film_actor USING(film_id)
        LEFT JOIN actor USING(actor_id)
    GROUP BY film_id
    ORDER BY title;
```
ovvero per elencare i film in cui non ha recitato nessun attore:
```SQL
SELECT title
    FROM film
        LEFT JOIN film_actor USING(film_id)
    WHERE actor_id IS NULL
    ORDER BY title;
```

## Osservazioni
In molti (vecchi) esempi si trovano queries in cui l'operazione di *join* viene eseguita sfruttando la clausola ```WHERE```.

Ad esempio, la query
```SQL
SELECT city, country
    FROM country JOIN city USING(country_id);
```
viene scritta come
```SQL
SELECT city, country
    FROM country, city
    WHERE city.country_id = country.country_id;
```
Il risultato delle due query è lo stesso ma è preferibile usare l'espressione ```JOIN```:
* si mantiene distinta la logica del database (```JOIN```) da quella della query (```WHERE```)
* si rende più leggibile la condizione della query (```WHERE```)
* si facilita la modifica quando ad esempio si trasforma un ```INNER JOIN``` in un ```OUTER JOIN```
