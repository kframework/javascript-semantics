#!/bin/bash

for i in "`for i in $(cat stdlib-for-coverage.txt); do find ../test262/test/suite/ch15/ -name $i; done`"; do
  ../run-test262.sh "$i"
done
for i in "`find ../test262 -name '*.cov'`"; do
  grep 'js.k' "$i" | cut -f 2 -d ':' >coverage
done
./report.py coverage ../js.k >coverage.k
