#ifndef H_SYMTABLE
#define H_SYMTABLE

#include <stdlib.h>       // needed for malloc. 
#include <string.h>       // needed for strlen.
#include <stdbool.h>
#include <stdio.h>

// variable type enumeration
enum VAR_TYPE {
  VAR_ATOM = 1,
  VAR_SCALAR = 2,
  VAR_FUNCTION = 3,
  VAR_DECLARATION = 4
};


typedef struct {
    char *string;
    double number;
    enum VAR_TYPE type;
} VAR_CONTENTS;

// structure of a symbol record 
typedef struct {
  char *name;           // name of symbol
  VAR_CONTENTS value;
  struct SYMREC *next;  // ptr to next symbol record
  enum VAR_TYPE type;
} SYMREC;

typedef struct
{
  char *name;
  char *value;
  struct DECL *next;
} DECL;

typedef struct
{
  struct TABLE *cur;
  struct TABLES *next;
} TABLES;

typedef struct
{
  char *name;
  SYMREC *head;
  struct TABLES *children;
  struct TABLE *parent;
} TABLE;

extern SYMREC* sym_table;
extern TABLE* parent;
extern TABLES* root_nodes;

/**
* Put a symbol in the specified symbol table
*
* @param sym_name   Specifies the name of symbol to insert
* @param sym_type   Specifies the type of symbol to insert
*
* @return  A pointer to next symbol table record
*/
SYMREC* symbol_put(char const *sym_name)
{
  SYMREC* ptr = (SYMREC*) malloc (sizeof (SYMREC));
  ptr->name = (char*) malloc (strlen (sym_name) + 1);
  strcpy (ptr->name, sym_name);
  ptr->next = (struct SYMREC*)sym_table;
  sym_table = ptr;
  return ptr;
}


/**
* Create a symbol with specified name by allocating memory
*
* @param sym_name   Specifies the name of symbol to insert
*
* @return  A pointer to the created symbol
*/
SYMREC* create_variable_table(char const *sym_name)
{
  SYMREC* ptr = (SYMREC*) malloc (sizeof (SYMREC));
  ptr->name = (char*) malloc (strlen (sym_name) + 1);
  strcpy (ptr->name, sym_name);
  return ptr;
}

/**
* Get a symbol from the symbol table
*
* @param sym_name   Specifies the name of symbol to search for
*
* @return  A pointer to next symbol table record or 0 if not found
*/
SYMREC* get_variable(char const *sym_name)
{
  SYMREC* ptr;
  for (ptr = sym_table; ptr != 0; ptr = (SYMREC*)ptr->next)
   { if (strcmp (ptr->name, sym_name) == 0)
      return ptr;
   }
  return 0;
}


/**
* Insert a symbol in the symbol table 
*
* @param s    Specifies a pointer to the symbol to insert
* @param t    Specifies the type of symbol that has to be inserted
*
* @return  A pointer to next symbol table record
*/
SYMREC* insert_variable(SYMREC* s, enum VAR_TYPE t)
{
  SYMREC *symbol = get_variable(s->name);
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



/**
* Print the entire symbol table in human readable form
*
*/
void print_variables ()
{
  SYMREC* ptr;
  
  printf("---------- ---------- ----------\n");
  printf("%-10s %-10s %-10s", "name", "type", "value");
  printf("\n---------- ---------- ----------\n");
  
  for (ptr = sym_table; ptr != (SYMREC *) 0; ptr = (SYMREC *)ptr->next) 
  {
    printf("%-12.12s ", ptr->name);
    if (ptr->type == VAR_SCALAR) {
      printf("%-10s","scalar");
      printf("%.1f%s", ptr->value.number, ptr->value.string);
        }
    if (ptr->type == VAR_ATOM) {
      printf("%-10s","atom");
      printf("%s", ptr->value.string);
    
    }
    if (ptr->type == VAR_FUNCTION) {
      printf("%-10s","function");
      printf("%s", ptr->value.string);
    }
    printf("\n");
  }
  
}

/**
* Count the number of symbol table records
*
* @return  The number of records
*/
int size ()
{
  SYMREC* ptr;
  int i = 0;
  for (ptr = sym_table; ptr != (SYMREC *) 0; ptr = (SYMREC *)ptr->next) 
  {
    i++;
  }
  return i;
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

void print_decls(TABLE *decls) {
  if(decls != 0) {
    // traversal w/ parent rules listed first
    print_decls((TABLE*) decls->parent);
    SYMREC *c = decls->head;
    while(c != 0) {
      if(c > 0 && c->name[0] != '$')
        printf("%s: %s;\n", c->name, c->value.string);
      c = (SYMREC*) c->next;
    }
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
    case VAR_DECLARATION: // avoiding warning 
    case VAR_FUNCTION:
      ret = strdup(v->string);
      break;
    case VAR_SCALAR:
      ret = malloc(128);
      snprintf(ret, 128, "%.2f%s", v->number, strdup(v->string));
  }
  return ret;
}

#endif