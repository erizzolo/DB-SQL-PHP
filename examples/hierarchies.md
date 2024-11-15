## Trasformazione gerarchie is-a

Nel modello **relazionale** non sono possibili gerarchie is-a, quindi è necessario trasformarle utilizzando altri costrutti.

Sono possibili tre opzioni (o meglio quattro!):
1. trasferimento (di attributi e associazioni) nell'entità generica
2. trasferimento (di attributi e associazioni) nelle entità specifiche
3. trasformazione in associazioni tra entità generica e specifiche
4. combinazione delle precedenti

Ricordiamo che le gerarchie is-a implementano l'ereditarità della OOP quindi le entità specifiche (*child entities* ovvero *subtypes*) **ereditano** gli attributi (ed in particolare gli **identificatori**) ed altro (metodi?!, *associazioni*, ...) dall'entità generica (*parent entity* ovvero *supertype*).

### Trasferimento (di attributi e associazioni) nell'entità generica
Questa trasformazione è sempre possibile e consiste in:

* spostamento degli attributi dalle entità specifiche all'entità generica, con cardinalità minima 0: *opzionali*
* spostamento delle associazioni dalle entità specifiche all'entità generica, con cardinalità minima 0: *opzionali*
* aggiunta di un attributo *tipo* all'entità generica (opzionale se la gerarchia è parziale, multivalore se la gerarchia è sovrapposta)
* eliminazione delle entità specifiche

In genere è conveniente se le entità specifiche hanno poche operazioni differenti...

### Trasferimento (di attributi e associazioni) nelle entità specifiche
Questa trasformazione è possibile **soltanto se** la specializzazione è **totale** (altrimenti si perdono informazioni!) e consiste in:

* spostamento degli attributi dall'entità generica alle entità specifiche
* spostamento delle associazioni dall'entità generica alle entità specifiche
* eliminazione dell'entità generica

In genere è conveniente se le entità specifiche hanno molte operazioni differenti e la duplicazione degli attributi e delle associazioni generiche non è penalizzante...

> **Attenzione** ai vincoli di congruenza quando la gerarchia è sovrapposta: gli attributi dell'entità generica possono essere duplicati (gestione ridondanza...)!

### Trasformazione in associazioni tra entità generica e specifiche
Questa trasformazione è sempre possibile e consiste in:

* sostituzione dei legami di ereditarietà con associazioni

Le cardinalità di tali associazioni sono, per l'entità generica:

* minima 0 se gerarchia parziale, 1 se totale
* massima 1 se gerarchia disgiunta, N se sovrapposta

per l'entità specifica, **sempre**:

* minima 1
* massima 1

quindi **identificante**!!!

In genere è conveniente se l'opzione precedente non è applicabile (gerarchia non totale) e le entità specifiche hanno operazioni differenti.

### Combinazione delle precedenti

E' in generale possibile combinare le diverse opzioni precedenti, ovvero usare opzioni diverse per diverse entità specifiche...

[back to restructuring](restructuring.md)