#include <stdio.h>

// error checking macro
#define cudaCheckErrors(msg) \
    do { \
        cudaError_t __err = cudaGetLastError(); \
        if (__err != cudaSuccess) { \
            fprintf(stderr, "Fatal error: %s (%s at %s:%d)\n", \
                msg, cudaGetErrorString(__err), \
                __FILE__, __LINE__); \
            fprintf(stderr, "*** FAILED - ABORTING\n"); \
            exit(1); \
        } \
    } while (0)

const int DSIZE = 4096;
const int block_size = 256;  // CUDA maximum is 1024

// Vector add kernel: B = B + A
__global__ void vadd(const float *A, float *B, int ds) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x; // create typical 1D thread index from built-in variables
    if (idx < ds) {
        B[idx] = B[idx] + A[idx];                    // do the vector (element) add here
    }
}

int main() {
    float *A, *B;
    cudaMallocManaged(&A, DSIZE * sizeof(float)); // allocate device space for vector A
    cudaMallocManaged(&B, DSIZE * sizeof(float)); // allocate device space for vector B
    cudaCheckErrors("Memory allocation failure"); // error checking

    // Initialize vectors
    for (int i = 0; i < DSIZE; ++i) {
        A[i] = rand() / (float) RAND_MAX;
        B[i] = 0.0;
    }

    // Launch kernel to do the vector addition
    vadd<<<(DSIZE + block_size - 1) / block_size, block_size>>>(A, B, DSIZE);
    cudaCheckErrors("Kernel launch failure");

    // Wait for kernel to complete; the return code from
    // cudaDeviceSynchronize() indicates whether there were any
    // runtime errors during kernel execution.
    cudaDeviceSynchronize();
    cudaCheckErrors("Kernel execution failure");

    // Verify on host that all values in A are the same as B
    for (int i = 0; i < DSIZE; ++i) {
        if (A[i] != B[i]) {
            printf("Error, A[%d] != B[%d]\n", i, i);
            return -1;
        }
    }

    printf ("Success!\n");

    return 0;
}
