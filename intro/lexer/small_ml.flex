%top{
typedef struct AST AST;
#include "../parser/small_ml.tab.h"
#include <string.h>
}

digit [0-9]
letter [a-zA-Z]

%%

"(" { return LP; }
")" { return RP; }
";".* { /* comment, ignore */ }
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
[ \t\n\r]+   { /* skip whitespace */ }
. {
    fprintf(stderr, "Unknown character [%c]\n", yytext[0]);
    exit(1);
}

%%

int yywrap(void){ return 1; }