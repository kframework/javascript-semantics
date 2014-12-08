#!/bin/bash

cmd=`basename "$0"`
dir=`dirname "$0"`
jsaf="$dir"/jsaf

tmp=`mktemp -d /tmp/"$cmd".XXXXXXXXXX`
cleanup() { rm -rf "$tmp"; }
trap cleanup EXIT INT TERM

FILEIN=false
while [ $# -gt 0 ]; do
  case "$1" in
    -f)
      FILEIN=true
      shift
    ;;
    *)
      break
    ;;
  esac
done

if "$FILEIN"; then
  input="$1"
else
  input="$tmp"/in.js
  echo "$1" >"$input"
fi

input2="$tmp"/pp.js
"$dir"/pp.sh -1 "$input" >"$input2"

export JS_HOME="$jsaf"
"$jsaf"/bin/jsaf parse -out "$tmp"/jsaf "$input2" >/dev/null; [ -f "$tmp"/jsaf ] || exit 1
"$jsaf"/bin/jsaf unparse -out "$tmp"/jsaf.js "$tmp"/jsaf; [ -f "$tmp"/jsaf.js ] || exit 1

"$dir"/pp.sh -2 "$tmp"/jsaf.js || exit 1
