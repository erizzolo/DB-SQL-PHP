# Database constraints (vincoli)

Un vincolo è una proprietà | regola | condizione che deve valere per tutte le istanze di un database.

È tipicamente espresso tramite un predicato logico.

Si riassumomo i diversi tipi di vincoli che possono essere imposti in un database utilizzando i costrutti tipici del linguaggio SQL, rimandando la trattazione di casi particolari ad altra sede (views, triggers).

Si distinguono anzitutto in:
* intrarelational constraints (vincoli intrarelazionali)
* interrelational constraints (vincoli interrelazionali)

# Intrarelational constraints (vincoli intrarelazionali)

Riguardano (si possono verificare tramite) una singola tabella.

Si distinguono a loro volta in:
* tuple constraints (vincoli di tupla)
* key constraints (vincoli di chiave)

## Tuple constraints (vincoli di riga)
Riguardano (si possono verificare tramite) una singola riga di una singola tabella.

Possono riguardare:
* un singolo attributo
* più attributi

### Single attribute constraints (vincoli di attributo)
Riguardano (si possono verificare tramite) una singola colonna di una singola riga di una singola tabella.

Possono riguardare:
* il dominio di un attributo
* un'ulteriore limite al dominio
* la possibilità di valori ```NULL```

#### Domain constraints (vincoli di dominio)

Sono imposti scegliendo un tipo di dati (tra quelli predefiniti del database) per l'attributo.
Ad esempio:

```voto TINYINT UNSIGNED```

impone un dominio corrispondente ai numeri naturali [0, 255].

#### Domain limit constraints (vincoli di limite al dominio)

Sono imposti con un predicato che restringe ulteriormente il dominio dell'attributo.
Ad esempio:

```CHECK (voto <= 30)```

restringe il dominio ai numeri naturali [0, 30].

#### Null value constraints (vincoli di valori null)

Permettono di consentire o vietare il valore speciale ```NULL``` per l'attributo.

Ad esempio (attributo obbligatorio): ```voto TINYINT UNSIGNED NOT NULL```

oppure (attributo facoltativo): ```voto TINYINT UNSIGNED NULL```

### Multiple attribute constraints (vincoli di attributi multipli)
Riguardano (si possono verificare tramite) più colonne di una singola riga di una singola tabella.

Possono riguardare:
* condizioni particolari sui valori degli attributi
* espressioni di dipendenza tra attributi

Ad esempio (condizione per avere la lode): ```CHECK (voto = 30 OR NOT lode)```

oppure (applicazione IVA): ```CHECK (totale = imponibile + IVA)```

## Key constraints (vincoli di chiave)

Riguardano i valori su (un insieme di) uno o più attributi in tutte le righe di una singola tabella: impongono che non vi siano due righe con i medesimi valori per gli attributi appartenenti all'insieme.

Si distinguono in:
* vincolo di chiave primaria
* vincoli di chiave candidata

> Si noti che questi vincoli richiedono implicitamente la creazione di particolari strutture dati (indici) per consentire le verifiche di integrità in tempi rapidi (ricerche "dicotomiche" con complessità logaritmica).
### Primary key constraint (vincolo di chiave primaria)
È **unico** ed **obbligatorio** per ciascuna tabella: impone, oltre all'univocità dei valori per gli attributi, l'impossibilità di valori ```NULL```.

Corrisponde quindi al successivo vincolo di chiave candidata con l'aggiunta implicita di vincoli ```NOT NULL``` per tutti gli attributi appartenenti all'insieme.

Ad esempio: ```PRIMARY KEY(nome, cognome)``` impone che non siano presenti casi di omonimia (nè di nomi e/o cognomi non specificati)
mentre ```PRIMARY KEY(nome, cognome, dataNascita)``` consente le omonimie, a patto che la data di nascita sia distinta per gli omonimi.

### Candidate key constraint (vincolo di chiave candidata)
Impone l'univocità dei valori per gli attributi (quando non ```NULL```), ma consente i valori ```NULL```.

Ad esempio: ```UNIQUE KEY(nome, cognome)``` impone che non siano presenti due casi di omonimia, pur consentendo la presenza di casi multipli di nome 'Giovanni' e cognome ```NULL```, ovvero di casi multipli con nome `NULL` e cognome ```NULL```.
# Interrelational constraints (vincoli interrelazionali)

Riguardano (si possono verificare tramite) due tabelle (non sempre diverse!).

Si dicono anche vincoli di integrità referenziale perché consentono di garantire la validità dei riferimenti tra una tabella (dipendente) ed un'altra tabella di riferimento (a volte la stessa).

Consentono anche di specificare quale azione intraprendere quando, in seguito ad una modifica/cancellazione dei dati referenziati, il vincolo sarebbe violato.
### Foreign key constraint (vincolo di chiave esterna)
Impone che i valori degli attributi di chiave esterna esistano in una riga della tabella referenziata.

Ad esempio, date le tabelle
* *comuni*, con attributi **provincia, nome**, codiceCatastale (e chiave primaria (provincia, nome))
*  *indirizzo*, con attributi via, numero, provincia, comune

la specifica (nella tabella *indirizzo*):

```FOREIGN KEY(provincia, comune) REFERENCES comuni(provincia, nome)```

impone che nella tabella *indirizzo* non vi siano righe in cui la coppia di valori degli attributi provincia e comune non sia anche presente in (almeno una) riga della tabella comuni negli attributi provincia e nome.

> Si noti che il riferimento è sempre alla chiave primaria della tabella referenziata.
>
> Particolare attenzione va fatta quando la chiave primaria è costituita da più di un attributo: in questo caso il vincolo di chiave esterna è **unico** e riguarda tutti gli attributi.
> Sarebbe un grave errore, nell'esempio precedente, sostituire l'unico vincolo con due vincoli separati come:
> 
> ```FOREIGN KEY(provincia) REFERENCES comuni(provincia)``` e
> 
> ```FOREIGN KEY(comune) REFERENCES comuni(nome)```
> 
> In questo caso infatti, sarebbero possibili dati quali:
> provincia = 'Napoli', comune = 'Mirano' oppure provincia = 'Venezia', comune = 'Portici' !!!
> 
> Ulteriore attenzione va fatta quando la chiave primaria è costituita da più di un attributo per consentire valori `NULL` della chiave esterna in nessuno oppure tutti gli attributi.
