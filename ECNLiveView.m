//
//  ECNLiveView.m
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 21/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CameraControllerInQCMaskRendererView.h"
#import "ECNLiveView.h"
#import "ECNPlaybackWindowController.h"
#import "CameraController.h"

struct MaskLayerAttributes
{
	bool visible;
	NSString* name;
	NSColor * color;
	bool shouldUpdate;
};


typedef struct MaskLayerAttributes   MaskLayerAttributes;


NSString *BackgroundDidChangeNotification = @"ECNBackgroundDidChange";
NSString *MasksHasBeenUpdatedNotification = @"MasksHasBeenUpdated";

@interface NSImage(ECNConvenience)
- (NSImage*)flipImage;
@end

@implementation NSImage(ECNConvenience)

- (NSImage*)flipImage
{
    // calculate the bounds for the rotated image
    NSRect imageBounds = {NSZeroPoint, [self size]};
	
    NSImage* rotatedImage = [[NSImage alloc]
							 initWithSize:[self size]];
	
	
    // set up the rotation transform
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform translateXBy: 0 yBy:  [self size].height];
	[transform scaleXBy:1.0 yBy:-1.0];
	[transform set];
	
    // draw the original image, rotated, into the new image
    [rotatedImage lockFocus];
    [transform set];
    [self drawInRect:imageBounds fromRect:NSZeroRect
		   operation:NSCompositeCopy fraction:1.0] ;
    [rotatedImage unlockFocus];
	
    return rotatedImage;
}

@end

#pragma mark -


@implementation ECNLiveView
- (id)initWithCoder:(NSCoder *)decoder		{
	
	self = [super initWithCoder: decoder];
	
	if (self)	{		
		_videoframe = nil;
		_cimask=nil;
		_ciContext = nil;
		_dropFrameFactor = 0.3f;
		_dropFrameCounter=0;
		_minFPSDropThreshold = 5;
		[self setupKinetoLayers];
	}
	return self;
}

- (void) dealloc {
	
	if (_imgBackground != nil) [_imgBackground release];
	[_ciContext release];
	[super dealloc];
}


#pragma mark *** Accessors

- (CIContext *)CIContext	{	
	return _ciContext;
}


- (void) setFlipImage: (bool)flipImage	{

   [[super renderer] setValue: [NSNumber numberWithBool: flipImage] forInputKey: @"horizontal_flop"];
   }

- (void)setColor: (NSColor*)color forLayer: (int)nLayer	{
	if (_kinetoLayersAttributes[nLayer]->color != nil) [_kinetoLayersAttributes[nLayer]->color release]; 
	
	_kinetoLayersAttributes[nLayer]->color = [color copyWithZone: nil] ;
//	_kinetoLayersAttributes[nLayer]->color = [[NSColor initWithColor: _kinetoLayersAttributes[nLayer]->color] retain];
	_kinetoLayersAttributes[nLayer]->shouldUpdate = true;

}

- (NSColor*) layerColor: (int) nLayer	{
	return [[_kinetoLayersAttributes[nLayer]->color copyWithZone: nil] autorelease];	
}

- (void)setVisible: (bool)visible forLayer: (int)nLayer		{
	 _kinetoLayersAttributes[nLayer]->visible = visible;
	_kinetoLayersAttributes[nLayer]->shouldUpdate = true;

}

- (bool)layerVisible: (int)nLayer	{
	return _kinetoLayersAttributes[nLayer]->visible;
}

- (NSString *)layerName: (int)nLayer	{
	return _kinetoLayersAttributes[nLayer]->name;
}


- (void) captureNextBackground {
	bCatturaProssimoSfondo = true;
}

- (NSImage *)backgroundImage  {
	return _imgBackground;
}

/*- (CIImage*)diffMask	{
	if (!_CIdiffMask) return nil;
	return _CIdiffMask ;
}

- (CIImage*)motionMask	{
	if (!_CIdiffMask) return nil;
	return _CIdiffMask ;
	
}*/

- (CIImage*)cimask	{
	return _cimask ;
}

