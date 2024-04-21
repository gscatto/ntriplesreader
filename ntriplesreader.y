%{

#include "y.tab.h"

#include "ntriplesbuilder.h"

#include <stdio.h>
#include <string.h>

extern int yyparse();
extern int yylex();
extern int starttoken;

void yyerror(const char *str) {
    fprintf(stderr, "error: %s\n", str);
}

int main(int argc, char *argv[]) {
    if (argc > 1) {
        char *t = argv[1];
        if (strcmp(t, "START_URI") == 0) {
            starttoken = START_URI;
        } else if (strcmp(t, "START_STRING") == 0) {
            starttoken = START_STRING;
        } else if (strcmp(t, "START_SUBJECT") == 0) {
            starttoken = START_SUBJECT;
        } else if (strcmp(t, "START_PREDICATE") == 0) {
            starttoken = START_PREDICATE;
        } else if (strcmp(t, "START_OBJECT") == 0) {
            starttoken = START_OBJECT;
        } else if (strcmp(t, "START_LITERAL") == 0) {
            starttoken = START_LITERAL;
        } else if (strcmp(t, "START_DATATYPE") == 0) {
            starttoken = START_DATATYPE;
        } else if (strcmp(t, "START_STATEMENT") == 0) {
            starttoken = START_STATEMENT;
        } else if (strcmp(t, "START_STATEMENTS") == 0) {
            starttoken = START_STATEMENTS;
        } else {
            fprintf(stderr, "unrecognized start token \"%s\"\n", t);
            return 1;
        }
    }
    return yyparse();
}

%}

%start start

%token <yytext> TXT
%token <yytext> URI
%token DOUBLECARET
%token FULLSTOP
%token GREATERTHANSIGN
%token LESSTHANSIGN
%token NEWLINE
%token QUOTATIONMARK
%token START_DATATYPE
%token START_LITERAL
%token START_OBJECT
%token START_PREDICATE
%token START_STATEMENT
%token START_STATEMENTS
%token START_STRING
%token START_SUBJECT
%token START_URI
%token TAB

%type <yytext> str

%union {
    char yytext[1024];
}

%%

start : START_URI uri
      | START_STRING string
      | START_SUBJECT subject
      | START_PREDICATE predicate
      | START_OBJECT object
      | START_LITERAL literal
      | START_DATATYPE datatype
      | START_STATEMENT statement
      | START_STATEMENTS statements
      ;

statements : statements newline statement
           | statement
           ;

newline : newline NEWLINE
        | NEWLINE
        ;

statement : clearstatement subject TAB predicate TAB object FULLSTOP buildstatement
          ;

clearstatement : { ntriplesbuilder_clearstatement(); }
               ;

buildstatement : { ntriplesbuilder_buildstatement(); }
               ;

subject : clearsubject uri { ntriplesbuilder_buildsubject(); }
        ;

clearsubject : { ntriplesbuilder_clearsubject(); }
             ;

predicate : clearpredicate uri { ntriplesbuilder_buildpredicate(); }
          ;

clearpredicate : { ntriplesbuilder_clearpredicate(); }
               ;

object : clearobject uri buildobject
       | clearobject literal buildobject
       ;

clearobject : { ntriplesbuilder_clearobject(); }
            ;

buildobject : { ntriplesbuilder_buildobject(); }
            ;

literal : clearliteral string datatype buildliteral
        | clearliteral string buildliteral
        ;

clearliteral : { ntriplesbuilder_clearliteral(); }
             ;

buildliteral : { ntriplesbuilder_buildliteral(); }
             ;

datatype : cleardatatype DOUBLECARET uri builddatatype
         ;

cleardatatype : { ntriplesbuilder_cleardatatype(); }
              ;

builddatatype : { ntriplesbuilder_builddatatype(); }
              ;

string : QUOTATIONMARK str QUOTATIONMARK { ntriplesbuilder_addstring($2); }
       ;

str : { *$$ = 0; }
    | str URI { strcat($$, $2); }
    | str TXT { strcat($$, $2); }
    ;

uri : LESSTHANSIGN URI GREATERTHANSIGN { ntriplesbuilder_adduri($2); }
    ;