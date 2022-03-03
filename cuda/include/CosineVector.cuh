#pragma once
#include <KernelMul.cuh>
#include <ScalarMulRunner.cuh>
#include <CommonKernels.cuh>

const char OUT_FILENAME6[] = "data/cos_vec.txt";

float CosineVector(int numElements, float* vector1, float* vector2, int blockSize);
