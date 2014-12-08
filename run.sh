#!/bin/bash

cmd=`basename "$0"`
dir=`dirname "$0"`
tmp=`mktemp /tmp/"$cmd".XXXXXXXXXX`
cleanup() { rm -f "$tmp" "$tmp.js"; }
trap cleanup EXIT INT TERM

for i in "$@"; do
  "$dir"/jsmassage.sh -f "$i" >"$tmp".js && \
  "$dir"/k/bin/krun -d "$dir" --pattern-matching --pattern "<k> K:K </k>" "$tmp".js
done
