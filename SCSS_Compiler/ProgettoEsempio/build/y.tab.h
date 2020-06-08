/* A Bison parser, made by GNU Bison 3.6.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    LP = 258,                      /* LP  */
    RP = 259,                      /* RP  */
    NUM = 260,                     /* NUM  */
    SEMI = 261,                    /* SEMI  */
    OP_ASSIGN = 262,               /* OP_ASSIGN  */
    OP_EXP = 263,                  /* OP_EXP  */
    IF = 264,                      /* IF  */
    THEN = 265,                    /* THEN  */
    ELSE = 266,                    /* ELSE  */
    ID = 267,                      /* ID  */
    EXIT = 268,                    /* EXIT  */
    RETURN = 269,                  /* RETURN  */
    QUIT = 270,                    /* QUIT  */
    OP_COMP = 271,                 /* OP_COMP  */
    VAR_TYPE = 272,                /* VAR_TYPE  */
    CMP_TYPE = 273,                /* CMP_TYPE  */
    OP_MINUS = 274,                /* OP_MINUS  */
    OP_PLUS = 275,                 /* OP_PLUS  */
    OP_MULT = 276,                 /* OP_MULT  */
    OP_DIV = 277,                  /* OP_DIV  */
    UMINUS = 278,                  /* UMINUS  */
    OP_I = 279                     /* OP_I  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif
/* Token kinds.  */
#define YYEOF 0
#define YYerror 256
#define YYUNDEF 257
#define LP 258
#define RP 259
#define NUM 260
#define SEMI 261
#define OP_ASSIGN 262
#define OP_EXP 263
#define IF 264
#define THEN 265
#define ELSE 266
#define ID 267
#define EXIT 268
#define RETURN 269
#define QUIT 270
#define OP_COMP 271
#define VAR_TYPE 272
#define CMP_TYPE 273
#define OP_MINUS 274
#define OP_PLUS 275
#define OP_MULT 276
#define OP_DIV 277
#define UMINUS 278
#define OP_I 279

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 31 "calc.y"

       char* lexeme;			// token text itself
       double value;			// value of an identifier of type NUM
       Complex complex;             // structure of type Complex
       symrec* symbol;              // structure of type symbol record (for ID)
       enum var_type varType;
       

#line 123 "y.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
