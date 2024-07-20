%{
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// numero massimo di variabili
#define MAX_VARIABLES 100

// struttura dati per la gestione di un punto
typedef struct Point {
    int x; // coordinata x del punto
    int y; // coordinata y del punto
} Point;

// struttura dati per la gestione di una polilinea
typedef struct Polyline {
    Point* points; // punti della polilinea
    int total; // numero totale di punti della polilinea
    int size; // numero massimo di punti della polilinea
} Polyline;

// struttura dati per la gestione di una variabile
typedef struct Variable {
    char* name; // nome della variabile
    Polyline* polyline; // polilinea associata alla variabile
} Variable;

extern FILE* yyin;

Variable variables[MAX_VARIABLES]; // variabili
int total_variables = 0; // numero totale di variabili

void yyerror(const char* s);
int yylex();

// funzione per aggiungere un punto a una polilinea
void add_point(Polyline* polyline, int x, int y);

// funzione per applicare una simmetria a una polilinea
void apply_symmetry(const char* symmetry, Polyline* polyline);

// funzione per calcolare la lunghezza di una polilinea
double calculate_length(Polyline* polyline);

// funzione per verificare se una polilinea è aperta
int is_open(Polyline* polyline);

// funzione per chiudere una polilinea
Polyline* close_polyline(Polyline* polyline);

// funzione per concatenare due polilinee
Polyline* concatenate_polylines(Polyline* polyline1, Polyline* polyline2);

// funzione per stampare i punti di una polilinea
void print_polyline(Polyline* polyline);

// funzione per verificare se una variabile esiste
int variable_exists(const char* name);

// funzione per aggiungere una variabile
void add_variable(const char* name, Polyline* polyline);

// funzione per modificare una variabile
void modify_variable(const char* name, Polyline* polyline);

// funzione per ottenere una polilinea data una variabile
Polyline* get_polyline(const char* name);
%}

%union {
    int integer;
    char* string;
    void* pointer;
}

%token <string> LBRACK RBRACK
%token <string> PLUS ASSIGN SEMICOLON
%token <string> ISOPEN CLOSE
%token <string> TERMINATE
%token <integer> INTEGER
%token <string> SYMMETRY
%token <string> VARIABLE

%type <pointer> polyline points end point

%%

program     : program statement { }
            | { }
            ;

