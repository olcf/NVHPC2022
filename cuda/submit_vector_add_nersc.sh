#!/bin/bash
#SBATCH -A ntrain4_g
#SBATCH --reservation=nvhpc_day2
#SBATCH -C gpu
#SBATCH -G 1
#SBATCH -q regular
#SBATCH -t 5
#SBATCH -n 1
#SBATCH -c 128
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-task=1

module load PrgEnv-nvidia
module load cudatoolkit

srun ./vector_add
