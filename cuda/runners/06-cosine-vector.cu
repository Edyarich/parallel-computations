#include <CosineVector.cuh>


int main(int argc, char** argv) {
    assert(argc == 3 && "Wrong arguments count");
    int blockSize = static_cast<int>(std::strtol(argv[1], nullptr, 10));
    int N = static_cast<int>(std::strtol(argv[2], nullptr, 10));

    size_t size = N * sizeof(float);

    float *x = (float*)malloc(size);
    float *y = (float*)malloc(size);

    for (int i = 0; i < N; ++i) {
        x[i] = 1.0f;
        y[i] = -1.0f;
    }

    cudaEvent_t start;
    cudaEvent_t stop;

    // Creating event
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);

    float cos_angle = CosineVector(N, x, y, blockSize);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    std::cout << "Cosine angle error = " << cos_angle + 1.0f << std::endl;
    std::cout << "Elapsed Time = " << milliseconds << std::endl;
    WriteToFile(OUT_FILENAME6, N, blockSize, milliseconds);

    free(x);
    free(y);
    return 0;

}

