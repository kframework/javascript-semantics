#!/bin/bash

cmd=`basename "$0"`
dir=`dirname "$0"`
jsaf=jsaf
cc=closure-compiler

tmp=`mktemp -d /tmp/"$cmd".XXXXXXXXXX`
cleanup() { rm -rf "$tmp"; }
trap cleanup EXIT INT TERM

if [ -z "$KRUN_IS_NOT_FILE" ]; then
  input="$1"
else
  input="$tmp"/in.js
  echo "$1" >"$input"
fi

java -jar "$cc"/build/compiler.jar --js "$input" --js_output_file "$tmp"/cc.js --compilation_level WHITESPACE_ONLY --formatting PRETTY_PRINT --language_in ECMASCRIPT5
if [ $? -eq 0 ]; then
  input2="$tmp"/cc.js
else
  input2="$input"
fi

export JS_HOME="$jsaf"
"$jsaf"/bin/jsaf parse -out "$tmp"/jsaf "$input2" >/dev/null; [ -f "$tmp"/jsaf ] || exit 1
"$jsaf"/bin/jsaf unparse -out "$tmp"/jsaf.js "$tmp"/jsaf; [ -f "$tmp"/jsaf.js ] || exit 1

"$dir"/k/bin/kast -d "$dir" "$tmp"/jsaf.js || exit 1
