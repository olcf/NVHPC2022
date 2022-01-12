#!/bin/bash
#BSUB -U NVIDIA_SDK_1
#BSUB -W 0:05
#BSUB -nnodes 1
#BSUB -J saxpy
#BSUB -o saxpy.%J
#BSUB -e saxpy.&J

jsrun -n 1 -a 1 -g 1 -c 7 ./saxpy_gpu
