%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


typedef enum {
    AST_INT, AST_BOOL, AST_NIL, AST_VAR,
    AST_DEFINE, AST_TEST,
    AST_PLUS, AST_MINUS, AST_TIMES, AST_EQUALS,
    AST_IF, AST_LET,
    AST_CONS,
    AST_NIL_HUH, AST_CONS_HUH, AST_CAR, AST_CDR,
    AST_PROGRAM
} ASTKind;

typedef struct AST {
    ASTKind kind;

    union {
        int int_val;
        int bool_val;
        char *var;

        struct { struct AST *a, *b; } bin;

        struct {
            struct AST *cond, *then_branch, *else_branch;
        } if_expr;

        struct {
            char *var;
            struct AST *value, *body;
        } let_expr;

        struct {
            struct AST **items;
            int count;
        } program;
    };
} AST;

AST *root;

/* constructors */
AST *ast_int(int v) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_INT;
    n->int_val = v;
    return n;
}

AST *ast_bool(int v) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_BOOL;
    n->bool_val = v;
    return n;
}

AST *ast_nil(void) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_NIL;
    return n;
}

AST *ast_var(char *v) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_VAR;
    n->var = v;
    return n;
}

AST *ast_bin(ASTKind k, AST *a, AST *b) {
    AST *n = malloc(sizeof(AST));
    n->kind = k;
    n->bin.a = a;
    n->bin.b = b;
    return n;
}

AST *ast_if(AST *c, AST *t, AST *e) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_IF;
    n->if_expr.cond = c;
    n->if_expr.then_branch = t;
    n->if_expr.else_branch = e;
    return n;
}

AST *ast_let(char *v, AST *val, AST *body) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_LET;
    n->let_expr.var = v;
    n->let_expr.value = val;
    n->let_expr.body = body;
    return n;
}

AST *ast_define(char *v, AST *e) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_DEFINE;
    n->bin.a = ast_var(v);
    n->bin.b = e;
    return n;
}

AST *ast_test(AST *e) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_TEST;
    n->bin.a = e;
    n->bin.b = NULL;
    return n;
}

AST *ast_program(AST **items, int count) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_PROGRAM;
    n->program.items = items;
    n->program.count = count;
    return n;
}

void yyerror(const char *s);
int yylex(void);
%}

%union {
    int num;
    char *id;
    AST *ast;
    struct {
        AST **items;
        int count;
    } list;
}

%token <id> IDENT
%token <num> NUMBER
%token LP RP
%token TRUE FALSE NIL
%token TEST DEFINE
%token PLUS MINUS TIMES EQUALS
%token IF LET
%token CONS
%token NIL_HUH CONS_HUH CAR CDR

%type <ast> program binding expression literal
%type <list> bindings

%start program

%%

program
    : bindings {
        root = ast_program($1.items, $1.count);
        $$ = root;
    }
    ;

bindings
    : /* empty */ {
        $$.items = NULL;
        $$.count = 0;
    }
    | bindings binding {
        $$.count = $1.count + 1;
        $$.items = realloc($1.items, sizeof(AST*) * $$.count);
        $$.items[$$.count - 1] = $2;
    }
    ;

binding
    : LP DEFINE IDENT expression RP {
        $$ = ast_define($3, $4);
    }
    | LP TEST expression RP {
        $$ = ast_test($3);
    }
    | expression {
        $$ = $1;
    }
    ;

expression
    : literal
    | IDENT {
        $$ = ast_var($1);
    }
    | LP PLUS expression expression RP {
        $$ = ast_bin(AST_PLUS, $3, $4);
    }
    | LP MINUS expression expression RP {
        $$ = ast_bin(AST_MINUS, $3, $4);
    }
    | LP TIMES expression expression RP {
        $$ = ast_bin(AST_TIMES, $3, $4);
    }
    | LP EQUALS expression expression RP {
        $$ = ast_bin(AST_EQUALS, $3, $4);
    }
    | LP IF expression expression expression RP {
        $$ = ast_if($3, $4, $5);
    }
    | LP LET LP LP IDENT expression RP RP expression RP {
        $$ = ast_let($5, $6, $9);
    }
    | LP CONS expression expression RP {
        $$ = ast_bin(AST_CONS, $3, $4);
    }
    | LP NIL_HUH expression RP {
        $$ = ast_bin(AST_NIL_HUH, $3, NULL);
    }
    | LP CONS_HUH expression RP {
        $$ = ast_bin(AST_CONS_HUH, $3, NULL);
    }
    | LP CAR expression RP {
        $$ = ast_bin(AST_CAR, $3, NULL);
    }
    | LP CDR expression RP {
        $$ = ast_bin(AST_CDR, $3, NULL);
    }
    ;

literal
    : NUMBER {
        $$ = ast_int($1);
    }
    | TRUE {
        $$ = ast_bool(1);
    }
    | FALSE {
        $$ = ast_bool(0);
    }
    | NIL {
        $$ = ast_nil();
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
    exit(1);
}

void print_ast(AST *n, int indent) {
    if (!n) return;
    for (int i = 0; i < indent; i++) printf("  ");

    switch(n->kind) {
        case AST_INT:    printf("Int(%d)\n", n->int_val); break;
        case AST_BOOL:   printf("Bool(%d)\n", n->bool_val); break;
        case AST_NIL:    printf("Nil\n"); break;
        case AST_VAR:    printf("Var(%s)\n", n->var); break;
        case AST_DEFINE: printf("Define\n"); print_ast(n->bin.a, indent+1); print_ast(n->bin.b, indent+1); break;
        case AST_TEST:   printf("Test\n"); print_ast(n->bin.a, indent+1); break;
        case AST_PLUS: case AST_MINUS: case AST_TIMES: case AST_EQUALS:
            printf("BinOp(%d)\n", n->kind);
            print_ast(n->bin.a, indent+1);
            print_ast(n->bin.b, indent+1);
            break;
        case AST_IF: printf("If\n"); print_ast(n->if_expr.cond, indent+1); print_ast(n->if_expr.then_branch, indent+1); print_ast(n->if_expr.else_branch, indent+1); break;
        case AST_LET: printf("Let(%s)\n", n->let_expr.var); print_ast(n->let_expr.value, indent+1); print_ast(n->let_expr.body, indent+1); break;
        case AST_CONS: printf("Cons\n"); print_ast(n->bin.a, indent+1); print_ast(n->bin.b, indent+1); break;
        case AST_NIL_HUH: case AST_CONS_HUH: case AST_CAR: case AST_CDR:
            printf("ListOp(%d)\n", n->kind); print_ast(n->bin.a, indent+1); break;
        case AST_PROGRAM:
            printf("Program\n");
            for (int i = 0; i < n->program.count; i++)
                print_ast(n->program.items[i], indent+1);
            break;
    }
}

int main(int argc, char **argv) {
    (void)argc; (void)argv;
    if (yyparse() == 0) {
        puts("Parse succeeded");
        print_ast(root, 0);
    }
    return 0;
}