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
#include <boost/regex.hpp>
#include <string>
#include <unordered_map>
#include "scanner.h"
#include "errors.h"

  static void returnText(const char* text);
  static void beginComment();
  static boost::cmatch regexMatch(char* s, std::string expression);
  static bool replacementKeyIsInvalid(std::string key);
  static void beginBadDirective(bool discardLine = false);
  static void leaveState();
  static void returnEndl();

  std::unordered_map<std::string, std::string> substitute_map;

  void InitPreprocessor();
%}

%s COMMENT
%s BAD_DIRECTIVE

%option noyywrap
%option stack

SPACE_TAB [ \t]
ENDL \n
WHITESPACE [[:space:]]
NOT_ENDL [^\n]

NOT_STRING_END [^\"\n]
STRING \"{NOT_STRING_END}*\"

NOT_WHITESPACE [^[:space:]]

UPCASE [[:upper:]]
SUBSTITUTION_NAME {UPCASE}+
SUBSTITUTION .*

BEGIN_DEFINITION "#define"
DEFINITION ^{BEGIN_DEFINITION}.*

ALPHA_NUM [[:alnum:]]
REPLACEMENT #{SUBSTITUTION_NAME}
BAD_REPLACEMENT #[^[:upper:]]{ALPHA_NUM}*

SINGLE_LINE_COMMENT "//".*
BEGIN_MULTI_COMMENT "/*"
END_MULTI_COMMENT "*/"

%%

<BAD_DIRECTIVE>{ENDL} {
  leaveState();
  returnEndl();
}

<BAD_DIRECTIVE>{NOT_ENDL}* {}

<*>{ENDL} returnEndl();

{SPACE_TAB} returnText(yytext);

{STRING} returnText(yytext);

{DEFINITION} {
  boost::regex define("#define\\ ([A-Z]+)(\\ ([^\n]*))?");
  boost::cmatch match;
  if (!boost::regex_match(yytext, match, define)) {
    beginBadDirective(true);
  } else {
    std::string key(match[1]);
    substitute_map[key] = match[3];
  }
}

{REPLACEMENT} {
  boost::cmatch match = regexMatch(yytext, "#([A-Z]+)");
  std::string key(match[1]);
  if (replacementKeyIsInvalid(key)) {
    beginBadDirective();
  } else {
    std::cout << substitute_map[key];
  }
}

{BAD_REPLACEMENT} beginBadDirective();


<INITIAL>{SINGLE_LINE_COMMENT} {}
<INITIAL>{BEGIN_MULTI_COMMENT} beginComment();
<COMMENT>{END_MULTI_COMMENT} leaveState();
<COMMENT>{NOT_WHITESPACE} {}
<COMMENT><<EOF>> {
  ReportError::UntermComment();
  leaveState();
  return 0;
}

{NOT_WHITESPACE} returnText(yytext);

%%

void InitPreprocessor() {
  yylineno = 1;
  yy_flex_debug = false;
  BEGIN(INITIAL);
}

void returnText(const char* text) {
  std::cout << text;
}

boost::cmatch regexMatch(char* s, std::string expression) {
  boost::regex e(expression);
  boost::cmatch cm;
  boost::regex_match(s, cm, e);
  return cm;
}

bool replacementKeyIsInvalid(std::string key) {
  auto replacement = substitute_map.find(key);
  return replacement == substitute_map.end();
}

void beginComment() {
  yy_push_state(COMMENT);
}

void beginBadDirective(bool discardLine) {
  ReportError::InvalidDirective(yylineno);
  if (discardLine)
    yy_push_state(BAD_DIRECTIVE);
  else
    returnText(std::string(yyleng, ' ').c_str());
}

void leaveState() {
  yy_pop_state();
}

void returnEndl() {
  ++yylineno;
  returnText(yytext);
}
