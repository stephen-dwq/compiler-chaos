/* AST definitions shared across parser, lexer and typechecker */
#ifndef AST_H
#define AST_H

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
    AST_MATCH,
    AST_FUN,
    AST_APP
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
        struct { char *param; AST *body; } fun;
        struct { AST *fn, *arg; } app;
    };
};

/* constructors declared in the parser implementation; declare them here so
   other modules can use them if needed. The parser provides definitions.
*/
AST *mk_fun(char *param, AST *body);
AST *mk_app(AST *fn, AST *arg);
AST *mk_int(int num);
AST *mk_bool(int boolean);
AST *mk_unit(void);
AST *mk_var(char *id);
AST *mk_binop(BinOp op, AST *lhs, AST *rhs);
AST *mk_if(AST *c, AST *t, AST *e);
AST *mk_let(char *id, AST *val, AST *body);
AST *mk_nil(void);
AST *mk_cons(AST *hd, AST *tl);
AST *mk_match(AST *e, Case *cs);
Case *mk_case(AST *pat, AST *exp, Case *next);

/* root produced by parser */
extern AST *root;

#endif /* AST_H */
