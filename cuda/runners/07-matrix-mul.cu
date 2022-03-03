#include <MatrixMul.cuh>

int main(int argc, char** argv) {
    assert(argc == 5 && "Wrong arguments count");
    int blockXSize = static_cast<int>(std::strtol(argv[1], nullptr, 10));
    int aHeight = static_cast<int>(std::strtol(argv[2], nullptr, 10));
    int aWidth = static_cast<int>(std::strtol(argv[3], nullptr, 10));
    int bWidth = static_cast<int>(std::strtol(argv[4], nullptr, 10));
    int bHeight = aWidth;
    int blockYSize = blockXSize;

    size_t aN = aHeight * aWidth;
    size_t bN = bHeight * bWidth;
    size_t resN = aHeight * bWidth;

    size_t aSize = aN * sizeof(float);
    size_t bSize = bN * sizeof(float);
    size_t resSize = resN * sizeof(float);

    float *a = (float*)malloc(aSize);
    float *b = (float*)malloc(bSize);
    float *res = (float*)malloc(resSize);

    FillData(a, aN);
    FillData(b, bN, 2.0f);

    size_t a_pitch = 0;
    size_t b_pitch = 0;
    size_t res_pitch = 0;
    float *d_a = nullptr;
    float *d_b = nullptr;
    float *d_res = nullptr;

    cudaMallocPitch(&d_a, &a_pitch, aWidth * sizeof(float), aHeight);
    cudaMallocPitch(&d_b, &b_pitch, bWidth * sizeof(float), bHeight);
    cudaMallocPitch(&d_res, &res_pitch, bWidth * sizeof(float), aHeight);

    cudaMemcpy2D(d_a, a_pitch, a, aWidth * sizeof(float), aWidth * sizeof(float), aHeight,
                 cudaMemcpyHostToDevice);
    cudaMemcpy2D(d_b, b_pitch, b, bWidth * sizeof(float), bWidth * sizeof(float), bHeight,
                 cudaMemcpyHostToDevice);

    cudaEvent_t start;
    cudaEvent_t stop;

    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);

    int numXBlocks = (res_pitch / sizeof(float) + blockXSize - 1) / blockXSize;
    int numYBlocks = (aHeight + blockYSize - 1) / blockYSize;
    int blockSizeInBytes = blockXSize * blockYSize * sizeof(float);

    dim3 numBlocks(numXBlocks, numYBlocks);
    dim3 blockSize(blockXSize, blockYSize);

    MatrixMul<<<numBlocks, blockSize, blockSizeInBytes * 2>>>(aHeight,
                                                                a_pitch / sizeof(float),
                                                                b_pitch / sizeof(float),
                                                                d_a,
                                                                d_b,
                                                                d_res);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    cudaMemcpy2D(res, bWidth * sizeof(float), d_res, res_pitch, bWidth * sizeof(float), aHeight,
                 cudaMemcpyDeviceToHost);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    // PrintMatrix(res, aHeight, bWidth);
    float maxError = CheckCalculation(resN, res, 2.0f * aWidth);
    std::cout << "maxError = " << maxError << std::endl;
    std::cout << "Elapsed Time = " << milliseconds << std::endl;
    WriteToFile(OUT_FILENAME,
                aWidth * aHeight,
                bWidth * bHeight,
                blockXSize,
                blockYSize,
                milliseconds);

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_res);

    free(a);
    free(b);
    free(res);
    return 0;
}

