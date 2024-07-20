# Analizzatore sintattico per la gestione di polilinee (linguaggio)

## Descrizione

Il progetto consiste in un analizzatore sintattico per un linguaggio che permette la gestione di polilinee, utilizzando Lex e Yacc. Una polilinea è una sequenza di segmenti lineari contigui e viene definita come una successione di punti nel piano. Se il punto iniziale e quello finale coincidono, si parla di polilinea chiusa. Diversamente, se non coincidono, si parla di polilinea aperta.

Il linguaggio supporta l'uso di simmetrie rispetto all'origine degli assi (`sim0`), rispetto all'asse x (`simx`) e rispetto all'asse y (`simy`) per definire i punti di una polilinea. È possibile anche utilizzare variabili per memorizzare e richiamare polilinee.

Le operazioni supportate includono la chiusura di una polilinea (`Close`), la verifica se una polilinea è aperta o chiusa (`isOpen`) e la concatenazione di due polilinee tramite un segmento che collega l'ultimo punto della prima polilinea al primo punto della seconda (`+`).

## File

Il progetto è organizzato nei seguenti file:

- `polyline.l` contiene le specifiche per Lex e definisce i token del linguaggio. Inoltre, gestisce il riconoscimento degli operatori, delle parole chiave, dei numeri interi e delle variabili, trasformandoli in token riconoscibili da Yacc.

- `polyline.y` contiene le specifiche per Yacc e definisce la grammatica del linguaggio. Inoltre, gestisce la sintassi del linguaggio, definendo come manipolare le strutture dati delle polilinee e delle variabili.

- `Makefile` semplifica il processo di compilazione del progetto.

- `README.md` fornisce una descrizione dettagliata del progetto.

## Compilazione ed esecuzione

Per compilare il progetto, utilizzando `Makefile`: `$ make`

Per eseguire il programma compilato: `$ ./polyline [file]`

Per terminare il programma: `$ (exit|e|quit|q);`

Per rimuovere i file generati (compreso l'eseguibile): `$ make clean`

## Utilizzo

Per utilizzare l'analizzatore sintattico, si compilano i file `polyline.l` e `polyline.y`, utilizzando `Makefile`, e si esegue il programma risultante. L'analizzatore legge le istruzioni dalla tastiera o da un file, le analizza sintatticamente ed esegue le azioni semantiche richieste.

## Esempi

## Strutture

## Funzioni

## Note
