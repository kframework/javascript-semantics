#!/usr/bin/python

import sys
import re

with open(sys.argv[1]) as f:
    for line in f:
        m = re.match(r'^#include "(.*)"', line)
        if m:
            print(open(m.group(1)).read()),
        else:
            print(line),
