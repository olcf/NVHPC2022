# Standard Language Parallelism

## Fortran

In this example we are solving a linear system Ax = B where A is square. This test will run on
the CPU or GPU, depending on the compilation/linking options, i.e.

```
# CPU
nvfortran -o testdgetrf_cpu testdgetrf.F90 -lblas # or other BLAS library

# GPU
nvfortran -o testdgetrf_gpu testdgetrf.F90 -stdpar -cuda -gpu=nvlamath,cuda11.4 -cudalib=nvlamath,curand
```

Note that because we use the `-stdpar` option in the GPU build, all Fortran allocatable arrays
use managed memory, and can be used on either the CPU or GPU.


## C++

We will look at a saxpy example using standard C++.

To compile for the GPU, we will use:
```
nvc++ -stdpar=gpu -o saxpy_gpu ./saxpy.cpp
```

The `-stdpar=gpu` command will enable the compiler to generate code that can run on the GPU.
(The default is `gpu` so you do not need to explicitly use that option, but it is useful to
be explicit, especially when switching between CPU and GPU platforms.)

To run the code:
```
sbatch submit_saxpy.sh
```

You should see SUCCESS written to the slurm output file in your directory. In the profiling section, we will see how to confirm that this code ran on the GPU using Nsight Systems.

Now we can repeat the process and target CPU parallelism using the `-stdpar=multicore` command.
```
nvc++ -stdpar=multicore -o saxpy_cpu ./saxpy.cpp
```

Update the executable name in the run script and try again:
```
sbatch submit_saxpy.sh
```
