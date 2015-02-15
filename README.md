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
([verification](verification/README.md)),
and finding known security vulnerabilities
([security-attack](security-attack/README.md)).



## How to Run Semantics

The following instructions are for standard Debian/Ubuntu distributions, especially for Ubuntu 14.04 LTS 64-bit.

### 0. Install Basic Dependencies

Install JDK 1.8:
```
$ sudo add-apt-repository ppa:webupd8team/java
$ sudo apt-get update
$ sudo apt-get install oracle-java8-installer
```

Install `build-essential`, `git`, and `maven`:
```
$ sudo apt-get install build-essential
$ sudo apt-get install git
$ sudo apt-get install maven
```


### 1. Install K

This semantics is compatible with a customized version of the latest K framework.
You can install the version of K as follows:
```
$ git clone https://github.com/kframework/k.git
$ cd k
$ git checkout -b kjs origin/kjs
$ mvn package
```

Ensure `kompile` and `krun` are included in your `$PATH`:
```
$ export PATH=$PATH:<path-to-k>/k-distribution/target/release/k/bin
```

### 2. Install Node.js

We use Node.js implementation
for `Math.sin`, `Number.toFixed`, and
`Number.toString` to test programs modulo the unsupported libraries.
```
$ sudo apt-get install nodejs
$ (cd $(dirname `which nodejs`); ln -s nodejs node)
```

### 3. Install KJS

You can compile the semantics using Makefile:
```
$ make
```

### 4. Run KJS

You can run a JavaScript program using `kjs.sh`:
```
$ ./kjs.sh <your-javascript-program>.js
```

For a 'hello-world' example,
```
$ cat >hello-world.js <<EOL
console.log("hello world!");
EOL

$ ./kjs.sh hello-world.js
hello world!
```

Note that, however, KJS support only a part of standard libraries,
and may fail to run a program with unsupported libraries
such as `Math`, `Date`, `RegExp`, and `JSON`.
For example, 
KJS fails to run the following program,
getting stuck at the unsupported library function call: `Date.now()`:
```
$ cat >time.js <<EOL
console.log(Date.now());
EOL

$ ./kjs.sh time.js
Error: failed to run the program: time.js
Check the dumped output: /tmp/kjs.bd7uNgkKud.out

$ cat /tmp/kjs.bd7uNgkKud.out
<T>
    <k>
        Call ( @ ( "Date.now" ) , @DateOid , @Nil ) ~> Exit ;
    </k>
...
```

### 5. Run ECMAScript conformance test suite([test262](http://test262.ecmascript.org))

You can run the core ECMAScript conformance test suite (2,782 tests in total) as follows:
(where `N` is a number of parallel processes to be used)
```
$ make -k -j N test262-core
```
Running all the tests will take 2 hours using 4 parallel processes in a machine with
Intel Xeon CPU 3.40GHz and DDR3 RAM 8GB 1600MHz.

You can also selectively run a part of the tests by using the environment variables:
```
$ TEST262_CORE_POSITIVE=<list-of-positive-tests> make test262-core-positive
$ TEST262_CORE_NEGATIVE=<list-of-negative-tests> make test262-core-negative
```


## Test Result of test262

We provide a test result of the core test262, [test262.out](test262.out).
For each test, it reports `succeed` when passed the test, and `failed` when failed.

Note that there are two types of tests: positive and negative tests. A negative test is identified by `@negative` in its preamble. The negative tests should fail to run.

### Invalid Tests

Among the 2,782 core tests, our semantics reports parsing errors for the following 6 programs,
which is the correct behavior according to the language standard
[ECMAScript 5.1 specification](http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-262.pdf).
These programs have function declarations inside a local block such as `try` or `while` loop,
while function declaration is only allowed at top-level
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

Note that we consider the above tests as negative tests, such that it will report `succeed`.


## Built-in Objects Support

Currently, KJS supports the standard built-in objects as follows:

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
 * [js-orig-syntax-util.k](js-orig-syntax-util.k): JavaScript syntax preprocessor
 * [js-core-syntax.k](js-core-syntax.k): IR syntax
 * [js-trans.k](js-trans.k): Translation from JavaScript to IR
 * [js-pseudo-code.k](js-pseudo-code.k): Pseudo-code semantics
 * [js-str-numeric-literal.k](js-str-numeric-literal.k): Paring numeric literals
 * [js-init-configuration.k](js-init-configuration.k): Initial configuration
 * [js-prelude.k](js-prelude.k): K built-in modules
 * [js-standard-builtin-objects.k](js-standard-builtin-objects.k): Standard built-in objects' constructor semantics
 * [stdlib/](stdlib/): Standard built-in objects' methods semantics written in JavaScript itself

* Applications
 * [security-attack](security-attack/README.md): Security attack detection using symbolic execution
 * [test262-coverage](test262-coverage/README.md): Test coverage measurement of test262 w.r.t. the standard
 * [verification](verification/README.md): Program verification based on the semantics

* Build semantics
 * [Makefile](Makefile): Compile semantics
 * [kpp.py](kpp.py): Create a single K file from the multiple files

* Run semantics
 * [kjs.sh](kjs.sh): Run JavaScript programs
 * [Makefile.test262](Makefile.test262): Run test262 programs
 * [test262.out](test262.out): Test result of the core test262
 * [prelude.js](prelude.js): Prelude of test262
 * [jsmassage.sh](jsmassage.sh): Wrapper of SAFE framework
 * [pp.sh](pp.sh): Preprocessor
 * [list-invalid-tests.txt](list-invalid-tests.txt): Invalid tests (See [the above](README.md#invalid-tests))


----

Note:
A virtual machine, in which all of the required programs and libraries have been installed and configured, is provided at:
