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

# test262
git clone https://github.com/tc39/test262.git

# kompile semantics

echo "Bootstrapping build..."
[ "$1" == "clean" ] && rm -rf .k js-kompiled
rm -f js-config.k
touch js-config.k
./kbuild.sh

echo "Self-hosted standard built-in objects..."
{ cat stdlib/00.debug.js
  cat stdlib/01.global.js
  cat stdlib/02.object.js
  cat stdlib/03.function.js
  cat stdlib/04.array.js
  cat stdlib/05.string.js
  cat stdlib/06.boolean.js
  cat stdlib/07.number.js
  cat stdlib/08.math.js
  cat stdlib/09.date.js
  cat stdlib/10.regexp.js
  cat stdlib/11.error.js
# cat stdlib/12.json.js
} >stdlib.js

echo "Hard-wiring standard built-in objects..."
{ echo "<objs> ( _ =>"
  ./k/bin/krun --parser ./parser.sh --pattern "<objs> O:Bag </objs>" stdlib.js | grep -v '^Search results:\|^Solution\|^O:Bag' | sed 's/#symInt(\([0-9]*\))/\1/g'
  echo ") </objs>"
} >js-config.k

echo "Final build..."
[ "$1" == "clean" ] && rm -rf .k js-kompiled
./kbuild.sh
