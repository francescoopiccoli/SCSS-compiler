#ifndef H_SYMTABLE
#define H_SYMTABLE

/* 
 * Symbol table related structures and functions
 */

#include <stdlib.h>       // needed for malloc. 
#include <string.h>       // needed for strlen.
#include <stdbool.h>
#include <stdio.h>
#include <math.h>

/*
 * Accepted variable types
 */
enum VAR_TYPE {
  VAR_ATOM = 1,
  VAR_SCALAR = 2,
  VAR_FUNCTION = 3,
  VAR_DECLARATION = 4
};

/*
 * Content of any accepted variable
 */
typedef struct {
    char *string;
    double number;
    enum VAR_TYPE type;
} VAR_CONTENTS;

/*
 * Symbol table record, supporting list-like features
 */
typedef struct {
  char *name;           // name of symbol (e.g. var name starting with dollar, or CSS selector)
  VAR_CONTENTS value;
  struct SYMREC *next;
  enum VAR_TYPE type;
} SYMREC;

/*
 * List of lists/tables, e.g. the list of all root nodes
 */
typedef struct
{
  struct TABLE *cur;
  struct TABLES *next;
} TABLES;

/*
 * Named tree-like (symbol) table, with pointers to both parents and children to allow for both top-down and bottom-up navigation
 */
typedef struct
{
  char *name;
  SYMREC *head;
  struct TABLES *children;
  struct TABLE *parent;
} TABLE;

// refs to global variables
extern SYMREC* sym_table;
extern TABLE* parent;
extern TABLES* root_nodes;

/*
 * Insert new item into global variables
 */
SYMREC* symbol_put(char const *sym_name);
/*
 * Create new pointer/table for global variables
 */
SYMREC* create_variable_table(char const *sym_name);

/*
 * Generate a new variable from its name
 */
SYMREC* generate_variable(char const *sym_name);

/*
 * Insert new item into global variables
 */
SYMREC* insert_variable(SYMREC* s, enum VAR_TYPE t);

/*
 * Print all global variables to the console for debugging purposes
 */
void print_variables();

/*
 * Add a table (e.g. a root node) to a list of tables
 */
void add_table(TABLES *list, TABLE *node);

/*
 * Insert CSS declaration in a symbol table
 */
void insert_decl(TABLE *decls, char *name, char *value);

/*
 * Print all CSS declaration in a node using a "top-down" algorithm (that is, from outer to inner layers)
 */
void print_decls_top_down(TABLE *decls);

/*
 * Convert variable to a CSS-accepted string
 */
char* var_to_string(VAR_CONTENTS *v);

SYMREC* symbol_put(char const *sym_name)
{
  SYMREC* ptr = (SYMREC*) malloc (sizeof (SYMREC));
  ptr->name = (char*) malloc (strlen (sym_name) + 1);
  strcpy (ptr->name, sym_name);
  ptr->next = (struct SYMREC*)sym_table;
  sym_table = ptr;
  return ptr;
}

SYMREC* create_variable_table(char const *sym_name)
{
  SYMREC* ptr = (SYMREC*) malloc (sizeof (SYMREC));
  ptr->name = (char*) malloc (strlen (sym_name) + 1);
  strcpy (ptr->name, sym_name);
  return ptr;
}

SYMREC* generate_variable(char const *sym_name)
{
  SYMREC* ptr;
  for (ptr = sym_table; ptr != 0; ptr = (SYMREC*)ptr->next)
   { if (strcmp (ptr->name, sym_name) == 0)
      return ptr;
   }
  return 0;
}

SYMREC* insert_variable(SYMREC* s, enum VAR_TYPE t)
{
  SYMREC *symbol = generate_variable(s->name);
  if(symbol == 0) {
    s->type = t;
    s->next = (struct SYMREC*)sym_table;
    sym_table = s;
    return s;
  } else {
    symbol->type = t;
    return s;
  }

}

