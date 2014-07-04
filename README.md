Javascript Semantics in K

This is a Javascript semantics, based on [ECMAScript 5.1 specification](http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-262.pdf).
It defines the language core semantics and several standard built-in objects.

Our semantics has been tested against [ECMAScript conformance test suite](http://test262.ecmascript.org),
and passes all 2,782 core language tests.

To execute this semantics, compile the semantics:
```
./build.sh
```
and run your programs:
```
./run.sh <your-javascript-program>.js
```

You can run all of ECMAScript conformance test suite (11,566 tests in total):
```
./run-test262-all.sh
```
or selectively run its core part (2,782 tests in total):
```
./run-test262-core.sh
```
or run separately each positive and negative part of it:
```
./run-test262-core-positive.sh
```
```
./run-test262-core-negative.sh
```


----

Among the 2,782 core tests, our semantics reports parsing errors for the following programs,
which is, however, a correct behavior according to the the language standard
[ECMAScript 5.1 specification](http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-262.pdf).
These programs have function declarations inside the local block such as `try` or `while` loop,
while the function declaration is only allowed in the top-level
(refer to the grammar specification [Annex A.5 Functions and Programs](http://es5.github.io/#A.5).
This grammar, however, will be revised to cover these programs in the next version
[Draft Specification of Ecma-262 Edition 6](http://wiki.ecmascript.org/doku.php?id=harmony:specification_drafts).

```
test262-d067d2f0ca30/test/suite/ch10/10.4/10.4.2/10.4.2-1-2.js
test262-d067d2f0ca30/test/suite/ch12/12.14/12.14-13.js
test262-d067d2f0ca30/test/suite/ch12/12.8/S12.8_A3.js
test262-d067d2f0ca30/test/suite/ch12/12.8/S12.8_A4_T1.js
test262-d067d2f0ca30/test/suite/ch12/12.8/S12.8_A4_T2.js
test262-d067d2f0ca30/test/suite/ch12/12.8/S12.8_A4_T3.js
```


----

Currently, the standard built-in objects are supported as follows:

* Fully defined:
  * Object
  * Function
  * Boolean
  * Error

* Partially defined:
  * Global
  * Array
  * String
  * Number

* Not defined:
  * Math
  * Date
  * RegExp
  * JSON
