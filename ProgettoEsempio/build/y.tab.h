/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

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

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    LP = 258,
    RP = 259,
    NUM = 260,
    SEMI = 261,
    OP_ASSIGN = 262,
    OP_EXP = 263,
    IF = 264,
    THEN = 265,
    ELSE = 266,
    ID = 267,
    EXIT = 268,
    RETURN = 269,
    QUIT = 270,
    OP_COMP = 271,
    VAR_TYPE = 272,
    CMP_TYPE = 273,
    OP_MINUS = 274,
    OP_PLUS = 275,
    OP_MULT = 276,
    OP_DIV = 277,
    UMINUS = 278,
    OP_I = 279
  };
#endif
/* Tokens.  */
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
#line 31 "calc.y" /* yacc.c:1915  */

       char* lexeme;			// token text itself
       double value;			// value of an identifier of type NUM
       Complex complex;             // structure of type Complex
       symrec* symbol;              // structure of type symbol record (for ID)
       enum var_type varType;
       

#line 111 "y.tab.h" /* yacc.c:1915  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