statement   : polyline SEMICOLON {
                print_polyline($1); // stampa della polilinea
                printf("Length: %.3f cm\n\n", calculate_length($1)); // stampa della lunghezza della polilinea
            }
            | ISOPEN polyline SEMICOLON {
                print_polyline($2); // stampa della polilinea
                printf("Is open: %s\n\n", is_open($2) ? "true" : "false"); // stampa dopo aver verificato se la polilinea è aperta
            }
            | CLOSE polyline SEMICOLON {
                if (is_open($2)) { // la polilinea è aperta
                    Polyline* closed_polyline = close_polyline($2); // chiusura della polilinea
                    printf("The polyline has been closed\n");
                    print_polyline(closed_polyline); // stampa della polilinea
                    printf("Length: %.3f cm\n\n", calculate_length(closed_polyline)); // stampa della lunghezza della polilinea
                } else { // la polilinea è chiusa
                    printf("The polyline was already closed\n");
                    print_polyline($2); // stampa della polilinea
                    printf("Length: %.3f cm\n\n", calculate_length($2)); // stampa della lunghezza della polilinea
                }
            }
            | VARIABLE ASSIGN polyline SEMICOLON {
                if (variable_exists($1)) { // la variabile esiste
                    modify_variable($1, $3); // modifica della variabile
                } else { // la variabile non esiste
                    add_variable($1, $3); // aggiunta della variabile
                }
                printf("Variable: %s\n", $1); // stampa della variabile
                print_polyline($3); // stampa della polilinea
                printf("\n");
            }
            | VARIABLE ASSIGN CLOSE polyline SEMICOLON {
                if (is_open($4)) { // la polilinea è aperta
                    Polyline* closed_polyline = close_polyline($4); // chiusura della polilinea
                    if (variable_exists($1)) { // la variabile esiste
                        modify_variable($1, closed_polyline); // modifica della variabile
                    } else { // la variabile non esiste
                        add_variable($1, closed_polyline); // aggiunta della variabile
                    }
                    printf("The polyline has been closed\n");
                    printf("Variable: %s\n", $1); // stampa della variabile
                    print_polyline(closed_polyline); // stampa della polilinea
                    printf("\n");
                } else { // la polilinea è chiusa
                    if (variable_exists($1)) { // la variabile esiste
                        modify_variable($1, $4); // modifica della variabile
                    } else { // la variabile non esiste
                        add_variable($1, $4); // aggiunta della variabile
                    }
                    printf("The polyline was already closed\n");
                    printf("Variable: %s\n", $1); // stampa della variabile
                    print_polyline($4); // stampa della polilinea
                    printf("\n");
                }
            }
            | VARIABLE ASSIGN VARIABLE SEMICOLON {
                Polyline* polyline = get_polyline($3); // ottenimento della polilinea
                if (polyline) { // la polilinea esiste
                    if (variable_exists($1)) { // la variabile esiste
                        modify_variable($1, polyline); // modifica della variabile
                    } else { // la variabile non esiste
                        add_variable($1, polyline); // aggiunta della variabile
                    }
                    printf("Variable: %s\n", $1); // stampa della variabile
                    print_polyline(polyline); // stampa della polilinea
                    printf("\n");
                } else { // la polilinea non esiste
                    printf("Undefined variable: %s\n\n", $3);
                }
            }
            | VARIABLE SEMICOLON {
                Polyline* polyline = get_polyline($1); // ottenimento della polilinea
                if (polyline) { // la polilinea esiste
                    printf("Variable: %s\n", $1); // stampa della variabile
                    print_polyline(polyline); // stampa della polilinea
                    printf("Length: %.3f cm\n\n", calculate_length(polyline)); // stampa della lunghezza della polilinea
                } else { // la polilinea non esiste
                    printf("Undefined variable: %s\n\n", $1);
                }
            }
            | ISOPEN VARIABLE SEMICOLON {
                Polyline* polyline = get_polyline($2); // ottenimento della polilinea
                if (polyline) { // la polilinea esiste
                    printf("Variable: %s\n", $2); // stampa della variabile
                    print_polyline(polyline); // stampa della polilinea
                    printf("Is open: %s\n\n", is_open(polyline) ? "true" : "false"); // stampa dopo aver verificato se la polilinea è aperta
                } else { // la polilinea non esiste
                    printf("Undefined variable: %s\n\n", $2);
                }
            }
            | CLOSE VARIABLE SEMICOLON {
                Polyline* polyline = get_polyline($2); // ottenimento della polilinea
                if (polyline) { // la polilinea esiste
                    if (is_open(polyline)) { // la polilinea è aperta
                        Polyline* closed_polyline = close_polyline(polyline); // chiusura della polilinea
                        modify_variable($2, closed_polyline); // modifica della variabile
                        printf("The polyline has been closed\n");
                        printf("Variable: %s\n", $2); // stampa della variabile
                        print_polyline(closed_polyline); // stampa della polilinea
                        printf("\n");
                    } else { // la polilinea è chiusa
                        printf("The polyline was already closed\n");
                        printf("Variable: %s\n", $2); // stampa della variabile
                        print_polyline(polyline); // stampa della polilinea
                        printf("\n");
                    }
                } else { // la polilinea non esiste
                    printf("Undefined variable: %s\n\n", $2);
                }
            }
            | VARIABLE ASSIGN CLOSE VARIABLE SEMICOLON {
                Polyline* polyline = get_polyline($4); // ottenimento della polilinea
                if (polyline) { // la polilinea esiste
                    if (is_open(polyline)) { // la polilinea è aperta
                        Polyline* closed_polyline = close_polyline(polyline); // chiusura della polilinea
                        if (variable_exists($1)) { // la variabile esiste
                            modify_variable($1, closed_polyline); // modifica della variabile
                        } else { // la variabile non esiste
                            add_variable($1, closed_polyline); // aggiunta della variabile
                        }
                        printf("The polyline has been closed\n");
                        printf("Variable: %s\n", $1); // stampa della variabile
                        print_polyline(closed_polyline); // stampa della polilinea
                        printf("\n");
                    } else { // la polilinea è chiusa
                        if (variable_exists($1)) { // la variabile esiste
                            modify_variable($1, polyline); // modifica della variabile
                        } else { // la variabile non esiste
                            add_variable($1, polyline); // aggiunta della variabile
                        }
                        printf("The polyline was already closed\n");
                        printf("Variable: %s\n", $1); // stampa della variabile
                        print_polyline(polyline); // stampa della polilinea
                        printf("\n");
                    }
                } else { // la polilinea non esiste
                    printf("Undefined variable: %s\n\n", $4);
                }
            }
            | VARIABLE ASSIGN VARIABLE PLUS VARIABLE SEMICOLON {
                Polyline* polyline1 = get_polyline($3); // ottenimento della polilinea
                Polyline* polyline2 = get_polyline($5); // ottenimento della polilinea
                if (polyline1 && polyline2) { // almeno una polilinea non esiste
                    Polyline* new_polyline = concatenate_polylines(polyline1, polyline2); // concatenazione delle polilinee
                    if (variable_exists($1)) { // la variabile esiste
                        modify_variable($1, new_polyline); // modifica della variabile
                    } else { // la variabile non esiste
                        add_variable($1, new_polyline); // aggiunta della variabile
                    }
                    printf("Variable: %s\n", $1); // stampa della variabile
                    print_polyline(new_polyline); // stampa della polilinea
                    printf("\n");
                } else { // entrambe le polilinee esistono
                    printf("Undefined variable: %s, %s or both\n\n", $3, $5);
                }
            }
            | TERMINATE SEMICOLON {
                return 0; // terminazione del parser
            }
            ;

