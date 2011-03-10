/*
 *  MaskSourceImageWithMaskChannel.h
 *  kineto
 *
 *  Created by Andrea Cremaschi on 18/02/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

@interface MaskSourceImageWithMaskChannelFilter: CIFilter
{
    CIImage   *inputImage;
    CIImage   *inputMask;
}

@end