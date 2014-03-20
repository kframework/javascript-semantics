#!/bin/bash

dir=`dirname "$0"`
"$dir"/run-test262.sh `find test262/test/suite/ch* -name '*.js'`
