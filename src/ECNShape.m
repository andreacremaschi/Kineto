//
//  ECNShape.m
//  kineto
//
//  Created by Andrea Cremaschi on 08/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import "ECNShape.h"
#import "ECNShapeTrigger.h"

#import "ECNVideoInputAsset.h"
#import "KLayer.h"
#import "KCue.h"

#import "KGPUCalculationObject.h"
#import "KGPUAreaAverage.h"
#import "KGPURowAverage.h"
#import "KGPUColumnAverage.h"
#import <OpenGL/CGLMacro.h>

// +  + Elements specific properties   +
NSString *ShapeMaskToObserveKey = @"mask_to_observe"; 
// +  +  +  +  +  +  +  +  +  +  +  +  +

// +  +  + Shape input ports +  +  +
NSString *ShapeInputVideoFrameImage = @"Video input";
NSString *ShapeInputMaskImage = @"Mask image";
// +  +  +  +  +  +  +  +  +  +  +  +

// +  +  + Shape output ports +  +  +

NSString *ShapeOutputImage = @"Image";
NSString *ShapeOutputMaskImage = @"Mask";
NSString *ShapeOutputShapeImage = @"Shape";

NSString *ShapeOutputExtension = @"Quantity";

NSString *ShapeOutputHighest = @"Highest";
NSString *ShapeOutputLowest = @"Lowest";
NSString *ShapeOutputRightmost = @"Rightmost";
NSString *ShapeOutputLeftmost = @"Leftmost";

NSString *ShapeOutputMiddleHorizontal = @"Middle horizontal";
NSString *ShapeOutputMiddleVertical = @"Middle vertical";

// +  +  +  +  +  +  +  +  +  +  +  +


// +  + Default values  +  +  +  +  +
NSString *ShapeClassValue = @"Undefined element";
NSString *ShapeNameDefaultValue = @"Undefined shape";
// +  +  +  +  +  +  +  +  +  +  +  +

@interface ECNShape	(ForwardDeclarations)
- (CIImage*) calculateShapeImageWithMask: (CIImage *)cimask;
- (CIImage*) calculateOutputMaskedImage;
- (CIImage*) calculateMaskImageWithMask: (CIImage *)cimask;
- (void) calculateAreaAverageWithMask: (CIImage *) cimask;
- (void) calculateAreaRowAverageWithMask: (CIImage *) cimask;
- (void) calculateAreaColumnAverageWithMask: (CIImage *) cimask;

@end

@implementation ECNShape


- (NSMutableDictionary *) attributesDictionary	{


	NSMutableDictionary* dict = [super attributesDictionary];
	
	// set default attributes values
	[dict setValue: ShapeClassValue forKey: ECNObjectClassKey];

	NSDictionary *propertiesDict = [NSDictionary dictionaryWithObjectsAndKeys:
									@"", ShapeMaskToObserveKey,
									nil];


	//[_attributes addEntriesFromDictionary: attributesDict];
	[[dict objectForKey: ECNPropertiesKey] addEntriesFromDictionary: propertiesDict ];

	
	
	
	
	//[[dict objectForKey: ECNOutputPortsKey] addEntriesFromDictionary: outputPortsDict ];
	
	// NO default values: ECNElement and ECNShape are abstract classes without constructors!
	/*	[dict setValue: ElementClassValue forKey: ECNObjectClassKey];
	 [dict setValue: ElementNameDefaultValue forPropertyKey: ECNObjectNameKey];*/
	
	return dict;
	
	
}

