#!/bin/bash

# echo "Running additional core tests in stdlib directory..."
# for i in `for j in $(cat stdlib-for-coverage.txt); do find ../test262/test/suite/ch15/ -name $j; done`; do
#   cat ../prelude.js "$i" >"$i".prelude && \
#   ../jsmassage.sh -f "$i".prelude >"$i".prelude.massage && \
#   krun -d . --pattern-matching --coverage-file "$i".cov "$i".prelude.massage >"$i".out 2>"$i".err
# done
echo "Gathering trace information..."
for i in `find ../test262 -name '*.cov'`; do grep 'js.k' "$i" | cut -f 2 -d ':'; done >coverage
echo "Generating coverage report..."
./report.py coverage ../js.k >coverage.k