- (CIImage*)videoframe	{
	return _videoframe ;
}

#pragma mark *** kineto mask layers
- (void) setupLayer:	(int) nLayer
			visible:	(bool) visible
			   name: (NSString *)name
			  color: (NSColor *)color	{
	
	if (nLayer > kMasksCount) return;
	
	_kinetoLayersAttributes[nLayer]->visible = visible;
	_kinetoLayersAttributes[nLayer]->name = [name retain];
	_kinetoLayersAttributes[nLayer]->color = [color retain];	
	_kinetoLayersAttributes[nLayer]->shouldUpdate = true;	
	
}





- (void) setupKinetoLayersToDefaults	{	
	[self setupLayer:	kMaskLiveInput
			 visible:	false
				name: @"Live input"
			   color: [NSColor greenColor]];
	
	[self setupLayer:	kMaskBackground
			 visible:	true
				name: @"Background"
			   color: [NSColor grayColor]];
	
	[self setupLayer:	kMaskDiffMask
			 visible:	true
				name: @"Diff mask"
			   color: [NSColor yellowColor]];
	
	[self setupLayer:	kMaskMotionMask
			 visible:	true
				name: @"Motion mask"
			   color: [NSColor redColor]];
}

- (void) setupKinetoLayers {
	int i;
	
	for (i=0; i<kMasksCount; i++)
		_kinetoLayersAttributes[i] = (MaskLayerAttributesRef)MemAlloc( sizeof(MaskLayerAttributes) );
	[self setupKinetoLayersToDefaults];
	
	
}

- (void) setValueForMask: (int) nMask	{
	NSString *layerName;
	switch (nMask) {
		case kMaskLiveInput: 	layerName = @"live_input"; break;
		case kMaskBackground:	layerName = @"background"; break;
		case kMaskDiffMask:		layerName = @"diff_mask"; break;
		case kMaskMotionMask:	layerName = @"motion_mask"; break;
		default: layerName = @"";
	}
	if (layerName != @"") {
		[[super renderer] setValue: [NSNumber numberWithBool: _kinetoLayersAttributes[nMask]->visible]
							forInputKey: [[NSString stringWithString: @"enable_"] stringByAppendingString:  layerName]];
		[[super renderer] setValue: _kinetoLayersAttributes[nMask]->color
							forInputKey: [[NSString stringWithString: @"color_"] stringByAppendingString:  layerName]];
		_kinetoLayersAttributes[nMask]->shouldUpdate = false;
	}
	
}

#pragma mark *** Other methods

/*- (void) readMasksInCPUMemory: (NSNotification*)notification	{

	float fps = (float)[self FPS];
	if (fps > _minFPSDropThreshold)	{
		float dropFrameInterval = _dropFrameFactor * fps;
	
		_dropFrameCounter ++;
		if (_dropFrameCounter >= dropFrameInterval)		{
			//NSLog (@"Frame drooped! Dropping 1 frame every %.2f (%.2f fps)", dropFrameInterval, [self FPS]);
			_dropFrameCounter -= dropFrameInterval;
			return;
			}
	}	
	
	

	if (_diffMask!=nil) 
		[_diffMask release]; 

	if (_motionMask!=nil) 
		[_motionMask release]; 
	
	
	_diffMask = [[[super renderer] valueForOutputKey: @"diff_mask" ofType:@"NSBitmapImageRep"] retain];
	_motionMask  = [[[super renderer] valueForOutputKey:@"motion_mask" ofType:@"NSBitmapImageRep"] retain];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:MasksHasBeenUpdatedNotification object:self];
}*/


