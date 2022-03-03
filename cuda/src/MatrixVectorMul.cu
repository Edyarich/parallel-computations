#include <MatrixVectorMul.cuh>

__global__
void MatrixVectorMul(int height, int width, float* matrix, float* vector, float* result) {
    extern __shared__ float sh_data[];
    float* mat_window = sh_data;

    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    float thread_sum = 0.0;

    for (int col = 0; col < width; ++col) {
        int mat_idx = tid * width + col;

        if (tid < height && col < width) {
            mat_window[threadIdx.x] = matrix[mat_idx];
        }

        __syncthreads();

        thread_sum += mat_window[threadIdx.x] * vector[col];
        __syncthreads();
    }

    if (tid < height) {
        result[tid] = thread_sum;
    }
}
