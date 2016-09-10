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
#include <string>
#include <unordered_map>
#include "scanner.h"

  static void returnText(char* text);
%}

%s COMMENT
%option noyywrap

ENDL \n
NOT_ENDL [^\n]
SINGLE_LINE_COMMENT "//"{NOT_ENDL}*
BEGIN_MULTI_COMMENT "/*"
END_MULTI_COMMENT "*/"
COMMENT_CONTENT [^{END_MULTI_COMMENT}{ENDL}]
LINE {NOT_ENDL}*{ENDL}

%%

{LINE} returnText(yytext);

%%

void InitScanner() {
  yy_flex_debug = false;
}

void returnText(char* text) {
  std::cout << text;
}
