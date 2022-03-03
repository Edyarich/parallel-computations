#!/usr/bin/env python3

import sys
import re


MIN_WORD_LEN = 3
FILTER_REG_EX = "[^A-Za-z\\s]"

for line in sys.stdin:
    try:
        article_id, text = line.strip().split('\t', 1)
    except ValueError as e:
        continue

    text_parts = text.lower().split()

    for part in text_parts:
        for word in re.split(FILTER_REG_EX, part):
            if len(word) < MIN_WORD_LEN:
                continue

            print("".join(sorted(word)), word, 1, sep='\t')

