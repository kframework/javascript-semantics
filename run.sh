#!/bin/bash

dir=`dirname "$0"`

export JAVA_TOOL_OPTIONS='-Djava.awt.headless=true'
"$dir"/k/bin/krun -d "$dir" --parser "$dir"/parser.sh --pattern "<k> K:K </k>" "$@"
