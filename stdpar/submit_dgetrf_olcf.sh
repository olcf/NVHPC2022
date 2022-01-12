#!/bin/bash
#BSUB -U NVIDIA_SDK_1
#BSUB -W 0:05
#BSUB -nnodes 1
#BSUB -J testdgetrf
#BSUB -o testdgetrf.%J
#BSUB -e testdgetrf.&J

jsrun -n 1 -a 1 -g 1 -c 7 ./testdgetrf_cpu
