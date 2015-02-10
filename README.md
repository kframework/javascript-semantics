# KJS: A Complete Formal Semantics of JavaScript

We present KJS, the most complete and throughly tested formal
semantics of JavaScript to date.
Being executable, KJS has been tested against the
[ECMAScript conformance test suite](http://test262.ecmascript.org),
and passes all 2,782 core language tests.

In addition to a reference implementation for JavaScript, KJS also yields a
semantic coverage metric for a test suite: the set of semantic rules it
exercises.
See [test262-coverage](test262-coverage/README.md) for details.

Being symbolically executable, KJS can also be used for
formal analysis and verification of JavaScript programs.
This is demonstrated by verifying non-trivial programs
([verification](verification/README.md)).
and finding known security vulnerabilities
([security-attack](security-attack/README.md)).



## How to Run Semantics

The following instructions are for Debian/Ubuntu.

### 1. Install K

This semantics is compatible with the latest version of the K framework.
See https://github.com/kframework/k/blob/master/src/README.md
for download and installation details.

### 2. Install Node.js

We use the Node.js implementation
of `Math.sin`, `Number.toFixed`, and
`Number.toString` to test programs modulo the unsupported libraries.
```
$ sudo apt-get install nodejs
```

### 3. Install KJS

Compile the semantics:
```
$ make
```
and run your programs:
```
$ ./run.sh <your-javascript-program>.js
```

### 4. Run KJS

You can run a JavaScript program using `kjs.sh` script:
```
$ ./kjs.sh <your-javascript-program>.js
```

For example,
```
$ cat hello.js
console.log("hello world!");
$ ./kjs.sh hello.js
hello world!
```

Note that, however, KJS support only a part of standard libraries,
and may fail to run a program with unsupported libraries
such as `Math`, `Date`, `RegExp`, and `JSON`.
For example, 
for the following program,
KJS gets stuck at the unsupported library function call: `Date.now()`:
```
$ cat now.js
console.log(Date.now());
$ ./kjs.sh now.js
Error: failed to run the program: now.js
Check the dumped output: /tmp/kjs..out
$ cat /tmp/kjs..out
<T>
    <k>
        Call ( @ ( "Date.now" ) , @DateOid , @Nil ) ~> Exit ;
    </k>
...
```

### 5. Run [test262](http://test262.ecmascript.org)

You can run the core part of ECMAScript conformance test suite (2,782 tests in total):
```
$ make -k -j N test262-core
```
where N is a number of processes to be used.
Running all the tests takes 2 hours with 4 processes in a machine with
Intel Xeon CPU 3.40GHz and DDR3 RAM 8GB 1600MHz.

You can also selectively run a part of the tests by using the environment variables:
```
$ TEST262_CORE_POSITIVE=<list-of-positive-tests> make test262-core-positive
```
or
```
$ TEST262_CORE_NEGATIVE=<list-of-negative-tests> make test262-core-negative
```

## Test Results

The test result will be given as follows:

 * [test262-core.out](test262-core.out): Test result of the core test262

For each test, it reports `succeed` when passed the test, and `failed` when failed.

### Invalid Tests

Among the 2,782 core tests, our semantics reports parsing errors for the following 6 programs,
which is, however, a correct behavior according to the language standard
[ECMAScript 5.1 specification](http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-262.pdf).
These programs have function declarations inside the local block such as `try` or `while` loop,
while the function declaration is only allowed in the top-level
(refer to the grammar specification [Annex A.5 Functions and Programs](http://es5.github.io/#A.5)).
This grammar mismatch problem was already admitted by the standard committee, and will be corrected in the next standard:
[Draft Specification of Ecma-262 Edition 6](http://wiki.ecmascript.org/doku.php?id=harmony:specification_drafts).

```
test262-9b669da66c78/test/suite/ch10/10.4/10.4.2/10.4.2-1-2.js
test262-9b669da66c78/test/suite/ch12/12.14/12.14-13.js
test262-9b669da66c78/test/suite/ch12/12.8/S12.8_A3.js
test262-9b669da66c78/test/suite/ch12/12.8/S12.8_A4_T1.js
test262-9b669da66c78/test/suite/ch12/12.8/S12.8_A4_T2.js
test262-9b669da66c78/test/suite/ch12/12.8/S12.8_A4_T3.js
```

Note that we consider the above tests as the negative tests, so that it will report `succeed` when it failed to run the program.
Other negative tests are marked by a comment in the test.

## Built-in Objects Support

Currently, the standard built-in objects are supported as follows:

* Fully defined:
  [`Object`](http://es5.github.io/#x15.2), 
  [`Function`](http://es5.github.io/#x15.3), 
  [`Boolean`](http://es5.github.io/#x15.6), 
  [`Error`](http://es5.github.io/#x15.11)
* Partially defined: 
  [`Global`](http://es5.github.io/#x15.1), 
  [`Array`](http://es5.github.io/#x15.4), 
  [`String`](http://es5.github.io/#x15.5), 
  [`Number`](http://es5.github.io/#x15.7)
* Not defined: 
  [`Math`](http://es5.github.io/#x15.8), 
  [`Date`](http://es5.github.io/#x15.9), 
  [`RegExp`](http://es5.github.io/#x15.10), 
  [`JSON`](http://es5.github.io/#x15.12)


## Directory Structure

* Semantics
 * [js-main.k](js-main.k): Core semantics
 * [js-orig-syntax.k](js-orig-syntax.k), [js-orig-syntax-util.k](js-orig-syntax-util.k): JavaScript syntax
 * [js-core-syntax.k](js-core-syntax.k): IR syntax
 * [js-trans.k](js-trans.k): Translation from JavaScript to IR
 * [js-pseudo-code.k](js-pseudo-code.k): Pseudo-code semantics
 * [js-str-numeric-literal.k](js-str-numeric-literal.k): Conversion semantics from strings to numbers
 * [js-init-configuration.k](js-init-configuration.k): Initial configuration
 * [js-standard-builtin-objects.k](js-standard-builtin-objects.k): Standard built-in objects's constructor semantics
 * [stdlib/](stdlib/): Standard built-in objects' methods semantics written in JavaScript itself

* Applications
 * [security-attack](security-attack/README.md): Security attack detection using symbolic execution
 * [test262-coverage](test262-coverage/README.md): Test coverage measurement of test262 w.r.t. the standard
 * [verification](verification/README.md): Program verification based on the semantics

* Build semantics
 * [Makefile](Makefile): Compile semantics
 * [kpp.py](kpp.py): Create a single K file from the multiple files

* Run semantics
 * [kjs.sh](run.sh): Run normal JavaScript programs
 * [Makefile.test262](Makefile.test262): Run test262 programs
 * [prelude.js](prelude.js): Prelude of test262
 * [jsmassage.sh](jsmassage.sh): Wrapper of SAFE framework
 * [pp.sh](pp.sh): Preprocessor


----

Note:
The applications use a customized version of K, which is not publicly availabile yet. It will be available soon.
