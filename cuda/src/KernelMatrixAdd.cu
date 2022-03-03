#include <KernelMatrixAdd.cuh>

__global__ void KernelMatrixAdd(int height, int width, int pitch,
                                    float* A, float* B, float* result) {
    int width_ind = blockIdx.x * blockDim.x + threadIdx.x;
    int height_ind = blockIdx.y * blockDim.y + threadIdx.y;

    int width_stride = blockDim.x * gridDim.x;
    int height_stride = blockDim.y * gridDim.y;

    for (int i = height_ind; i < height; i += height_stride) {
        for (int j = width_ind; j < width; j += width_stride) {
            int idx = i * width + j;
            result[idx] = A[idx] + B[idx];
        }
    }
}
