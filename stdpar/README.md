# Standard Language Parallelism

## Fortran

In this example we are solving a linear system Ax = B where A is square. This test will run on
the CPU or GPU, depending on the compilation/linking options.

To set up the environment, make sure you have the NVIDIA HPC SDK loaded.

```
# NERSC (note that PrgEnv-nvidia is the default)
module load PrgEnv-nvidia
module load cudatoolkit

# OLCF
module load nvhpc/21.9
```

### Exercise 1

Verify you can compile the code to run on the CPU.

```
nvfortran -o testdgetrf_cpu testdgetrf.F90 -lblas # or other BLAS library
```

Now submit the job and make sure the output of the test passes. Which script you use
will depend on the site you're running at.

```
# NERSC
sbatch submit_dgetrf_nersc.sh

# OLCF
bsub -P PROJ123 submit_dgetrf_olcf.sh
```

### Exercise 2

Recompile the code to target the GPU.

```
nvfortran -o testdgetrf_gpu testdgetrf.F90 -stdpar -cuda -gpu=nvlamath,cuda11.4 -cudalib=nvlamath,curand
```

Note that because we use the `-stdpar` option in the GPU build, all Fortran allocatable arrays
use managed memory, and can be used on either the CPU or GPU.

Now update the job script to use the GPU build instead of the CPU build. Again verify the test passes.

### Exercise 3

Collect a profile of the GPU application using Nsight Systems. You'll need to update the job script
so that it prepends `nsys profile --stats=true` to the executable name. The `nsys` command should come
after the job launcher command (srun, jsrun, etc.). Verify that the GPU build actually executed a GPU kernel.

### Exercise 4

Vary `M` and `N` (keeping the matrix square for simplicity). Collect a profile for each case and see how the
performance depends on the linear system size. You may want to use the `-o` option to Nsight Systems to name
your profiles explicitly (e.g. `nsys profile --stats=true -o dgetrf_1000`).

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
