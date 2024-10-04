#!/bin/bash

mpirun -np 1 lmp_meso -i in.md : -np 1 lmp_meso -in in.mdpd > log.out &


# mpirun -np 1 lmp_meso -in in.mdpd : -np 1 lmp_mpi -i in.dpd > log.out &

echo "waitting for process to finish"
wait