- (id) init {
	self = [super init];
	if (nil != self)	{

		_flags.cachedRect = CGRectMake(0,0, 1, 1);
		_gpuObjectsArray = [[NSMutableArray array] retain];
	}
	return self;
	
	
}
- (void) initPorts // WithProjectDocument: (ECNProjectDocument *)document
{
	/*self = [super init]; //initWithProjectDocument: document];
	if (self) {*/
		
		// INPUT PORTS
		[self addInputPortWithType:ECNPortTypeImage 
							forKey:ShapeInputMaskImage 
					withAttributes:nil];
		[self addInputPortWithType:ECNPortTypeImage 
							forKey:ShapeInputVideoFrameImage 
					withAttributes:nil];
		
		
		
		// OUTPUT PORTS		
		[self addOutputPortWithType: ECNPortTypeImage
							 forKey: ShapeOutputImage
					 withAttributes: nil];
		[self addOutputPortWithType: ECNPortTypeImage
							 forKey: ShapeOutputMaskImage
					 withAttributes: nil];
		[self addOutputPortWithType: ECNPortTypeImage
							 forKey: ShapeOutputShapeImage
					 withAttributes: nil];
		
		
		
		
		[self addOutputPortWithType: ECNPortTypeNumber
							forKey: ShapeOutputExtension 
					 withAttributes: nil];

		
		[self addOutputPortWithType: ECNPortTypeNumber
							 forKey: ShapeOutputHighest 
					 withAttributes: nil];
		[self addOutputPortWithType: ECNPortTypeNumber
							 forKey: ShapeOutputLowest 
					 withAttributes: nil];
		[self addOutputPortWithType: ECNPortTypeNumber
							 forKey: ShapeOutputRightmost 
					 withAttributes: nil];
		[self addOutputPortWithType: ECNPortTypeNumber
							 forKey: ShapeOutputLeftmost 
					 withAttributes: nil];
		

		[self addOutputPortWithType: ECNPortTypeNumber
							 forKey: ShapeOutputMiddleHorizontal 
					 withAttributes: nil];
		[self addOutputPortWithType: ECNPortTypeNumber
							 forKey: ShapeOutputMiddleVertical 
					 withAttributes: nil];

		
		//NSLog (@"%@", [self attributes]);
		


		_flags.shouldUpdateShapeMask = true;
//		_flags.mask_extension = 1.0;		
		
	/*}
	return self;	*/
}

- (void)dealloc {
	[_gpuObjectsArray release];
	
    [super dealloc];
}

+ (Class) triggerClass		{
	return [ECNShapeTrigger class];
}

+ (NSString*) defaultTriggerPortKey		{
	return ShapeOutputExtension;
}

#pragma mark Constructors
+ (ECNElement *)elementWithDocument: (ECNProjectDocument *)document	{
	//NB ELEMENT is an abstract class, that should never return an instance
	return nil;
	
}

#pragma mark Accessors
- (KLayer *)observedMask {
	NSString *layerKey = [self valueForPropertyKey: ShapeMaskToObserveKey];
	return [[[self cue] videoAsset] layerWithKey: layerKey];
}

// override of ECNElement
- (void)setCue:(KCue *)scene {
	[super setCue: scene];
	
	//check if selected cue video asset contains element's observed mask
	ECNVideoInputAsset *cueVideoAsset = [[self cue] videoAsset];
	if (nil != cueVideoAsset) {
		NSString *layerKey = [self valueForPropertyKey: ShapeMaskToObserveKey];
		if (((layerKey == @"") || (nil==[cueVideoAsset layerWithKey: layerKey])) && (nil != [cueVideoAsset defaultMaskKey]))
			//set cue's default mask key
			[self setValue: [cueVideoAsset defaultMaskKey] forPropertyKey: ShapeMaskToObserveKey];
	}
	
}

#pragma mark -
#pragma mark ECNElement overrides

- (NSImage *)icon {
	return [NSImage imageNamed: @"Rectangle"];
}

- (void) setBounds:(NSRect)bounds	{
	[super setBounds: bounds];
	_flags.shouldUpdateShapeMask = true;
}

