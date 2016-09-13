# csce434-pp1

The purpose of the project was to build the preprocessor and scanner components
of the compiler.

## Interesting Notes

### Test Script
Creating a script that runs the sample files through
`dcc` comparing them to the expected output files really sped up development.
The script can be executed by invoking `make test` which will also build the
compiler and preprocessor if necessary.

### Boost::Regex
`g++-4.7` the highest version of `g++` supported on `linux.cse.tamu.edu` does
not properly implement ECMAScript RegEx syntax, so I had to switch from using
`std::regex` to `boost::regex`.

### Define Directive
To avoid complicated manipulation of the lex state stack, I decided to have lex
match any directive that begins with `#define `. Then inside the lex rule I use
`boost::regex_match` to determine if the define directive is well formed whilst
simultaneously capturing the key and value for the replacement hash table.

### Ill-formed Replacement Directive
When a replacement directive is ill-formed, i.e. the replacement key doesn't
exist in the hash table, I decided to pass a number of spaces equal to the
length of the ill-formed directive to the scanner so the columns kept track of
by the scanner would not surprise the user when the directive token is discarded.
