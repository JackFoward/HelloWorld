/*
 *  Copyright (C) 2017 RidgeRun, LLC (http://www.ridgerun.com)
 *  All Rights Reserved.
 *  Author: Jennifer Caballero <jennifer.caballero@ridgerun.com>
 *
 *  The contents of this software are proprietary and confidential to RidgeRun,
 *  LLC.  No part of this program may be photocopied, reproduced or translated
 *  into another programming language without prior written consent of
 *  RidgeRun, LLC.  The user is free to modify the source code after obtaining
 *  a software license from RidgeRun.  All source code changes must be provided    *  back to RidgeRun without any encumbrance.
 */
//hi there
#include "stdio.h"
#include "mixer.h"

__global__ void
cudaImageMixer (unsigned char *grayIn, unsigned char *colorInY, unsigned char *colorInU,
    unsigned char *colorInV, unsigned char *colorOut, int width, int height,
      unsigned char threshold, unsigned char yColor, unsigned char uColor, unsigned char vColor, int pitch)
{
  /* Compute indexes */
  int yIndex = (2 * width * blockIdx.y) + (2 * threadIdx.x) +
      ((width / 2) * (blockIdx.x));

  int yIndexPitchOdd = yIndex + (2 * pitch * blockIdx.y);
  int yIndexpitchEven = yIndexPitchOdd + pitch;

  int uIndex = (width * height) + ((width / 2) * blockIdx.y) +
      threadIdx.x + ((width / 4) * blockIdx.x);

  int vIndex = uIndex + ((width * height) / 4);
  int uvIndexPitch = uIndex + ((pitch/2) * blockIdx.y) - (width * height);


  /* Test threshold and assign U and V accordingly */

  if (grayIn[yIndexPitchOdd] > threshold || grayIn[yIndexPitchOdd + 1] > threshold ||
      grayIn[yIndexpitchEven + width] > threshold
      || grayIn[yIndexpitchEven + width + 1] > threshold) {
    colorOut[uIndex] = uColor;
    colorOut[vIndex] = vColor;
  } else {
    colorOut[uIndex] = colorInU[uvIndexPitch];
    colorOut[vIndex] = colorInV[uvIndexPitch];
  }

  colorOut[yIndex] = colorInY[yIndexPitchOdd];
  colorOut[yIndex + 1] = colorInY[yIndexPitchOdd + 1];
  colorOut[yIndex + width] = colorInY[yIndexpitchEven + width];
  colorOut[yIndex + width + 1] = colorInY[yIndexpitchEven + width + 1];

}

bool
imageMixer (unsigned char *grayIn, unsigned char *colorInY, unsigned char *colorInU,
    unsigned char *colorInV, unsigned char *colorOut, int width, int height,
      unsigned char threshold, unsigned char *color, int pitch)
{

  cudaError_t cudaErr;

  if (color == NULL) {
    printf ("Error: Please provide a color\n");
    return false;
  } else if (grayIn == NULL || colorInY == NULL || colorInU == NULL
      || colorInV == NULL || colorOut == NULL) {
    printf ("Error: NULL memory pointer in %s\n", __FUNCTION__);
    return false;
  }

  cudaImageMixer <<< dim3 (2, (height / 2), 1), dim3 (width / 4, 1,
      1) >>> (grayIn, colorInY, colorInU, colorInV, colorOut, width, height, threshold, color[0],
      color[1], color[2], pitch);

  cudaErr = cudaGetLastError ();

  if (cudaSuccess != cudaErr) {
    printf ("CUDA kernel Error\n");
    return false;
  }

  cudaDeviceSynchronize ();

  cudaErr = cudaGetLastError ();

  if (cudaSuccess != cudaErr) {
    printf ("CUDA sync Error\n");
    return false;
  }

  return true;
}

bool
imageMixerAllocateMemory (unsigned char **grayIn, unsigned char **colorInY,
    unsigned char **colorInU, unsigned char **colorInV,
      unsigned char **colorOut, int width, int height, int pitch)
{

  cudaError_t cudaErr;

  if (grayIn == NULL || colorInY == NULL || colorInU == NULL|| colorInV == NULL
      || colorOut == NULL) {
    printf ("Error: NULL memory pointer in %s\n", __FUNCTION__);
    return false;
  }

  /* TX1 Hardware doesn't support more than 1024 threads/block */
  if (width / 4 > 1024) {
    printf ("Error: Max supported width is 4096\n");
    return false;
  }

  cudaMallocManaged (colorInY, (width + pitch) * height);
  cudaMallocManaged (colorInU, (width + pitch) * (height/4));
  cudaMallocManaged (colorInV, (width + pitch) * (height/4));
  cudaMallocManaged (colorOut, width * height * 1.5);
  cudaMallocManaged (grayIn, (width + pitch) * height);

  cudaErr = cudaGetLastError ();
  if (cudaSuccess != cudaErr) {
    printf ("CUDA alloc Error\n");
    return false;
  }

  return true;
}

bool
imageMixerFreeMemory (unsigned char *grayIn, unsigned char *colorInY,
    unsigned char *colorInU, unsigned char *colorInV, unsigned char *colorOut)
{

  cudaError_t cudaErr;

  if (grayIn == NULL || colorInY == NULL || colorInU == NULL || colorInV == NULL
      || colorOut == NULL) {
    printf ("Error: NULL memory pointer in %s\n", __FUNCTION__);
    return false;
  }

  cudaFree (grayIn);
  cudaFree (colorInY);
  cudaFree (colorInU);
  cudaFree (colorInV);
  cudaFree (colorOut);
  cudaErr = cudaGetLastError ();

  if (cudaSuccess != cudaErr) {
    printf ("CUDA alloc Error\n");
    return false;
  }

  return true;
}
