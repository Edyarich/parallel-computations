#!/usr/bin/env python3

import sys
import random


MAX_FICTIONAL_IND = 100000
MIN_FICTIONAL_IND = 0

for line in sys.stdin:
    rand_ind = random.randint(MIN_FICTIONAL_IND, MAX_FICTIONAL_IND)
    print(rand_ind, line, sep=' ')

