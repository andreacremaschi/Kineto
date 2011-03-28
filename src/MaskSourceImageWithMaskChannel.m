//
//  MaskSrcUsingChannelFilter.m
//  MaskSrcUsingChannel
//
//  Created by Andrea Cremaschi on 18/02/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "MaskSrcUsingChannelFilter.h"
#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

@implementation MaskSrcUsingChannelFilter

static CIKernel *_MaskSrcUsingChannelFilterKernel = nil;

- (id)init
{
    if(_MaskSrcUsingChannelFilterKernel == nil)
    {
		NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"MaskSrcUsingChannelFilter")];
		NSStringEncoding encoding = NSUTF8StringEncoding;
		NSError     *error = nil;
		NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"mask_srcimg_withmask_REDchannel" ofType:@"cikernel"] encoding:encoding error:&error];
		NSArray     *kernels = [CIKernel kernelsWithString:code];
		
		_MaskSrcUsingChannelFilterKernel = [[kernels objectAtIndex:0] retain];
    }
    return [super init];
}


// called when setting up for fragment program and also calls fragment program
- (CIImage *)outputImage
{
    CISampler *src;
    CISampler *maskImage;
    
    src = [CISampler samplerWithImage:inputImage];
    maskImage = [CISampler samplerWithImage:mask];
	
    return [self apply: _MaskSrcUsingChannelFilterKernel, src, nil];
}

@end