- (void) readMasksInCPUMemory: (NSNotification*)notification	{
	
	float fps = (float)[self FPS];
	if (fps > _minFPSDropThreshold)	{
		float dropFrameInterval = _dropFrameFactor * fps;
		
		_dropFrameCounter ++;
		if (_dropFrameCounter >= dropFrameInterval)		{
			//NSLog (@"Frame drooped! Dropping 1 frame every %.2f (%.2f fps)", dropFrameInterval, [self FPS]);
			_dropFrameCounter -= dropFrameInterval;
			return;
		}
	}	
	
	@synchronized (self) {
		if (_cimask!=nil) {
			[_cimask release]; 
			_cimask = nil;
		}
		if (_videoframe!=nil) {
			[_videoframe release]; 
			_videoframe = nil;
		}
		_cimask = [[[super renderer] valueForOutputKey: @"masks" ofType:@"CIImage"] retain] ;
		_videoframe = [[[super renderer] valueForOutputKey: @"VideoOutput" ofType:@"CIImage"] retain] ;

	}
		
	[[NSNotificationCenter defaultCenter] postNotificationName:MasksHasBeenUpdatedNotification object:self];
}

#pragma mark *** Overrides of CameraControllerInQCMaskRendererView

- (NSString *) qcPatchName {
	
	return @"kineto_masks";
	
}

- (void) hookToCameraController: (CameraController*)cameraController	{
	
	[super hookToCameraController: cameraController];
	[self captureNextBackground];

	int i;
	for (i=0;i<kMasksCount;i++)
		[self setValueForMask:i];
	
	int width = [cameraController cameraSize].width;
	int height = [cameraController cameraSize].height;
	
	data = malloc (width * height * 8);
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(readMasksInCPUMemory:) 
												 name:NewFrameHasBeenProcessedNotification 
											   object:self];

	// create a CoreImage context
	// (used to calculate area averages for collision detection elements/masks)
	CIContext *myCIContext;
	myCIContext = [CIContext contextWithCGLContext: [[self openGLContext] CGLContextObj]
									   pixelFormat: [[self pixelFormat] CGLPixelFormatObj]
										   options: nil];
	if (myCIContext == nil)	{
		NSLog(@"ECNLiveview.h: Error in creating Core Image Context!");
		
	}
	_ciContext = [myCIContext retain];
}



- (void) prepareRenderingWithFrame: (CVImageBufferRef) currentFrame	{
	
	int i;
	
	
	// RETAIN VIDEOFRAME IN A CIIMAGE
/*	if (_videoframe!=nil) [_videoframe release]; 
	_videoframe = [[CIImage imageWithCVImageBuffer: (CVImageBufferRef) currentFrame] retain];
*/
	
	
	// BACKGROUND
	[[super renderer] setValue: [NSNumber numberWithBool: bCatturaProssimoSfondo]
						forInputKey: @"background_store_next_frame"];
	if (bCatturaProssimoSfondo) {	
		
		bCatturaProssimoSfondo = false;
		
		if (_imgBackground) [_imgBackground release];
		
		// save videoframe to CPU memory in a NSImage
		NSImage *image = [[[NSImage alloc] initWithSize:
						   NSMakeSize([_videoframe extent].size.width,
									  [_videoframe extent].size.height)]
						  autorelease];
		[image lockFocus];
		[[[NSGraphicsContext currentContext] CIContext] drawImage: _videoframe 
														  atPoint: CGPointMake(0, 0)
														 fromRect: [_videoframe extent]];
		[image unlockFocus];
		
		_imgBackground = [[image flipImage] retain];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:BackgroundDidChangeNotification object:self];
		
	}
	
	
	// UPDATE LAYERS ATTRIBUTES (visible, color)
	for (i=0;i<kMasksCount;i++)
		if (_kinetoLayersAttributes[i]->shouldUpdate) [self setValueForMask:i];
	
	[super prepareRenderingWithFrame: currentFrame];
	
}



- (void) willFlushGLContextObj: (CGLContextObj) cgl_ctx	{
	//	if (bShowMaskVisualizers)
//	 {	[[_visualizers objectAtIndex:kVDiffMask] drawGridInOpenGLContext: _sharedGLContext];
//	 //[[_visualizers objectAtIndex:kVDiffMask] drawInOpenGLContext: _sharedGLContext];
//	 //[[_visualizers objectAtIndex:kVMotionMask] drawInOpenGLContext: _sharedGLContext];
//	 }
	
	[[ECNPlaybackWindowController sharedECNPlaybackWindowController] drawPlaybackElements];
}


@end
