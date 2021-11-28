
%{
    #include "scanner.h"
    
    int currentColumn = 1;
    int showsuccess = 0;
    void yysuccess(const char *s, const char *lexeme, int length);
    void yyerror(const char *s);
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
}

{READ} {
    yysuccess("READ", yytext, yyleng);
}

{WRITE} {
    yysuccess("WRITE", yytext, yyleng);
}

{ENTRY} {
    yysuccess("the main entry", yytext, yyleng);
}

{IF} {
    yysuccess("IF condition", yytext, yyleng);
}

{ELSE} {
    yysuccess("ELSE condition", yytext, yyleng);
}

{BREAK} {
    yysuccess("Loop break", yytext, yyleng);
}

{CONTINUE} {
    yysuccess("Loop continue", yytext, yyleng);
}


{ID} {
    yysuccess("IDENTIFIER", yytext, yyleng);

}


{DOT} {
    yysuccess("DOT", yytext, yyleng);
}

{COMMA} {
    yysuccess("COMMA", yytext, yyleng);
}

{SEMICOLON} {
    yysuccess("SEMICOLON", yytext, yyleng);
}




{OPENPARENTHESIS} {
    yysuccess("OPENPARENTHESIS", yytext, yyleng);
}

{CLOSEPARENTHESIS} {
    yysuccess("CLOSEPARENTHESIS", yytext, yyleng);
}

{OPENHOOK} {
    yysuccess("OPENHOOK", yytext, yyleng);
}

{CLOSEHOOK} {
    yysuccess("CLOSEHOOK", yytext, yyleng);
}

{OPENBRACKET} {
    yysuccess("OPENBRACKET", yytext, yyleng);
}

{CLOSEBRACKET} {
    yysuccess("CLOSEBRACKET", yytext, yyleng);
}


			
{EQUAL} {
    yysuccess("EQU operator", yytext, yyleng);
}

{NONEQUAL} {
    yysuccess("NONEQU operator", yytext, yyleng);
}

{AND} {
    yysuccess("AND operator", yytext, yyleng);
}

{OR} {
    yysuccess("OR operator", yytext, yyleng);
}

{NON} {
    yysuccess("NON operator", yytext, yyleng);
}

{INFERIOR} {
    yysuccess("INFERIOR sign", yytext, yyleng);
}

{SUPERIOR} {
    yysuccess("SUPERIOR sign", yytext, yyleng);
}

{INFERIOREQUAL} {
    yysuccess("INFERIOREQUAL sign", yytext, yyleng);
}

{SUPERIOREQUAL} {
    yysuccess("SUPERIOREQUAL sign", yytext, yyleng);
}

{ADD} {
    yysuccess("ADDITION operator", yytext, yyleng);
}

{SUB} {
    yysuccess("SUBTRACTION operator", yytext, yyleng);
}

{MULT} {
    yysuccess("MULTIPLICATION operator", yytext, yyleng);
}

{DIV} {
    yysuccess("DIVISION operator", yytext, yyleng);
}

{MOD} {
    yysuccess("MODULO operator", yytext, yyleng);
}

{POWER} {
    yysuccess("POWER operator", yytext, yyleng);
}


{ASSIGNMENT} {
    yysuccess("ASSIGNMENT", yytext, yyleng);
}

{RETURN} {
    yysuccess("RETURN", yytext, yyleng);
}



{INTEGER} {
    yysuccess("constant INTEGER", yytext, yyleng);
}

{REALNUMBER} {
    yysuccess("constant REALNUMBER", yytext, yyleng);
}


{STRING} {
    yysuccess("constant STRING", yytext, yyleng);
} 


{FUNCTIONDECLARE} {
    yysuccess("FUNCTION declaration", yytext, yyleng);
} 

{NUMBERDECLARE} {
    yysuccess("NUMBER declaration", yytext, yyleng);
}

{STRINGDECLARE} {
    yysuccess("STRING declaration", yytext, yyleng);
}

{CONSTDECLARE} {
    yysuccess("CONSTANT declaration", yytext, yyleng);
}

{BOOLEENDECLARE} {
    yysuccess("BOOLEAN declaration", yytext, yyleng);
}

{STRUCTTYPEDECLARE} {
    yysuccess("STRUCTTYPE declaration", yytext, yyleng);
}

{STRUCTDECLARE} {
    yysuccess("STRUCT declaration", yytext, yyleng);
}

{POINTERDECLARE} {
    yysuccess("POINTER declaration", yytext, yyleng);
}

{TABLEDECLARE} {
    yysuccess("TABLE declaration", yytext, yyleng);
}

{ADDRESSVALUE} {
    yysuccess("ADDRESS value", yytext, yyleng);
}

{POINTERVALUE} {
    yysuccess("POITER value", yytext, yyleng);
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
  
    yylex();

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
    printf("%s at Ln %d Col %d \n", s, yylineno, currentColumn);
    printf("\033[0m"); 
    currentColumn+=yyleng;
}

