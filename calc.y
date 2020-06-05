%{
/** @file calc.y
 *  @brief Grammar rules for the scss to css compiler/preprocessor.
 *
 *  This contains the Grammar rules for the preprocessor 
 *  together with some rudimentary error handling and
 *  the main function which either prompts for input or
 *  parses a input file to the command line if given as 
 *  argument. 
 *
 *  @author Raffaele Tranquillini  <rtranquillini@unibz.it>
 *  @author Francesco Piccoli <fpiccoli@unibz.it> 
 *
 *
 *  @bug No known bugs?
 */

#define YYERROR_VERBOSE 1

#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include "header/scssFunctions.h"
#include "header/symtable.h"
#include "header/error.h"
%}

// here we define all return values that lex can return

%union {
       char* lexeme;
       double value;
       }



// here we define the tokens with its respective precedences

%token            LP
%token            RP
%token            NUM
%token            SEMI
%token            OP_ASSIGN
%token            OP_EXP
%token            ID
%token            EXIT
%token            RETURN
%token            QUIT
%token            OP_COMP

%token            IDENTIFIER
%token            NUMBER
%token            UNIT
%token            ATOM
%token            INHERIT
%token            PSEUDO


%token            T_DOLLAR
%token            T_SEMICOLON
%token            T_COLON
%token            T_DOT
%token            T_COMMA
%token            T_HASH
%token            T_PERCENT
%token            T_PX
%token            T_PL
%token            T_PR
%token            T_CBL
%token            T_CBR
%token            T_OP
%token            T_OM
%token            T_OS
%token            T_OD


%type <lexeme>   S //sbagliati da correggere
%type <value>    ST

%left OP_MINUS OP_PLUS 
%left OP_MULT OP_DIV 
%right UMINUS OP_I

%start S

// here we define the grammar

%%

// line and statement rules

S :
  | ST S
  ;
    
ST: VARDECL
  | CSSRULE
  ;

VARDECL
  : VAR EXPR
  ;

VAR:
  | T_DOLLAR IDENTIFIER
  ;

EXPR
  : VAR
  | NUMBER UNIT
  | ATOM
  | FNCALL
  | T_PL EXPR T_PR
  | EXPR T_OP EXPR
  | EXPR T_OM EXPR
  | EXPR T_OS EXPR
  | EXPR T_OD EXPR
  ;

FNCALL
  : IDENTIFIER T_PL P T_PR
  ;

P :
  | EXPR
  | EXPR PARAMS
  ;

PARAMS
  :
  | T_COMMA EXPR
  ;

CSSRULE
  : SELECTORS T_CBL DECLS T_CBR
  ;

SELECTORS
  :
  | SELECTORS INHERIT SELECTOR PSEUDOCLASS
  ;

SELECTOR
  : IDENTIFIER
  | T_HASH IDENTIFIER
  | T_DOT IDENTIFIER
  ;

PSEUDOCLASS
  :
  | PSEUDO
  ;
  
DECLS
  :
  | DECL DECLS
  ;
  
DECL
  : IDENTIFIER T_COLON EXPR T_SEMICOLON
  | CSSRULE
  | VARDECL

%%

#include "lex.yy.c"

int main(int argc, char *argv[]) 
{      

 // interactive mode or file mode
      if(argc < 2) 
      {
            printf("Welcome to ScssTocss compiler, a simple preprocessor which converts scss to css!\n");
            return yyparse();
      } 
      else 
      {
            FILE *fp = fopen(argv[1],"r");
            if(!fp) 
            {
                  printf("Unable to open file for reading\n");
                  exit(0);
            }
            yyin = fp;
            int flag = yyparse();
            fclose(yyin);
            
            return flag;
      }
}

int yyerror (char const *message)
{
  return fprintf (stderr, "%s\n", message);
  fputs (message, stderr);
  fputc ('\n', stderr);
  return 0;
}
