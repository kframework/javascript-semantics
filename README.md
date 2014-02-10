Javascript semantics in K (in progress)

This is an initial (incomplete) Javascript semantics.
Currently, this does NOT support:
- Array objects and its related stuff such as 'for-in' constructors and 'arguments' objects
- Regular expressions
- Standard built-in objects (Only basic features are supported)
- Automatic semicolon insertions
- 'get' and 'set' attributes (will be supported soon!)
- Miscellaneous corner cases

This semantics is based on ECMAScript 5.1 specification:
Fifth Edition of ECMA-262
http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-262.pdf
