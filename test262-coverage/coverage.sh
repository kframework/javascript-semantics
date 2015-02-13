#!/bin/bash

# NOTE: Run first 'make -k -j N test262-core-coverage' where N is a number of processes.

echo "Gathering trace information..."
for i in `find ../test262 -name '*.cov'`; do grep 'js.k' "$i" | cut -f 2 -d ':'; done >coverage
echo "Generating coverage report..."
./report.py coverage ../js.k | \
sed 's/^[ ]\([ ]*0[ ][ ]*\)\(rule\|Let\|Do\|If\|Return\|Nop\|Exit\)/!\1\2/' | \
sed 's/^\([ ][ ]*\)0/\1 /' | \
sed 's/^!/ /'
