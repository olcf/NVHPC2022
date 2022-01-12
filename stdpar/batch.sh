#!/bin/bash
#SBATCH -A ntrain4_g
#SBATCH --reservation=nvhpc_day1
#SBATCH -C gpu
#SBATCH -G 1
#SBATCH -q regular
#SBATCH -t 5
#SBATCH -n 1
#SBATCH -c 128
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-task=1

srun ./a.out
