Javascript semantics in K (in progress)

This is an initial (incomplete) Javascript semantics.
Currently, this does NOT support:
* Standard built-in objects (Only basic features are supported)

This semantics is based on [ECMAScript 5.1 specification](http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-262.pdf).

---

Being executable, this semantics has been tested against [ECMAScript conformance test suite](http://test262.ecmascript.org).
Currently, it passes 94.7% (2634 out of 2782) test programs.

To execute this semantics, compile the semantics:
```
./build.sh
```
and run your programs:
```
./run.sh <your-javascript-program>.js
```

You can run all of ECMAScript conformance test suite (11,566 test programs in total):
```
./run-test262-all.sh
```
or selectively run its core part (2,782 test programs in total):
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
