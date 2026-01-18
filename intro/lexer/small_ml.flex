%top{
typedef struct AST AST;
typedef struct Case Case;
#include "../parser/small_ml.tab.h"
#include <string.h>
}

digit [0-9]
letter [a-zA-Z]

%%

"(" { return LP; }
")" { return RP; }

";".*[\n<<EOF>>] { /* comment */ }

"fun" { return FUN; }

"true" { return TRUE; }
"false" { return FALSE; }
"unit" { return UNIT; }

"match" { return MATCH; }
"with" { return WITH; }
"if" { return IF; }
"then" { return THEN; }
"else" { return ELSE; }
"let" { return LET; }
"in" { return IN; }
"end" { return END; }

"[]" { return E_LIST; }
"::" { return CONS; }
"->" { return ARROW; }

"|" { return BAR; }
"+" { return PLUS; }
"-" { return MINUS; }
"*" { return TIMES; }
"=" { return EQUALS; }

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