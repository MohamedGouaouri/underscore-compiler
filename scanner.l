
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "scanner.h"
    #include "symtable.h"

    // specified  because when I convert
    // the string length to its char representation 
    // I get an error
    #define MAX_STRING_LENGTH 255

    SymTable* symt;

    int currentColumn = 1;
    int showsuccess = 0;


    void yysuccess(const char *s, const char *lexeme, int length);
    void yyerror(const char *s);
    void showLexicalError();
%}

/*Used to get the current line number*/
%option yylineno 
%option noyywrap 
%option outfile = "scanner.c"
/*Used for multiline comments*/
%x c_comment     

UNDERSCORE "_"

/*Reserved keywords*/
LOOP loop
READ READ
WRITE WRITE
ENTRY entry
MAIN (\(\)){UNDERSCORE}" entry"(\(\))

IF \?
ELSE :

BREAK break
CONTINUE continue

/*Identifiers*/
ID [a-zA-Z][a-zA-Z0-9_]*

ANYTHING .*
DOT \.
LINEBREAK "\n"|"\r"
SEMICOLON ;
COMMA \,

OPENPARENTHESIS \(
CLOSEPARENTHESIS \)
OPENHOOK \{
CLOSEHOOK \}
OPENBRACKET \[
CLOSEBRACKET \]


/*Logical and arithmetic operators*/
EQUAL =
NONEQUAL !=
AND &&
OR \|\|
NON !
INFERIOR \<
SUPERIOR \>
INFERIOREQUAL \<\=
SUPERIOREQUAL \>\=
ADD \+
SUB -
MULT \*
DIV \/
MOD \%
POWER \^

/*Elementary instructions*/
ASSIGNMENT \<\-
RETURN -\>

