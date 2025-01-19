# Subqueries
Una *subquery* non è altro che una *query* (istruzione di selezione dati) annidata in un'altra *query*.

Le *subqueries* sono spesso usate nella clausola ```WHERE``` ma, restituendo comunque una *tabella* di dati, possono anche essere usate nella clausola ```FROM``` (assegnandovi in questo caso un nome identificativo, cioè un alias).

Vi sono tre tipi di *subqueries* a seconda del numero di righe/colonne che la *subquery* restituisce:

* **scalare**: un singolo dato (una riga, una colonna)
* **di riga**: una singola riga (una riga, una o più colonne)
* **di tabella**: una o più righe (una o più righe, una o più colonne)

Con le *subqueries* si usano spesso operatori particolari, quali ```IN```, ```ANY``` = ```SOME```, ```ALL```, ```EXISTS```.

In questo documento considereremo soltanto alcune delle possibilità ed utilizzeremo il DB sakila per gli esempi.

## Scalar subqueries
È la forma più semplice di *subquery*, che restituisce un singolo valore e può essere usata nella quasi totalità dei casi in cui si puù usare una costante o un singolo dato.

Ad esempio:
* ```SELECT MAX(amount) FROM payment;```
* ```SELECT MAX(length) FROM film;```
* ```SELECT AVG(length) FROM film;```
* ```SELECT title FROM film WHERE film_id = 27;```
* ```SELECT first_name FROM actor WHERE actor_id = 101;```

Queste *subqueries* si possono usare, ad esempio, così:

* Pagamenti di importo massimo: ```SELECT * FROM payment WHERE amount = (SELECT MAX(amount) FROM payment);```
* Titolo dei film di lunghezza massima: ```SELECT title FROM film WHERE length = (SELECT MAX(length) FROM film);```
* Titolo e percentuale di durata rispetto al massimo dei film: ```SELECT title, length / (SELECT MAX(length) FROM film) AS 'Percent of maximum length' FROM film;```
* Film di durata superiore alla media: ```SELECT * FROM film WHERE length > (SELECT AVG(length) FROM film);```
* Film con titolo uguale a quello del film con id 27: ```SELECT * FROM film WHERE title = ( SELECT title FROM film WHERE film_id = 27);```
* Attori con nome uguale a quello dell'attore con id 101: ```SELECT * FROM actor WHERE first_name = (SELECT first_name FROM actor WHERE actor_id = 101);```

> ATTENZIONE: quando una *scalar subquery* non trova nessun dato, restituisce ```NULL```.

## Row subqueries
Una *row subquery* restituisce in una unica riga più valori di tipo possibilmente diverso. Può essere utilizzata per confrontare più valori contemporaneamente.

Ad esempio:
* ```SELECT last_name, first_name FROM actor WHERE actor_id = 101;```

Queste *subqueries* si possono usare, ad esempio, così:

> Si noti l'uso delle parentesi.

* Omonimi dell'attore con id 101: ```SELECT * FROM actor WHERE (last_name, first_name) = (SELECT last_name, first_name FROM actor WHERE actor_id = 101);```
* Attori successivi in ordine alfabetico rispetto all'attore con id 101: ```SELECT * FROM actor WHERE (last_name, first_name) > (SELECT last_name, first_name FROM actor WHERE actor_id = 101);```

## Table subqueries
È la forma più generica di *subquery*, che può restituire una tabella con più colonne e più righe.

> Si noti che, mentre il numero di colonne è pari al numero di espressioni specificati dopo la keyword ```SELECT```, e quindi **noto** ed **indipendente** dai dati effettivamente presenti nel database, il numero di righe è **variabile** e **dipendente** dai dati effettivamente presenti nel database!

Con questo tipo di *subqueries* si usano spesso operatori particolari, quali ```IN```, ```ANY``` = ```SOME```, ```ALL```, ```EXISTS```.

### Operator ```IN```
Si usa nella forma: *espressione* IN (*lista di valori*)

Restituisce vero se *espressione* risulta uguale ad (almeno) uno dei valori presenti nella lista.

Ad esempio:

```(5+4) IN (3, 8, 9, 10, NULL)``` restituisce ```TRUE```

>Attenzione ai valori NULL:
>
>If expr is NULL, IN always returns NULL. If at least one of the values in the list is NULL, and one of the comparisons is true, the result is 1. If at least one of the values in the list is NULL and none of the comparisons is true, the result is NULL.
>
>Se tra i valori restituiti dalla subquery ci sono dei ```NULL```, ```NOT IN``` **NON** è l'**opposto** di ```IN```!

L'espressione può essere scalare, cioè un singolo dato, o multipla, come ad esempio:
```SQL
SELECT *
    FROM actor
    WHERE (last_name, first_name)
            IN
          (SELECT last_name, first_name
                FROM actor
                WHERE actor_id < 10);
```
restituisce i dati degli attori omonimi degli attori con id < 10.

Oltre che con una subquery, la lista di valori può essere specificata in altri modi; ad esempio:
```SQL
SELECT *
    FROM actor
    WHERE first_name IN ('John', 'Susan', 'Willard');
```
### Operator ```ALL```
Si usa nella forma: *< espressione scalare >* *< operatore di confronto >* ```ALL``` (*column subquery*)

Restituisce vero se *espressione scalare* soddisfa il *confronto* specificato per tutte le righe restituite dalla *subquery* (ad una sola colonna).

>Si noti che se la *subquery* non restituisce righe viene restituito ```TRUE```.

Ad esempio:
```SQL
SELECT payment_id, amount
    FROM payment
    WHERE amount >= ALL (SELECT amount FROM payment);
```
equivale (supponendo che *amount* non possa assumere valore ```NULL```) a:
```SQL
SELECT payment_id, amount
    FROM payment
    WHERE amount = (SELECT MAX(amount) FROM payment);
```

### Operator ```ANY``` = ```SOME```
Si usa nella forma: *< espressione scalare >* *< operatore di confronto >* ```ANY``` (*column subquery*)

Restituisce vero se *espressione scalare* soddisfa il *confronto* specificato per almeno una delle righe restituite dalla *subquery* (ad una sola colonna).

>Si noti che se la *subquery* non restituisce righe viene restituito ```TRUE```.

Ad esempio:
```SQL
SELECT payment_id, amount
    FROM payment
    WHERE amount > ANY (SELECT amount FROM payment);
```
equivale (supponendo che *amount* non possa assumere valore ```NULL```) a:
```SQL
SELECT payment_id, amount
    FROM payment
    WHERE amount != (SELECT MIN(amount) FROM payment);
```

### Operator ```EXISTS```
Si usa nella forma: ```EXISTS``` (*subquery*)

Restituisce vero se *subquery* restituisce almeno una riga.

Ad esempio:
```SQL
SELECT payment_id, amount
    FROM payment p
    WHERE EXISTS (SELECT * FROM payment WHERE amount > p.amount);
```
equivale (supponendo che *amount* non possa assumere valore ```NULL```) a:
```SQL
SELECT payment_id, amount
    FROM payment
    WHERE amount < (SELECT MAX(amount) FROM payment);
```

### Sinonimi e contrari
>Si noti che il *contrario* di un operatore può **NON** dare il risultato opposto se vi sono valori ```NULL```.

| operatore | sinonimo | contrario  |
| --------- | -------- | ---------- |
| ANY       | SOME     |            |
| EXISTS    |          | NOT EXISTS |
| IN        | = ANY    | NOT IN     |
| NOT IN    | <> ALL   | IN         |
| SOME      | ANY      |            |