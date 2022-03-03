#pragma once
#include <cmath>
#include <iostream>
#include <fstream>
#include <cassert>
#include <CommonKernels.cuh>

const char OUT_FILENAME[] = "data/matrix_vector_mul.txt";

__global__ void MatrixVectorMul(int height, int width, float* matrix, float* vector, float* result);
