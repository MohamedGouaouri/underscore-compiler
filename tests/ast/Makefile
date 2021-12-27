CC = gcc
CFLAGS = -W -Wall -Wextra
LDFLAGS = `pkg-config libgvc --cflags` -g -O2 -lcgraph -lgvc
EXEC = test.c ast.c

all: $(EXEC) clean
	$(CC) test.c ast.c -o ast $(CFLAGS)


viz: ast.dot
	dot -Tpng ast.dot -o ast.png

clean:
	rm -rf *.o
	echo Clean done.

mrproper: clean
	rm -rf $(EXEC)