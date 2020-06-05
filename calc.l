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
NUM         {DIGIT}+(\.{DIGIT}+)?
LETTER      [a-zA-Z]
ID          ({LETTER}|\-|_)({LETTER}|{DIGIT}|\-_)* 
COMMENT     \/\/.*\n
UNIT        %|px
ATOM        black|red|white|blue|green
PSEUDOCLASS (:active|:checked|:disabled|:empty|:enabled|:first-child|:first-of-type|:focus|:hover|:in-range|:invalid|:last-child|:last-of-type|:link|:only-of-type|:only-child|:optional|:out-of-range|:read-only|:read-write|:required|:root|:target|:valid|:visited)


%%

[ \t\n]       {} // ignore whitespace
{COMMENT}     {} // ignore comments of type "//"
"/\*.*\*/"    {}  ECHO; // report identically in new file

"px"        {return T_PX;}
"+"         {return T_OP;}   // operators 
"-"         {return T_OM;}
"*"         {return T_OS;}
"/"         {return T_OD;}     
"("         {return T_PL;}
")"         {return T_PR;}     
"{"         {return T_CBL;}
"}"         {return T_CBR;}
"="         {return OP_ASSIGN;}
"^"         {return OP_EXP;}      
":"         {return T_COLON;}
"=="        {return OP_COMP;}
";"         {return T_SEMICOLON;} 
","         {return T_COMMA;}
"."         {return T_DOT;}
"#"         {return T_HASH;}
"%"         {return T_PERCENT;}

{NUM}       {/*yylval.value = atof(yytext); return NUM; */}


{ATOM}       {/*yylval.lexeme = strdup(yytext); return ATOM; */}

{ID}        {/*yylval.lexeme = strdup(yytext); return ID; */}

{PSEUDOCLASS} {/*yylval.lexeme = strdup(yytext); return PSEUDO; */}

.           { printf("Unexpected character: %c\n", yytext[0]); return yytext[0]; } //return error if all else fails

%%
