#include <ScalarMulRunner.cuh>

int main(int argc, char** argv) {
    assert(argc == 3 && "Wrong arguments count");
    int blockSize = static_cast<int>(std::strtol(argv[1], nullptr, 10));
    int N = static_cast<int>(std::strtol(argv[2], nullptr, 10));

    size_t size = N * sizeof(float);

    float *x = (float*)malloc(size);

    for (int i = 0; i < N; ++i) {
        x[i] = 1.0f;
    }

    cudaEvent_t start;
    cudaEvent_t stop;

    // Creating event
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);

    float first_scalar_mul = ScalarMulSumPlusReduction(N, x, x, blockSize);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    std::cout << "First scalar mul error = " << first_scalar_mul - N << std::endl;
    std::cout << "Elapsed Time = " << milliseconds << std::endl;
    WriteToFile(OUT_FIRST_FILENAME, N, blockSize, milliseconds);
    ////////////////////////////////////////////////////////////////////////////////////////////////
    cudaEventRecord(start);

    float second_scalar_mul = ScalarMulTwoReductions(N, x, x, blockSize);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    cudaEventElapsedTime(&milliseconds, start, stop);

    std::cout << "Second scalar mul error = " << second_scalar_mul - N << std::endl;
    std::cout << "Elapsed Time = " << milliseconds << std::endl;
    WriteToFile(OUT_SND_FILENAME, N, blockSize, milliseconds);

    free(x);
    return 0;
}


