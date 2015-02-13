# [Paper #194] PLDI 2015 Artifact Evaluation

## KJS: A Complete Formal Semantics of JavaScript

### Artifact Submission

 * Accepted paper: [pdf]() (~500KB)
 * VM image: [ova]() (~2GB)
   * login: kjs, passwd: kjs

### Instruction

Our artifact consists of: (the link provides README for each artifact)
 * [Formal semantics](README.md#directory-structure)
   * [Testing the semantics against test262](README.md#5-run-ecmascript-conformance-test-suitetest262)
 * [Applications](README.md#directory-structure)
   * [Measuring the semantic coverage of test262](test262-coverage/README.md)
   * [Finding a known security attack](security-attack/README.md)
   * [Verifying JavaScript programs](verification/README.md)

You can simply reproduce all of the results by using [`run-all.sh`](run-all.sh):
```
$ ./run-all.sh
```
