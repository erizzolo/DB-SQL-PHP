# Restructuring an E/R diagram
Come fase iniziale della progettazione logica, è possibile/consigliabile ristrutturare il diagramma E/R per meglio adattarlo al modello logico scelto (nel nostro caso, *forzatamente* il modello **relazionale**).

Nel modello **relazionale** infatti non sono possibili attributi multipli, né gerarchie is-a, né ...

> Per ottenere un risultato ottimale sarebbe opportuno conoscere (o *ipotizzare*) quale sarà il carico di lavoro che il nostro database dovrà gestire (volume dei dati, operazioni previste e loro frequenza, ...) per poter effettuare scelte **motivate**.

In generale, i passi da compiere (non necessariamente nell'ordine e magari ciclicamente) sono:
* [analisi ridondanze](redundancies.md)
* [trasformazione gerarchie is-a](hierarchies.md)
* [trasformazione attributi multipli](multivalued.md)
* [partizionamento o fusione di entità ed associazioni](partitioning.md)
* [analisi delle chiavi e scelta della chiave primaria](identifiers.md)
* [ulteriori considerazioni](further.md)
