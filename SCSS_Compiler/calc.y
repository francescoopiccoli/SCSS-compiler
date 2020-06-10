%{
/** @file calc.y
 *  @brief Grammar rules for the scss compiler/preprocessor.
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

%}
// useful for syntax error debugging
%define parse.error verbose

// here we define all the possible return values

%union {
        char* string;
        double number;
        SYMREC *sym;
        TABLE *decls;
        SYMREC *decl;
        VAR_CONTENTS expression;
       }



// here we define the tokens with its respective precedences

%token<string>    ID
%token<number>    NUM
%token<string>    UNIT
%token<string>    PSEUDO
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

// here we define the type of non-terminals

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
%type <string>       P 
%type <string>       PARAMS

//precedence rules
%left T_MINUS T_PLUS
%left T_STAR T_DIV

//S is the starting symbol
%start S


%%

// here we define the grammar productions

S: ST S
  | {}
  ;

ST: VARDECL
  | CSSRULE
  ;

VARDECL: VAR T_COLON EXPR T_SEMICOLON { vardecl_function($3, $1);}
  ;

EXPR: VAR { $$ = assign_var($1); }
  | SCALAR { $$ = $1; }
  | ID {  $$ = assign_id($1); }
  | FNCALL { $$ = assign_fncall($1); }
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
    v.string = strdup($2);
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
  | {$$="";}
  ;

PARAMS: T_COMMA EXPR PARAMS { 
  $$ = malloc(BUFFER_SIZE_SMALL);
  snprintf($$, BUFFER_SIZE_SMALL, ",%s%s", strdup(var_to_string(&$2)), strdup($3));
  }
  | {$$="";}
  ;

/* bugs bugs bugs */
CSSRULE: SELECTORS 
    {
      TABLE *d = parent;
      char *selectors = strdup($1);
      while(d != 0) {
        char *s2 = strdup(selectors);
        snprintf(selectors, BUFFER_SIZE_SMALL, "%s %s", d->name, s2);
        d = (TABLE*) d->parent;
      }

      printf("%s { \n", selectors); // print parent selectors as well!
      parent = create_decl_table($1,parent);
    } 
    T_BL DECLS T_BR 
    { 
      // todo: serious logical bugs -> iteratively insert all of cur layers contents
      SYMREC *c = $4;
      while(c != 0) {
        insert_decl(parent,c->name,c->value.string);
        c = (SYMREC*) c->next;
      }
      print_decls(parent);
      
      printf("}\n");
      parent = (TABLE*) parent->parent;
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

PSEUDOCLASS: PSEUDO { $$ = malloc(BUFFER_SIZE_SMALL); snprintf($$, BUFFER_SIZE_SMALL, "%s", strdup($1)); }
  | {$$="";}
  ;

  RELATIONSHIP: T_COMMA SELECTORS { $$ = malloc(BUFFER_SIZE_SMALL); snprintf($$, BUFFER_SIZE_SMALL, ",%s", strdup($2)); }
  | T_GT SELECTORS { $$ = malloc(BUFFER_SIZE_SMALL); snprintf($$, BUFFER_SIZE_SMALL, "> %s", strdup($2)); }
  | SELECTORS { $$ = $1; }
  | {$$="";}
  ;
  
DECLS: DECL DECLS {
  if($1 != 0) { 
    $$ = $1;
    $$->next = 0;

    if($2 > 0) {
      $$->next = (struct SYMREC *) $2;
    }
  } else {
    $$ = $2;
  }
}
  | {$$ = 0;}
  ;
  
DECL: ID T_COLON EXPR T_SEMICOLON {
  SYMREC *d = malloc(sizeof(SYMREC));
  d->name = strdup($1);
  d->value.string = var_to_string(&$3);
  d->next = 0;
  d->type = VAR_DECLARATION;
  $$ = d;
}
  | CSSRULE {$$ = 0; /* handled at lower level */}
  | VARDECL {$$ = 0; /*nothing to do */}

%%

SYMREC *sym_table = 0;
TABLE *parent = 0;

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