#!/bin/bash

dir=`dirname $0`

$dir/kpp.py $dir/js-main.k >$dir/js.k
export JAVA_TOOL_OPTIONS='-Djava.awt.headless=true'
$dir/k/bin/kompile $dir/js.k
