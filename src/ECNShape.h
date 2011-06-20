//
//  ECNShape.h
//  kineto
//
//  Created by Andrea Cremaschi on 08/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import "ECNElement.h"

// +  + Object specific properties  +
extern NSString *ShapeMaskToObserveKey;

// +  +  +  +  +  +  +  +  +  +  +  +


// +  +  + Shape input ports +  +  +
extern NSString *ShapeInputMaskImage;
extern NSString *ShapeInputVideoFrameImage;
// +  +  +  +  +  +  +  +  +  +  +  +



// +  +  + Shape output ports +  +  +

extern NSString *ShapeOutputExtension ;

extern NSString *ShapeOutputHighest ;
extern NSString *ShapeOutputLowest ;
extern NSString *ShapeOutputRightmost ;
extern NSString *ShapeOutputLeftmost ;

extern NSString *ShapeOutputMiddleHorizontal ;
extern NSString *ShapeOutputMiddleVertical;

// +  +  +  +  +  +  +  +  +  +  +  +
@class ECNShapeTrigger;
@interface ECNShape : ECNElement {

	struct __shapeFlags {
		bool shouldUpdateShapeMask;
//		float mask_extension;
    } _flags;
	
	
	// CoreImage thingies for fast collision calculations
	NSBitmapImageRep *_onePixelBitmap;
	NSGraphicsContext *_onePixelContext;
	CIFilter *_areaAverageFilter;
	CIFilter *_MaskSrcUsingChannelFilter;
}

@end
