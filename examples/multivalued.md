## Trasformazione attributi multipli

Nel modello **relazionale** non sono possibili attributi multipli, quindi è necessario trasformare l'attributo in una ulteriore entità, legata all'entità originaria da un'associazione.

Le cardinalità di tali associazioni sono, per l'entità originaria:

* minima 0 se attributo facoltativo, 1 se obbligatorio (i.e. le stesse che aveva l'attributo)
* massima N, ovviamente

per l'entità derivata dall'attributo:

* minima 1 (altrimenti l'istanza non avrebbe senso)
* massima 1 o N a seconda dei casi (attributo potenzialmente identificante come e-mail, numero telefonico cellulare oppure no)

>Attenzione che l'introduzione di un'associazione *molti a molti* è in genere utile solo se si voglio codificare i possibili valori dell'attributo.

Come *esempio*, si consideri l'attributo *numero di cellulare* di una persona:
* esso: è potenzialmente identificante, quindi univoco nel database.

L'entità *Persona* partecipa con cardinalità X:N all'associazione *ProprietarioSIM*.

L'entità-attributo *Cellulare* partecipa con cardinalità 1:1 all'associazione *ProprietarioSIM*.

Come *esempio*, si consideri l'attributo *sport praticato* di una persona:
* esso non è identificante, quindi multiplo nel database.

Vi sono due possibilità:
1. voglio codificare i valori assunti (ad esempio per evitare 'hockey', 'hocky' e 'ockey' per lo stesso sport)
2. non mi interessa codificare i valori

In entrambi i casi:

>l'entità *Persona* partecipa con cardinalità X:N all'associazione *Pratica*.

ma nel caso:
1. l'entità *Sport* partecipa con cardinalità 1:N all'associazione *Pratica* (molti a molti).

2. l'entità *Sport* partecipa con cardinalità 1:1 all'associazione *Pratica* (uno a molti, identificante).

[back to restructuring](restructuring.md)