## Analisi ridondanze

In una base di dati vi sono dei dati (detti *derivati* o *calcolati*) che si possono ottenere elaborandone altri.

Gli esempi sono infiniti:

* età attuale di una persona, nota la data di nascita e quella attuale (e.g. 60 anni,... dati 1964-10-18 e 2024-11-11)
* data di nascita di una persona, dato il codice fiscale (*con ipotesi sul secolo!!!*)
* da peso lordo = peso netto + tara:
  * peso lordo, dati peso netto e tara (e.g. 6.2 kg = 6.0 kg + 0.2 kg)
  * peso netto, dati peso lordo e tara (e.g. 6.0 kg = 6.2 kg - 0.2 kg)
  * tara, dati peso netto e peso lordo (e.g. 0.2 kg = 6.2 kg - 6.0 kg)
* importo IVA, dati imponibile ed aliquota
* numero di residenti in una città, note le città di residenza della popolazione
* media dei voti di uno studente, dati i voti

et cetera, et cetera, ...

Ogni dato *derivato* o *calcolato* costituisce, se memorizzato, una **ridondanza** nella base di dati, e cioé un dato:

* superfluo in quanto ottenibile in altro modo
* possibilmente incongruo, se diverso da quanto ottenibile in altro modo
* utile in quanto immediatamente disponibile

**Memorizzare** un dato *derivato* o *calcolato* comporta:

* un maggiore utilizzo di spazio di memoria (-)
* il minor tempo di accesso al dato quando serve (+)
* la necessità di mantenerlo coerente con i dati da cui deriva, quando essi sono modificati (-) 

**NON memorizzare** un dato *derivato* o *calcolato* comporta:

* un minore utilizzo di spazio di memoria (+)
* un maggior tempo di accesso al dato quando serve (-)
* la certezza della coerenza con i dati da cui deriva (+) 

Il bilancio tra vantaggi (+) e svantaggi (-) dipende dalla complessità di elaborazione necessaria per ottenere il dato, dalla frequenza del suo utilizzo, dalla frequenza degli aggiornamenti dei dati su cui l'elaborazione si basa, ...

Come *esempio*, si consideri la classifica del campionato di calcio; essa:

* varia quando si giocano delle partite (in genere una volta alla settimana)
* il calcolo comporta l'analisi di tutte le partite già giocate da tutte le squadre, con tempi di risposta potenzialmente
  inaccettabili per gli utenti che la richiedono
* viene consultata *spesso* (almeno settimanalmente) da tutti i tifosi
* ...

direi che è il caso di memorizzarla...

Come *esempio*, si consideri l'età degli studenti per il registro elettronico; essa:

* varia quando essi compiono gli anni (in genere qualcuno ogni giorno)
* il calcolo è abbastanza banale (**ma non troppo!!!** quindi provate a farlo...)
* viene consultata *molto di rado* (quando devono giustificare ed il docente ha dei dubbi...)
* ...

direi che è il caso di NON memorizzarla...

[back to restructuring](restructuring.md)