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


//BUGS
// - prod di relationship
// - numeri con - passati come identifier invece che come espressioni -> precedenza 

#define YYERROR_VERBOSE 1

#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
//#include "header/scssFunctions.h"
//#include "header/symtable.h"
//#include "header/error.h"

int yylex();
int yyerror (char const *message);

%}

// here we define all return values that lex can return

%union {
       char* lexeme;
       double value;
       //symtable sym;
       }



// here we define the tokens with its respective precedences

%token            ID
%token            NUM
%token            UNIT
%token            SCALAR
%token            ATOM
%token            PSEUDO
%token            T_DOLLAR
%token            T_SEMICOLON
%token            T_COLON
%token            T_DOT
%token            T_COMMA
%token            T_HASH
%token            T_PL
%token            T_PR
%token            T_BL
%token            T_BR
%token            T_PLUS
%token            T_MINUS
%token            T_STAR
%token            T_DIV
%token            T_GT


%left T_MINUS T_PLUS
%left T_STAR T_DIV

%start S

// here we define the grammar

%%

// line and statement rules

EPS:
  ;

S: ST S
  | EPS
  ;
    
ST: VARDECL
  | CSSRULE
  ;

VARDECL: VAR T_COLON EXPR T_SEMICOLON
  ;

VAR: T_DOLLAR ID
  ;

EXPR: VAR
  | SCALAR
  | NUM
  | ATOM
  | FNCALL
  | T_PL EXPR T_PR
  | EXPR T_PLUS EXPR
  | EXPR T_MINUS EXPR
  | EXPR T_STAR EXPR
  | EXPR T_DIV EXPR
  ;

FNCALL: ID T_PL P T_PR
  ;

P: EXPR PARAMS
  | EPS
  ;

PARAMS: T_COMMA EXPR PARAMS
  | EPS
  ;

CSSRULE: SELECTORS T_BL DECLS T_BR
  ;

SELECTORS: SELECTORS RELATIONSHIP SELECTOR PSEUDOCLASS
  | EPS
  ;

SELECTOR: ID
  | T_HASH ID
  | T_DOT ID
  ;

PSEUDOCLASS: PSEUDO
  | EPS
  ;

  RELATIONSHIP: T_COMMA
  | T_GT
  | EPS
  ;
  
DECLS: DECL DECLS
  | EPS
  ;
  
DECL: ID T_COLON EXPR T_SEMICOLON
  | CSSRULE
  | VARDECL

%%

#include "lex.yy.c"

int main(int argc, char *argv[]) 
{      

 // interactive mode or file mode
      if(argc < 2) 
      {
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