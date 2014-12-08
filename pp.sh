#!/bin/bash

cat "$2" | case "$1" in
-1)
# unicode variable names
sed 's/\\u0042/B/g' | \
sed 's/\\u005f/_/g' | \
sed 's/\\u0076/v/g' | \
sed 's/\\u0061/a/g' | \
sed 's/\\u0072/r/g' | \
sed 's/\\u0066/f/g' | \
sed 's/\\u0075/u/g' | \
sed 's/\\u006e/n/g' | \
sed 's/\\u0063/c/g' | \
# use strict
sed "s/'use strict'/'USE_STRICT'/g" | \
sed 's/"use strict"/"USE_STRICT"/g'
;;
-2)
# fromCharCode/ToUint16
sed 's/String\.fromCharCode(\([^)]*\))\.charCodeAt(0)/@ToUint16(\1)/g'
;;
*)
echo "Invalid arguments"; exit 1
;;
esac
