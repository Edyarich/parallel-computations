#pragma once
#include <CommonKernels.cuh>

const char OUT_FILENAME[] = "data/matrix_mul.txt";

__global__
void MatrixMul(int heightA, int widthA, int widthB,
                float *matrixA, float *matrixB, float *matrixResult);
