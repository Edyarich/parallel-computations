#pragma once
#include <cmath>
#include <iostream>
#include <fstream>
#include <cassert>
#include <CommonKernels.cuh>

const char OUT_FILENAME[] = "data/kernel_add.txt";

__global__ void KernelAdd(int numElements, float* x, float* y, float* result);
