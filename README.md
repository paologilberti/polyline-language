# Parser per la gestione di polilinee (linguaggio)

## Descrizione

Il progetto consiste in un parser per un linguaggio che permette la gestione di polilinee, utilizzando Lex e Yacc. Una polilinea è una sequenza di segmenti lineari contigui e viene definita come una successione di punti nel piano. Se il punto iniziale e quello finale coincidono, si parla di polilinea chiusa. Diversamente, se non coincidono, si parla di polilinea aperta.

Il linguaggio supporta l'uso di simmetrie rispetto all'origine degli assi (`sim0`), rispetto all'asse x (`simx`) e rispetto all'asse y (`simy`) per definire i punti di una polilinea. È possibile anche utilizzare variabili per memorizzare e richiamare polilinee.

Le operazioni supportate includono la chiusura di una polilinea (`Close`), la verifica se una polilinea è aperta o chiusa (`isOpen`) e la concatenazione di due polilinee tramite un segmento che collega l'ultimo punto della prima polilinea al primo punto della seconda (`+`).

## File

Il progetto è organizzato nei seguenti file:

- `polyline.l` contiene le specifiche per Lex e definisce i token del linguaggio. Inoltre, gestisce il riconoscimento degli operatori, delle parole chiave, dei numeri interi e delle variabili, trasformandoli in token riconoscibili da Yacc.
- `polyline.y` contiene le specifiche per Yacc e definisce la grammatica del linguaggio. Inoltre, gestisce la sintassi del linguaggio, definendo come manipolare le strutture dati delle polilinee e delle variabili.
- `Makefile` semplifica il processo di compilazione del progetto.
- `README.md` fornisce una descrizione dettagliata del progetto.

## Compilazione ed esecuzione

Per compilare il progetto, utilizzando `Makefile`:

```
$ make
```

Per eseguire il programma compilato:

```
$ ./polyline [file]
```

Per terminare il programma:

```
$ (exit|e|quit|q);
```

Per rimuovere i file generati (compreso l'eseguibile):

```
$ make clean
```

## Utilizzo

Per utilizzare il parser, si compilano i file `polyline.l` e `polyline.y`, utilizzando `Makefile`, e si esegue il programma risultante. Il parser legge le istruzioni dalla tastiera o da un file, le analizza sintatticamente ed esegue le azioni semantiche richieste.

## Esempi

### Definizione di un punto

Input:

```
1 -2;
```

Output:

```
Polyline: (1 -2)
Length: 0.000 cm
```

### Definizione di una polilinea

Input:

```
1 -2 -3 4 5 6;
```

Output:

```
Polyline: (1 -2) (-3 4) (5 6)
Length: 15.457 cm
```

### Definizione di una polilinea con simmetrie

Input:

```
simx(1 2 sim0(3 4)) 5 6;
```

Output:

```
Polyline: (1 -2) (-3 4) (5 6)
Length: 15.457 cm
```

### Verifica se una polilinea (aperta) è aperta

Input:

```
isOpen simx(1 2 sim0(3 4)) 5 6;
```

Output:

```
Polyline: (1 -2) (-3 4) (5 6)
Is open: true
```

### Verifica se una polilinea (chiusa) è aperta

Input:

```
isOpen simx(1 2 sim0(3 4)) 5 6 1 -2;
```

Output:

```
Polyline: (1 -2) (-3 4) (5 6) (1 -2)
Is open: false
```

### Chiusura di una polilinea (aperta)

Input:

```
Close simx(1 2 sim0(3 4)) 5 6;
```

Output:

```
The polyline has been closed
Polyline: (1 -2) (-3 4) (5 6) (1 -2)
Length: 24.402 cm
```

### Chiusura di una polilinea (chiusa)

Input:

```
Close simx(1 2 sim0(3 4)) 5 6 1 -2;
```

Output:

```
The polyline was already closed
Polyline: (1 -2) (-3 4) (5 6) (1 -2)
Length: 24.402 cm
```

### Utilizzo di variabili per la memorizzazione di polilinee

Input:

```
P1 = simx(1 2 sim0(3 4)) 5 6;
```

Output:

```
Variable: P1
Polyline: (1 -2) (-3 4) (5 6)
```

### Utilizzo di variabili per la memorizzazione di polilinee (chiusura)

Input:

```
P2 = Close P1;
```

Output:

```
The polyline has been closed
Variable: P2
Polyline: (1 -2) (-3 4) (5 6) (1 -2)
```

### Utilizzo di variabili per la memorizzazione di polilinee (concatenazione)

Input:

```
P3 = P1 + P2;
```

Output:

```
Variable: P3
Polyline: (1 -2) (-3 4) (5 6) (1 -2) (-3 4) (5 6) (1 -2)
```

## Strutture dati

Il programma include le seguenti strutture dati per la gestione dei punti, delle polilinee e delle variabili:

- `Point` rappresenta un punto con coordinate intere x e y.
- `Polyline` rappresenta una polilinea composta da un array dinamico di punti, dal numero totale di punti e dalla dimensione dell'array.
- `Variable` contiene il nome di una variabile e un puntatore alla polilinea associata.

## Funzioni

Il programma include le seguenti funzioni per la gestione dei punti, delle polilinee e delle variabili:

- `add_point` aggiunge un punto alla polilinea specificata e, se necessario, ridimensiona l'array di punti.
- `apply_symmetry` applica una simmetria alla polilinea specificata. Le simmetrie possibili sono `sim0` (rispetto all'origine degli assi), `simx` (rispetto all'asse x) e `simy` (rispetto all'asse y).
- `calculate_length` calcola e restituisce la lunghezza della polilinea specificata, sommando le distanze tra punti consecutivi.
- `is_open` verifica se la polilinea specificata è aperta, cioè se il primo e l'ultimo punto della polilinea non coincidono. Restituisce 1 se è aperta, 0 altrimenti.
- `close_polyline` chiude la polilinea specificata, aggiungendo un punto finale che coincide con il punto iniziale. Restituisce la nuova polilinea.
- `concatenate_polylines` concatena due polilinee, creando una nuova polilinea che contiene tutti i punti della prima polilinea seguiti da tutti i punti della seconda polilinea. Restituisce la nuova polilinea.
- `print_polyline` stampa i punti della polilinea specificata.
- `variable_exists` verifica se una variabile con il nome specificato esiste. Restituisce 1 se esiste, 0 altrimenti.
- `add_variable` aggiunge una nuova variabile con il nome specificato e associa ad essa la polilinea specificata.
- `modify_variable` modifica la polilinea associata alla variabile con il nome specificato.
- `get_polyline` restituisce la polilinea associata alla variabile con il nome specificato. Se la variabile non esiste, restituisce NULL.

## Note

Alcune note aggiuntive:

- I comandi sono case-sensitive e devono essere scritti correttamente.
- Il programma gestisce fino a 100 variabili.
- Ogni operazione è seguita da un output che indica il risultato ottenuto.
