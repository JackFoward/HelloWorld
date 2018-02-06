/*  
 *  Copyright (C) 2017 RidgeRun, LLC (http://www.ridgerun.com)
 *  All Rights Reserved. 
 *  Author: Jennifer Caballero <jennifer.caballero@ridgerun.com>
 *
 *  The contents of this software are proprietary and confidential to RidgeRun, 
 *  LLC.  No part of this program may be photocopied, reproduced or translated 
 *  into another programming language without prior written consent of
 *  RidgeRun, LLC.  The user is free to modify the source code after obtaining 
 *  a software license from RidgeRun.  All source code changes must be provided 
 *  back to RidgeRun without any encumbrance. 
 */

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <errno.h>
#include <string.h>

#include "mixer.h"

int
main (int argc, char *argv[])
{
  unsigned char *grayIn, *colorInY, *colorInU,*colorInV, *colorOut, threshold;
  FILE *colorInputFile, *grayInputFile, *colorOutputFile;
  int rwErr, width, height, pitch;
  clock_t begin, end;
  double timeSpent;

  /* Full green as the color to use in cuda kernel */
  unsigned char color[3] = { 255, 0, 0 };

  if (argc < 7) {
    fprintf
        (stderr, "%s %s %s", "Usage:", argv[0],
        "<color image filename> <gray image filename> <output image filename> <width> <height> <threshold>\n");
    return EXIT_FAILURE;
  }

  width = atoi (argv[4]);
  height = atoi (argv[5]);
  sscanf (argv[6], "%hhuox", &threshold);

  /* Open input files */
  colorInputFile = fopen (argv[1], "rb");
  if (colorInputFile == 0) {
    fprintf (stderr, "%s %s %s %s", "Could not open color image: ", argv[1],
	     ", error\n", strerror(errno));
    return EXIT_FAILURE;
  }

  grayInputFile = fopen (argv[2], "rb");
  if (grayInputFile == 0) {
    fprintf (stderr, "%s %s %s %s", "Could not open color image: ", argv[2],
	     ", error\n", strerror(errno));
    return EXIT_FAILURE;
  }

  /* Compute pitch*/
  pitch = 1;

  while ((pitch - width) < 0) {
      pitch = pitch << 1;
  }

  pitch = pitch - width;

  printf ("Computed pitch is: %d\n", pitch);

  /* CUDA memory allocation */
  if (!imageMixerAllocateMemory (&grayIn, &colorInY, &colorInU, &colorInV, &colorOut, width, height, pitch))
    return EXIT_FAILURE;

  /* Load image data into cuda allocated memory */
  rwErr = fread (colorInY, 1, (width + pitch) * height, colorInputFile);

  if (rwErr != (width + pitch) * height) {
    fprintf (stderr, "%s %s %s %s", "File ", argv[1], " Y plane read error: \n", strerror(errno));
    return EXIT_FAILURE;
  }

  rwErr = fread (colorInU, 1, (width + pitch) * (height/4), colorInputFile);

  if (rwErr != (width + pitch) * (height/4)) {
    fprintf (stderr, "%s %s %s %s", "File ", argv[1], " U plane read error: \n", strerror(errno));
    return EXIT_FAILURE;
  }

  rwErr = fread (colorInV, 1, (width + pitch) * (height/4), colorInputFile);

  if (rwErr != (width + pitch) * (height/4)) {
    fprintf (stderr, "%s %s %s %s", "File ", argv[1], " V plane read error: \n", strerror(errno));
    return EXIT_FAILURE;
  }
  fclose (colorInputFile);

  rwErr = fread (grayIn, 1, (width + pitch) * height, grayInputFile);

  if (rwErr != (width + pitch) * height) {
    fprintf (stderr, "%s %s %s", "File ", argv[2], " read error\n");
  }
  fclose (grayInputFile);

  begin = clock ();

  /* Call CUDA algorithm */
  if (!imageMixer (grayIn, colorInY, colorInV, colorInU, colorOut, width, height, threshold, color, pitch))
    return EXIT_FAILURE;

  end = clock ();
  timeSpent = (double) (end - begin) / CLOCKS_PER_SEC;
  printf ("Time spent by CUDA kernel: %f s\n", timeSpent);

  /* Write output file */
  colorOutputFile = fopen (argv[3], "wb");

  if (colorOutputFile == 0) {
    fprintf (stderr, "%s %s %s %s", "Could not open color image: ", argv[3],
	     ", error\n", strerror(errno));
    return EXIT_FAILURE;
  }
  rwErr = fwrite (colorOut, 1, width * height * 1.5, colorOutputFile);

  if (rwErr != width * height * 1.5) {
    fprintf (stderr, "%s %s %s", "File ", argv[3], " write error\n");
  }
  fclose (colorOutputFile);

  /* Free CUDA memory  */
  if (!imageMixerFreeMemory (grayIn, colorInY, colorInU, colorInV, colorOut))
    return EXIT_FAILURE;

  return 0;
}
