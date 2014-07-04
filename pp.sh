#!/bin/bash

cat $1 | \
# use strict
sed "s/'use strict'/'USE_STRICT'/g" | \
sed 's/"use strict"/"USE_STRICT"/g' | \
# fromCharCode/ToUint16
sed 's/String\.fromCharCode(\([^)]*\))\.charCodeAt(0)/ToUint16(\1)/g' | \
# characters
sed 's/\\u0042/B/g' | \
sed 's/\\u005f/_/g' | \
sed 's/\\u0076/v/g' | \
sed 's/\\u0061/a/g' | \
sed 's/\\u0072/r/g' | \
sed 's/\\u0066/f/g' | \
sed 's/\\u0075/u/g' | \
sed 's/\\u006e/n/g' | \
sed 's/\\u0063/c/g' | \
# line terminators
sed 's/\\\\r\|\\\\u000A\|\\\\u000D\|\\\\u2028\|\\\\u2029/\\\\n/g' | \
sed 's/\\r\|\\u000A\|\\u000D\|\\u2028\|\\u2029/\\n/g' | \
# white spaces
sed 's/\\\\t\|\\\\f\|\\\\u0009\|\\\\u000C\|\\\\u0020\|\\\\u00A0\|\\\\u000B\|\\\\u1680\|\\\\u180E\|\\\\u2000\|\\\\u2001\|\\\\u2002\|\\\\u2003\|\\\\u2004\|\\\\u2005\|\\\\u2006\|\\\\u2007\|\\\\u2008\|\\\\u2009\|\\\\u200A\|\\\\u202F\|\\\\u205F\|\\\\u3000/ /g' | \
sed 's/\\t\|\\f\|\\u0009\|\\u000C\|\\u0020\|\\u00A0\|\\u000B\|\\u1680\|\\u180E\|\\u2000\|\\u2001\|\\u2002\|\\u2003\|\\u2004\|\\u2005\|\\u2006\|\\u2007\|\\u2008\|\\u2009\|\\u200A\|\\u202F\|\\u205F\|\\u3000/ /g'
