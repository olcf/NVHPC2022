#!/bin/bash
#BSUB -U NVIDIA_SDK_2
#BSUB -W 0:05
#BSUB -nnodes 1
#BSUB -J hello
#BSUB -o hello.%J
#BSUB -e hello.&J

module load nvhpc/21.9

jsrun -n 1 -a 1 -g 1 -c 7 --smpiargs="-disable_gpu_hooks" ./vector_add
