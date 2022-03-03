#include "KernelAdd.cuh"

int main(int argc, char** argv) {
    assert(argc == 3 && "Wrong arguments count");
    int blockSize = static_cast<int>(std::strtol(argv[1], nullptr, 10));
    int N = static_cast<int>(std::strtol(argv[2], nullptr, 10));
    int numBlocks = fmin(maxXBlocks, (N + blockSize - 1) / blockSize);

    size_t size = N * sizeof(float);
    float *x = (float*)calloc(N, sizeof(float));
    float *y = (float*)calloc(N, sizeof(float));
    float *res = (float*)calloc(N, sizeof(float));

    float *d_x = nullptr;
    float *d_y = nullptr;
    float *d_res = nullptr;

    cudaMalloc(&d_x, size);
    cudaMalloc(&d_y, size);
    cudaMalloc(&d_res, size);

    for (int i = 0; i < N; ++i) {
        x[i] = i;
        y[i] = -i;
    }

    cudaMemcpy(d_x, x, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_y, y, size, cudaMemcpyHostToDevice);

    cudaEvent_t start;
    cudaEvent_t stop;

    // Creating event
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    KernelAdd<<<numBlocks, blockSize>>>(N, d_x, d_y, d_res);

    // cudaEventRecord(stop);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    cudaMemcpy(res, d_res, size, cudaMemcpyDeviceToHost);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    float maxError = CheckCalculation(N, res, 0.0f);
    std::cout << "maxError = " << maxError << std::endl;
    std::cout << "Elapsed Time = " << milliseconds << std::endl;
    WriteToFile(OUT_FILENAME, N, blockSize, milliseconds);

    cudaFree(d_x);
    cudaFree(d_y);
    cudaFree(d_res);

    free(x);
    free(y);
    free(res);
    return 0;
}
