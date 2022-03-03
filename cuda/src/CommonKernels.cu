#include <CommonKernels.cuh>


__global__ void ReduceSum(int numElements, float* input, float* output) {
    extern __shared__ float sh_data[];
    int tid = blockDim.x * blockIdx.x * 2 + threadIdx.x;
    int local_tid = threadIdx.x;

    if (tid + blockDim.x < numElements) {
        sh_data[local_tid] = input[tid] + input[tid + blockDim.x];
    } else if (tid < numElements) {
        sh_data[local_tid] = input[tid];
    } else {
        sh_data[local_tid] = 0;
    }
    __syncthreads();

    for (int step = blockDim.x / 2; step >= 1; step >>= 1) {
        if (threadIdx.x < step) {
            sh_data[local_tid] += sh_data[local_tid + step];
            __syncthreads();
        } else {
            break;
        }
    }

    if (threadIdx.x == 0) {
        output[blockIdx.x] = sh_data[0];
    }
}

__global__ void SumBlocks(int numElements, float* input, float* result) {
    int local_tid = threadIdx.x;
    float thread_sum = 0.0f;

    for (int i = local_tid; i < numElements; i += blockDim.x) {
        thread_sum += input[i];
    }
    
    result[local_tid] = thread_sum;
}

float Sum(int numElements, float* vector, int blockSize) {
    int numBlocks = (numElements + blockSize - 1) / blockSize;
    float* result = (float*)calloc(blockSize, sizeof(float));

    float* d_vec = nullptr;
    float* d_result = nullptr;

    cudaMalloc(&d_vec, numElements * sizeof(float));
    cudaMalloc(&d_result, numBlocks * sizeof(float));

    cudaMemcpy(d_vec, vector, numElements * sizeof(float), cudaMemcpyHostToDevice);

    int remainderSize = numElements;

    while (numBlocks > 1) {
        ReduceSum<<<numBlocks, blockSize, blockSize * sizeof(float)>>>(remainderSize,
                                                                       d_vec,
                                                                       d_result);
        cudaMemcpy(d_vec, d_result, numBlocks * sizeof(float), cudaMemcpyDeviceToDevice);

        remainderSize = numBlocks;
        numBlocks = (numBlocks + blockSize - 1) / blockSize;
    }

    cudaMemcpy(result, d_vec, remainderSize * sizeof(float), cudaMemcpyDeviceToHost);

    float sum = 0.0;
    for (int i = 0; i < remainderSize; ++i) {
        sum += result[i];
    }

    cudaFree(d_vec);
    cudaFree(d_result);
    free(result);

    return sum;
}

void WriteToFile(const char* filename, const int data_size,
                    const int block_size, const double time) {
    std::fstream outfile;
    outfile.open(filename, std::ios::out | std::ios::app);
    outfile << data_size << ' ' << block_size << ' ' << time << '\n';
    outfile.close();
}

void WriteToFile(const char* filename, const int data_x_size, const int data_y_size,
                    const int block_x_size, const int block_y_size, const double time) {
    std::fstream outfile;
    outfile.open(filename, std::ios::out | std::ios::app);
    outfile << data_x_size << ' ' << data_y_size << ' ' << block_x_size << ' ';
    outfile << block_y_size << ' ' << time << '\n';
    outfile.close();
}

float CheckCalculation(int numElements, float* result, float true_value) {
    float maxError = 0.0f;
    for (int i = 0; i < numElements; ++i) {
        maxError = fmax(maxError, fabs(result[i] - true_value));
    }
    return maxError;
}

void FillData(float* data, int size, float value) {
    for (int i = 0; i < size; ++i) {
        data[i] = value;
    }
}

void PrintMatrix(float* matrix, int height, int width) {
    for (int i = 0; i < height; ++i) {
        for (int j = 0; j < width; ++j) {
            std::cout << i << " " << j << " " << matrix[i * width + j] << "\n";
        }
    }
}

void PrintArray(float* array, int size) {
    for (int i = 0; i < size; ++i) {
        std::cout << i << " " << array[i] << std::endl;
    }
}