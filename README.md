# KJS: A Complete Formal Semantics of JavaScript

We present KJS, the most complete and throughly tested formal
semantics of JavaScript to date.
Being executable, KJS has been tested against the
[ECMAScript conformance test suite](http://test262.ecmascript.org),
and passes all 2,782 core language tests.

In addition to a reference implementation for JavaScript, KJS also yields a
simple coverage metric for a test suite: the set of semantic rules it
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

This version of semantics is compatible with the latest version 3.4.1 of the K framework.
(https://github.com/kframework/k/releases/tag/v3.4.1).
See http://kframework.org for download and installation details.

### 2. Install SAFE

We pre-process the input JavaScript program using the SAFE framework
for automatic semicolon insertion.
We slightly modified the SAFE framework, given as [jsaf.patch](jsaf.patch).
```
$ git clone git://plrg.kaist.ac.kr/jsaf.git
$ cd jsaf
$ git reset --hard 6926a7e9e19c466408650d2f27a0d805fd722609
$ patch -p1 <../jsaf.patch
$ wget http://cs.nyu.edu/rgrimm/xtc/xtc.jar
$ mv xtc.jar bin/
$ export JS_HOME=`pwd`
$ ant clean compile
```

### 3. Install Node.js

We use the Node.js implementation
of `Math.sin`, `Number.toFixed`, and
`Number.toString` to test programs modulo the unsupported libraries.
```
$ sudo apt-get install nodejs
```

### 4. Install test262 (Optional)

```
$ git clone https://github.com/tc39/test262.git
$ cd test262
$ git reset --hard 9b669da66c78bd583bc130a7ca3151258e4681a1
```

### 5. Install KJS

Compile the semantics:
```
./build.sh
```
and run your programs:
```
./run.sh <your-javascript-program>.js
```

### 6. Run [test262](http://test262.ecmascript.org)

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

## Test Results

The results of each of positive and negative core test are given as follows:

 * [run-test262-core-positive.sh.out](run-test262-core-positive.sh.out): Test result of positive core test262
 * [run-test262-core-negative.sh.out](run-test262-core-negative.sh.out): Test result of negative core test262

The positive tests are supposed to succeed, while the negative tests are supposed to fail.
The [positive test result](run-test262-core-positive.sh.out) reports all `succeed`, except the following invalid tests, and the [negative test result](run-test262-core-negative.sh.out) reports all `failed`, as expected.

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
 * [js-orig-syntax.k](js-orig-syntax.k): JavaScript syntax
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
 * [build.sh](build.sh): Compile semantics
 * [kbuild.sh](kbuild.sh): Wrapper of `kompile`
 * [autoinclude-java.k](autoinclude-java.k): Include built-in K functions
 * [kpp.py](kpp.py): Create a single K file from the multiple files
 * [jsaf.patch](jsaf.patch): Patch for SAFE framework

* Run semantics
 * [run.sh](run.sh): Run normal JavaScript programs
 * [run-test262.sh](run-test262.sh): Run test262 programs
 * [run-test262-core.sh](run-test262-core.sh): Run core of test262
 * [run-test262-core-positive.sh](run-test262-core-positive.sh): Run positive core of test262
 * [run-test262-core-negative.sh](run-test262-core-negative.sh): Run negative core of test262
 * [run-test262-all.sh](run-test262-all.sh): Run all of test262
 * [prelude.js](prelude.js): Prelude of test262
 * [jsmassage.sh](jsmassage.sh): Wrapper of SAFE framework
 * [pp.sh](pp.sh): Preprocessor


----

Note:
The applications use a customized version of K, which is not publicly availabile yet. It will be available soon.
