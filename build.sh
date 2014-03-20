#!/bin/bash

# k
git clone https://github.com/kframework/k.git
cd k
git reset --hard 6b6f75eb0bdca81800444672b89fd4369fe2b9af
patch -p1 <../k.patch 
ant
cd ..

# jsaf
git clone git://plrg.kaist.ac.kr/jsaf.git
cd jsaf
git reset --hard 6926a7e9e19c466408650d2f27a0d805fd722609
patch -p1 <../jsaf.patch
wget http://cs.nyu.edu/rgrimm/xtc/xtc.jar
mv xtc.jar bin/
export JS_HOME=`pwd`
ant clean compile
cd ..

# closure-compiler
git clone https://code.google.com/p/closure-compiler/
cd closure-compiler
git reset --hard 83ba7c6bee97ab88521b647c73ee5928a34d6eda
patch -p1 <../closure-compiler.patch 
ant jar
cd ..

# test262
git clone https://github.com/tc39/test262.git

# kompile semantics
export JAVA_TOOL_OPTIONS='-Djava.awt.headless=true'
./k/bin/kompile js.k
