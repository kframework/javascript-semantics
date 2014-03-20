#!/bin/bash

cmd=`basename "$0"`
dir=`dirname "$0"`
tmp=`mktemp /tmp/"$cmd".XXXXXXXXXX`
cleanup() { rm -f "$tmp" "$tmp.js"; }
trap cleanup EXIT INT TERM

for i in "$@"; do
  cat "$dir"/prelude.js "$i" >"$tmp".js
  echo -n "#### $i "
  "$dir"/k/bin/krun --parser "$dir"/parser.sh --pattern "<k> @Normal </k>" "$tmp".js 2>/dev/null | grep -q 'Empty substitution' && echo "succeed" || echo "failed"
done