polyline    : points {
                $$ = $1;
            }
            | end {
                $$ = $1;
            }
            ;

points      : polyline point {
                add_point($1, ((Point*) $2)->x, ((Point*) $2)->y); // aggiunta del punto alla polilinea
                $$ = $1;
            }
            | polyline SYMMETRY LBRACK polyline RBRACK {
                apply_symmetry($2, $4); // applicazione della simmetria
                $$ = concatenate_polylines($1, $4); // concatenazione delle polilinee
            }
            ;

end         : point {
                Polyline* current_polyline = malloc(sizeof(Polyline)); // allocazione dello spazio per la polilinea
                current_polyline->points = malloc(10 * sizeof(Point)); // allocazione dello spazio per i punti della polilinea
                current_polyline->total = 0; // inizializzazione del numero totale di punti della polilinea
                current_polyline->size = 10; // inizializzazione del numero massimo di punti della polilinea
                add_point(current_polyline, ((Point*) $1)->x, ((Point*) $1)->y); // aggiunta del punto alla polilinea
                $$ = current_polyline;
            }
            | SYMMETRY LBRACK polyline RBRACK {
                apply_symmetry($1, $3); // applicazione della simmetria
                $$ = $3;
            }
            ;

point       : INTEGER INTEGER {
                $$ = malloc(sizeof(Point)); // allocazione dello spazio per il punto
                ((Point*) $$)->x = $1; // inizializzazione della coordinata x del punto
                ((Point*) $$)->y = $2; // inizializzazione della coordinata y del punto
            }
            ;

%%

int main(int argc, char **argv) {
    if (argc > 1) { // la lettura dei dati avviene da un file
        printf("Reading from a file (%s)\n\n", argv[1]);
        yyin = fopen(argv[1], "r"); // aggiornamento del flusso di input
    } else { // la lettura dei dati avviene dalla tastiera
        printf("Reading from the keyboard\n\n");
        yyin = stdin; // aggiornamento del flusso di input
    }
    yyparse(); // chiamata del parser
    return 0;
}

void yyerror(const char* s) {
    fprintf(stderr, "Error: %s\n", s);
}

void add_point(Polyline* polyline, int x, int y) {
    if (polyline->total >= polyline->size) { // il numero totale di punti della polilinea è maggiore o uguale al numero massimo di punti della polilinea
        polyline->size += 10; // incremento del numero massimo di punti della polilinea
        polyline->points = realloc(polyline->points, polyline->size * sizeof(Point)); // riallocazione dello spazio per i punti della polilinea
    }
    polyline->points[polyline->total].x = x; // aggiunta del punto (coordinata x)
    polyline->points[polyline->total].y = y; // aggiunta del punto (coordinata y)
    polyline->total++; // incremento del numero totale di punti della polilinea
}

void apply_symmetry(const char* symmetry, Polyline* polyline) {
    for (int i = 0; i < polyline->total; i++) { // scorrimento dei punti della polilinea
        if (strcmp(symmetry, "sim0") == 0) { // la simmetria è rispetto all'origine degli assi
            polyline->points[i].x = - polyline->points[i].x; // modifica della coordinata x di un punto
            polyline->points[i].y = - polyline->points[i].y; // modifica della coordinata y di un punto
        } else if (strcmp(symmetry, "simx") == 0) { // la simmetria è rispetto all'asse x
            polyline->points[i].y = - polyline->points[i].y; // modifica della coordinata y di un punto
        } else if (strcmp(symmetry, "simy") == 0) { // la simmetria è rispetto all'asse y
            polyline->points[i].x = - polyline->points[i].x; // modifica della coordinata x di un punto
        }
    }
}

