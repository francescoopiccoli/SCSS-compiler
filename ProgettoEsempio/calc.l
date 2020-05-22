%option noyywrap
%option yylineno

%{
#include <stdlib.h>
#include <string.h>
#include "header/complex_num.h"
#include "header/symtable.h"

int badtoken_cnt = 0;
int token_cnt = 0;
int col_cnt = 0;
int lineno = 0;
%}

DIGIT       [0-9]
INTEGER     {DIGIT}+
NUM         {DIGIT}+(\.{DIGIT}+)?
LETTER      [a-zA-Z]
ID          {LETTER}({LETTER}|{DIGIT})* 
COMMENT     \/\*([^*]|\n)*\*\/ 
%%

[ \t\n]       { ; } // ignore whitespace
{COMMENT}     { ; } // ignore comments in C-style
"//"          {     char c;
                    do { c = input();
                    } while (c != '\n');
                    lineno++;
              }     //  handle // style comments

"if"        {return IF;}
"then"      {return THEN;}
"else"      {return ELSE;}
"double"    {return VAR_TYPE;} 
"cmp"       {return CMP_TYPE;}

{NUM}       {yylval.value = atof(yytext); return NUM;}
{ID}        {
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
