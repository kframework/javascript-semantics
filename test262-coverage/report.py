#!/usr/bin/python

import sys
import re

stat = sys.argv[1]
jsk  = sys.argv[2]

loc = sum(1 for line in open(jsk))
m = [0 for x in range(loc + 1)]

with open(stat) as f:
    for line in f:
        m[int(line)] += 1

i = 0
with open(jsk) as f:
    for line in f:
        i += 1
        print '{0:9d}  {1}'.format(m[i], line),