// ovverride of method called by [super executeAtTime:(NSTimeInterval)time] during playback
- (BOOL) executeAtTime:(NSTimeInterval)time {
	
	CIImage *shapeImage;
	
	CIImage * cimask = [self valueForInputKey: ShapeInputMaskImage];
	
	//reset previous values for output ports!
	for (ECNPort *myPort in [self valueForInputKey: ECNOutputPortsKey])
		[myPort invalidate];
	
	if (!_flags.shouldUpdateShapeMask) {
		//CGRect inputMaskRect = [cimask extent];
		CGRect shapeMaskRect = [self calcPixelBoundsInRect: [cimask extent]]; 
		/*NSLog(@"%@, %@, %@", NSStringFromRect( NSRectFromCGRect( inputMaskRect)), 
			  NSStringFromRect( NSRectFromCGRect( shapeMaskRect)) ,
			  NSStringFromRect(NSRectFromCGRect( _flags.cachedRect))
			  );*/
		_flags.shouldUpdateShapeMask = ! NSEqualRects(shapeMaskRect, _flags.cachedRect);
		if (_flags.shouldUpdateShapeMask) 
			NSLog(@"Updated shape rect with size: %@", 
			   NSStringFromRect( NSRectFromCGRect( shapeMaskRect)) 
			   );
		//_flags.shouldUpdateShapeMask = true;
	}
	
	// generate shape mask 
	if (_flags.shouldUpdateShapeMask)	{
		if (cimask == nil) return false;
		shapeImage = [self calculateShapeImageWithMask: cimask ];
		[self setValue:	shapeImage
		  forOutputKey: ShapeOutputShapeImage ];
	}
	else
		shapeImage = [self valueForOutputKey: ShapeOutputShapeImage];
		
	// generate masked image	
	CIImage *maskImage = [self calculateMaskImageWithMask: cimask];
	[self setValue:	maskImage
	  forOutputKey: ShapeOutputMaskImage ];
	
	//fire async calculations!
	for (KGPUCalculationObject *gpuCalc in _gpuObjectsArray)
		[gpuCalc executeWithMask: maskImage
						   async: YES
						   error: nil];
	
	return [super executeAtTime: time];
}

- (void) drawInCGContext: (CGContextRef)context withRect: (CGRect) rect {
	CGMutablePathRef objectPath = [self quartzPathInRect: rect];
	
	NSColor *objectColor = [self strokeColor];
	
	CGContextSetRGBStrokeColor (
								context,
								[objectColor redComponent],
								[objectColor greenComponent],
								[objectColor blueComponent], 1.0
								);
	
	CGContextSetLineWidth (context, rect.size.width / 160.0);
	
	CGContextBeginPath(context);
	CGContextAddPath(context, objectPath);
	CGContextStrokePath( context);	
	
	

	
	
	
}


// returns a default value for the current element
- (id) defaultValue	{
	
	return [[self firstTrigger] lastValue] ;
}

#pragma mark -
#pragma mark OpenGL primitives

#pragma mark Core Image primitives

- (CIImage *)CIcropImage: (CIImage*)ciImage withRect: (NSRect) cropRect	{
	
	CIFilter *cropFilter   = [CIFilter filterWithName: @"CICrop"] ;
	//CIImage *cimask = [self valueForInputKey: ShapeInputMaskImage];
	
	[cropFilter setDefaults];
	[cropFilter setValue: ciImage forKey:@"inputImage"];
	
	
	[cropFilter setValue: [CIVector vectorWithX: cropRect.origin.x
											  Y: cropRect.origin.y
											  Z: cropRect.size.width
											  W: cropRect.size.height ]
				  forKey:@"inputRectangle"];
	
	CIImage * result =[cropFilter valueForKey: @"outputImage"];
	
	return result;
}

- (CIImage *) CIMultiplyWithInputImage: (CIImage *) shapeImage 
				   withBackgroundImage: (CIImage *) cimask {
	
	CIFilter *multiplyFilter   = [CIFilter filterWithName: @"CIMultiplyCompositing"] ;
	[multiplyFilter setDefaults];
	[multiplyFilter setValue: shapeImage forKey:@"inputImage"];
	[multiplyFilter setValue: cimask forKey:@"inputBackgroundImage"];
	
	CIImage * result =[multiplyFilter valueForKey: @"outputImage"];
	
	return result;

}


#pragma mark Core Image Filters and Bitmap calculations management

