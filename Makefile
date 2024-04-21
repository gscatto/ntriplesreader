test: ntriplereadertest
	sh test/run.sh $(shell find test/all/* -type d)

ntriplereadertest: lex.yy.c y.tab.c test/ntriplebuildermock.c
	cc -o $@ -I main $^

lex.yy.c: main/ntriplereader.l y.tab.h
	lex $<

y.tab.h y.tab.c: main/ntriplereader.y
	yacc -d $<
