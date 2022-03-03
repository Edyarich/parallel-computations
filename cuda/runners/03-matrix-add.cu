#include <KernelMatrixAdd.cuh>

int main(int argc, char** argv) {
    assert(argc == 5 && "Wrong arguments count");
    int blockXSize = static_cast<int>(std::strtol(argv[1], nullptr, 10));
    int blockYSize = static_cast<int>(std::strtol(argv[2], nullptr, 10));
    int matXSize = static_cast<int>(std::strtol(argv[3], nullptr, 10));
    int matYSize = static_cast<int>(std::strtol(argv[4], nullptr, 10));

    size_t N = matXSize * matYSize;
    size_t size = N * sizeof(float);
    
    float *x = (float*)malloc(size);
    float *y = (float*)malloc(size);
    float *res = (float*)malloc(size);

    for (int i = 0; i < N; ++i) {
        x[i] = 1.0f;
        y[i] = 2.0f;
    }

    size_t pitch = 0;
    float *d_x = nullptr;
    float *d_y = nullptr;
    float *d_res = nullptr;

    cudaMallocPitch(&d_x, &pitch, matXSize * sizeof(float), matYSize);
    cudaMallocPitch(&d_y, &pitch, matXSize * sizeof(float), matYSize);
    cudaMallocPitch(&d_res, &pitch, matXSize * sizeof(float), matYSize);

    // std::cout << "Matrix width = " << pitch / sizeof(float) << std::endl;

    cudaMemcpy2D(d_x, pitch, x, matXSize * sizeof(float), matXSize * sizeof(float), matYSize,
                                                                            cudaMemcpyHostToDevice);
    cudaMemcpy2D(d_y, pitch, y, matXSize * sizeof(float), matXSize * sizeof(float), matYSize,
                                                                            cudaMemcpyHostToDevice);

    cudaEvent_t start;
    cudaEvent_t stop;

    // Creating event
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);

    int numXBlocks = fmin(maxXBlocks, (pitch / sizeof(float) + blockXSize - 1) / blockXSize);
    int numYBlocks = fmin(maxYBlocks, (matYSize + blockYSize - 1) / blockYSize);

    dim3 numBlocks(numXBlocks, numYBlocks);
    dim3 blockSize(blockXSize, blockYSize);

    KernelMatrixAdd<<<numBlocks, blockSize>>>(matYSize, pitch / sizeof(float), 0, d_x, d_y, d_res);

    // cudaEventRecord(stop);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    cudaMemcpy2D(res, matXSize * sizeof(float), d_res, pitch, matXSize * sizeof(float), matYSize,
                    cudaMemcpyDeviceToHost);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    
    float maxError = CheckCalculation(N, res);
    std::cout << "maxError = " << maxError << std::endl;
    std::cout << "Elapsed Time = " << milliseconds << std::endl;
    WriteToFile(OUT_FILENAME, matXSize, matYSize, blockXSize, blockYSize, milliseconds);

    cudaFree(d_x);
    cudaFree(d_y);
    cudaFree(d_res);

    free(x);
    free(y);
    free(res);
    return 0;
}
