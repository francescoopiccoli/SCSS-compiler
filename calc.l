%option noyywrap

%{
#include <stdlib.h>
#include <string.h>
#include "header/scssFunctions.h"
#include "header/symtable.h"

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
ATOM        black|red|white|blue|green
PSEUDOCLASS (:active|:checked|:disabled|:empty|:enabled|:first-child|:first-of-type|:focus|:hover|:in-range|:invalid|:last-child|:last-of-type|:link|:only-of-type|:only-child|:optional|:out-of-range|:read-only|:read-write|:required|:root|:target|:valid|:visited)?
%%

[ \t\n]       { ; } // ignore whitespace
{COMMENT}     { ; } // ignore comments of type "//"
"/\*.*\*/"    ECHO  // report identically in new file


{NUM}       {yylval.value = atof(yytext); 
            return NUM;}

{ID}        {yylval.lexeme = strdup(yytext);
             return ID;}


{ATOM}       {yylval.lexeme = strdup(yytext);
              return ATOM;}

{PSEUDOCLASS} {yylval.lexeme = strdup(yytext);
              return PSEUDOCLASS;}

"px"        {return PX}
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
"{"         {return LBRACE;}
"}"         {return RBRACE;}  
","         {return COMMA;}
"."         {return DOT;}
"#"         {return HASH;}
"%"         {return PERCENT}
.           { printf("Unexpected character: %c\n", yytext[0]); return yytext[0]; } //return error if all else fails
%%
