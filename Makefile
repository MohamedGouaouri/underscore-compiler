
underscore: scanner.l parser.y
	flex scanner.l
	bison -d parser.y
	gcc scanner.lex.c parser.tab.c ast.c symtable.c -o underscore
	cp underscore tests/underscore

clean: scanner.lex.c parser.tab.c underscore
	rm scanner.lex.c parser.tab.c underscore
	rm tests/underscore