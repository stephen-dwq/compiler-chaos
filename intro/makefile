CC      := clang
FLEX    := flex
YACC    := byacc

CFLAGS  := -Wall -Wextra -Iast -Iparser

TARGET  := small_ml

LEXER_C := small_ml.yy.c
PARSER_C := y.tab.c
PARSER_H := y.tab.h

LEXER_O := small_ml.yy.o
PARSER_O := y.tab.o
MAIN_O := main.o
AST_O := ast.o

OBJS := $(LEXER_O) $(PARSER_O) $(MAIN_O) $(AST_O)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(LEXER_C): small_ml.flex $(PARSER_H)
	$(FLEX) -o $@ $<

$(PARSER_C) $(PARSER_H): small_ml.yacc
	$(YACC) -d small_ml.yacc

clean:
	rm -f $(TARGET) $(OBJS) $(LEXER_C) $(PARSER_C) $(PARSER_H)

.PHONY: all clean