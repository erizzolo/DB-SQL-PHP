# Translation of E/R diagram to relational schema
Prima di procedere ad un esempio di traduzione di una schema E/R, vediamone i principi generali, che possono essere leggermente diversi a seconda della ristrutturazione effettuata dello schema.

I passi da compiere sono in generale:
* traduzione entità
* traduzione associazioni N:M, 1:N ed 1:1 (+ eventuali attributi multipli)
* eventuali ottimizzazioni/varianti/altri vincoli

## Traduzione delle entità
Le entità danno origine ad una tabella, tipicamente con lo stesso nome dell'entità, avente come colonne gli attributi (non multipli) dell'entità.

> In questa fase si possono ignorare le associazione cui l'entità partecipa e tradurle successivamente.

> È bene definire subito i vincoli che non richiedono altre tabelle, tipicamente quindi vincoli di dominio, di tupla, di chiave primaria e di chiave candidata.

> Fanno eccezione le entità con identificatori esterni: in questo caso è opportuno inserire anche tali identificatori nella tabella ed aggiungere il vincolo di chiave esterna con riferimento al campo della tabella dell'entità identificante (che si suppone già creata).

> Si noti che questo è un caso particolare di traduzione di un'associazione 1:N, nel quale la chiave primaria dell'entità che partecipa con cardinalità massima N, inserita come chiave esterna nella tabella dell'entità che partecipa con cardinalità massima 1, diventa parte della chiave primaria di quest'ultima.

## Traduzione delle associazioni N:M
Le associazioni N:M danno origine ad una ulteriore tabella, tipicamente con lo stesso nome dell'associazione, avente come colonne le chiavi primarie delle entità partecipanti (con il rispettivo vincolo di chiave esterna) e gli attributi propri dell'associazione.

La tabella risulta quindi così composta:
1. chiavi primarie delle entità partecipanti (con vincolo di FOREIGN KEY)
   * chiave primaria dell'entità 1 (con vincolo di FOREIGN KEY)
   * chiave primaria dell'entità 2 (con vincolo di FOREIGN KEY)
   * ... per le altre entità partecipanti
2. eventuali attributi identificanti dell'associazione
3. eventuali altri attributi dell'associazione (possibilmente NULL se opzionali)

La chiave primaria della tabella è costituita dall'insieme di 1. e 2., ovvero dall'insieme delle chiavi esterne ed eventuali attributi identificanti dell'associazione.

In genere va motivata la scelta degli attributi identificanti (2.).

> Questo è un caso generale a cui si possono ricondurre anche quelli delle associazioni 1:N e 1:1.

## Traduzione delle associazioni 1:N
Le associazioni 1:N, come già visto, non danno necessariamente origine ad una ulteriore tabella, anche se questa possibilità può essere presa in considerazione per casi particolari (opportunamente **motivati**).

Tipicamente esse sono tradotte inserendo come chiave esterna, nella tabella dell'entità che partecipa con cardinalità massima 1:
1. chiave primaria dell'entità che partecipa con cardinalità massima N (con vincolo di FOREIGN KEY)
2. eventuali attributi (necessariamente non identificanti) dell'associazione

Se la cardinalità (per l'entità nella cui tabella è inserita la chiave esterna) è 0:1 (partecipazione opzionale) sia la chiave esterna che gli eventuali attributi divengono opzionali.

Può essere opportuno inserire dei vincoli aggiuntivi affinchè tutti gli attributi inseriti siano NULL o non lo sia nessuno.

Naturalmente si può, in generale, inserire i campi ed i vincoli direttamente in fase di creazione della tabella.

Una strada alternativa, in alcuni casi più efficiente o conveniente (ma da **motivare**), è quella di creare comunque una tabella aggiuntiva, così composta:
1. chiave primaria dell'entità che partecipa con cardinalità massima 1 (con vincolo di FOREIGN KEY)
2. chiave primaria dell'entità che partecipa con cardinalità massima N (con vincolo di FOREIGN KEY)
3. eventuali attributi (necessariamente non identificanti) dell'associazione

La chiave primaria della tabella è costituita soltanto da 1., ovvero dalla chiave primaria dell'entità con partecipazione singola.

Questa scelta può risultare migliore quando:
* l'associazione è poco utilizzata (poche operazioni non frequenti);
* la percentuale di istanze che partecipano è limitata.

## Traduzione delle associazioni 1:1
Le associazioni 1:1, come già visto per le 1:N, non danno necessariamente origine ad una ulteriore tabella, anche se questa possibilità può essere presa in considerazione per casi particolari.

Tipicamente esse sono tradotte inserendo come le associazioni 1:N, scegliendo quale entità considerare come lato 1, ed **aggiungendo un vincolo di unicità per la chiave esterna inserita**.

Tipicamente si sceglierà per l'inserimento l'entità con partecipazione obbligatoria, oppure quella con la chiave primaria più complessa.

Scelta l'entità in cui aggiungere colonne e vincoli, si inseriscono:
1. chiave primaria dell'altra entità (con vincolo di FOREIGN KEY e **UNIQUE**)
2. eventuali attributi (necessariamente non identificanti) dell'associazione

Se la cardinalità (per l'entità nella cui tabella è inserita la chiave esterna) è 0:1 (partecipazione opzionale) sia la chiave esterna che gli eventuali attributi divengono opzionali.

Può essere opportuno inserire dei vincoli aggiuntivi affinchè tutti gli attributi inseriti siano NULL o non lo sia nessuno.

## Eventuali ottimizzazioni/varianti/altri vincoli
Si possono introdurre ottimizzazioni/varianti oppure introdurre vincoli previsti dalle *Business Rules* non esplicitate dal modello E/R.

In generale ciò può essere considerato attinente alla progettazione *fisica* più che a quella *logica*, ma i confini, se esistenti, sono piuttosto labili (**come sempre**).

## Esempio
Si veda il seguente esempio: [translation example](company/translation_example.md)