void print_variables()
{
  SYMREC* ptr;
  
  fprintf(stderr,"---------- ---------- ----------\n");
  fprintf(stderr,"%-10s %-10s %-10s", "name", "type", "value");
  fprintf(stderr,"\n---------- ---------- ----------\n");
  
  for (ptr = sym_table; ptr != (SYMREC *) 0; ptr = (SYMREC *)ptr->next) 
  {
    fprintf(stderr,"%-12.12s ", ptr->name);
    if (ptr->type == VAR_SCALAR) {
      fprintf(stderr,"%-10s","scalar");
      if(ptr->value.number == round(ptr->value.number)) {
        fprintf(stderr,"%.0f%s", ptr->value.number, ptr->value.string);
      }
      else{
        fprintf(stderr,"%.2f%s", ptr->value.number, ptr->value.string);
      }
    }
    if (ptr->type == VAR_ATOM) {
      fprintf(stderr,"%-10s","atom");
      fprintf(stderr,"%s", ptr->value.string);
    
    }
    if (ptr->type == VAR_FUNCTION) {
      fprintf(stderr,"%-10s","function");
      fprintf(stderr,"%s", ptr->value.string);
    }
    fprintf(stderr,"\n");
  }
  
}

void add_table(TABLES *list, TABLE *node) {
  TABLES *c = list;

  if(c->cur != 0) {
    while(c->next != 0)
      c = (TABLES*) c->next;

    TABLES *n = malloc(sizeof(TABLES));
    c->next = (struct TABLES *) n;
    n->cur = (struct TABLE *) node;
  } else {
    c->cur = (struct TABLE *) node;
  }
}

TABLE *create_decl_table(char *name, TABLE *parent) {
  TABLE *d = (TABLE*) malloc(sizeof(TABLE));
  d->name = name;
  d->parent = (struct TABLE*) parent;
  d->head = 0;

  struct TABLES *children = malloc(sizeof(TABLES));
  d->children = children;

  if(parent != 0) {
    if(parent->children == 0)
      parent->children = malloc(sizeof(TABLES*));

    add_table((TABLES*) parent->children,d);
  }
  return d;
}

void insert_decl(TABLE *decls, char *name, char *value) {
  SYMREC *d = malloc(sizeof(SYMREC));
  d->name = strdup(name);
  d->value.string = strdup(value);
  d->type = VAR_DECLARATION;
  d->next = 0;

  if(decls->head > 0) {
    SYMREC *last = decls->head;
    while(last->next != 0)
      last = (SYMREC*) last->next;
    last->next = (struct SYMREC*) d;
  } else {
    decls->head = d; 
  }
}
void print_decls_top_down(TABLE *decls) {
  if(decls != 0) {
    printf("%s {\n", decls->name);

    TABLE *d = decls;
    while(d != 0) {
      SYMREC *c = d->head;
      while(c != 0) {
        if(c > 0 && c->name[0] != '$')
          printf("\t%s: %s;\n", c->name, c->value.string);
        c = (SYMREC*) c->next;
      }
      d = (TABLE*) d->parent;
    }
    printf("}\n\n");

    TABLES *child = (TABLES*) decls->children;
    while(child != 0 && child->cur != 0) {
      print_decls_top_down((TABLE*) child->cur);
      child = (TABLES *) child->next;
    }
  }
}

char* var_to_string(VAR_CONTENTS *v) {
  char *ret;
  switch(v->type) {
    case VAR_ATOM:
    case VAR_DECLARATION:
    case VAR_FUNCTION:
      ret = strdup(v->string);
      break;
    case VAR_SCALAR:
      ret = malloc(128);

      if(v->number == round(v->number))
        snprintf(ret, 128, "%.0f%s", v->number, strdup(v->string));
      else
        snprintf(ret, 128, "%.2f%s", v->number, strdup(v->string));
      
  }
  return ret;
}

#endif