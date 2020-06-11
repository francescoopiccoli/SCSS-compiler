#ifndef H_FUNCTIONS
#define H_FUNCTIONS

#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <math.h>
#include "symtable.h"


/*
 * Prints all CSS declaration "trees" from root nodes
 */
void print_css_tree();

/*
 * Initialize the hierarchical table for CSS declarations
 */
void css_decl_table_init(char* sels);

/*
 * Insert all CSS declarations from a list in the a table
 */
void css_decl_insert_all(TABLE *t, SYMREC* s);

/*
 * Append a list of declarations after a single declaration
 */
SYMREC *css_decl_merge(SYMREC* decl, SYMREC* declsProd);

/*
 * Converts a list of selectors to a string
 */
char *selector_to_string(char* selector, char* pseudoclass, char* relationship);

/*
 * Declares a new variable
 */
void declare_variable(SYMREC* sym, VAR_CONTENTS contents);


/*
 * Generate various types of accepted variables from raw parameters
 */
VAR_CONTENTS generate_var(SYMREC *var);
VAR_CONTENTS generate_id(char* id);
VAR_CONTENTS generate_atom(char* string);
VAR_CONTENTS generate_fncall(char* fncall);
VAR_CONTENTS generate_scalar(double num, char* unit);
SYMREC* generate_decl(char* id, VAR_CONTENTS* expr);

/*
 * Compute an arithmetic scalar operation on two variables
 */
VAR_CONTENTS operation(VAR_CONTENTS v, VAR_CONTENTS x, char *operation);


void print_css_tree() {
  TABLES *root_node = (TABLES*) root_nodes;
  while(root_node != 0 && root_node->cur != 0) {
    print_decls_top_down((TABLE*) root_node->cur);
    root_node = (TABLES *) root_node->next;
  }
  // clear all nodes we already printed -> work there is "done"
  root_nodes->cur = 0;
  
}

void css_decl_table_init(char* sels) {
  char *selectors = malloc(BUFFER_SIZE_SMALL);
  if(parent != 0) {
    snprintf(selectors, BUFFER_SIZE_SMALL, "%s%s", parent->name, strdup(sels));
  } else {
    snprintf(selectors, BUFFER_SIZE_SMALL, "%s", strdup(sels));
  }

  parent = create_decl_table(selectors,parent);
  if(parent->parent == 0) {
    add_table(root_nodes,parent);
  }
}

void css_decl_insert_all(TABLE *t, SYMREC* s) { 
  SYMREC *c = s;
  while(c != 0) {
    insert_decl(t,c->name,c->value.string);
    c = (SYMREC*) c->next;
  }
}

SYMREC *css_decl_merge(SYMREC* decl, SYMREC* decls) {
  SYMREC *declsHead;
  if(decl != 0) { 
    declsHead = decl;
    declsHead->next = 0;

    if(decl > 0) {
      declsHead->next = (struct SYMREC *) decls;
    }
  } else {
    declsHead = decls;
  }
  return declsHead;
}

char *selector_to_string(char* selector, char* pseudoclass, char* relationship) {
  char *s1 = malloc(BUFFER_SIZE_SMALL);
  strcpy(s1, selector);
  char *s2 = malloc(BUFFER_SIZE_SMALL);
  strcpy(s2, pseudoclass);
  char *s3 = malloc(BUFFER_SIZE_SMALL);
  strcpy(s3, relationship);
  char *ret = malloc(BUFFER_SIZE_SMALL);

  snprintf(ret,BUFFER_SIZE_SMALL,"%s%s %s", s1, s2, s3);
  return ret;
}


void declare_variable(SYMREC* sym, VAR_CONTENTS contents) {
  SYMREC* symbol = insert_variable(sym, contents.type);
  symbol->value.number = contents.number;
  symbol->value.string = strdup(contents.string);
}

