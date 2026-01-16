/* definitions */

%top{
    #include "y.tab.h"
}

digit [0-9]
letter [a-zA-Z]

%%
/* rules */

"(" { return LP; }
")" { return RP; }
";" { return SC; }
"true" { return TRUE; }
"false" { return FALSE; }
"nil" { return NIL; }
"test" { return TEST; }
"define" { return DEFINE; }
"+" { return PLUS; }
"-" { return MINUS; }
"*" { return TIMES; }
"=" { return EQUALS; }
"if" { return IF; }
"let" { return LET; }
"cons" { return CONS; }
"nil?" { return NIL_HUH; }
"cons?" { return CONS_HUH; }
"car" { return CAR; }
"cdr" { return CDR; }
{letter}({letter}|{digit})* {
    yylval.id = strdup(yytext); 
    return IDENT; 
}
{digit}+ {
    yylval.num = atoi(yytext);
    return NUMBER; 
}
[\t\n\r] 
. { 
    printf("Unknown character [%c]\n", yytext[0]); 
    return UNK; 
}

%%
/* user code */ 

int yywrap(void){ return 1; }