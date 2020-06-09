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
 */


//BUGS
// - prod di relationship
// - numeri con - passati come identifier invece che come espressioni -> precedenza 

#define YYERROR_VERBOSE 1
#define BUFFER_SIZE_SMALL 128
#define BUFFER_SIZE_LARGE 1024

#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <math.h>
#include "header/scssFunctions.h"
#include "header/symtable.h"
#include "header/error.h"

int yylex();
void yyerror (char const *message);
VAR_CONTENTS operations(VAR_CONTENTS v, VAR_CONTENTS x, char *operation);



%}
// in this way, the expected token will be printed whenever possible
%error-verbose

// here we define all return values that lex can return

%union {
        char* string;
        double number;
        SYMREC *sym;
        DECLARATIONS *decls;
        DECL *decl;
        VAR_CONTENTS expression;
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
%token            T_GT
/* %token            CSS_DATA_TYPE  
%token            HTML_DATA_TYPE 
%token            FNNAME */

%type <expression>   EXPR
%type <expression>   SCALAR
%type <decls>        CSSRULE
%type <decl>         DECLS
%type <decl>         DECL
%type <string>       FNCALL
%type <string>       SELECTORS 
%type <string>       SELECTOR 
%type <string>       PSEUDOCLASS 
%type <string>       RELATIONSHIP 
%type <string>       EPS 
%type <string>       P 
%type <string>       PARAMS


%left T_MINUS T_PLUS
%left T_STAR T_DIV



%start S

// here we define the grammar

%%

// line and statement rules



S: ST S
  | EPS
  ;

EPS: { $$ = ""; }
  ;

ST: VARDECL
  | CSSRULE
  ;

VARDECL: VAR T_COLON EXPR T_SEMICOLON {
  VAR_CONTENTS v = $3;
  
  SYMREC* symbol = insert_variable($1,v.type);
  symbol->value.number = v.number;
  symbol->value.string = v.string;

}
  ;

EXPR: VAR 
  {
    if(get_variable($1->name) > 0) {
      VAR_CONTENTS v;
      v.type = get_variable($1->name)->type;
      v.string = get_variable($1->name)->value.string;
      v.number = get_variable($1->name)->value.number;
      $$ = v;
    } else {
      // crash?
      printf("Variable %s not declared!",$1->name);
    }
  }
  | SCALAR { $$ = $1; }
  | ID {
    VAR_CONTENTS v;
    v.type = VAR_ATOM;
    v.string = $1;
    v.number = 0;
    $$ = v; 
    }
  | FNCALL {
    VAR_CONTENTS v;
    v.type = VAR_FUNCTION;
    v.string = $1;
    $$ = v; 
    }
  | T_PL EXPR T_PR {$$ = $2;}
  | EXPR T_PLUS EXPR  {$$ = operations($1, $3, "+");}
  | EXPR T_MINUS EXPR {$$ = operations($1, $3, "-");}
  | EXPR T_STAR EXPR {$$ = operations($1, $3, "*");}
  | EXPR T_DIV EXPR  {$$ = operations($1, $3, "/");}
  ;

SCALAR: NUM UNIT {
    VAR_CONTENTS v;
    v.type = VAR_SCALAR;
    v.number = $1;
    v.string = $2;
    $$ = v; 
    }
  | NUM {
    VAR_CONTENTS v;
    v.type = VAR_SCALAR;
    v.number = $1;
    v.string = "";
    $$ = v; 
    }
  ;

FNCALL: ID T_PL P T_PR { 
  $$ = malloc(BUFFER_SIZE_SMALL);
  snprintf($$, BUFFER_SIZE_SMALL, "%s(%s)", strdup($1), strdup($3));
  }
  /*| FNNAME T_PL P T_PR*/
  ;

P: EXPR PARAMS { 
  $$ = malloc(BUFFER_SIZE_SMALL);
  snprintf($$, BUFFER_SIZE_SMALL, "%s%s", strdup(var_to_string(&$1)), strdup($2));
  }
  | EPS
  ;

PARAMS: T_COMMA EXPR PARAMS { 
  $$ = malloc(BUFFER_SIZE_SMALL);
  snprintf($$, BUFFER_SIZE_SMALL, ",%s%s", strdup(var_to_string(&$2)), strdup($3));
  }
  | EPS
  ;

/* bugs bugs bugs */
CSSRULE: SELECTORS 
    {
      DECLARATIONS *d = parent;
      char *selectors = strdup($1);
      while(d != 0) {
        char *s2 = strdup(selectors);
        snprintf(selectors, BUFFER_SIZE_SMALL, "%s %s", d->name, s2);
        d = (DECLARATIONS*) d->parent;
      }

      printf("%s { \n", selectors); // print parent selectors as well!
      parent = create_decl_table($1,parent);
      
      printf("}\n");
    } 
    T_BL DECLS T_BR 
    { 
      // todo: serious logical bugs -> iteratively insert all of cur layers contents
      DECL *c = $4;
      while(c != 0) {
        insert_decl(parent,c->name,c->value);
        c = (DECL*) c->next;
      }
      print_decls(parent);
      parent = (DECLARATIONS*) parent->parent;
    }
  ;

SELECTORS: SELECTOR PSEUDOCLASS RELATIONSHIP {
  char *s1 = malloc(BUFFER_SIZE_SMALL);
  strcpy(s1, $1);
  char *s2 = malloc(BUFFER_SIZE_SMALL);
  strcpy(s2, $2);
  char *s3 = malloc(BUFFER_SIZE_SMALL);
  strcpy(s3, $3);

  snprintf($$,BUFFER_SIZE_SMALL,"%s%s %s", s1, s2, s3);
}
  ;

SELECTOR: ID { $$ = $1; }
  | T_HASH ID { $$ = malloc(BUFFER_SIZE_SMALL);  snprintf($$, BUFFER_SIZE_SMALL, "#%s", strdup($2)); }
  | T_DOT ID { $$ = malloc(BUFFER_SIZE_SMALL); snprintf($$, BUFFER_SIZE_SMALL, ".%s", strdup($2)); }
  ;

PSEUDOCLASS: T_COLON ID { $$ = malloc(BUFFER_SIZE_SMALL); snprintf($$, BUFFER_SIZE_SMALL, ":%s", strdup($2)); }
  | EPS
  ;

  RELATIONSHIP: T_COMMA SELECTORS { $$ = malloc(BUFFER_SIZE_SMALL); snprintf($$, BUFFER_SIZE_SMALL, ",%s", strdup($2)); }
  | T_GT SELECTORS { $$ = malloc(BUFFER_SIZE_SMALL); snprintf($$, BUFFER_SIZE_SMALL, "> %s", strdup($2)); }
  | SELECTORS { $$ = $1; }
  | EPS
  ;
  
DECLS: DECL DECLS { 
  //$$->next = 0;

  if($2 > 0) {
    //$$->next = $2;
  }
}
  | EPS { $$ = 0; }
  ;
  
DECL: ID T_COLON EXPR T_SEMICOLON {
  DECL *d = malloc(sizeof(DECL));
  d->name = $1;
  d->value = var_to_string(&$3);
  d->next = 0;
  $$ = d;
}
  | CSSRULE {$$ = 0; /* handled at lower level */}
  | VARDECL {$$ = 0; /*nothing to do */}

%%

SYMREC *sym_table = 0;
DECLARATIONS *parent = 0;

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

void yyerror (char const *message)
{
  extern int yylineno;
  fprintf (stderr, "\n!!! ERROR at line %d: %s !!!\n  ", yylineno, message);
  fputc ('\n', stderr);
}

VAR_CONTENTS operations(VAR_CONTENTS v, VAR_CONTENTS x, char* operation){

    VAR_CONTENTS z;
    VAR_CONTENTS q; 

    if(strcmp(operation, "+") == 0 || strcmp(operation, "-") == 0){
        if(v.type == x.type && v.type == 2 && strcmp(v.string, x.string) == 0){
            z.type = 2;
            z.string = v.string;
            if(strcmp(operation, "+") == 0){
                z.number = v.number + x.number;
            }
            else{
                z.number = v.number - x.number;
            }
        } 
        else{ 
            if(strcmp(operation, "+") == 0){
              printf("ERROR: sum between \"%s\" and \"%s\" not allowed\n", v.string, x.string);
            }
            else{
              printf("ERROR: subtraction between \"%s\" and \"%s\" not allowed\n", v.string, x.string);
            }
            return q;
        }
    }

    if(strcmp(operation, "*") == 0){
        if(v.type == x.type && v.type == 2 && (strcmp(v.string, "") == 0 || (strcmp(x.string, "") == 0))){
            z.type = 2;
            if(strcmp(v.string, "") == 0){
                z.string = x.string;
            }
            else{
                z.string = v.string;
            }
                z.number = v.number * x.number;
        } 
        else{ 
             printf("ERROR: multiplication between \"%s\" and \"%s\" not allowed\n", v.string, x.string);
             return q;
        }
    }

      if(strcmp(operation, "/") == 0){
        if(v.type == x.type && v.type == 2 && (strcmp(v.string, "") == 0 || (strcmp(x.string, "") == 0))){
            z.type = 2;
            if(strcmp(v.string, "") == 0){
                z.string = x.string;
            }
            else{
                z.string = v.string;
            }
                z.number = v.number / x.number;
        }
        else if((strcmp(x.string, v.string) == 0)){
          z.type = 2;
          z.string = "";
          z.number = v.number / x.number;
        }
        else{ 
             printf("ERROR: division between \"%s\" and \"%s\" not allowed\n", v.string, x.string);
             return q;
        }
    }
    return z;
}