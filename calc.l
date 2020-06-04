%option noyywrap

%{
#include <stdlib.h>
#include <string.h>

//variabili usate spesso che potrebbero tornare utili
int badtoken_cnt = 0;
int token_cnt = 0;
int col_cnt = 0;
int lineno = 0;

%}

DIGIT       [0-9]
NUM         {DIGIT}+(\.{DIGIT}+)? //teniamo anche i float?
LETTER      [a-zA-Z]
ID          ({LETTER}|\-|_)({LETTER}|{DIGIT}|\-_)* 
COMMENT     \/\/.*\n
UNIT        %|px
ATOM        black|red|white|blue|green
PSEUDOCLASS (:active|:checked|:disabled|:empty|:enabled|:first-child|:first-of-type|:focus|:hover|:in-range|:invalid|:last-child|:last-of-type|:link|:only-of-type|:only-child|:optional|:out-of-range|:read-only|:read-write|:required|:root|:target|:valid|:visited)?
%%

[ \t\n]       { ; } // ignore whitespace
{COMMENT}     { ; } // ignore comments of type "//"
"/\*.*\*/"    ECHO  // report identically in new file


{NUM}       {yylval.value = atof(yytext); 
            return NUM;}

{ID}        { //qualcosa che ha a che fare con la symbol table da rivedere
            char* name = strdup(yytext); 
            symrec* s = getSymbol(name);
            if(s == 0) {
                  s = createSymbol(name);
            }
            yylval.symbol = s;
            return ID;
            }

"+"         {return OP_PLUS;}   // operators 
"-"         {return OP_MINUS;}
"*"         {return OP_MULT;}
"/"         {return OP_DIV;}     
"("         {return LP;}
")"         {return RP;}
"="         {return OP_ASSIGN;}
"^"         {return OP_EXP;}      
":"         {return OP_I;}
"=="        {return OP_COMP;}
";"         {return SEMI;}   
.           { printf("Unexpected character: %c\n", yytext[0]); return yytext[0]; } //return error if all else fails
%%
