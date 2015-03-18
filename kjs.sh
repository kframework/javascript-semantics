#!/bin/bash

dir=$(cd `dirname "$0"`; pwd)
tmp=`mktemp /tmp/kjs.XXXXXXXXXX`
cleanup() { rm -f "$tmp" "$tmp".js "$tmp".out; }
trap cleanup INT TERM

for i in "$@"; do
  "$dir"/jsmassage.sh -f "$i" >"$tmp".js && \
  krun -d "$dir" --output-file "$tmp".out "$tmp".js && \
  if [ "`sed -n '/<k>/,/<\/k>/{ p }' "$tmp".out | tr -d ' \n'`" = "<k>@Normal</k>" ]; then
    cleanup
  else
    echo "Error: failed to run the program: $i"
    echo "Check the dumped output: $tmp.out"
  fi
done
