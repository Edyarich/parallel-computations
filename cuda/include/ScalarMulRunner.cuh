#pragma once

#include <ScalarMul.cuh>
#include <CommonKernels.cuh>
#include <cmath>
#include <iostream>
#include <fstream>
#include <cassert>

const char OUT_FIRST_FILENAME[] = "data/sc_mul_one_red.txt";
const char OUT_SND_FILENAME[] = "data/sc_mul_two_red.txt";

float ScalarMulTwoReductions(int numElements, float* vector1, float* vector2, int blockSize);
float ScalarMulSumPlusReduction(int numElements, float* vector1, float* vector2, int blockSize);
