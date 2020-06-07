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
#include <math.h>
#include "header/scssFunctions.h"
#include "header/symtable.h"
#include "header/error.h"

int yylex();
int yyerror (char const *message);

typedef struct {
    char *string;
    double number;
    enum var_type type;
} var_contents;

%}

// here we define all return values that lex can return

%union {
        char* string;
        double number;
        symrec *sym;
        enum var_type varType;
        var_contents expression;
       }



// here we define the tokens with its respective precedences

%token<string>    ID
%token<number>    NUM
%token<string>    UNIT
%token<sym>       VAR
%token            T_SEMICOLON
%token<string>    T_COLON
%token<string>    T_DOT
%token<string>    T_COMMA
%token<string>    T_HASH
%token            T_PL
%token            T_PR
%token            T_BL
%token            T_BR
%token            T_PLUS
%token            T_MINUS
%token            T_STAR
%token            T_DIV
%token<string>    T_GT
/* %token            CSS_DATA_TYPE  
%token            HTML_DATA_TYPE 
%token            FNNAME */

%type <expression>   EXPR
%type <expression>   SCALAR
%type <string>       FNCALL
%type <string>       SELECTORS 
%type <string>       SELECTOR 
%type <string>       PSEUDOCLASS 
%type <string>       RELATIONSHIP 
%type <string>       EPS 


%left T_MINUS T_PLUS
%left T_STAR T_DIV



%start S

// here we define the grammar

%%

// line and statement rules



S: ST S
  | EPS
  ;

EPS: {printf(""); /*inutile pero almeno non genera il warning*/}
  ;

ST: VARDECL
  | CSSRULE
  ;

VARDECL: VAR T_COLON EXPR T_SEMICOLON {
  var_contents v = $3;
  
  symrec* symbol = insertSymbol($1,v.type);
  symbol->value.number = v.number;
  symbol->value.string = v.string;

}
  ;

EXPR: VAR 
  {
    if(getSymbol($1->name) > 0) {
      var_contents v;
      v.type = getSymbol($1->name)->type;
      v.string = getSymbol($1->name)->value.string;
      v.number = getSymbol($1->name)->value.number;
      $$ = v;
    } else {
      // crash?
      printf("Variable %s not declared!",$1->name);
    }
  }
  | SCALAR { $$ = $1; }
  | ID {
    var_contents v;
    v.type = VAR_ATOM;
    v.string = $1;
    v.number = 0;
    $$ = v; 
    }
  | FNCALL {
    var_contents v;
    v.type = VAR_FUNCTION;
    v.string = $1;
    $$ = v; 
    }
  | T_PL EXPR T_PR {$$ = $2;}
  | EXPR T_PLUS EXPR {
                      var_contents v; var_contents x; 
                      v = $1; x = $3; 
                      if(v.type == x.type && v.type == 2 && strcmp(v.string, x.string) == 0){
                        var_contents z;
                        z.type = 2;
                        z.string = v.string;
                        z.number = v.number + x.number;
                        $$ = z;
                      } else{ 
                        printf("sum between \"%s\" and \"%s\" not allowed\n", v.string, x.string);
                        var_contents q; //questo evita che nella symbol table se l'operazione non è consentita, non venga salvato il primo elemento ($1), in ogni caso la variabile viene erroneamente salvata
                        $$ = q;
                        }
                      }
  | EXPR T_MINUS EXPR {
                       var_contents v; var_contents x; 
                      v = $1; x = $3; 
                      if(v.type == x.type && v.type == 2 && strcmp(v.string, x.string) == 0){
                        var_contents z;
                        z.type = 2;
                        z.string = v.string;
                        z.number = fabs(v.number - x.number);
                        $$ = z;
                      } else{ 
                        printf("subtraction between \"%s\" and \"%s\" not allowed\n", v.string, x.string);
                        var_contents q; //questo evita che nella symbol table se l'operazione non è consentita, non venga salvato il primo elemento ($1), in ogni caso la variabile viene erroneamente salvata
                        $$ = q;
                        }
                      }
  | EXPR T_STAR EXPR {
                      var_contents v; var_contents x; 
                      v = $1; x = $3; 
                      if(v.type == x.type && v.type == 2 && (strcmp(v.string, "") == 0 || (strcmp(x.string, "") == 0))){
                        var_contents z;
                        z.type = 2;
                        if(strcmp(v.string, "") == 0){
                          z.string = x.string;
                        }
                        else{
                          z.string = v.string;
                        }
                        z.number = v.number * x.number;
                        $$ = z;
                      } else{ 
                        printf("multiplication between \"%s\" and \"%s\" not allowed\n", v.string, x.string);
                        var_contents q; //questo evita che nella symbol table se l'operazione non è consentita, non venga salvato il primo elemento ($1), in ogni caso la variabile viene erroneamente salvata
                        $$ = q;
                        }
                      }
  | EXPR T_DIV EXPR {
                      var_contents v; var_contents x; 
                      v = $1; x = $3; 
                      if(v.type == x.type && v.type == 2 && (strcmp(v.string, "") == 0 || (strcmp(x.string, "") == 0))){
                        var_contents z;
                        z.type = 2;
                        if(strcmp(v.string, "") == 0){
                          z.string = x.string;
                        }
                        else{
                          z.string = v.string;
                        }
                        z.number = v.number / x.number;
                        $$ = z;
                      } else{ 
                        printf("division between \"%s\" and \"%s\" not allowed\n", v.string, x.string);
                        var_contents q; //questo evita che nella symbol table se l'operazione non è consentita, non venga salvato il primo elemento ($1), in ogni caso la variabile viene erroneamente salvata
                        $$ = q;
                      }
                      }
  ;

SCALAR: NUM UNIT {
    var_contents v;
    v.type = VAR_SCALAR;
    v.number = $1;
    v.string = $2;
    $$ = v; 
    }
  | NUM {
    var_contents v;
    v.type = VAR_SCALAR;
    v.number = $1;
    v.string = "";
    $$ = v; 
    }
  ;

FNCALL: ID T_PL P T_PR { $$ = $1; }
  /*| FNNAME T_PL P T_PR*/
  ;

P: EXPR PARAMS 
  | EPS
  ;

PARAMS: T_COMMA EXPR PARAMS
  | EPS
  ;

CSSRULE: SELECTORS T_BL DECLS T_BR {
  // printf("%s { %s }", $1);
  }
  ;

SELECTORS: SELECTOR PSEUDOCLASS RELATIONSHIP { }
  ;

SELECTOR: ID
  | T_HASH ID
  | T_DOT ID
  ;

PSEUDOCLASS: T_COLON ID
  | EPS
  ;

  RELATIONSHIP: T_COMMA SELECTORS
  | T_GT SELECTORS
  | SELECTORS
  | EPS
  ;
  
DECLS: DECL DECLS
  | EPS
  ;
  
DECL: ID T_COLON EXPR T_SEMICOLON
  /* | CSS_DATA_TYPE T_COLON EXPR T_SEMICOLON */
  | CSSRULE
  | VARDECL

%%

symrec *sym_table = 0;

#include "lex.yy.c"

int main(int argc, char *argv[]) 
{      

 // interactive mode or file mode
      if(argc < 2) 
      {
            printf("To exit at any time, press Ctrl+D (EOF).\n");
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