SYMREC* generate_decl(char* id, VAR_CONTENTS* expr) {
  SYMREC *d = malloc(sizeof(SYMREC));
  d->name = strdup(id);
  d->value.string = var_to_string(expr);
  d->next = 0;
  d->type = VAR_DECLARATION;
  return d;
}


VAR_CONTENTS generate_var(SYMREC* var) {

  if(generate_variable(var->name) > 0) {
      VAR_CONTENTS v;
      v.type = generate_variable(var->name)->type;
      v.string = generate_variable(var->name)->value.string;
      v.number = generate_variable(var->name)->value.number;
      return v;
    } else {
      extern int yylineno;
      fprintf(stderr, "!!! ERROR at line %d: Variable %s not declared !!!", yylineno, var->name);
      exit(1);
    }

} 

VAR_CONTENTS generate_id(char* id) {
  VAR_CONTENTS v;
  v.type = VAR_ATOM;
  v.string = strdup(id);
  v.number = 0;
  return v; 
}

VAR_CONTENTS generate_atom(char* string) {
  VAR_CONTENTS v;
  v.type = VAR_ATOM;
  v.string = strdup(string);
  v.number = 0;
  return v; 
}


VAR_CONTENTS generate_fncall(char* fncall) {
  VAR_CONTENTS v;
  v.type = VAR_FUNCTION;
  v.string = strdup(fncall);
  return v; 
}

VAR_CONTENTS generate_scalar(double num, char* unit) {
  VAR_CONTENTS v;
  v.type = VAR_SCALAR;
  v.number = num;
  v.string = strdup(unit);
  return v;
}

VAR_CONTENTS operation(VAR_CONTENTS v, VAR_CONTENTS x, char* operation) {

    VAR_CONTENTS z;

    if(strcmp(operation, "+") == 0 || strcmp(operation, "-") == 0) {
        if(v.type == x.type && v.type == 2 && strcmp(v.string, x.string) == 0) {
            z.type = 2;
            z.string = v.string;
            if(strcmp(operation, "+") == 0) {
                z.number = v.number + x.number;
            }
            else{
                z.number = v.number - x.number;
            }
        } 
        else{ 
            if(strcmp(operation, "+") == 0) {
              extern int yylineno;
              fprintf(stderr, "!!! ERROR at line %d: sum between \"%s\" and \"%s\" not allowed !!!\n", yylineno, v.string, x.string);
              exit(1);
            }
            else{
              extern int yylineno;
              fprintf(stderr, "!!! ERROR at line %d: subtraction between \"%s\" and \"%s\" not allowed !!!\n", yylineno, v.string, x.string);
              exit(1);
            }
        }
    }

    if(strcmp(operation, "*") == 0) {
        if(v.type == x.type && v.type == 2 && (strcmp(v.string, "") == 0 || (strcmp(x.string, "") == 0))) {
            z.type = 2;
            if(strcmp(v.string, "") == 0) {
                z.string = x.string;
            }
            else{
                z.string = v.string;
            }
                z.number = v.number * x.number;
        } 
        else{ 
             extern int yylineno;
             fprintf(stderr, "!!! ERROR at line %d: multiplication between \"%s\" and \"%s\" not allowed !!!\n", yylineno, v.string, x.string);
             exit(1);
        }
    }

      if(strcmp(operation, "/") == 0) {
        if(v.type == x.type && v.type == 2 && (strcmp(v.string, "") == 0 || (strcmp(x.string, "") == 0))) {
            z.type = 2;
            if(strcmp(v.string, "") == 0) {
                z.string = x.string;
            }
            else{
                z.string = v.string;
            }
                z.number = v.number / x.number;
        }
        else if((strcmp(x.string, v.string) == 0)) {
          z.type = 2;
          z.string = "";
          z.number = v.number / x.number;
        }
        else{
             extern int yylineno;
             fprintf(stderr, "!!! ERROR at line %d: division between \"%s\" and \"%s\" not allowed !!!\n", yylineno, v.string, x.string);
             exit(1);
        }
    }
    
    return z;
}

#endif