- (NSBitmapImageRep *) drawCIImageInBitmap: (CIImage *)ciimage	{

	NSSize maskSize = NSMakeSize([ciimage extent].size.width, [ciimage extent].size.height);

	
	// create CoreImage thingies for fast collision calculations
	NSBitmapImageRep* bitmap = [[[NSBitmapImageRep alloc]
								 initWithBitmapDataPlanes: nil
								 pixelsWide: maskSize.width
								 pixelsHigh: maskSize.height 
								 bitsPerSample:8
								 samplesPerPixel:4
								 hasAlpha: YES 
								 isPlanar: NO 
								 colorSpaceName: NSCalibratedRGBColorSpace
								 bytesPerRow: 0
								 bitsPerPixel:32] autorelease] ;

	NSGraphicsContext * context = [NSGraphicsContext
									graphicsContextWithBitmapImageRep: bitmap] ;
	
	[[context CIContext] drawImage: ciimage
						   atPoint: CGPointZero
						  fromRect: [ciimage extent]];
	
	return bitmap;
}

#pragma mark Image ports calculation

- (void) calculateAreaAverageWithMask: (CIImage *) cimask	{
	
	NSError *error;
	if (![_gpuObjectsArray containsObject: calcAreaAverage]) {
		[_gpuObjectsArray addObject: calcAreaAverage];
		[calcAreaAverage executeWithMask: cimask
									error: &error];
	}
	
	[self setValue:	
	  [NSNumber numberWithFloat: [(KGPUAreaAverage *) calcAreaAverage result]  ] // / _flags.mask_extension]
	  forOutputKey: ShapeOutputExtension ];
	
}

		
- (void) calculateAreaColumnAverageWithMask: (CIImage *) cimask	{


	
	NSError *error;
	KGPUColumnAverage * calcObject = (KGPUColumnAverage*) calcColumnAverage;
	if (![_gpuObjectsArray containsObject: calcObject])  {
		[_gpuObjectsArray addObject: calcObject];
		[calcObject executeWithMask: cimask
								error: &error];
	}
	
	[self setValue:	
	 [NSNumber numberWithFloat: [calcObject rightmost]] //(float)rightMost[0] / maskSize.width]
	  forOutputKey: ShapeOutputRightmost ];
	
	[self setValue:	
	 [NSNumber numberWithFloat: [calcObject leftmost]]  //(float)leftMost[0] / maskSize.width]
	  forOutputKey: ShapeOutputLeftmost ];
	
	[self setValue:	
	 [NSNumber numberWithFloat: [calcObject middleHorizontal]]  // (float)middleHorizontal[0] / maskSize.width]
	  forOutputKey: ShapeOutputMiddleHorizontal ];

	return;	
}

		
- (void) calculateAreaRowAverageWithMask: (CIImage *) cimask	{
	
	
	NSError *error;
	KGPURowAverage * calcObject = (KGPURowAverage*) calcRowAverage;
	if (![_gpuObjectsArray containsObject: calcObject])  {
		[_gpuObjectsArray addObject: calcObject];
		[calcObject executeWithMask: cimask
							  error: &error];
	}	
	
	[self setValue:	
	  [NSNumber numberWithFloat: [calcObject highest] ]
	  forOutputKey: ShapeOutputHighest ];
	
	[self setValue:	
	  [NSNumber numberWithFloat: [calcObject lowest] ]
	  forOutputKey: ShapeOutputLowest ];
	
	[self setValue:	
	  [NSNumber numberWithFloat: [calcObject middleVertical] ]
	  forOutputKey: ShapeOutputMiddleVertical ];

	
	return;	
}

- (CIImage*) calculateMaskImageWithMask: (CIImage *)cimask	{
	
	NSRect srcRect = NSRectFromCGRect( [cimask extent] );
	
	NSRect cropRect = [self calcPixelBoundsInRect: srcRect];
	cropRect.origin.y = [cimask extent].size.height - cropRect.origin.y - cropRect.size.height;

	CIImage * shapeImage = [self valueForOutputKey: ShapeOutputShapeImage];
	CIImage * cropSrcImage = [self CIcropImage: cimask withRect: cropRect ];
	CIImage * result = [self CIMultiplyWithInputImage: cropSrcImage
								  withBackgroundImage: shapeImage];
	return result;
}


