#!/bin/bash

rm data.txt
rm out.txt
rm error.txt

sbatch --ntasks=8 --comment="Mpi task" --output=out.txt --error=error.txt run.sh
