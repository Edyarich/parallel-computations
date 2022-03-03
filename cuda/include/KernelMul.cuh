#pragma once
#include <cmath>
#include <iostream>
#include <fstream>
#include <cassert>
#include <CommonKernels.cuh>

const char OUT_FILENAME[] = "data/kernel_mul.txt";

__global__ void KernelMul(int numElements, float* x, float* y, float* result);
