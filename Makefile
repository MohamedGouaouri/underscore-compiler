
underscore: scanner.l parser.y
	flex scanner.l
	bison --defines -g parser.y
	gcc scanner.lex.c parser.tab.c ast.c symtable.c -o underscore
	cp underscore tests/underscore

analyze-png: parser.dot
	dot -Tpng parser.dot -o parser.png

analyze-pdf: parser.dot
	dot -Tpdf parser.dot -o parser.pdf

analyze-ps: parser.dot
	dot -Tps parser.dot -o parser.ps

clean: scanner.lex.c parser.tab.c parser.tab.c
	rm scanner.lex.c parser.tab.c

