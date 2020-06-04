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
    ID = 264,                      /* ID  */
    EXIT = 265,                    /* EXIT  */
    RETURN = 266,                  /* RETURN  */
    QUIT = 267,                    /* QUIT  */
    OP_COMP = 268,                 /* OP_COMP  */
    IDENTIFIER = 269,              /* IDENTIFIER  */
    NUMBER = 270,                  /* NUMBER  */
    UNIT = 271,                    /* UNIT  */
    ATOM = 272,                    /* ATOM  */
    INHERIT = 273,                 /* INHERIT  */
    PSEUDO = 274,                  /* PSEUDO  */
    T_DOLLAR = 275,                /* T_DOLLAR  */
    T_SEMICOLON = 276,             /* T_SEMICOLON  */
    T_COLON = 277,                 /* T_COLON  */
    T_DOT = 278,                   /* T_DOT  */
    T_COMMA = 279,                 /* T_COMMA  */
    T_HASH = 280,                  /* T_HASH  */
    T_PERCENT = 281,               /* T_PERCENT  */
    T_PX = 282,                    /* T_PX  */
    T_PL = 283,                    /* T_PL  */
    T_PR = 284,                    /* T_PR  */
    T_CBL = 285,                   /* T_CBL  */
    T_CBR = 286,                   /* T_CBR  */
    T_OP = 287,                    /* T_OP  */
    T_OM = 288,                    /* T_OM  */
    T_OS = 289,                    /* T_OS  */
    T_OD = 290,                    /* T_OD  */
    OP_MINUS = 291,                /* OP_MINUS  */
    OP_PLUS = 292,                 /* OP_PLUS  */
    OP_MULT = 293,                 /* OP_MULT  */
    OP_DIV = 294,                  /* OP_DIV  */
    UMINUS = 295,                  /* UMINUS  */
    OP_I = 296                     /* OP_I  */
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
#define ID 264
#define EXIT 265
#define RETURN 266
#define QUIT 267
#define OP_COMP 268
#define IDENTIFIER 269
#define NUMBER 270
#define UNIT 271
#define ATOM 272
#define INHERIT 273
#define PSEUDO 274
#define T_DOLLAR 275
#define T_SEMICOLON 276
#define T_COLON 277
#define T_DOT 278
#define T_COMMA 279
#define T_HASH 280
#define T_PERCENT 281
#define T_PX 282
#define T_PL 283
#define T_PR 284
#define T_CBL 285
#define T_CBR 286
#define T_OP 287
#define T_OM 288
#define T_OS 289
#define T_OD 290
#define OP_MINUS 291
#define OP_PLUS 292
#define OP_MULT 293
#define OP_DIV 294
#define UMINUS 295
#define OP_I 296

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 29 "calc.y"

       
       

#line 153 "y.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
