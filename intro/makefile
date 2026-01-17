CC      := clang
FLEX    := flex
YACC    := byacc

CFLAGS  := -Wall -Wextra

LEXER_DIR   := lexer
PARSER_DIR  := parser

TARGET      := small_ml

LEXER_SRC   := $(LEXER_DIR)/$(TARGET).flex
PARSER_SRC  := $(PARSER_DIR)/$(TARGET).yacc

LEXER_C     := $(LEXER_DIR)/$(TARGET).yy.c
PARSER_C    := $(PARSER_DIR)/$(TARGET).tab.c
PARSER_H    := $(PARSER_DIR)/$(TARGET).tab.h


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