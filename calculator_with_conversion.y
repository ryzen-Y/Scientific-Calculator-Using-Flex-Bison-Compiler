%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#define DEG2RAD(x) ((x) * M_PI / 180.0) // Convert degrees to radians

int yylex(void);
void yyerror(const char *s);

char* dec_to_hex(double num) {
    char *res = malloc(20);
    sprintf(res, "%X", (int)num);
    return res;
}

char* dec_to_oct(double num) {
    char *res = malloc(20);
    sprintf(res, "%o", (int)num);
    return res;
}

char* dec_to_bin(double num) {
    char *res = malloc(65);
    int n = (int)num;
    int i = 0;
    for(int bit = 31; bit >= 0; bit--) {
        res[i++] = (n & (1 << bit)) ? '1' : '0';
    }
    res[i] = '\0';
    char *ptr = res;
    while (*ptr == '0' && *(ptr+1) != '\0') ptr++;
    return strdup(ptr);
}

double hex_to_dec(const char *hex) {
    int num;
    sscanf(hex, "%x", &num);
    return num;
}

double oct_to_dec(const char *oct) {
    int num;
    sscanf(oct, "%o", &num);
    return num;
}

double bin_to_dec(const char *bin) {
    int num = 0;
    while (*bin) {
        num = num * 2 + (*bin++ - '0');
    }
    return num;
}
%}

%union {
    double val;
    char* str;
}

%token <val> NUMBER
%token <str> STRING
%token SIN COS TAN LOG SQRT EXP
%token DEC2HEX HEX2DEC DEC2OCT OCT2DEC DEC2BIN BIN2DEC
%left '+' '-'
%left '*' '/'
%right '^'
%left '(' ')'

%type <val> expression
%type <str> conversion

%%
input:
    /* empty */
    | input line
;

line:
    '\n'
    | expression '\n'   { printf("Result: %g\n", $1); }
    | conversion '\n'   { printf("Result: %s\n", $1); free($1); }
;

expression:
      NUMBER
    | expression '+' expression   { $$ = $1 + $3; }
    | expression '-' expression   { $$ = $1 - $3; }
    | expression '*' expression   { $$ = $1 * $3; }
    | expression '/' expression   { $$ = $1 / $3; }
    | expression '^' expression   { $$ = pow($1, $3); }
    | '(' expression ')'           { $$ = $2; }
    | SIN '(' expression ')'       { $$ = sin(DEG2RAD($3)); }
    | COS '(' expression ')'       { $$ = cos(DEG2RAD($3)); }
    | TAN '(' expression ')'       { $$ = tan(DEG2RAD($3)); }
    | LOG '(' expression ')'       { $$ = log10($3); } // base-10 log
    | SQRT '(' expression ')'      { $$ = sqrt($3); }
    | EXP '(' expression ')'       { $$ = exp($3); }
;

conversion:
      DEC2HEX '(' expression ')'   { $$ = dec_to_hex($3); }
    | DEC2OCT '(' expression ')'   { $$ = dec_to_oct($3); }
    | DEC2BIN '(' expression ')'   { $$ = dec_to_bin($3); }
    | HEX2DEC '(' STRING ')'       { double val = hex_to_dec($3); free($3); char *res = malloc(50); sprintf(res, "%g", val); $$ = res; }
    | OCT2DEC '(' STRING ')'       { double val = oct_to_dec($3); free($3); char *res = malloc(50); sprintf(res, "%g", val); $$ = res; }
    | BIN2DEC '(' STRING ')'       { double val = bin_to_dec($3); free($3); char *res = malloc(50); sprintf(res, "%g", val); $$ = res; }
;
%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    printf("Calculator with Conversion (Degrees for trig, log base 10)\n");
    printf("Enter expressions or conversions:\n");
    yyparse();
    return 0;
}
