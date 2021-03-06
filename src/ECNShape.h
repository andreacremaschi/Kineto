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
@class ECNShapeTrigger, KLayer, KGPUCalculationObject;
@interface ECNShape : ECNElement {

	struct __shapeFlags {
		bool shouldUpdateShapeMask;
		NSRect cachedRect;
//		float mask_extension;
    } _flags;
	
	
	KGPUCalculationObject *calcAreaAverage;
	KGPUCalculationObject *calcRowAverage;
	KGPUCalculationObject *calcColumnAverage;
	
	NSMutableArray *_gpuObjectsArray;

}

- (KLayer *)observedMask;

@end
