#!/bin/bash

module add mpi/openmpi4-x86_64
# mpiCC main.cpp -std=c++11 -o main.exe
for segments_cnt in 1000 1000000 100000000
do
    for proc_cnt in 1 2 3 4 5 6 7 8
    do
        mpiexec --mca opal_warn_on_missing_libcuda 0 -np $proc_cnt ./main.exe $segments_cnt
    done
done
