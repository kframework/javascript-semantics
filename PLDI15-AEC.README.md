# [Paper #194] PLDI 2015 Artifact Evaluation

## KJS: A Complete Formal Semantics of JavaScript

### Artifact Submission

 * Accepted paper: [[pdf]](http://fslweb.cs.illinois.edu/kjs/pldi15-paper194.pdf)
 * VM image: 
   * VMWare: [[ova]](http://fslweb.cs.illinois.edu/kjs/kjs.vmware.ova) (~3.5GB) |
             [[md5]](http://fslweb.cs.illinois.edu/kjs/kjs.vmware.ova.md5)
   * VirtualBox: [[ova]](http://fslweb.cs.illinois.edu/kjs/kjs.virtualbox.ova) (~2.8GB) |
                 [[md5]](http://fslweb.cs.illinois.edu/kjs/kjs.virtualbox.ova.md5)
   * login: kjs, passwd: kjs
   * artifact location: `/home/kjs/javascript-semantics`

NOTE: Since the VM images contain a **64-bit** guest OS (Ubuntu 14.04), it may not work if your system does not support a proper virtualization. For example, you may not able to run it in VirtualBox if the CPU does not support hardware virtualization such as AMD-V or VT-x.


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
NOTE: Running all of the test will take several hours even in a native machine. Thus, running it in a virtual machine would be too heavy. 
(For example, `run-all.sh` took ~35 hours in the given VirtualBox VM
on the top of a machine with Intel Xeon CPU 3.40GHz and DDR3 RAM 8GB 1600MHz.)
We recommend you to install KJS in a native machine so that you can save time to reproduce all of the results. (Minimum RAM requirement: 4GB).
