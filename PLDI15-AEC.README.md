# [Paper #194] PLDI 2015 Artifact Evaluation

## KJS: A Complete Formal Semantics of JavaScript

### Artifact Submission

 * Accepted paper: [[pdf]]() (~500KB)
 * VM image: [[ova]]() (~2GB)
   * login: kjs, passwd: kjs

### Instruction

Our artifact consists of: (the link provides README for each artifact)
 * Formal semantics: [[js-main.k]](js-main.k) [[js-orig-syntax.k]](js-orig-syntax.k) [[stdlib]](stdlib) [[...]](README.md#directory-structure)
   * Testing the semantics against test262: [[README]](README.md#5-run-ecmascript-conformance-test-suitetest262) [[Result]](test262.out)
 * Applications
   * Measuring the semantic coverage of test262: [[README]](test262-coverage/README.md) [[Result]](test262-coverage/test262-coverage.out)
   * Finding a known security attack: [[README]](security-attack/README.md) [[Result]](security-attack/security-attack.out)
   * Verifying JavaScript programs: [[README]](verification/README.md) [[Result]](verification/verification.out)

You can simply reproduce all of the results by using [`run-all.sh`](run-all.sh):
```
$ ./run-all.sh
```
