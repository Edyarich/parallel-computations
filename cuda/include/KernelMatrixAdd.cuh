#pragma once
#include <cmath>
#include <iostream>
#include <fstream>
#include <cassert>
#include <CommonKernels.cuh>

const char OUT_FILENAME[] = "data/matrix_add.txt";

__global__ void KernelMatrixAdd(int height, int width, int pitch,
                                float* A, float* B, float* result);
