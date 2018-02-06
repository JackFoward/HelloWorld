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

#ifndef MIXER_H
#define MIXER_H

bool imageMixerAllocateMemory (unsigned char **grayIn, unsigned char **colorInY,
    unsigned char **colorInU, unsigned char **colorInV, unsigned char **colorOut,
      int width, int height, int pitch);

bool imageMixer (unsigned char *grayIn, unsigned char *colorInY,
    unsigned char *colorInU, unsigned char *colorInV, unsigned char *colorOut,
      int width, int height, unsigned char threshold,
      unsigned char *color, int pitch);

bool imageMixerFreeMemory (unsigned char *grayIn, unsigned char *colorInY,
    unsigned char *colorInU, unsigned char *colorInV, unsigned char *colorOut);

#endif /* MIXER_H */
