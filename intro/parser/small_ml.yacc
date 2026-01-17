%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


typedef enum {
    AST_INT,
    AST_BOOL,
    AST_UNIT,
    AST_VAR,
    AST_BINOP,
    AST_IF,
    AST_LET,
    AST_NIL,
    AST_CONS,
    AST_MATCH
} ASTKind;

typedef enum {
    OP_PLUS,
    OP_MINUS,
    OP_TIMES,
    OP_EQ
} BinOp;

typedef struct AST AST;
typedef struct Case Case;

struct Case {
    AST *pat;
    AST *exp;
    Case *next;
};

struct AST {
    ASTKind kind;
    union {
        int num;
        int boolean;
        char *id;

        struct { BinOp op; AST *lhs, *rhs; } binop;
        struct { AST *cond, *then_br, *else_br; } ifexp;
        struct { char *id; AST *val, *body; } let;
        struct { AST *hd, *tl; } cons;
        struct { AST *scrutinee; Case *cases; } match;
    };
};

AST *root;

/* constructors */
AST *mk_int(int n) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_INT;
    n->num = n;

    return n;
}

AST *mk_bool(int b) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_BOOL;
    n->boolean = b;

    return n;
}

AST *mk_unit(void) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_UNIT;

    return n;
}

AST *mk_var(char *s) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_VAR;
    n->id = stdrup(s);

    return n;
}

AST *mk_binop(BinOp op, AST *l, AST *r) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_BINOP;
    n->binop.op = op; n->binop.lhs = l; n->binop.rhs = r;

    return n;
}

AST *mk_if(AST *c, AST *t, AST *e) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_IF;
    n->ifexp.cond = c; n->ifexp.then_br = t; n->ifexp.else_br = e;

    return n;
}

AST *mk_let(char *id, AST *v, AST *b) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_LET;
    n->let.id = strdup(id); n->let.val = v; n->let.body = b;

    return n;
}

AST *mk_nil(void) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_NIL;

    return n;
}

AST *mk_cons(AST *h, AST *t) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_CONS;
    n->cons.hd = h; n->cons.tl = t;

    return n;
}

AST *mk_match(AST *e, Case *cs) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_MATCH;
    n->match.scrutinee = e; n.match->cases = cs;

    return n;
}

Case *mk_case(AST *p, AST *e, Case *n) {
    Case *n = malloc(sizeof(AST));
    c->pat = p; c->exp = e; c->next = n;
}

void yyerror(const char *s);
int yylex(void);
%}

%union {
    int num;
    char *id;
    AST *ast;
    Case *case_list;
}

%token <num> NUMBER
%token <id> IDENT

%token LP RP

%token TRUE FALSE UNIT
%token IF THEN ELSE LET IN END
%token MATCH WITH
%token PLUS MINUS TIMES EQUALS
%token CONS ARROW BAR
%token E_LIST

%type <ast> program exp atom pattern
%type <case_list> cases case

%start program

%nonassoc EQUALS
%right CONS
%left PLUS MINUS
%left TIMES

%%
program
    : exp
        { root = $1; }
    ;

exp
    : atom
    | exp PLUS exp
        { $$ = mk_binop(OP_PLUS,  $1, $3); }
    | exp MINUS exp
        { $$ = mk_binop(OP_MINUS, $1, $3); }
    | MINUS exp %prec MINUS
        { $$ = mk_binop(OP_MINUS, mk_int(0), $2); }
    | exp TIMES exp
        { $$ = mk_binop(OP_TIMES, $1, $3); }
    | exp EQUALS exp
        { $$ = mk_binop(OP_EQ,    $1, $3); }
    | exp CONS exp
        { $$ = mk_cons($1, $3); }
    | IF exp THEN exp ELSE exp
        { $$ = mk_if($2, $4, $6); }
    | LET IDENT EQUALS exp IN exp END
        { $$ = mk_let($2, $4, $6); }
    | MATCH exp WITH cases
        { $$ = mk_match($2, $4); }
    ;

atom
    : NUMBER
        { $$ = mk_int($1); }
    | TRUE
        { $$ = mk_bool(1); }
    | FALSE
        { $$ = mk_bool(0); }
    | UNIT
        { $$ = mk_unit(); }
    | IDENT
        { $$ = mk_var($1); }
    | E_LIST
        { $$ = mk_nil(); }
    | LP exp RP
        { $$ = $2; }
    ;

cases
    : case
        { $$ = $1; }
    | cases BAR case {
        Case *c = $1;
        while (c->next) c = c->next;
        c->next = $3;
        $$ = $1;
    }
    ;

case
    : pattern ARROW exp
        { $$ = mk_case($1, $3, NULL); }
    ;

pattern
    : IDENT
        { $$ = mk_var($1); }
    | E_LIST
        { $$ = mk_nil(); }
    | pattern CONS pattern
        { $$ = mk_cons($1, $3); }
    ;
%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
    exit(1);
}