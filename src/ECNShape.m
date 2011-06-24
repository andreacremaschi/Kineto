//
//  ECNShape.m
//  kineto
//
//  Created by Andrea Cremaschi on 08/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import "ECNShape.h"
#import "ECNShapeTrigger.h"
#import "MaskSrcUsingChannelFilter.h"

#import "ECNVideoInputAsset.h"
#import "KLayer.h"
#import "KCue.h"

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
		
		// create CoreImage thingies for fast collision calculations
		_onePixelBitmap = [[[NSBitmapImageRep alloc]
							initWithBitmapDataPlanes: nil
							pixelsWide: 1
							pixelsHigh: 1 
							bitsPerSample:8
							samplesPerPixel:4
							hasAlpha:YES
							isPlanar:NO 
							colorSpaceName:NSCalibratedRGBColorSpace
							bytesPerRow: 0
							bitsPerPixel:32] retain];
	
		_onePixelContext = [[NSGraphicsContext
							 graphicsContextWithBitmapImageRep:_onePixelBitmap] retain];
		
		
		// setup the "CIAreaAverage" filter
		_areaAverageFilter   = [[CIFilter filterWithName: @"CIAreaAverage"] retain];
		_MaskSrcUsingChannelFilter = [[[MaskSrcUsingChannelFilter alloc] init] retain];

		_flags.shouldUpdateShapeMask = true;
//		_flags.mask_extension = 1.0;		
		
	/*}
	return self;	*/
}

