CC      := clang
FLEX    := flex
YACC    := byacc

CFLAGS  := -Wall -Wextra -Iast -Iparser

TARGET  := small_ml

LEXER_DIR       := lexer
PARSER_DIR      := parser
AST_DIR         := ast

LEXER_SRC   := $(LEXER_DIR)/$(TARGET).flex
PARSER_SRC  := $(PARSER_DIR)/$(TARGET).yacc
TYPECHECK_SRC     := $(AST_DIR)/typecheck.c
MAIN_SRC    := main.c

LEXER_C    := $(LEXER_DIR)/$(TARGET).yy.c
PARSER_C   := $(PARSER_DIR)/$(TARGET).tab.c
PARSER_H   := $(PARSER_DIR)/$(TARGET).tab.h

LEXER_O    := $(LEXER_DIR)/$(TARGET).yy.o
PARSER_O   := $(PARSER_DIR)/$(TARGET).tab.o
TYPECHECK_O      := $(AST_DIR)/typecheck.o
MAIN_O     := main.o

OBJS := $(LEXER_O) $(PARSER_O) $(TYPECHECK_O) $(MAIN_O)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(PARSER_C) $(PARSER_H): $(PARSER_SRC)
	$(YACC) -d -o $(PARSER_C) $(PARSER_SRC)

$(LEXER_C): $(LEXER_SRC) $(PARSER_H)
	$(FLEX) -o $@ $<

$(TYPECHECK_O): $(TYPECHECK_SRC)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(TARGET) \
	      $(LEXER_C) $(PARSER_C) $(PARSER_H) \
	      $(OBJS) \
	      $(TARGET).dSYM

.PHONY: all clean