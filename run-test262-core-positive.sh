#!/bin/bash

dir=`dirname "$0"`
"$dir"/run-test262.sh `find test262/test/suite/ch{08,09,10,11,12,13,14} -name '*.js' -exec grep -L '@negative' {} \;`
