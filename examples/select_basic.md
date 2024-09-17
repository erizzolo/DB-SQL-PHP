# ```SELECT``` statement
L'istruzione ```SELECT``` è parte fondamentale del DML (*Data Manipulation Language*) e può essere relativamente complessa, consentendo elaborazioni dei dati molto articolate e raffinate.

Essa restituisce una *tabella* con una riga di intestazione ed un numero variabile di righe di dati.

In questo documento considereremo soltanto alcune delle possibilità ed utilizzeremo il [DB sakila](https://dev.mysql.com/doc/sakila/en/) per gli esempi.

## Minimal ```SELECT``` statement
Le parti obbligatoriamente presenti sono:
* la keyword ```SELECT```
* una lista non vuota di espressioni (separate da ',')

Ad esempio:

```SELECT 'Ciao';```

Questa forma di ```SELECT``` restituisce una tabella con una sola riga di dati (i valori delle espressioni) ed una colonna per ciascuna delle espressioni nella lista (nell'esempio una).

Nella lista il nome delle espressioni (in genere corrispondente all'espressione stessa) può essere modificato usando ```AS nuovo_nome``` dopo l'espressione.

Ad esempio:

```SELECT 'Ciao' AS saluto, EXP(1) AS 'numero di Nepero';```

La ridenominazione risulterà utile quando occorrerà fare riferimento all'espressione in altre parti dell'istruzione.

Naturalmente questa forma minimale non è molto utilizzata: di norma si recuperano dati da (almeno) una tabella.

## ```FROM``` clause

Per specificare le tabelle da cui recuperare i dati, si utilizza la clausola ```FROM``` che nella forma più semplice è costituita da:
* la keyword ```FROM```
* una lista non vuota di nomi di tabelle/views

Per ora ci limiteremo al caso di una sola tabella/view.

Ad esempio:

```SELECT actor_id, CONCAT(first_name,' ', last_name) AS name FROM actor;```

Questa forma di ```SELECT``` restituisce una tabella con tante righe di dati quante sono le righe nella tabella indicata.

Per ciascuna riga della tabella vengono valutate le espressioni che ora possono comprendere i nomi delle colonne della tabella.

Raramente ci interessano tutte le possibili righe e quindi possiamo indicare un criterio in base al quale includere la riga nel risultato oppure escluderla,

## ```WHERE``` clause

Per specificare il criterio di selezione si usa la clausola ```WHERE``` che è costituita da:
* la keyword ```WHERE```
* una condizione che dev'essere verificata affinché la riga sia inclusa nel risultato

Ad esempio:

```SELECT actor_id, CONCAT(first_name,' ', last_name) AS name FROM actor WHERE first_name = 'John';```

Questa istruzione restituisce una tabella con una riga per ciascun attore il cui nome è 'John'.

> Si noti che il confronto tra stringhe è in generale *case unsensitive*.

Come si vede dall'esempio, l'espressione della clausola WHERE deve essere valutabile ma può fare riferimento a dati non presenti nell'output.

Si possono creare condizioni complesse usando parentesi ed operatori logici quali ```NOT```, ```AND```, ```OR```, ```XOR``` oppure ```!```, ```&&```, ```||```.

### Operatore ```LIKE```

L'operatore ```LIKE``` verifica se una stringa corrisponde o meno ad un *pattern* che può comprendere i caratteri speciali:

* % corrisponde a un qualsiasi numero di caratteri, anche zero.
* _ corrisponde a un singolo carattere.

Utilizzi tipici:

* espressione ```LIKE 'A%'```: l'espressione inizia per 'A'
* espressione ```LIKE '%A'```: l'espressione finisce per 'A'
* espressione ```LIKE '%A%'```: l'espressione contiene 'A'


### Operatore ```BETWEEN```

L'operatore ```BETWEEN``` verifica se una espressione appartiene ad un intervallo definito dagli estremi inferiore e superiore (compresi)

Utilizzo tipico:

* espressione ```BETWEEN minimo AND massimo```

## ```ORDER BY``` clause

Per specificare il criterio di ordinamento con cui saranno restituite le righe si usa la clausola ```ORDER BY``` che è costituita da:
* la keyword ```ORDER BY```
* lista non vuota di espressioni (criteri di ordinamento, in ordine di importanza decrescente)

L'ordinamento è per default crescente, ma si può specificare ```DESC``` dopo l'espressione per ottenere l'ordine decrescente.

Ad esempio:

```SELECT actor_id, CONCAT(first_name,' ', last_name) AS name FROM actor ORDER BY name, actor_id DESC;```

Come si vede dall'esempio, nella clausola ```ORDER BY``` è possibile utilizzare i nomi assegnati alle espressioni precedenti per evitare di ripeterle.

## ```LIMIT``` clause

Per limitare il numero di righe che saranno restituite dall'istruzione si può usare la clausola ```LIMIT``` che si può usare nelle forme:
* ```LIMIT count```: limita l'output a *count* righe
* ```LIMIT offset, count```: limita l'output a *count* righe, ignorando *offset* righe
* ```LIMIT count OFFSET offset```: limita l'output a *count* righe, ignorando *offset* righe

Ad esempio:

```SELECT actor_id, CONCAT(first_name,' ', last_name) AS name FROM actor ORDER BY name, actor_id DESC LIMIT 10, 5;```


