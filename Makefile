
underscore: scanner.l parser.y
	flex scanner.l
	bison --defines parser.y
	gcc -w scanner.lex.c parser.tab.c ast.c symtable.c -o underscore
	cp underscore tests/underscore

report:
	bison -d parser.y --report=all 

clean: scanner.lex.c parser.tab.c parser.tab.c
	rm scanner.lex.c parser.tab.c

