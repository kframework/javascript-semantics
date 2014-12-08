#!/bin/bash

error() { echo "error: $@"; exit 1; }

echo "Bootstrapping build..."
rm -f js-config.k && \
touch js-config.k && \
./kbuild.sh || error "failed bootstrapping build"

echo "Self-hosted standard built-in objects..."
{ cat stdlib/00.debug.js
  cat stdlib/01.global.js
  cat stdlib/02.object.js
  cat stdlib/03.function.js
  cat stdlib/04.array.js
  cat stdlib/05.string.js
  cat stdlib/06.boolean.js
  cat stdlib/07.number.js
  cat stdlib/08.math.js
  cat stdlib/09.date.js
  cat stdlib/10.regexp.js
  cat stdlib/11.error.js
# cat stdlib/12.json.js
} >stdlib.js || error "failed to create stdlib.js"

echo "Hard-wiring standard built-in objects..."
{ echo "<objs> ( _ =>" && \
  ./k/bin/krun stdlib.js | awk '/<objs>/ {p=1; next} /<\/objs>/ {p=0} p' | sed 's/@o/@oo/g' && \
  echo ") </objs>" && \
  echo "syntax Oid ::= \"@oo\" \"(\" Int \")\""
} >js-config.k || error "failed to create js-config.k"

echo "Final build..."
./kbuild.sh || error "failed final build"
