## Partizionamento o fusione di entità ed associazioni

Può essere utili suddividere oppure fondere entità/associazioni.

Comuni criteri per la suddivisione (partizionamento) possono essere:
* logici (ad es. dati anagrafici/lavorativi/altro ambito...) quindi possibilmente utili/significativi per diversi ambiti applicativi
* temporali (ad es. dati attuali, passati, futuri) quindi più o meno utilizzati per ricerche/statistiche/consultazioni
* spaziali (ad es. dati di differenti ambiti geografici, di maggiore o minore interesse per situazioni/lingue/utenti)

Con criteri simili si possono fondere entità ed associazioni strettamente collegate tra loro, tipicamnete se tra le entità da fondere esiste un'associazione uno a uno, ovvero quando i legami rappresentati dalle associazioni sono spesso/sempre collegati.

>Si noti che la suddivisione/fusione può avere un grande impatto sulle prestazioni delle operazioni.

Come *esempio*, si considerino le entità *Prodotto* e *Cliente* e le associazioni tra esse *Acquisto* e *Giudizio*, si potrebbero accorpare *Acquisto* e *Giudizio* poichè probabilmente hanno senso solo congiuntamente.

Come *esempio*, si consideri il caso di un sito di annunci immobiliari:

1. le ricerche effettuate dagli utenti del sito sono in genere *frequenti* (molte al giorno) e relative agli annunci ancora validi
2. a scopi statistici (e non solo) è comunque utile mantenere anche gli annunci ormai *archiviati* dagli inserzionisti, che magari saranno consultati *raramente*

La separazione tra annunci "attuali" ed "archiviati" contribuisce all'efficienza delle ricerche di tipo 1. e non penalizza eccessivamente quelle di tipo 2.

[back to restructuring](restructuring.md)