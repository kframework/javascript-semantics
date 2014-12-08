#!/bin/bash

dir=`dirname $0`

echo "rule @PWD => \"`pwd`\"" >$dir/js-pwd.k
$dir/kpp.py $dir/js-main.k >$dir/js.k
$dir/k/bin/kompile --backend java $dir/js.k
