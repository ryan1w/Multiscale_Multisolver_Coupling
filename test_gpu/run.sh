#!/bin/bash

# OMP_NUM_THREADS=2 mpirun -np 2 ./lmp_meso -in in.md > log.out

# OMP_NUM_THREADS=2 mpirun -np 2 ./lmp_meso  -in in.md_gpu > log.out

gdb --args ./lmp_meso -in in.md_gpu