double calculate_length(Polyline* polyline) {
    double length = 0.0; // inizializzazione della lunghezza della polilinea
    for (int i = 1; i < polyline->total; i++) { // scorrimento dei punti della polilinea
        int dx = polyline->points[i].x - polyline->points[i - 1].x; // distanza tra le coordinate x di due punti consecutivi
        int dy = polyline->points[i].y - polyline->points[i - 1].y; // distanza tra le coordinate y di due punti consecutivi
        length += sqrt(dx * dx + dy * dy); // aggiornamento della lunghezza della polilinea
    }
    return length;
}

int is_open(Polyline* polyline) {
    return !(polyline->points[0].x == polyline->points[polyline->total - 1].x &&
                polyline->points[0].y == polyline->points[polyline->total - 1].y);
}

Polyline* close_polyline(Polyline* polyline) {
    Polyline* closed_polyline = malloc(sizeof(Polyline)); // allocazione dello spazio per la nuova polilinea
    closed_polyline->points = malloc((polyline->size + 1) * sizeof(Point)); // creazione dello spazio per i punti della nuova polilinea
    memcpy(closed_polyline->points, polyline->points, polyline->total * sizeof(Point)); // copia dei punti della polilinea
    closed_polyline->total = polyline->total + 1; // aggiornamento del numero totale di punti della nuova polilinea
    closed_polyline->points[closed_polyline->total - 1] = polyline->points[0]; // aggiunta dell'ultimo punto della nuova polilinea
    closed_polyline->size = polyline->size + 10; // aggiornamento del numero massimo di punti della nuova polilinea
    return closed_polyline;
}

Polyline* concatenate_polylines(Polyline* polyline1, Polyline* polyline2) {
    Polyline* new_polyline = malloc(sizeof(Polyline)); // allocazione dello spazio per la nuova polilinea
    new_polyline->total = polyline1->total + polyline2->total; // inizializzazione del numero totale di punti della nuova polilinea
    new_polyline->size = polyline1->size + polyline2->size; // inizializzazione del numero massimo di punti della nuova polilinea
    new_polyline->points = malloc(new_polyline->size * sizeof(Point)); // allocazione dello spazio per i punti della nuova polilinea
    memcpy(new_polyline->points, polyline1->points, polyline1->total * sizeof(Point)); // copia dei punti della prima polilinea
    memcpy(&new_polyline->points[polyline1->total], polyline2->points, polyline2->total * sizeof(Point)); // copia dei punti della seconda polilinea
    return new_polyline;
}

void print_polyline(Polyline* polyline) {
    if (!polyline || polyline->total == 0) { // la polilinea è vuota
        printf("Polyline void\n");
    } else { // la polilinea non è vuota
        printf("Polyline: ");
        for (int i = 0; i < polyline->total; i++) { // scorrimento dei punti della polilinea
            printf("(%d %d)", polyline->points[i].x, polyline->points[i].y); // stampa di un punto
            if (i < polyline->total - 1) {
                printf(" ");
            }
        }
        printf("\n");
    }
}

int variable_exists(const char* name) {
    for (int i = 0; i < total_variables; i++) { // scorrimento delle variabili
        if (strcmp(variables[i].name, name) == 0) { // la variabile esiste
            return 1;
        }
    }
    // la variabile non esiste
    return 0;
}

void add_variable(const char* name, Polyline* polyline) {
    variables[total_variables].name = strdup(name); // aggiunta della variabile (nome)
    variables[total_variables].polyline = polyline; // aggiunta della variabile (polilinea)
    total_variables++; // incremento del numero totale di variabili
}

void modify_variable(const char* name, Polyline* polyline) {
    for (int i = 0; i < total_variables; i++) { // scorrimento delle variabili
        if (strcmp(variables[i].name, name) == 0) { // la variabile esiste
            variables[i].polyline = polyline; //modifica della variabile
            return;
        }
    }
    // la variabile non esiste
}

Polyline* get_polyline(const char* name) {
    for (int i = 0; i < total_variables; i++) { // scorrimento delle variabili
        if (strcmp(variables[i].name, name) == 0) { // la variabile esiste
            return variables[i].polyline;
        }
    }
    // la variabile non esiste
    return NULL;
}