- (CIImage*) calculateOutputMaskedImage	{
	
	//use a custom CoreImage filter that multiplies source image with pixels from selected channel
	//so that we can use diff_mask or motion_mask as masks for the input videoframe
/*	CIFilter *ciCustomFilter = _MaskSrcUsingChannelFilter;

	

	// 1. first input: Mask Image
	[ciCustomFilter setValue: [self valueForOutputKey: ShapeOutputMaskImage] 
					  forKey: @"mask"];

	
	// 2. second input: Cropped Video frame

	// mask the ci filter with source video image
	CIImage * videoFrame = [self valueForInputKey: ShapeInputVideoFrameImage];
	
	NSRect srcRect = NSRectFromCGRect( [videoFrame extent] );
	NSRect cropRect = [self calcPixelBoundsInRect: srcRect];
	cropRect.origin.y = [videoFrame extent].size.height - cropRect.origin.y - cropRect.size.height;
	
	CIImage * cropSrcImage = [self CIcropImage: videoFrame 
									  withRect: cropRect ];

	[ciCustomFilter setValue: cropSrcImage forKey:@"inputImage"];

	// 3. process Core image filter
	CIImage * result = [ciCustomFilter valueForKey: @"outputImage"];

	return result;*/
	return nil;
}



- (CIImage*) calculateShapeImageWithMask: (CIImage *)cimask{
	
	NSRect rect = NSRectFromCGRect( [cimask extent] );
	
	// Build an offscreen CGContext
	int bytesPerRow = rect.size.width*4;			//bytes per row - one byte each for argb
	bytesPerRow += (16 - bytesPerRow%16)%16;		// ensure it is a multiple of 16
	size_t byteSize = bytesPerRow * rect.size.height;
	void * bitmapData = malloc(byteSize); 
	bzero(bitmapData, byteSize); //only necessary if don't draw the entire image
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB); 
	CGContextRef cg = CGBitmapContextCreate(bitmapData,
											rect.size.width,
											rect.size.height,
											8, // bits per component
											bytesPerRow,
											colorSpace,
											kCGImageAlphaPremultipliedFirst); //later want kCIFormatARGB8 in CIImage
	
	// Ensure the y-axis is flipped
	CGContextTranslateCTM(cg, 0, rect.size.height);	
	CGContextScaleCTM(cg, 1.0, -1.0 );
	CGContextSetPatternPhase(cg, CGSizeMake(0,rect.size.height)); 
	
	// Draw into the offscreen CGContext
	[NSGraphicsContext saveGraphicsState];
	NSGraphicsContext * nscg = [NSGraphicsContext graphicsContextWithGraphicsPort:cg flipped:NO];
	[NSGraphicsContext setCurrentContext:nscg];
	
	// set background color to TRANSPARENCY (this is important for area average calculation!)
	[[NSColor clearColor] set];
	NSRectFillUsingOperation(  rect, NSCompositeCopy);    
							 
	
	// Here is where you want to do all of your drawing...
	[[NSColor whiteColor] set];
	NSBezierPath *bezierPath = [self bezierPathInRect: rect]; 
	[bezierPath fill];
	[bezierPath setLineWidth: 3];
	[bezierPath stroke];
	
	[NSGraphicsContext restoreGraphicsState];
	CGContextRelease(cg);
	
	// Extract the CIImage from the raw bitmap data that was used in the offscreen CGContext
	CIImage * coreimage = [[[CIImage alloc] 
						   initWithBitmapData:[NSData dataWithBytesNoCopy:bitmapData length:byteSize] 
						   bytesPerRow:bytesPerRow 
						   size:CGSizeMake(rect.size.width, rect.size.height) 
						   format:kCIFormatARGB8
						   colorSpace:colorSpace] autorelease];
		
	
	// crop to mask dimensions
	NSRect ciSize = NSRectFromCGRect( [coreimage extent] );
	NSRect cropRect = [self calcPixelBoundsInRect: ciSize];
	cropRect.origin.y = ciSize.size.height - cropRect.origin.y - cropRect.size.height;
	CIImage *result = [self CIcropImage: coreimage withRect: cropRect];

	_flags.cachedRect =  [self calcPixelBoundsInRect: rect]; 
	
	//calculate the shape image extension in percentual
