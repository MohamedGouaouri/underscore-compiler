# Local build used generally for testing

CC = gcc
SOURCES = tests/test.c symtable.c
TESTFILE = bin/testfile


test: $(TESTFILE)
	./$(TESTFILE)

$(TESTFILE): $(SOURCES)
	$(CC) $(SOURCES) -o $(TESTFILE)