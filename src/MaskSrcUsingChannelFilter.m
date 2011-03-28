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
		
		NSBundle    *bundle  = [NSBundle mainBundle];
//		NSStringEncoding encoding = NSUTF8StringEncoding;
		NSError     *error = nil;		
		/*NSString    *code = [NSString stringWithContentsOfFile:[bundle
																pathForResource:@"maskSrcUsingRedChannel" 
																ofType:@"cikernel"] 
													  encoding:encoding 
														 error:&error];*/
		
		NSString *code = @"kernel vec4 maskImageWithRedChannel(sampler image1, sampler mask) {float d;d =  sample(mask, samplerCoord(mask)).r;return sample(image1, samplerCoord(image1)) * d;}";		
		NSLog(@"using bundle: %@", bundle);

		NSLog(@"kernel path: %@",[bundle
								  pathForResource:@"maskSrcUsingRedChannel" 
								  ofType:@"cikernel"]);
		NSLog(@"Core image Kernel loaded: '%@' with error: '%@'", code, error);
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

	NSArray * outputExtent = [NSArray arrayWithObjects:
							  [NSNumber numberWithInt:[inputImage extent].origin.x],
							  [NSNumber numberWithInt:[inputImage extent].origin.y],
							  [NSNumber numberWithFloat:[inputImage extent].size.width],
							  [NSNumber numberWithFloat:[inputImage extent].size.height],nil];
	
	
    return [self apply: _MaskSrcUsingChannelFilterKernel, 
			src, 
			maskImage, 
			kCIApplyOptionExtent, outputExtent, 
			kCIApplyOptionDefinition, [src definition],
			nil];
}

@end
