# [Paper #194] PLDI 2015 Artifact Evaluation

## KJS: A Complete Formal Semantics of JavaScript

### Artifact Submission

 * Accepted paper: [[pdf]]()
 * VM image: [[ova]]() (~2GB)
   * login: kjs, passwd: kjs
   * artifact location: `/home/kjs/javascript-semantics`

### Instruction

Our artifact consists of:
 * Formal semantics: [[core]](js-main.k) [[stdlib]](stdlib) [[etc]](README.md#directory-structure)
   * Running the semantics: [[README]](README.md)
   * Testing the semantics against [test262](http://test262.ecmascript.org): [[README]](README.md#5-run-ecmascript-conformance-test-suitetest262) [[Result]](test262.out)
 * Applications
   * Measuring the semantic coverage of [test262](http://test262.ecmascript.org): [[README]](test262-coverage/README.md) [[Result]](test262-coverage/test262-coverage.out)
   * Detecting a known security attack: [[README]](security-attack/README.md) [[Result]](security-attack/security-attack.out)
   * Verifying JavaScript programs: [[README]](verification/README.md) [[Result]](verification/verification.out)

All of the results can be simply reproduced by using [`run-all.sh`](run-all.sh):
```
$ cd /home/kjs/javascript-semantics
$ ./run-all.sh
```
