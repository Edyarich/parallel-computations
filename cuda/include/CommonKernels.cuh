#pragma once
#include <cmath>
#include <iostream>
#include <fstream>
#include <cassert>

const int maxXBlocks = 65535;
const int maxYBlocks = 65535;

__global__ void ReduceSum(int numElements, float* input, float* output);
__global__ void SumBlocks(int numElements, float* input, float* result);
float Sum(int numElements, float* vector, int blockSize);

void WriteToFile(const char* filename, const int data_size,
                    const int block_size, const double time);
void WriteToFile(const char* filename, const int data_x_size, const int data_y_size,
                 const int block_x_size, const int block_y_size, const double time);

float CheckCalculation(int numElements, float* result, float true_value = 3.0f);

void PrintMatrix(float* matrix, int height, int width);
void PrintArray(float* array, int size);

void FillData(float* data, int size, float value = 1.0f);