/*	NSUInteger curPixel[4];
	[_areaAverageFilter setDefaults];
	CIImage *shapeExtensionImage = [self calculateAreaAverageWithFilter: _areaAverageFilter 
												  withMask: result];
	
	[[_onePixelContext CIContext] drawImage: shapeExtensionImage
									atPoint: CGPointZero
								   fromRect: CGRectMake (0,0,1,1)];
	
	[_onePixelBitmap getPixel: curPixel atX:0 y:0];*/

//	_flags.mask_extension = (float)curPixel[0]/255.0;
	
	_flags.shouldUpdateShapeMask = false;	
	//NSLog(@"Shape for element: %@ has just been refreshed.",[self valueForPropertyKey: ECNObjectNameKey]);
  
		/*  ,[self valueForPropertyKey: ECNObjectNameKey],
		  _flags.mask_extension);*/
	NSError	*error;
	/*if (![self initCalculationsOpenGLContextWithError: &error])	{
		NSLog (@"%@", error);
	} else if (![self initCalculationsFBOsWithError: &error])	{
		NSLog (@"%@", error);
	}*/
	
	if (calcAreaAverage)
		[calcAreaAverage release];
	if (calcRowAverage)
		[calcRowAverage release];
	if (calcColumnAverage)
		[calcColumnAverage release];
	
	if ([_gpuObjectsArray count] > 0) 
		[_gpuObjectsArray removeAllObjects];
	
	calcAreaAverage = [[KGPUAreaAverage calculationObjectInSharedContext: [[[self cue] videoAsset] openGLRenderContext]] retain];
	calcRowAverage = [[KGPURowAverage calculationObjectInSharedContext: [[[self cue] videoAsset] openGLRenderContext]
															withHeight: _flags.cachedRect.size.height] retain];
	calcColumnAverage = [[KGPUColumnAverage calculationObjectInSharedContext: [[[self cue] videoAsset] openGLRenderContext]
						  withWidth: _flags.cachedRect.size.width] retain];
	
	// Housekeeping
	CGColorSpaceRelease(colorSpace); 


	
	return result;
}


#pragma mark ECNElement (PlaybachHandling) Overrides
// -[ECNElement valueForOutputPort] override
// used for cache reasons
- (id) valueForOutputPort:(NSString *)portKey	{
	
	CIImage *maskImage = [self valueForOutputKey: ShapeOutputMaskImage];
	if (nil == maskImage) return nil;
	if ([portKey isEqualToString: ShapeOutputMaskImage])	{
	
		[self setValue:	[self calculateOutputMaskedImage]
				forOutputKey: ShapeOutputImage ];
	} else	
	if ([portKey isEqualToString: ShapeOutputExtension])	{
			[self calculateAreaAverageWithMask: maskImage];
	} else
	if (([portKey isEqualToString: ShapeOutputHighest]) || 
		([portKey isEqualToString: ShapeOutputLowest]) ||
		([portKey isEqualToString: ShapeOutputMiddleVertical]))	{
		[self calculateAreaRowAverageWithMask: maskImage];			
	} 	else
	if (([portKey isEqualToString: ShapeOutputRightmost]) || 
		([portKey isEqualToString: ShapeOutputLeftmost]) ||
		([portKey isEqualToString: ShapeOutputMiddleHorizontal]))	{
		[self calculateAreaColumnAverageWithMask: maskImage];
			
	} 	
	
	return [super valueForOutputPort: portKey];
	// calculate image analysis
	
		
}

@end
