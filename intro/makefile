CC      := clang
FLEX    := flex
YACC    := byacc

LEXER_DIR   := lexer
PARSER_DIR  := parser

LEXER_SRC   := $(LEXER_DIR)/trefoil_v2.flex
PARSER_SRC  := $(PARSER_DIR)/trefoil_v2.yacc

LEXER_C     := $(LEXER_DIR)/trefoil_v2.yy.c
PARSER_C    := $(PARSER_DIR)/trefoil_v2.tab.c
PARSER_H    := $(PARSER_DIR)/trefoil_v2.tab.h

TARGET      := trefoil_v2

CFLAGS  := -Wall -Wextra


all: $(TARGET)

$(PARSER_C) $(PARSER_H): $(PARSER_SRC)
	$(YACC) -d -o $(PARSER_C) $(PARSER_SRC)

$(LEXER_C): $(LEXER_SRC) $(PARSER_H)
	$(FLEX) -o $(LEXER_C) $(LEXER_SRC)

$(TARGET): $(PARSER_C) $(LEXER_C)
	$(CC) $(CFLAGS) $^ -o $@

clean:
	rm -rf $(TARGET) \
	      $(PARSER_C) $(PARSER_H) \
	      $(LEXER_C) \
		  ${TARGET}.dSYM

.PHONY: all clean