%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

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
%token FUN

%type <ast> program exp atom pattern
%type <case_list> cases case

%start program

%nonassoc EQUALS
%right CONS
%left PLUS MINUS
%left TIMES
%left APP

%%
program
    : exp
        { root = $1; }
    ;

exp
    : atom
    | exp atom %prec APP
        { $$ = mk_app($1, $2); }
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
    | FUN IDENT ARROW exp
        { $$ = mk_fun($2, $4); }
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
    | pattern CONS pattern
        { $$ = mk_cons($1, $3); }
    ;
%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
    exit(1);
}