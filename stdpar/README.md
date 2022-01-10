# Standard Language Parallel

## Fortran

This test will run on the CPU or GPU, depending on the compilation/linking options, i.e.
```
nvfortran tdgetrf.F90 -lblas (or other BLAS library)
```

There are some macros to determine how you want to do the last verification: `-DUSE_CUBLAS`, `-DUSE_DOCONCURRENT`, or the default do loop.

This compile/link line should pull everything in for GPU:
```
nvfortran tdgetrf.F90 -stdpar -cuda -gpu=nvlamath -cudalib=nvlamath,cutensor,curand
```

A is square, 2 RHS in B.  Increase N scale up when profiling

`-stdpar` turns on OpenACC recognition, so you can use !@acc as a macro short-cut,
and preserve source integrity when running on the CPU.

`-stdpar` also treats all Fortran allocatable arrays as managed memory.

## C++

We will look at a saxpy example using standard C++. 

To compile, use 
```
nvc++ -stdpar ./saxpy_stdpar.cpp
```

This will compile our executable ready for the GPU. 
