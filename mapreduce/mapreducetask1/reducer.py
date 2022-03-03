#!/usr/bin/env python3

import sys
import random


MAX_IDS_IN_ROW = 5
MIN_IDS_IN_ROW = 1

ids_to_write = 0
ids = []

def print_ids(ids):
    for i, id in enumerate(ids):
        if i == len(ids) - 1:
            print(id)
        else:
            print(id, end=',')
            

for line in sys.stdin:
    items = line.split()
    if not items:
        continue

    _, curr_id = items

    if ids_to_write == 0:
        print_ids(ids)
        ids.clear()
        ids_to_write = random.randint(MIN_IDS_IN_ROW, MAX_IDS_IN_ROW)
        
    ids.append(curr_id)
    ids_to_write -= 1


if ids_to_write > 0:
    print_ids(ids)
    
