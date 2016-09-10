# csce434-pp1

This project was quite fun. Creating a script that runs the sample files through
`dcc` comparing them to the expected output files really sped up development.
The script can be executed by invoking `make test` which will also build the
compiler and preprocessor if necessary.

## Interesting Note

`g++-4.7` the highest version of `g++` supported on `linux.cse.tamu.edu` does
not properly implement ECMAScript RegEx syntax, so I had to switch from using
`std::regex` to `boost::regex`.
