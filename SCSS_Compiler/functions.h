#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <math.h>
#include "symtable.h"

VAR_CONTENTS operations(VAR_CONTENTS v, VAR_CONTENTS x, char *operation);
VAR_CONTENTS get_var(SYMREC *var);
VAR_CONTENTS get_id(char* id);
VAR_CONTENTS get_string(char* string);
VAR_CONTENTS get_fncall(char* fncall);
VAR_CONTENTS scalar_function(double num, char* unit);

void print_cssrule_function();
void selectors_function(char* selectors, char* selector, char* pseudoclass, char* relationship);
void vardecl_function(VAR_CONTENTS v, SYMREC* s);
void cssrule_function_for_selectors(char* selectors);
void cssrule_function_for_decls(SYMREC* s);
SYMREC *decls_function(SYMREC* decl, SYMREC* declsProd);
SYMREC* decl_function(char* id, VAR_CONTENTS* expr);

void print_cssrule_function(){
  TABLES *root_node = (TABLES*) root_nodes;
  while(root_node != 0 && root_node->cur != 0) {
    print_decls_top_down((TABLE*) root_node->cur);
    root_node = (TABLES *) root_node->next;
  }
  // clear nodes we already printed
  root_nodes->cur = 0;
  
}

void cssrule_function_for_selectors(char* sels){
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

void cssrule_function_for_decls(SYMREC* s){ 
  SYMREC *c = s;
  while(c != 0) {
    insert_decl(parent,c->name,c->value.string);
    c = (SYMREC*) c->next;
  }
  parent = (TABLE*) parent->parent;
}

SYMREC *decls_function(SYMREC* decl, SYMREC* declsProd){
  SYMREC *declsHead;
  if(decl != 0) { 
    declsHead = decl;
    declsHead->next = 0;

    if(declsProd > 0) {
      declsHead->next = (struct SYMREC *) declsProd;
    }
  } else {
    declsHead = declsProd;
  }
  return declsHead;
}

void selectors_function(char* selectors, char* selector, char* pseudoclass, char* relationship){
  char *s1 = malloc(BUFFER_SIZE_SMALL);
  strcpy(s1, selector);
  char *s2 = malloc(BUFFER_SIZE_SMALL);
  strcpy(s2, pseudoclass);
  char *s3 = malloc(BUFFER_SIZE_SMALL);
  strcpy(s3, relationship);

  snprintf(selectors,BUFFER_SIZE_SMALL,"%s%s %s", s1, s2, s3);
}


void vardecl_function(VAR_CONTENTS var, SYMREC* sym){
  VAR_CONTENTS v = var;
  SYMREC* symbol = insert_variable(sym, v.type);
  symbol->value.number = v.number;
  symbol->value.string = v.string;
}

SYMREC* decl_function(char* id, VAR_CONTENTS* expr){
  SYMREC *d = malloc(sizeof(SYMREC));
  d->name = strdup(id);
  d->value.string = var_to_string(expr);
  d->next = 0;
  d->type = VAR_DECLARATION;
  return d;
}


VAR_CONTENTS get_var(SYMREC* var){

  if(get_variable(var->name) > 0) {
      VAR_CONTENTS v;
      v.type = get_variable(var->name)->type;
      v.string = get_variable(var->name)->value.string;
      v.number = get_variable(var->name)->value.number;
      return v;
    } else {
      extern int yylineno;
      fprintf(stderr, "!!! ERROR at line %d: Variable %s not declared !!!", yylineno, var->name);
      exit(1);
    }

} 

VAR_CONTENTS get_id(char* id){
  VAR_CONTENTS v;
  v.type = VAR_ATOM;
  v.string = strdup(id);
  v.number = 0;
  return v; 
}

VAR_CONTENTS get_string(char* string){
  VAR_CONTENTS v;
  v.type = VAR_ATOM;
  v.string = strdup(string);
  v.number = 0;
  return v; 
}


VAR_CONTENTS get_fncall(char* fncall){
  VAR_CONTENTS v;
  v.type = VAR_FUNCTION;
  v.string = strdup(fncall);
  return v; 
}

VAR_CONTENTS scalar_function(double num, char* unit){
  VAR_CONTENTS v;
  v.type = VAR_SCALAR;
  v.number = num;
  v.string = strdup(unit);
  return v;
}

VAR_CONTENTS operations(VAR_CONTENTS v, VAR_CONTENTS x, char* operation){

    VAR_CONTENTS z;

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
             extern int yylineno;
             fprintf(stderr, "!!! ERROR at line %d: multiplication between \"%s\" and \"%s\" not allowed !!!\n", yylineno, v.string, x.string);
             exit(1);
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
             extern int yylineno;
             fprintf(stderr, "!!! ERROR at line %d: division between \"%s\" and \"%s\" not allowed !!!\n", yylineno, v.string, x.string);
             exit(1);
        }
    }
    
    return z;
}