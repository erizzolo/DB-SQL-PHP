## Analisi delle chiavi e scelta della chiave primaria

Si ricordano alcune definizioni, utilizzando una terminologia già legata al modello relazionale:

#### Superchiave (superkey)
Un insieme di attributi (possibilmente ridondante) che identifica univocamente un'istanza di un'entità (una tupla di una relazione/una riga di una tabella).

#### Chiave candidata (candidate key)
Una superchiave minimale, quindi priva di attributi ridondanti.

#### Chiave primaria (primary key)
La chiave candidata scelta come ottimale.

### Scelta della chiave primaria
E' opportuno, prima di passare alla traduzione vera e propria, scegliere tra le possibili chiavi candidate quella ottimale per efficienza ed utilizzo.

#### Criteri di scelta.
Per gli attributi della chiave primaria:
* è **necessario** che siano obbligatori (non NULL!)
* è **opportuno**  che siano in numero minimo possibile
* è **opportuno**  che siano interni all'entità
* è **opportuno**  che siano di tipo "semplice" (ad es. numerico intero)
* è **opportuno**  che siano stabili (frequentemente utilizzati ma raramente modificati)

Nel caso in cui la scelta ottimale non risulti soddisfacente, è possibile introdurre una chiave *surrogata*, ovvero "ad hoc", con il solo scopo di fungere da identificatore.

Tipicamente questa è un codice numerico di tipo intero gestito automaticamente dal DBMS.

Per MySQL e MariaDB, una colonna con la seguente definizione:

```SQL
id INT AUTO_INCREMENT PRIMARY KEY COMMENT "identifier"
```
 o simili per altri DBMS.

[back to restructuring](restructuring.md)