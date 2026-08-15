%{
#include "calculator_with_conversion.tab.h"
#include <math.h>
#include <string.h>
#include <stdlib.h>
%}

digit   [0-9]
number  {digit}+(\.{digit}+)?([eE][-+]?{digit}+)?

%%
"sin"    { return SIN; }
"cos"    { return COS; }
"tan"    { return TAN; }
"log"    { return LOG; }
"sqrt"   { return SQRT; }
"exp"    { return EXP; }

"DEC2HEX"           { return DEC2HEX; }
"HEX2DEC"           { return HEX2DEC; }
"DEC2OCT"           { return DEC2OCT; }
"OCT2DEC"           { return OCT2DEC; }
"DEC2BIN"           { return DEC2BIN; }
"BIN2DEC"           { return BIN2DEC; }

{number} {
    yylval.val = atof(yytext);
    return NUMBER;
}

\"[0-9A-Fa-f]+\"    { yylval.str = strdup(yytext + 1); yylval.str[strlen(yylval.str) - 1] = '\0'; return STRING; }

[ \t]    ;
\n       return '\n';

.        return yytext[0];

%%
int yywrap(void) {
    return 1;
}