- (void)dealloc {

	[_onePixelBitmap release];
	[_onePixelContext release];
	[_areaAverageFilter release];
	
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
/*

- (void) drawInOpenGLContext: (NSOpenGLContext *)openGLContext
{
	NSRect drawingBounds = [self bounds];
	GLint saveMode;
	NSPoint startPoint, endPoint;
	
	//convert to opengl coordinates
	drawingBounds.origin.x=drawingBounds.origin.x*2.0-1.0;
	drawingBounds.origin.y=1.0-drawingBounds.origin.y*2.0;
	drawingBounds.size.width*=2.0;
	drawingBounds.size.height*=2.0;
		
	CGLContextObj cgl_ctx = [openGLContext CGLContextObj];
	glGetIntegerv(GL_MATRIX_MODE, &saveMode);
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
	
	glBegin(GL_LINES);
	
	GLfloat sizes[2];  // Store supported line width range
	GLfloat step;     // Store supported line width increments
	
	glGetFloatv(GL_LINE_WIDTH_RANGE, sizes);
	glGetFloatv(GL_LINE_WIDTH_GRANULARITY, &step);
	
	for (ECNShapeTrigger * trigger in [self triggers])	{

		bool isTriggered = false;		
		if ([trigger isActive]) isTriggered = true;

		// to represent object value we will use only the trigger value,
		// that will halt changing in latency periods
		id triggerValue = [trigger lastValue];
		if (![triggerValue isKindOfClass: [NSNumber class]]) break;
		float fTriggerValue = [triggerValue floatValue];
		
		ECNPort *observedPort = [trigger valueForPropertyKey: ECNTriggerPortToObserveKey];
		if ((observedPort != nil) && ([observedPort isKindOfClass:[ECNPort class]]))	{

			NSString *portName = [observedPort name];
			if (portName == ShapeOutputExtension)	{
				break;
			} else if ((portName == ShapeOutputHighest) || (portName == ShapeOutputLowest) || (portName == ShapeOutputMiddleVertical))	{
				
				float yPosition = drawingBounds.origin.y - drawingBounds.size.height  * (1.0 - fTriggerValue);
				startPoint = NSMakePoint(drawingBounds.origin.x, yPosition);
				endPoint = NSMakePoint(drawingBounds.origin.x + drawingBounds.size.width, yPosition);
				
			} else if ((portName == ShapeOutputRightmost)	|| (portName == ShapeOutputLeftmost) || (portName == ShapeOutputMiddleHorizontal)){
				
				float xPosition = drawingBounds.origin.x + fTriggerValue * drawingBounds.size.width;
				startPoint = NSMakePoint(xPosition, drawingBounds.origin.y);
				endPoint = NSMakePoint(xPosition, drawingBounds.origin.y - drawingBounds.size.height);
				
			}
			
			//imposta la dimensione della linea a seconda se l'elemento è stato azionato oppure no
			if (isTriggered) {
				glLineWidth((GLfloat)sizes[0] + step*3);
				glColor3f(1.0f, 0.0f, 0.0f);
			}
			else {
				glLineWidth(sizes[0]);
				glColor3f(1.0f, 1.0f, 1.0f);
			}
			
			glVertex2f(startPoint.x, startPoint.y);
			glVertex2f(endPoint.x, endPoint.y);
			
			//	glVertex2f(startPoint.x, startPoint.y);
			
			

		}
	}
	
	glEnd();
	
	//After drawing, restore original OpenGL states.
    glPopMatrix();
    glMatrixMode(saveMode);
	
    // Check for errors.
    glGetError();
}*/

// returns a default value for the current element
- (id) defaultValue	{
	
	return [[self firstTrigger] lastValue] ;
}

#pragma mark -
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

/*- (int) maskToObserve	{
	NSNumber *nMaskToObserve = [self valueForPropertyKey: ShapeMaskToObserveKey];
	if (!nMaskToObserve) return 0;	//default to diff_mask
	return [nMaskToObserve intValue];
}*/

- (CIImage *) calculateAreaAverageWithFilter: (CIFilter *)averageFilter 
									withMask: (CIImage *)cimask	{

	[averageFilter setDefaults];
	[averageFilter setValue: cimask forKey:@"inputImage"];
	
	/*
	NSRect bounds = [self calcPixelBoundsInRect: NSRectFromCGRect([cimask extent]) ];
	bounds.origin.y = [cimask extent].size.height - bounds.origin.y - bounds.size.height;
	*/
	NSRect bounds = NSRectFromCGRect([cimask extent]) ;
	[averageFilter setValue: [CIVector vectorWithX: bounds.origin.x
												 Y: bounds.origin.y
												 Z: bounds.size.width
												 W: bounds.size.height  ]
					 forKey:@"inputExtent"];

	return [averageFilter valueForKey: @"outputImage"];
	
}



- (void) calculateAreaAverageWithMask: (CIImage *) cimask	{
	NSUInteger curPixel[4];
	
	[_areaAverageFilter setDefaults];
	
	CIImage *result = [self calculateAreaAverageWithFilter: _areaAverageFilter 
												  withMask: cimask];
	
	[[_onePixelContext CIContext] drawImage: result
									atPoint: CGPointZero
								   fromRect: CGRectMake (0,0,1,1) ];
	
	[_onePixelBitmap getPixel:curPixel atX:0 y:0];
	

	[self setValue:	
	  [NSNumber numberWithFloat: (curPixel[0] / 255.0) ] // / _flags.mask_extension]
	  forOutputKey: ShapeOutputExtension ];
	//NSLog( @"%i, %i, %i, %i", curPixel[0],curPixel[1], curPixel[2], curPixel[3]);
	
}

		
- (void) calculateAreaColumnAverageWithMask: (CIImage *) cimask	{

	NSSize maskSize = NSMakeSize([cimask extent].size.width, [cimask extent].size.height);
	//int bytesSize = 4 *  maskSize.width;
	NSUInteger curPixel[4];
	
	
	CIFilter *columnAverageFilter   = [CIFilter filterWithName: @"CIColumnAverage"] ;
	CIImage *result = [self calculateAreaAverageWithFilter: columnAverageFilter withMask: cimask];
	
	NSBitmapImageRep * resultBitmap = [[self drawCIImageInBitmap: result] retain];
	
	int i, c;
	int nMasks =2;
	int leftMost[nMasks];
	int rightMost[nMasks];
	int middleHorizontal[nMasks];
	//int maskToObserve =[self maskToObserve];
	
	for (c=0;c<nMasks;c++)	{
		 leftMost[c] = 0;
		 rightMost[c] = 0;
		 middleHorizontal[c] = 0;
		
	}

		for (i=0;i<maskSize.width;i++)	{
		[resultBitmap getPixel:curPixel atX:i y:0];
		for (c=0;c<nMasks;c++)	{
			if (curPixel[c] > 0)	{
				leftMost[c] = (leftMost[c] == 0) ? i : leftMost[c];
				rightMost[c] = i; 
			}
		}
	}
	//NSLog(@"%.2f",leftMost[0]); 
	for (c=0;c<nMasks;c++)
		middleHorizontal[c] = rightMost[c] > 0 ? (rightMost[c] + leftMost[c]) / 2 : 0;
	
	//NSLog(@"Leftmost: %.2f, Rightmost: %.2f, Middle horz: %.2f", (float)leftMost / maskSize.width, (float)rightMost / maskSize.width, (float)middleHorizontal / maskSize.width);
	[resultBitmap release];

	[self setValue:	
	 [NSNumber numberWithFloat: (float)rightMost[0] / maskSize.width]
	  forOutputKey: ShapeOutputRightmost ];
	
	[self setValue:	
	 [NSNumber numberWithFloat: (float)leftMost[0] / maskSize.width]
	  forOutputKey: ShapeOutputLeftmost ];
	
	[self setValue:	
	 [NSNumber numberWithFloat: (float)middleHorizontal[0] / maskSize.width]
	  forOutputKey: ShapeOutputMiddleHorizontal ];
	
	/*
	[self setValue:	
	  [NSDictionary dictionaryWithObjectsAndKeys:
	   [NSNumber numberWithFloat: (float)rightMost[0] / maskSize.width],	@"diff_mask",
	   [NSNumber numberWithFloat: (float)rightMost[1] / maskSize.width],	@"motion_mask",
	   nil]
	  forOutputKey: ShapeOutputRightmost ];
	
	[self setValue:	
	  [NSDictionary dictionaryWithObjectsAndKeys:
	   [NSNumber numberWithFloat: (float)leftMost[0] / maskSize.width],	@"diff_mask",
	   [NSNumber numberWithFloat: (float)leftMost[1] / maskSize.width],	@"motion_mask",
	   nil]
	  forOutputKey: ShapeOutputLeftmost ];

	[self setValue:	
	  [NSDictionary dictionaryWithObjectsAndKeys:
	   [NSNumber numberWithFloat: (float)middleHorizontal[0] / maskSize.width],	@"diff_mask",
	   [NSNumber numberWithFloat: (float)middleHorizontal[1] / maskSize.width],	@"motion_mask",
	   nil]
	  forOutputKey: ShapeOutputMiddleHorizontal ];
*/							
	return;	
}

		
- (void) calculateAreaRowAverageWithMask: (CIImage *) cimask	{
	
	NSSize maskSize = NSMakeSize([cimask extent].size.width, [cimask extent].size.height);
	//int bytesSize = 4 *  maskSize.width;
	NSUInteger curPixel[4];
	

	CIFilter *rowAverageFilter   = [CIFilter filterWithName: @"CIRowAverage"] ;
	CIImage *result = [self calculateAreaAverageWithFilter: rowAverageFilter withMask: cimask];
	NSBitmapImageRep * resultBitmap = [[self drawCIImageInBitmap: result] retain];
	
	int i, c;
	int nMasks =2;
	int highest[nMasks];
	int lowest[nMasks];
	int middleVertical[nMasks];
	//int maskToObserve =[self maskToObserve];
	
	for (c=0;c<nMasks;c++)	{
		highest[c] = 0;
		lowest[c] = 0;
		middleVertical[c] = 0;
		
	}
	//NSLog(@"%.2f, %.2f", maskSize.width, maskSize.height);
	//NSLog(@"%i", maskSize.width );
	c=0;
	for (i=0;i<maskSize.height;i++)	{
		[resultBitmap getPixel:curPixel atX:i y:0];
		
		//for (c=0;c<nMasks;c++)	{
			if (curPixel[c] > 0)	{
				lowest[c] = (lowest[c] == 0) ? i : lowest[c];
				highest[c] = i; 
			}
		//}
	}

	//for (c=0;c<nMasks;c++)
		middleVertical[c] = highest[c] > 0 ? (highest[c] + lowest[c]) / 2 : 0;
	
	//NSLog(@"Leftmost: %.2f, Rightmost: %.2f, Middle horz: %.2f", (float)leftMost / maskSize.width, (float)rightMost / maskSize.width, (float)middleHorizontal / maskSize.width);
	[resultBitmap release];
	

	[self setValue:	
	  [NSNumber numberWithFloat: (float)highest[0] / maskSize.height]
	  forOutputKey: ShapeOutputHighest ];
	
	[self setValue:	
	  [NSNumber numberWithFloat: (float)lowest[0] / maskSize.height]
	  forOutputKey: ShapeOutputLowest ];
	
	[self setValue:	
	  [NSNumber numberWithFloat: (float)middleVertical[0] / maskSize.height]
	  forOutputKey: ShapeOutputMiddleVertical ];

	
/*	[self setValue:	
	 [NSDictionary dictionaryWithObjectsAndKeys:
	  [NSNumber numberWithFloat: (float)highest[0] / maskSize.height],	@"diff_mask",
	  [NSNumber numberWithFloat: (float)highest[1] / maskSize.height],	@"motion_mask",
	  nil]
	  forOutputKey: ShapeOutputHighest ];
	
	[self setValue:	
	 [NSDictionary dictionaryWithObjectsAndKeys:
	  [NSNumber numberWithFloat: (float)lowest[0] / maskSize.height],	@"diff_mask",
	  [NSNumber numberWithFloat: (float)lowest[1] / maskSize.height],	@"motion_mask",
	  nil]
	  forOutputKey: ShapeOutputLowest ];
	
	[self setValue:	
	 [NSDictionary dictionaryWithObjectsAndKeys:
	  [NSNumber numberWithFloat: (float)middleVertical[0] / maskSize.height],	@"diff_mask",
	  [NSNumber numberWithFloat: (float)middleVertical[1] / maskSize.height],	@"motion_mask",
	  nil]
	  forOutputKey: ShapeOutputMiddleVertical ];*/
	
	return;	
}
/*- (NSNumber *) calculateAreaRowAverageWithMask: (CIImage *) cimask	{
	
	NSSize maskSize = NSMakeSize([cimask extent].size.width, [cimask extent].size.height);
	//int bytesSize = 4 *  maskSize.width;
	NSUInteger curPixel[4];
	
	
	CIFilter *columnAverageFilter   = [CIFilter filterWithName: @"CIRowAverage"] ;
	CIImage *result = [self calculateAreaAverageWithFilter: columnAverageFilter withMask: cimask];
	NSBitmapImageRep * resultBitmap = [[self drawCIImageInBitmap: result] retain];
	
	int i;
	int highest = 0;
	int lowest = 0;
	int middleVertical = 0;
	
	for (i=0;i<maskSize.height;i++)	{
		[resultBitmap getPixel:curPixel atX:0 y:i];
		if (curPixel[0] > 0)	{
			highest = (highest == 0) ? i : highest;
			lowest = i; 
		}
	}
	middleVertical = highest > 0 ? highest + lowest / 2 : 0;
	//NSLog(@"highest: %.2f, lowest: %.2f, Middle vert: %.2f", (float)highest / maskSize.height, (float)lowest / maskSize.height, (float)middleVertical / maskSize.height);
	[self setValue:	[NSNumber numberWithFloat: (float)highest / maskSize.height]
	  forOutputKey: ShapeOutputHighest ];
	[self setValue:	[NSNumber numberWithFloat: (float)lowest / maskSize.height]
	  forOutputKey: ShapeOutputLowest ];
	[self setValue:	[NSNumber numberWithFloat: (float)middleVertical / maskSize.height]
	  forOutputKey: ShapeOutputMiddleVertical ];
	
	[resultBitmap release];
	
	return [NSNumber numberWithFloat: 0];
	
}*/

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

/*
- (CIImage*) calculateOutputMaskedImage	{
	
	// create a video mask using mask channel for r/g/b channels
	// the m
	
	CIFilter *colorMatrixFilter   = [CIFilter filterWithName: @"CIColorMatrix"] ;
	CIImage *cimask = [self valueForOutputKey: ShapeOutputMaskImage];
	
	[colorMatrixFilter setDefaults];
	[colorMatrixFilter setValue: cimask forKey:@"inputImage"];

	
	[colorMatrixFilter setValue: [CIVector vectorWithX: 1
										  Y: 0
										  Z: 0
										  W:0	]
				  forKey:@"inputRVector"];
	[colorMatrixFilter setValue: [CIVector vectorWithX: 1
										  Y: 0
										  Z: 0
										  W:0	]
				  forKey:@"inputGVector"];
	[colorMatrixFilter setValue: [CIVector vectorWithX: 1
										  Y: 0
										  Z: 0
										  W:0	]
				  forKey:@"inputBVector"];
	[colorMatrixFilter setValue: [CIVector vectorWithX: 0
										  Y: 0
										  Z: 0
										  W:0	]
				  forKey:@"inputAVector"];
	[colorMatrixFilter setValue: [CIVector vectorWithX: 0
										  Y: 0
										  Z: 0
										  W:1	]
				  forKey:@"inputBiasVector"];

	
	
	CIImage * shapeImage =[colorMatrixFilter valueForKey: @"outputImage"];

	
	// mask the ci filter with source video image
	CIImage * videoFrame = [self valueForInputKey: ShapeInputVideoFrameImage];

	NSRect srcRect = NSRectFromCGRect( [videoFrame extent] );
	
	NSRect cropRect = [self calcPixelBoundsInRect: srcRect];
	cropRect.origin.y = [videoFrame extent].size.height - cropRect.origin.y - cropRect.size.height;

	CIImage * cropSrcImage = [self CIcropImage: videoFrame 
									  withRect: cropRect ];
	
	// multiply the two masks
	CIImage * result = [self CIMultiplyWithInputImage: shapeImage 
								  withBackgroundImage: cropSrcImage];
		
	return result;
}
*/
- (CIImage*) calculateOutputMaskedImage	{
	
	//use a custom CoreImage filter that multiplies source image with pixels from selected channel
	//so that we can use diff_mask or motion_mask as masks for the input videoframe
	CIFilter *ciCustomFilter = _MaskSrcUsingChannelFilter;

	

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

	return result;
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

	
	
	//calculate the shape image extension in percentual
	NSUInteger curPixel[4];
	[_areaAverageFilter setDefaults];
	CIImage *shapeExtensionImage = [self calculateAreaAverageWithFilter: _areaAverageFilter 
												  withMask: result];
	
	[[_onePixelContext CIContext] drawImage: shapeExtensionImage
									atPoint: CGPointZero
								   fromRect: CGRectMake (0,0,1,1)];
	
	[_onePixelBitmap getPixel: curPixel atX:0 y:0];

//	_flags.mask_extension = (float)curPixel[0]/255.0;
	_flags.shouldUpdateShapeMask = false;	
	//NSLog(@"Shape for element: %@ has just been refreshed.",[self valueForPropertyKey: ECNObjectNameKey]);
  
		/*  ,[self valueForPropertyKey: ECNObjectNameKey],
		  _flags.mask_extension);*/
	
	
	// Housekeeping
	CGColorSpaceRelease(colorSpace); 

	
	return result;
}




/*
- (id)valueForOutputKey:(NSString *)key	{

	// get the output port
	
	if ([key isEqual: ShapeOutputShapeImage]) {
		CIImage *shapeImage;
	
		// generate shape mask 
		if (_flags.shouldUpdate)	{
			CIImage * cimask = [self valueForInputKey: ShapeInputMaskImage];
			if (cimask == nil) return nil;
			shapeImage = [self calculateShapeImageWithMask: cimask ];
			[self setValue:	shapeImage
			  forOutputKey: ShapeOutputShapeImage ];
		}
		else
			shapeImage = [self valueForOutputKey: ShapeOutputShapeImage];
		
		return shapeImage;
	}
	
	
	// check if port value is still valid
	// (this means that no input key for this element has been changed)
	if ([self isOutputPortValueStillValidForKey: key]) 
		return [self valueForOutputKey: key];
	
	
	// -- port is not valid anymore: update it and return!
	
	CIImage *maskImage;
	CIImage * cimask = [self valueForInputKey: ShapeInputMaskImage];
	if (cimask == nil) return nil;
	
	if ([key isEqual: ShapeOutputMaskImage]) {

		// generate masked image	
		maskImage = [self calculateMaskImageWithMask: cimask];
		[self setValue:	maskImage
		  forOutputKey: ShapeOutputMaskImage ];
		return maskImage;
		
	}
	maskImage = [self valueForOutputKey: ShapeOutputMaskImage];
	
	// update output port value
	if ([key isEqual: ShapeOutputImage] ) {
		CIImage *maskedImage = [self calculateOutputMaskedImage];
		// generate masked image	
		[self setValue:	maskedImage
		  forOutputKey: ShapeOutputImage ];
	}
	if ([key isEqual: ShapeOutputExtension] ) {
		[self calculateAreaAverageWithMask: maskImage];
		
	} else if (([key isEqual: ShapeOutputHighest] ) || 
			   ([key isEqual: ShapeOutputLowest] ) ||  
			   ([key isEqual: ShapeOutputMiddleVertical] )) {

		[self calculateAreaRowAverageWithMask: maskImage];
		
	} else if (([key isEqual: ShapeOutputRightmost] ) || 
			   ([key isEqual: ShapeOutputLeftmost] ) ||  
			   ([key isEqual: ShapeOutputMiddleHorizontal] )) {

		[self calculateAreaColumnAverageWithMask: maskImage];
	
	}		
	return [super valueForOutputKey: key];
}
*/


#pragma mark ECNElement (PlaybachHandling) Overrides
// ECNElement::valueForOutputPort override
// used for cache reasons
- (id) valueForOutputPort:(NSString *)portKey	{
	
	CIImage *maskImage = [self valueForOutputKey: ShapeOutputMaskImage];
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
