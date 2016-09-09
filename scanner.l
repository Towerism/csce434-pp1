/*
 * File:	scanner.l
 * ----------------
 * Lex inupt file to generate the scanner for the compiler.
 */

%{

  /* The text within this first region delimited by %{ and %} is assumed to
   * be C/C++ code and will be copied verbatim to the lex.yy.c file ahead
   * of the definitions of the yylex() function. Add other header file inclusions
   * or C++ variable declarations/prototypes that are needed by your code here.
   */

#include <algorithm>
#include <string.h>
#include <string>
#include "scanner.h"
#include "utility.h" // for PrintDebug()
#include "errors.h"

  /* Global variable: yylval
   * -----------------------
   * This global variable is how we get attribute information about the token
   * just scanned to the client. The scanner sets the global variable
   * appropriately and since it's global the client can just read it.	 In the
   * future, this variable will be declared for us in the y.tab.c file
   * produced by Yacc, but for now, we declare it manually.
   */
  YYSTYPE yylval;	 // manually declared for pp1, later Yacc provides

  /* Global variable: yylloc
   * -----------------------
   * This global variable is how we get position information about the token
   * just scanned to the client. (Operates similarly to yylval above)
   */
  struct yyltype yylloc; // manually dclared for pp1, later Yacc provides

  /* Macro: YY_USER_ACTION 
   * ---------------------
   * This flex built-in macro can be defined to provide an action which is
   * always executed prior to any matched rule's action. Basically, it is
   * a way of having a piece of code common to all actions factored out to
   * this routine.	We already defined it for you and left the empty
   * function DoBeforeEachAction ready for your use as needed. It will
   * be called once for each pattern scanned from the file, before
   * executing its action.
   */
  static void DoBeforeEachAction(); 
#define YY_USER_ACTION DoBeforeEachAction();

%}


/* The section before the first %% is the Definitions section of the lex
* input file. Here is where you set options for the scanner, define lex
* states, and can set up definitions to give names to regular expressions
* as a simple substitution mechanism that allows for more readable
* entries in the Rules section later. 
*/
%option noyywrap

SPACE_TAB [ \t]
ENDL \n
IDENTIFIER [:alpha:][[:alnum:]_]*
DIGIT [0-9]

NOT_STRING_END [^\"\n]
STRING \"{NOT_STRING_END}*\"
UNTERMINATED_STRING \"{NOT_STRING_END}*

HEX_ALPHA [a-fA-F]
HEX_SUFFIX_CHAR {DIGIT}|{HEX_ALPHA}
HEX_SUFFIX {HEX_SUFFIX_CHAR}+
HEXADECIMAL 0[xX]{HEX_SUFFIX}

DECIMAL {DIGIT}+

EXPONENT [eE]"+"{DECIMAL}
DOUBLE_MANTISSA "."{DIGIT}+
DOUBLE {DECIMAL}{DOUBLE_MANTISSA}{EXPONENT}?

TRUE "true"
FALSE "false"

PUNCTUATION_1 [\+\-\*/%<>=!;,\.\[\]\(\)\{\}]

LESS_EQUAL "<="
GREATER_EQUAL ">="
EQUAL "=="
NOT_EQUAL "!="
AND "&&"
OR "||"

%%						 /* BEGIN RULES SECTION */
 /* All patterns and actions should be placed between the start and stop
  * %% markers which delimit the Rules section. 
  */ 

{SPACE_TAB} {}

{ENDL} {
  ++yylloc.first_line;
  yylloc.first_column = yylloc.last_column = 1;
}

{IDENTIFIER} {
  std::string lexeme(yytext);
  if (lexeme.length() > MaxIdentLen) {
    ReportError::LongIdentifier(&yylloc, yytext);
  }
  strncpy(yylval.identifier, yytext, MaxIdentLen);
  yylval.identifier[MaxIdentLen] = '\0';
  return T_Identifier;
}

{UNTERMINATED_STRING} ReportError::UntermString(&yylloc, yytext);

{STRING} {
  yylval.stringConstant = yytext;
  return T_StringConstant;
}

{TRUE} {
  yylval.boolConstant = true;
  return T_Bool;
}

{FALSE} {
  yylval.boolConstant = false;
  return T_Bool;
}

{HEXADECIMAL} {
  yylval.integerConstant = std::stoi(yytext, nullptr, 16);
  return T_IntConstant;
}

{DECIMAL} {
  yylval.integerConstant = std::stoi(yytext);
  return T_IntConstant;
}

{DOUBLE} {
  yylval.doubleConstant = std::stod(yytext);
  return T_DoubleConstant;
}

{LESS_EQUAL} return T_LessEqual;
{GREATER_EQUAL} return T_GreaterEqual;
{EQUAL} return T_Equal;
{NOT_EQUAL} return T_NotEqual;
{AND} return T_And;
{OR} return T_Or;

{PUNCTUATION_1} return yytext[0];

. ReportError::UnrecogChar(&yylloc, yytext[0]);

%%
 /* The closing %% above marks the end of the Rules section and the beginning
  * of the User Subroutines section. All text from here to the end of the
  * file is copied verbatim to the end of the generated lex.yy.c file.
  * This section is where you put definitions of helper functions.
  */


 /* function: InitScanner
  * ---------------------
  * This function will be called before any calls to yylex().	It is designed
  * to give you an opportunity to do anything that must be done to initialize
  * the scanner (set global variables, configure starting state, etc.). One
  * thing it already does for you is assign the value of the global variable
  * yy_flex_debug that controls whether flex prints debugging information
  * about each token and what rule was matched. If set to false, no information
  * is printed. Setting it to true will give you a running trail that might
  * be helpful when debugging your scanner. Please be sure the variable is
  * set to false when submitting your final version.
  */
void InitScanner()
{
  PrintDebug("lex", "Initializing scanner");
  yylloc.first_line = yylloc.first_column = yylloc.last_column = 1;
  yy_flex_debug = false;
}


/* Function: DoBeforeEachAction()
 * ------------------------------
 * This function is installed as the YY_USER_ACTION. This is a place
 * to group code common to all actions.
 */
static void DoBeforeEachAction()
{
  std::string lexeme(yytext);
  yylloc.first_column = yylloc.last_column;
  int length = std::max(lexeme.length() - 1, (std::size_t)1);
  yylloc.last_column = yylloc.first_column + length;
}
