//
//  MaskSrcUsingChannelFilter.h
//  MaskSrcUsingChannel
//
//  Created by Andrea Cremaschi on 18/02/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@interface MaskSrcUsingChannelFilter : CIFilter
{
    CIImage      *inputImage;
    CIImage      *mask;
}

@end
