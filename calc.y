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

%}

// here we define all return values that lex can return

%union {
       
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

%token            T_DOLLAR
%token            T_SEMICOLON
%token            T_COLON
%token            T_DOT
%token            T_COMMA
%token            T_HASH
%token            T_PL
%token            T_PR
%token            T_PCL
%token            T_PCR
%token            T_OP
%token            T_OM
%token            T_OS
%token            T_OD


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
  : SELECTORS T_PCL DECLS T_PCR
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

