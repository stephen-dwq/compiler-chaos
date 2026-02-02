#include "ast.h"
#include <stdlib.h>
#include <string.h>

AST *root = NULL;

/* constructors */
AST *mk_fun(char *param, AST *body) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_FUN;
    n->fun.param = param; n->fun.body = body;

    return n;
}

AST *mk_app(AST *fn, AST *arg) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_APP; n->app.fn = fn; n->app.arg = arg;

    return n;
}

AST *mk_int(int num) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_INT;
    n->num = num;

    return n;
}

AST *mk_bool(int boolean) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_BOOL;
    n->boolean = boolean;

    return n;
}

AST *mk_unit(void) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_UNIT;

    return n;
}

AST *mk_var(char *id) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_VAR;
    n->id = strdup(id);

    return n;
}

AST *mk_binop(BinOp op, AST *lhs, AST *rhs) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_BINOP;
    n->binop.op = op; n->binop.lhs = lhs; n->binop.rhs = rhs;

    return n;
}

AST *mk_if(AST *c, AST *t, AST *e) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_IF;
    n->ifexp.cond = c; n->ifexp.then_br = t; n->ifexp.else_br = e;

    return n;
}

AST *mk_let(char *id, AST *val, AST *body) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_LET;
    n->let.id = strdup(id); n->let.val = val; n->let.body = body;

    return n;
}

AST *mk_nil(void) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_NIL;

    return n;
}

AST *mk_cons(AST *hd, AST *tl) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_CONS;
    n->cons.hd = hd; n->cons.tl = tl;

    return n;
}

AST *mk_match(AST *e, Case *cs) {
    AST *n = malloc(sizeof(AST));
    n->kind = AST_MATCH;
    n->match.scrutinee = e; n->match.cases = cs;

    return n;
}

Case *mk_case(AST *pat, AST *exp, Case *next) {
    Case *n = malloc(sizeof(Case));
    n->pat = pat; n->exp = exp; n->next = next;

    return n;
}