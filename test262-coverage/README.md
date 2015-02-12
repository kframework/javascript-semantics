## Semantic Coverage of ECMAScript Conformance Test Suite

We measured the semantic coverage (i.e., the set of semantic rules it exercises)
of [ECMAScript Conformance Test Suite](http://test262.ecmascript.org).

You can measure the semantic coverage of a given test using the `--coverage-file` option:
```
$ krun --coverage-file trace.txt test.js
```
The output `trace.txt` shows which parts of the semantics are executed, in the order of the execution.

In order to measure the semantic coverage of the core test262,
you will first run all the tests with the `--coverage-file` option:
(where `N` is a number of parallel processes to be used)
```
$ make -k -j N test262-core-coverage
```
and then generate a coverage report from the trace outputs:
```
$ ./coverage.sh
```
The above command will generate a coverage report `js.k` in the current directory.

In the coverage report [`js.k`](js.k), each semantic rule is annotated with a number
of how many times it was executed by the test suite.
The number `0` means that the corresponding semantic rule is not covered by any test.

This way we found that there are 17 semantic rules in the core
semantics which are not covered by the test suite, each corresponding to the
language standard as shown in the following:
(Note that we only consider rules that directly correspond to the core part of the standard, but ignore auxiliary rules and standard library rules.)

Section# - Step# of [Standard](http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-262.pdf) | Line# of [Formal Semantics](js.k) | Feasible?
---------------------------------------------------------------------------------------------------------------------------|-------------------------|-----------------------
[8.7.1 GetValue (V)                       - [[Get]], Step 6                             ](http://es5.github.io/#x8.7.1)  |  [5917](js.k#L5917)                                            |  O 
[8.7.2 PutValue (V, W)                    - [[Put]], Step 2.a                           ](http://es5.github.io/#x8.7.2)  |  [5951](js.k#L5951)                                            |  O 
[8.7.2 PutValue (V, W)                    - [[Put]], Step 2.b                           ](http://es5.github.io/#x8.7.2)  |  [5953](js.k#L5953)                                            |  O 
[8.7.2 PutValue (V, W)                    - [[Put]], Step 4.a                           ](http://es5.github.io/#x8.7.2)  |  [5960](js.k#L5960)                                            |  X  
[8.7.2 PutValue (V, W)                    - [[Put]], Step 4.b                           ](http://es5.github.io/#x8.7.2)  |  [5962](js.k#L5962)                                            |  X  
[8.7.2 PutValue (V, W)                    - [[Put]], Step 6.a \& 6.b                    ](http://es5.github.io/#x8.7.2)  |  [5967](js.k#L5967),[5968](js.k#L5967)                         |  O 
[8.7.2 PutValue (V, W)                    - [[Put]], Step 7.a                           ](http://es5.github.io/#x8.7.2)  |  [5972](js.k#L5972)                                            |  O 
[8.12.4 \[[CanPut]\] (P)                    - Step 8.a                                  ](http://es5.github.io/#x8.12.4)  |  [6332](js.k#L6332)                                           |  O 
[10.2.1.1.3 SetMutableBinding (N,V,S)     - Step 4                                      ](http://es5.github.io/#x10.2.1.1.3)  |  [6978](js.k#L6978)                                       |  O 
[10.2.1.1.4 GetBindingValue(N,S)          - Step 3.a                                    ](http://es5.github.io/#x10.2.1.1.4)  |  [7004](js.k#L7004),[7008](js.k#L7008),[7006](js.k#L7006) |  X  
[10.2.1.1.5 DeleteBinding (N)             - Step 2                                      ](http://es5.github.io/#x10.2.1.1.5)  |  [7051](js.k#L7051)                                       |  X  
[10.2.1.1.5 DeleteBinding (N)             - Step 4 \& 5                                 ](http://es5.github.io/#x10.2.1.1.5)  |  [7039](js.k#L7039)                                       |  O 
[10.2.1.2.4 GetBindingValue(N,S)          - Step 4.a                                    ](http://es5.github.io/#x10.2.1.2.4)  |  [7021](js.k#L7021),[7024](js.k#L7024),[7022](js.k#L7022) |  X  
[10.5 Declaration Binding Instantiation   - Step 5.e.iii.1                              ](http://es5.github.io/#x10.5)  |  [7351](js.k#L7351)                                             |  O 
[10.5 Declaration Binding Instantiation   - Step 5.e.iv, 1st condition is true          ](http://es5.github.io/#x10.5)  |  [7354](js.k#L7354)                                             |  O 
[10.5 Declaration Binding Instantiation   - Step 5.e.iv, 2nd condition is true          ](http://es5.github.io/#x10.5)  |  [7357](js.k#L7357)                                             |  O 
[10.6 Arguments Object                    - [[DefineOwnProperty]], Step 4.a, else-branch](http://es5.github.io/#x10.6)  |  [7532](js.k#L7532)                                             |  X  


We succeeded to manually write test programs that hit 11 out of 17 behaviors:
(Each link shows the corresponding test program.)

  * [8.7.1 GetValue (V)                       - [[Get]], Step 6                              ](01 - 8.7.1 GetValue (V) - [[Get]], Step 6.js)
  * [8.7.2 PutValue (V, W)                    - [[Put]], Step 2.a                            ](02 - 8.7.2 PutValue (V, W) - [[Put]], Step 2.a.js)
  * [8.7.2 PutValue (V, W)                    - [[Put]], Step 2.b                            ](03 - 8.7.2 PutValue (V, W) - [[Put]], Step 2.b.js)
  * [8.7.2 PutValue (V, W)                    - [[Put]], Step 6.a \& 6.b                     ](06 - 8.7.2 PutValue (V, W) - [[Put]], Step 6.a-b.js)
  * [8.7.2 PutValue (V, W)                    - [[Put]], Step 7.a                            ](07 - 8.7.2 PutValue (V, W) - [[Put]], Step 7.a.js)
  * [8.12.4 \[[CanPut]\] (P)                    - Step 8.a                                     ](08 - 8.12.4 [[CanPut]] (P) - Step 8.a.js)
  * [10.2.1.1.3 SetMutableBinding (N,V,S)     - Step 4                                       ](09 - 10.2.1.1.3 SetMutableBinding (N,V,S) - Step 4.js)
  * [10.2.1.1.5 DeleteBinding (N)             - Step 4 \& 5                                  ](12 - 10.2.1.1.5 DeleteBinding (N) - Step 4-5.js)
  * [10.5 Declaration Binding Instantiation   - Step 5.e.iii.1                               ](14 - 10.5 Declaration Binding Instantiation - Step 5.e.iii.1.js)
  * [10.5 Declaration Binding Instantiation   - Step 5.e.iv, 1st condition is true           ](15 - 10.5 Declaration Binding Instantiation - Step 5.e.iv, 1st.js)
  * [10.5 Declaration Binding Instantiation   - Step 5.e.iv, 2nd condition is true           ](16 - 10.5 Declaration Binding Instantiation - Step 5.e.iv, 2nd.js)

Moreover, the remaining 6 semantic behaviors are infeasible, that is, they
represent flaws in the language standard itself:
(Each link presents a brief explanation of why it is infeasible.)

  * [8.7.2 PutValue (V, W)                    - [[Put]], Step 4.a                            ](04 - 8.7.2 PutValue (V, W) - [[Put]], Step 4.a.js)
  * [8.7.2 PutValue (V, W)                    - [[Put]], Step 4.b                            ](05 - 8.7.2 PutValue (V, W) - [[Put]], Step 4.b.js)
  * [10.2.1.1.4 GetBindingValue(N,S)          - Step 3.a                                     ](10 - 10.2.1.1.4 GetBindingValue(N,S) - Step 3.a.js)
  * [10.2.1.1.5 DeleteBinding (N)             - Step 2                                       ](11 - 10.2.1.1.5 DeleteBinding (N) - Step 2.js)
  * [10.2.1.2.4 GetBindingValue(N,S)          - Step 4.a                                     ](13 - 10.2.1.2.4 GetBindingValue(N,S) - Step 4.a.js)
  * [10.6 Arguments Object                    - [[DefineOwnProperty]], Step 4.a, else-branch ](17 - 10.6 Arguments Object - [[DefineOwnProperty]], Step 4.a, else.js)