/*Constant strings and numbers*/
DIGIT [0-9]
NUMBER ([1-9]{DIGIT}*|"0")
INTEGER -?{NUMBER}
REALNUMBER -?{NUMBER}"\."{DIGIT}+
STRING (\"{ANYTHING}\")|(\'{ANYTHING}\') 

/*Declarations*/
FUNCTIONDECLARE \(\){UNDERSCORE}
NUMBERDECLARE \${UNDERSCORE}
STRINGDECLARE ((\"\")|(\'\')){UNDERSCORE}
CONSTDECLARE \~{UNDERSCORE}
BOOLEENDECLARE \?{UNDERSCORE}

STRUCTTYPEDECLARE \{\}{UNDERSCORE}
STRUCTDECLARE {UNDERSCORE}{ID}
POINTERDECLARE ((\@)+)(({STRUCTDECLARE})|({NUMBERDECLARE}|{STRINGDECLARE}|{CONSTDECLARE}|{BOOLEENDECLARE}))
TABLEDECLARE ((\@)*)((\$)|((\"\")|(\'\'))|(\~)|(\?)|(\{\}))((\[\])+){UNDERSCORE}

/*Pointers*/
ADDRESSVALUE &
POINTERVALUE @

/*Comments*/
INLINECOMMENT #[^_]{ANYTHING}


%%



{LOOP} {
    yysuccess("LOOP", yytext, yyleng);
    insertNewEntry(symt, _LOOP);
}

{READ} {
    yysuccess("READ", yytext, yyleng);
    insertNewEntry(symt, _READ);
}

{WRITE} {
    yysuccess("WRITE", yytext, yyleng);
    insertNewEntry(symt, _WRITE);
}

{ENTRY} {
    yysuccess("the main entry", yytext, yyleng);
    insertNewEntry(symt, _ENTRY);
}

{IF} {
    yysuccess("IF condition", yytext, yyleng);
    insertNewEntry(symt, _IF);
}

{ELSE} {
    yysuccess("ELSE condition", yytext, yyleng);
    insertNewEntry(symt, _ELSE);
}

{BREAK} {
    yysuccess("Loop break", yytext, yyleng);
    insertNewEntry(symt, _BREAK);
}

{CONTINUE} {
    yysuccess("Loop continue", yytext, yyleng);
    insertNewEntry(symt, _CONTINUE);
}


{ID} {
    yysuccess("IDENTIFIER", yytext, yyleng);
    SymTableNode* node = insertNewEntry(symt, _ID);
    set_attr(node, _NAME_ATTR, yytext);
}


{DOT} {
    yysuccess("DOT", yytext, yyleng);
    insertNewEntry(symt, _DOT);
}

{COMMA} {
    yysuccess("COMMA", yytext, yyleng);
    insertNewEntry(symt, _COMMA);
}

{SEMICOLON} {
    yysuccess("SEMICOLON", yytext, yyleng);
    insertNewEntry(symt, _SEMICOLON);
}




{OPENPARENTHESIS} {
    yysuccess("OPENPARENTHESIS", yytext, yyleng);
    insertNewEntry(symt, _OPENPARENTHESIS);
}

{CLOSEPARENTHESIS} {
    yysuccess("CLOSEPARENTHESIS", yytext, yyleng);
    insertNewEntry(symt, _CLOSEPARENTHESIS);
}

{OPENHOOK} {
    yysuccess("OPENHOOK", yytext, yyleng);
    insertNewEntry(symt, _ENTRY);
}

{CLOSEHOOK} {
    yysuccess("CLOSEHOOK", yytext, yyleng);
    insertNewEntry(symt, _OPENHOOK);
}

{OPENBRACKET} {
    yysuccess("OPENBRACKET", yytext, yyleng);
    insertNewEntry(symt, _OPENBRACKET);
}

{CLOSEBRACKET} {
    yysuccess("CLOSEBRACKET", yytext, yyleng);
    insertNewEntry(symt, _CLOSEBRACKET);
}


			
{EQUAL} {
    yysuccess("EQU operator", yytext, yyleng);
    insertNewEntry(symt, _EQUAL);
}

{NONEQUAL} {
    yysuccess("NONEQU operator", yytext, yyleng);
    insertNewEntry(symt, _NONEQUAL);
}

{AND} {
    yysuccess("AND operator", yytext, yyleng);
    insertNewEntry(symt, _AND);
}

{OR} {
    yysuccess("OR operator", yytext, yyleng);
    insertNewEntry(symt, _OR);
}

{NON} {
    yysuccess("NON operator", yytext, yyleng);
    insertNewEntry(symt, _NON);
}

{INFERIOR} {
    yysuccess("INFERIOR sign", yytext, yyleng);
    insertNewEntry(symt, _INFERIOR);
}

{SUPERIOR} {
    yysuccess("SUPERIOR sign", yytext, yyleng);
    insertNewEntry(symt, _SUPERIOR);
}

{INFERIOREQUAL} {
    yysuccess("INFERIOREQUAL sign", yytext, yyleng);
    insertNewEntry(symt, _INFERIOREQUAL);
}

{SUPERIOREQUAL} {
    yysuccess("SUPERIOREQUAL sign", yytext, yyleng);
    insertNewEntry(symt, _SUPERIOREQUAL);
}

{ADD} {
    yysuccess("ADDITION operator", yytext, yyleng);
    insertNewEntry(symt, _ADD);
}

{SUB} {
    yysuccess("SUBTRACTION operator", yytext, yyleng);
    insertNewEntry(symt, _SUB);

}

{MULT} {
    yysuccess("MULTIPLICATION operator", yytext, yyleng);
    insertNewEntry(symt, _MULT);
}

{DIV} {
    yysuccess("DIVISION operator", yytext, yyleng);
    insertNewEntry(symt, _DIV);
}

{MOD} {
    yysuccess("MODULO operator", yytext, yyleng);
    insertNewEntry(symt, _MOD);
}

{POWER} {
    yysuccess("POWER operator", yytext, yyleng);
    insertNewEntry(symt, _POWER);
}


{ASSIGNMENT} {
    yysuccess("ASSIGNMENT", yytext, yyleng);
    insertNewEntry(symt, _ASSIGNMENT);
}

{RETURN} {
    yysuccess("RETURN", yytext, yyleng);
    insertNewEntry(symt, _RETURN);
}



{INTEGER} {
    yysuccess("constant INTEGER", yytext, yyleng);
    SymTableNode* node = insertNewEntry(symt, _INTEGER);
    // insert integer value
    set_attr(node, _VALUE_ATTR, yytext);
}

{REALNUMBER} {
    yysuccess("constant REALNUMBER", yytext, yyleng);
    SymTableNode* node = insertNewEntry(symt, _REALNUMBER);
    // insert rea lnumber value
    set_attr(node, _VALUE_ATTR, yytext);
}


{STRING} {
    yysuccess("constant STRING", yytext, yyleng);
    SymTableNode* node = insertNewEntry(symt, _STRING);
    // insert string value & length
    set_attr(node, _VALUE_ATTR, yytext);

    // convert int length to char length
    char len[MAX_STRING_LENGTH];
    sprintf(len, "%d", yyleng-2);
    set_attr(node, _LENGTH_ATTR, len);
} 


{FUNCTIONDECLARE} {
    yysuccess("FUNCTION declaration", yytext, yyleng);
    insertNewEntry(symt, _FUNCTIONDECLARE);

} 

{NUMBERDECLARE} {
    yysuccess("NUMBER declaration", yytext, yyleng);
    insertNewEntry(symt, _NUMBERDECLARE);
}

{STRINGDECLARE} {
    yysuccess("STRING declaration", yytext, yyleng);
    insertNewEntry(symt, _STRINGDECLARE);
}

{CONSTDECLARE} {
    yysuccess("CONSTANT declaration", yytext, yyleng);
    insertNewEntry(symt, _CONSTDECLARE);
}

{BOOLEENDECLARE} {
    yysuccess("BOOLEAN declaration", yytext, yyleng);
    insertNewEntry(symt, _BOOLEENDECLARE);
}

{STRUCTTYPEDECLARE} {
    yysuccess("STRUCTTYPE declaration", yytext, yyleng);
    insertNewEntry(symt, _STRUCTTYPEDECLARE);
}

{STRUCTDECLARE} {
    yysuccess("STRUCT declaration", yytext, yyleng);
    insertNewEntry(symt, _STRUCTDECLARE);
}

{POINTERDECLARE} {
    yysuccess("POINTER declaration", yytext, yyleng);
    insertNewEntry(symt, _POINTERDECLARE);
}

{TABLEDECLARE} {
    yysuccess("TABLE declaration", yytext, yyleng);
    insertNewEntry(symt, _TABLEDECLARE);
}

{ADDRESSVALUE} {
    yysuccess("ADDRESS value", yytext, yyleng);
    insertNewEntry(symt, _ADDRESSVALUE);
}

{POINTERVALUE} {
    yysuccess("POITER value", yytext, yyleng);
    insertNewEntry(symt, _POINTERVALUE);
}


{INLINECOMMENT} {
    yysuccess("INLINE comment", "", yyleng);
}

{LINEBREAK} {
    currentColumn = 1;
}


#_ { BEGIN(c_comment); yymore(); }
<c_comment>[^_]* { yymore(); }
<c_comment>"_"+[^_#]* { yymore(); }
<c_comment>"_#" { yysuccess("MULTILINE comment", yytext, yyleng); BEGIN(INITIAL);}


[ \t]+ {
    currentColumn+=yyleng;
}

<<EOF>> yyterminate();

. {
    yyerror("Unrecognized character");
    showLexicalError();
    yyterminate();
}


%%

int main(int argc, char **argv) {

    extern FILE *yyin, *yyout;
  
    yyin = fopen(argv[1], "r");
  
    yyout = fopen("Output.txt", "w");

    if (argc>=3 && sscanf (argv[2], "%i", &showsuccess) != 1) {
        fprintf(stderr, "error - not an integer");
    }
    if(showsuccess != 0) showsuccess = 1;
    
    // alocate the symbols table
    symt = allocateSymTable();

    // tokenize the source program
    yylex();

    // free the symbol table.
    // logically it will maintained in memory until
    // the compiler finishes everything
    // but here we are doing just the first step
    freeUpSymTable(symt);
    fclose(yyin);
    fclose(yyout);
    return 0;

}

void yysuccess(const char *s, const char *lexeme, int length) {
    if(showsuccess) {
        printf("Found %s : ", s);
        printf("\033[0;32m");
        printf("'%s'", lexeme); 
        printf("\033[0m"); 
        printf(" at Ln %d Col %d \n", yylineno, currentColumn);
    }
    currentColumn += length;
}

void yyerror(const char *s) {
    printf("\033[0;31m"); 
    //printf("%s at Ln %d Col %d \n", s, yylineno, currentColumn);
    printf("\033[0m"); 
}

void showLexicalError() {

    char line[256], introError[80]; 

    fseek(yyin, 0, SEEK_SET);
    
    int i = 0; 

    while (fgets(line, sizeof(line), yyin)) { 
        i++; 
        if(i == yylineno) break;  
    } 
        
    sprintf(introError, "Lexical error in Line %d : Unrecognized character : ", yylineno);
    printf("%s%s", introError, line);  
    int j=1;
    while(j<currentColumn+strlen(introError)) { printf(" "); j++; }
    printf("^\n");


}


