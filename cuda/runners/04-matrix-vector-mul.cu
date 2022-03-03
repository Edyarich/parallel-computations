#include <MatrixVectorMul.cuh>

int main(int argc, char** argv) {
    assert(argc == 4 && "Wrong arguments count");
    int blockSize = static_cast<int>(std::strtol(argv[1], nullptr, 10));
    int matXSize = static_cast<int>(std::strtol(argv[2], nullptr, 10));
    int matYSize = static_cast<int>(std::strtol(argv[3], nullptr, 10));

    size_t N = matXSize * matYSize;

    float *mat = (float*)malloc(N * sizeof(float));
    float *vec = (float*)malloc(matXSize * sizeof(float));
    float *res = (float*)malloc(matYSize * sizeof(float));

    FillData(mat, N);
    FillData(vec, matXSize);

    size_t pitch = 0;
    float *d_mat = nullptr;
    float *d_vec = nullptr;
    float *d_res = nullptr;

    cudaMallocPitch(&d_mat, &pitch, matXSize * sizeof(float), matYSize);
    cudaMallocPitch(&d_vec, &pitch, matXSize * sizeof(float), 1);
    cudaMalloc(&d_res, matYSize * sizeof(float));

    cudaMemcpy2D(d_mat, pitch, mat, matXSize * sizeof(float), matXSize * sizeof(float), matYSize,
                 cudaMemcpyHostToDevice);
    cudaMemcpy2D(d_vec, pitch, vec, matXSize * sizeof(float), matXSize * sizeof(float), 1,
                 cudaMemcpyHostToDevice);

    cudaEvent_t start;
    cudaEvent_t stop;

    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    int numBlocks = fmin(maxXBlocks, (matYSize + blockSize - 1) / blockSize);
    int sharedMemInBytes = blockSize  * sizeof(float);

    cudaEventRecord(start);

    MatrixVectorMul<<<numBlocks, blockSize, sharedMemInBytes>>>(matYSize,
                                                                pitch / sizeof(float),
                                                                d_mat,
                                                                d_vec,
                                                                d_res);

    // cudaEventRecord(stop);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    cudaMemcpy(res, d_res, matYSize * sizeof(float), cudaMemcpyDeviceToHost);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    // PrintMatrix(res, 1, matYSize);
    float maxError = CheckCalculation(matYSize, res, matXSize);
    std::cout << "maxError = " << maxError << std::endl;
    std::cout << "Elapsed Time = " << milliseconds << std::endl;
    WriteToFile(OUT_FILENAME, matXSize, matYSize, blockSize, 1, milliseconds);

    cudaFree(d_mat);
    cudaFree(d_vec);
    cudaFree(d_res);

    free(mat);
    free(vec);
    free(res);
    return 0;
}
