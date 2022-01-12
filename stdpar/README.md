# Standard Language Parallelism

## Fortran

In this example we are solving a linear system Ax = B where A is square. This test will run on
the CPU or GPU, depending on the compilation/linking options, i.e.

```
# CPU
nvfortran testdgetrf.F90 -lblas # or other BLAS library

# GPU
nvfortran testdgetrf.F90 -stdpar -cuda -gpu=nvlamath,cuda11.4 -cudalib=nvlamath,curand
```

Note that because we use the `-stdpar` option in the GPU build, all Fortran allocatable arrays
use managed memory, and can be used on either the CPU or GPU.


## C++

We will look at a saxpy example using standard C++.

To compile for the GPU, we will use:
```
nvc++ -stdpar=gpu -gpu=cc80 ./saxpy_stdpar.cpp
```

The `-stdpar=gpu` command will enable the compiler to generate code that can run on the GPU. The default to this command is `=gpu` so you do not need to explicitly use that opition, but I find it helpful. `-gpu=cc80` simply says that we are targeting A100 GPUs, the GPUs on Perlmutter.

This will compile our executable ready for the GPU. 

To run the code:
```
sbatch batch.sh
```

You should see SUCCESS written to the slurm output file in your directory. In the profiling section, we will see how to confirm that this code ran on the GPU using Nsight Systems.

Now we can repeat the process and target CPU parallelism using the `-stdpar=multicore` command.
```
nvc++ -stdpar=multicore ./saxpy_stdpar.cpp
```

Rerun your code with:
```
sbatch batch.sh
```
