#!/usr/bin/env python3

import sys
        

prev_sorted_word = None
prev_permutated_word = None
total_count = 0
permutated_words = 1

for line in sys.stdin:
    try:
        sorted_word, word, count = line.strip().split('\t')
        count = int(count)
    except ValueError as e:
        continue

    if sorted_word == prev_sorted_word or prev_sorted_word == None:
        if word != prev_permutated_word and prev_permutated_word != None:
            permutated_words += 1
        
        total_count += count

    else:
        print(prev_sorted_word, total_count, permutated_words, sep='\t')
        total_count = count
        permutated_words = 1

    prev_sorted_word = sorted_word
    prev_permutated_word = word

print(prev_sorted_word, total_count, permutated_words, sep='\t')
