# Local build used generally for testing

CC = gcc
LDFLAGS	= -lfl
SYMTABLE_TEST_SOURCES = tests/test.c symtable.c
SYMTABLE_TEST_FILE = tests/testfile

LEX_SCANNER = scanner.l
SCANNER_SOURCES = scanner.c symtable.c
SCANNER_OUT = tests/scanner
# Symtable build

symtabletest: $(SYMTABLE_TEST_FILE)
	./$(SYMTABLE_TEST_FILE)

$(SYMTABLE_TEST_FILE): $(SYMTABLE_TEST_SOURCES)
	$(CC) $(SYMTABLE_TEST_SOURCES) -o $(SYMTABLE_TEST_FILE)

# scanner build
scanner: $(SCANNER_SOURCES)
	flex $(LEX_SCANNER)
	$(CC) $(SCANNER_SOURCES) -o $(SCANNER_OUT) $(LDFLAGS)