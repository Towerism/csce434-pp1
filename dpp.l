/*
 * file:  dpp.l
 * ------------
 * Lex inupt file to generate the scanner for the preprocessor.
 * If you decide to use lex for the preprocesor, put your rules
 * here, otherwise the file can remain empty.
 */

%{
#include <string.h>
#include <iostream>
#include <regex>
#include <string>
#include <unordered_map>
#include "scanner.h"
#include "errors.h"

  static void returnText(char* text);
  static void beginComment();
  static void beginInitial();

  std::unordered_map<std::string, std::string> substitute_map;

  void InitPreprocessor();
%}

%s COMMENT

%option noyywrap

SPACE_TAB [ \t]
ENDL \n
WHITESPACE {SPACE_TAB}|{ENDL}
NOT_ENDL [^\n]

NOT_STRING_END [^\"\n]
STRING \"{NOT_STRING_END}*\"

NOT_WHITESPACE [^ \t\n]

UPCASE [A-Z]
SUBSTITUTION_NAME {UPCASE}+
SUBSTITUTION .*

BEGIN_DEFINITION "#define"
DEFINITION {BEGIN_DEFINITION}" "{SUBSTITUTION_NAME}" "{SUBSTITUTION}
BAD_DEFINITION #[dD][eE][fF][iI][nN][eE]" "*[a-zA-Z0-9]+" "*{SUBSTITUTION}

REPLACEMENT #{SUBSTITUTION_NAME}
BAD_REPLACEMENT #[a-zA-Z0-9]+

SINGLE_LINE_COMMENT "//".*
BEGIN_MULTI_COMMENT "/*"
END_MULTI_COMMENT "*/"

%%

<*>{ENDL} {
  ++yylineno;
  returnText(yytext);
};

{SPACE_TAB} returnText(yytext);

{STRING} returnText(yytext);

{DEFINITION} {
  std::regex define("#define[ ]([A-Z]+)\[ ]([^\n]*)");
  std::cmatch cm;
  std::regex_match(yytext, cm, define);
  std::string key(cm[1]);
  substitute_map[key] = cm[2];
}

{BAD_DEFINITION} ReportError::InvalidDirective(yylineno);

{REPLACEMENT} {
  std::regex replace("#([A-Z]+)");
  std::cmatch cm;
  std::regex_match(yytext, cm, replace);
  std::string key(cm[1]);
  auto replacement = substitute_map.find(key);
  if (replacement == substitute_map.end())
    ReportError::InvalidDirective(yylineno);
  std::cout << substitute_map[key];
}

{BAD_REPLACEMENT} ReportError::InvalidDirective(yylineno);

<INITIAL>{SINGLE_LINE_COMMENT} {}
<INITIAL>{BEGIN_MULTI_COMMENT} beginComment();
<COMMENT>{END_MULTI_COMMENT} beginInitial();
<COMMENT>{NOT_WHITESPACE} {}
<COMMENT><<EOF>> ReportError::UntermComment();

{NOT_WHITESPACE} returnText(yytext);

%%

void InitPreprocessor() {
  yylineno = 1;
  yy_flex_debug = false;
  BEGIN(INITIAL);
}

void returnText(char* text) {
  std::cout << text;
}

void beginComment() {
  BEGIN(COMMENT);
}

void beginInitial() {
  BEGIN(INITIAL);
}
