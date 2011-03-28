//
//  ECNLiveViewerController.m
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 20/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SynthesizeSingleton.h"
#import "AppController.h"

#include <OpenGL/CGLMacro.h>
#include "OpenGLQuad.h"
#include "OpenGLTexture.h"

#import "ECNLiveViewerController.h"
#import "ECNPlaybackWindowController.h"
#import "ECNLiveInputSelectorWindowController.h"
#import "ECNLiveView.h"

#import "Colorcell.h"

//#import "ECNLiveInputSelectorWindowController.h"

//#import "PBufferRenderer.h"
#import "LiveInputRenderer.h"
#import "QCMaskRenderer.h"
#import "CameraController.h"


NSString *ECNBackgroundDidChangeNotification = @"ECNBackgroundDidChange";

/*NSString *ECNBackgroundDidChangeNotification = @"ECNBackgroundDidChange";
NSString *ECNNewFrameHasBeenProcessedNotification = @"ECNNewFrameHasBeenProcessed";


@interface NSImage(ECNConvenience)
- (NSImage*)flipImage;
@end

struct MaskLayerAttributes
{
	bool visible;
	NSString* name;
	NSColor * color;
	bool shouldUpdate;
};


typedef struct MaskLayerAttributes   MaskLayerAttributes;



*/

#define kDefaultLiveInputAspectRatio 1.66f

@interface ECNLiveViewerController (PrivateMethods)
- (void) _framerateHasBeenUpdated: (NSNotification *)notification;
@end


@implementation ECNLiveViewerController

SYNTHESIZE_SINGLETON_FOR_CLASS(ECNLiveViewerController);


- (id)init {

	if (![self initWithWindowNibName: @"LiveViewer"])
	{
		NSLog(@"Could not init LiveViewer!");
		return nil;
	}
	
	liveInputAspectRatio = kDefaultLiveInputAspectRatio; // di default
	
	// attensiù che questo comando attiva windowdidload
	//[[self window] makeKeyAndOrderFront:nil];

    return self;
}

- (void)dealloc {
	
	//Stop observing the rendering view
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [super dealloc];
}


#pragma mark *** Offline renderers initialization ***


- (void) setDefaultValues
{
	float diffMaskDefaultValue = 0.86f;
	float motionMaskDefaultValue = 0.14f;
	
	//_prevVisibleMask = kQCLiveInput;
	[oDiffBGThreshold setFloatValue: diffMaskDefaultValue];
	[oMotionMaskThreshold setFloatValue: motionMaskDefaultValue];
	
//	[[_renderers objectAtIndex: kQCDiffMask] setValue:[NSNumber numberWithFloat: diffMaskDefaultValue] forInputKey:@"DB_threshold"];
	[[liveView renderer] setValue:[NSNumber numberWithFloat: diffMaskDefaultValue] forInputKey:@"DB_threshold"];
	[txtDiffBGThreshold setFloatValue: diffMaskDefaultValue];
	
//	[[_renderers objectAtIndex: kQCMotionMask] setValue:[NSNumber numberWithFloat: motionMaskDefaultValue] forInputKey:@"motion_threshold"];
	[[liveView renderer] setValue:[NSNumber numberWithFloat: diffMaskDefaultValue] forInputKey:@"motion_threshold"];
	[txtMotionMaskThreshold setFloatValue: motionMaskDefaultValue];
	
	
	
	
}


- (void) setCameraController: (CameraController *)cameraController	{

	
	NSLog(@"    ### LIVEVIEWER init beginning ###");
	[liveView hookToCameraController: cameraController];
	_deviceInputUniqueID=	[NSString stringWithString: [[cameraController captureDevice] uniqueID]];

	[self setDefaultValues];


//	[self setupMaskVisualizers];
	

	// redim window to set correct aspect ratio and refresh
	liveInputAspectRatio = [cameraController aspectRatio] ;
	liveInputAspectRatio = liveInputAspectRatio > 0.0 ? liveInputAspectRatio : 1.0;
	
	NSSize framesize = NSMakeSize( [[self window] frame].size.width, 
								   [[self window] frame].size.height );


	framesize.width = framesize.height - [[self window] frame].size.height + [liveView bounds].size.height * liveInputAspectRatio;
	int dx= [[self window] frame].size.width - framesize.width;


	[[self window] setFrame: NSMakeRect([[self window] frame].origin.x + dx,
										[[self window] frame].origin.y,
										framesize.width , 
										framesize.height)
					display: YES];
	
	// start rendering
	[liveView startRendering];
	[self _framerateHasBeenUpdated: nil];
}


#pragma mark *** Accessors ***
- (CIContext *)CIContext	{
	
	return [liveView CIContext];
}

// mask data
/*- (CIImage*)diffMask	{
	return [liveView diffMask] ;
}

- (CIImage*)motionMask	{
	return [liveView motionMask] ;	
}*/
- (CIImage*)videoframe	{
	return [liveView videoframe] ;
}

- (CIImage*)cimask	{
	return [liveView cimask] ;
}


- (NSImage *)getBackground	{
	return [liveView backgroundImage];
}

// Playback accessors
- (NSOpenGLContext *) openGLContext	{
	return [liveView openGLContext];
}


- (float) getRenderAspectRatio {
	return liveInputAspectRatio;
}

- (void) setTitle {	
//	[[self window] setTitle: [NSString stringWithFormat:@"Live Window - %ix%i - %ifps", (int)renderSize.width, (int)renderSize.height, (int)_FPS/2]];	
}



#pragma mark *** Observing
- (void) _backgroundDidChange: (NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] postNotificationName:ECNBackgroundDidChangeNotification object:self];
}

- (void) _masksHasBeenUpdated: (NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] postNotificationName:MasksHasBeenUpdatedNotification object:self];

	return;
	
}
- (void) _framerateHasBeenUpdated: (NSNotification *)notification {
	NSSize cameraSize = [[[liveView liveInput] cameraController] cameraSize];
	[[self window] setTitle: [NSString stringWithFormat:@"Live Window - %ix%i - %.1ffps", (int)cameraSize.width, (int)cameraSize.height, (float)[liveView FPS]]];	

	return;

}


#pragma mark *** delegate of NSWindow ***

- (void)windowDidLoad {
	
	
	[super windowDidLoad];
	
	// init custom colorCell in kinetoLayersTableView
	NSTableColumn* column;
	ColorCell* colorCell;
	
	column = [[oKinetoLayersTableView tableColumns] objectAtIndex: 3];
	colorCell = [[[ColorCell alloc] init] autorelease];
	[colorCell setEditable: YES];
	[colorCell setTarget: self];
	[colorCell setAction: @selector (colorClick:)];
	[column setDataCell: colorCell];
	
	// Be the data source... 
    [oKinetoLayersTableView setDataSource:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_masksHasBeenUpdated:) 
												 name:MasksHasBeenUpdatedNotification 
											   object:liveView];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_framerateHasBeenUpdated:) 
												 name:FramerateHasChangedNotification
											   object:liveView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_backgroundDidChange:) 
												 name:BackgroundDidChangeNotification
											   object:liveView];
	
	
	
	
	
	// load default webcam
	
	CameraController *cameraController = [[ECNLiveInputSelectorWindowController sharedECNLiveInputSelectorWindowController] configDefaultDeviceInput] ;
	[self setCameraController: cameraController];
	

	
}

- (void)windowDidResize:(NSNotification *)notification
 
{
	[liveView update];
}


-(NSSize)windowWillResize:(NSWindow *)sender
				   toSize:(NSSize)framesize;
{
	framesize.height = framesize.width / liveInputAspectRatio + [[self window] frame].size.height - [liveView bounds].size.height;

	//Notify the OpenGL context its rendering view has changed
	return framesize;
}





#pragma mark *** LiveViewer events ***



- (void)showOrHideWindow {
	
    // Simple.
    NSWindow *window = [self window];
    if ([window isVisible]) {
		[window orderOut:self];
    } else {
		[self showWindow:self];
    }
	
}


- (IBAction) catturaSfondo:(id)sender {

	
	[liveView captureNextBackground];

	// manda un segnale a AppController che lo sfondo è cambiato
//	[(AppController *)[self application] setNewBGImage: (NSImage *)[self grabCurBGImage]];


}


- (IBAction) setDiffBGThreshold:(NSSlider *)sender {
	
	
	float value;
	
	// show diff mask!
	/*if (_visibleMask != kQCDiffMask)
	{	
		_prevVisibleMask = _visibleMask;*/
/*		[viewSelectorMatrix selectCellAtRow: kQCDiffMask column: 0];
		[self switchView: self];*/
	//}
	
	value = [sender floatValue];
	
	// TODO controlla Inputkey!
	if (![[liveView renderer] setValue:[NSNumber numberWithFloat:value] forInputKey:@"DB_threshold"]) {
		
		NSLog(@"Could not change QC value 'DB threshold'");
		return;
	};
	
	[txtDiffBGThreshold setStringValue: [NSString stringWithFormat:@"%.2f", value]]; 
		
/*	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(sliderDoneMoving:) object:sender];
		[self performSelector:	@selector(sliderDoneMoving:)
				   withObject:	sender afterDelay:0];
*/	
}

- (IBAction) setMotionMaskThreshold:(NSSlider *)sender {
	
	float value;
	value = [sender floatValue];
	

	// show motion mask!
/*	if (_visibleMask != kQCMotionMask)
	{	_prevVisibleMask = _visibleMask;
		[viewSelectorMatrix selectCellAtRow: kQCMotionMask column: 0];
		[self switchView: self];
	}*/

	// TODO controlla perché motionMaskThreshold non si aggancia!
	if (![[liveView renderer] setValue:[NSNumber numberWithFloat:value] forInputKey:@"motion_threshold"]) {
		
		NSLog(@"Could not change QC value 'Motion mask threshold'");
		return;
		
	};

	
	[txtMotionMaskThreshold setStringValue: [NSString stringWithFormat:@"%.2f", value]]; 

/*	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(sliderDoneMoving:) object:sender];
//	if (_prevVisibleMask != kQCMotionMask)
	
	[self performSelector:@selector(sliderDoneMoving:)
			   withObject:sender afterDelay:0];*/
	

}

- (IBAction) setMotionMaskPersistence:(NSSlider *)sender {
	
	float value;
	value = [sender floatValue];
	
	
	// show motion mask!
	/*	if (_visibleMask != kQCMotionMask)
	 {	_prevVisibleMask = _visibleMask;
	 [viewSelectorMatrix selectCellAtRow: kQCMotionMask column: 0];
	 [self switchView: self];
	 }*/
	
	// TODO controlla perché motionMaskThreshold non si aggancia!
	if (![[liveView renderer] setValue:[NSNumber numberWithFloat:value] forInputKey:@"motion_persistence"]) {
		
		NSLog(@"Could not change QC value 'Motion mask threshold'");
		return;
		
	};
	
	
	[txtMotionMaskPersistence setStringValue: [NSString stringWithFormat:@"%.2f", value]]; 
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(sliderDoneMoving:) object:sender];
	//	if (_prevVisibleMask != kQCMotionMask)
	[self performSelector:@selector(sliderDoneMoving:)
			   withObject:sender afterDelay:0];
	
	
}


#pragma mark *** UI events methods ***


- (IBAction) openLiveInputSelectorModal: (id)sender	{
	
	[liveView stopRendering];
	CameraController *cameraController = [liveView releaseCameraController];
//	[cameraController closeStream];
	
//	CameraController *newCameraController  = [[ECNLiveInputSelectorWindowController sharedECNLiveInputSelectorWindowController] configDeviceWithUniqueID: _deviceInputUniqueID] ;
	cameraController  = [[ECNLiveInputSelectorWindowController sharedECNLiveInputSelectorWindowController] configCameraController: cameraController] ;

	[self setCameraController: cameraController];

}




#pragma mark *** NSTableView delegate methods ***

- (void) colorClick: (id) sender { // sender is the table view
	NSColorPanel* panel;
	
	_currentlyModifyingLayer = [sender clickedRow];
	panel = [NSColorPanel sharedColorPanel];
	[panel setTarget: self];
	[panel setAction: @selector (colorChanged:)];
	[panel setColor: [liveView layerColor: _currentlyModifyingLayer]];	 
	[panel makeKeyAndOrderFront: self];
}

- (void) colorChanged: (id) sender { // sender is the NSColorPanel
	[liveView setColor: [sender color] forLayer: _currentlyModifyingLayer];
	[oKinetoLayersTableView reloadData];

}


// Table View
- (int) numberOfRowsInTableView: (NSTableView*) tableView {
	return kMasksCount;
}

- (id) tableView: (NSTableView*) aTableView objectValueForTableColumn:
				(NSTableColumn*) aTableColumn row: (int) rowIndex {
	
	id theValue;
	
	NSParameterAssert(rowIndex >= 0 && rowIndex < kMasksCount);
	
	theValue = @"";
	
	if ([[aTableColumn identifier] isEqualToString: @"visible"])
	{	theValue = [NSNumber numberWithBool: [liveView layerVisible:rowIndex]  ];	}
	if ([[aTableColumn identifier] isEqualToString: @"layer_name"])
	{	theValue = [liveView layerName:rowIndex];	}
	if ([[aTableColumn identifier] isEqualToString: @"solo"])
	{	theValue = [NSNumber numberWithBool: false];
	}
	if ([[aTableColumn identifier] isEqualToString: @"color"])
	{	theValue = [liveView layerColor:rowIndex];
	}
	
	//	theValue = [theRecord objectForKey:[aTableColumn identifier]];
	
	return theValue;
	
	
}

- (void)tableView:	(NSTableView *)aTableView setObjectValue:(id)objectValue 
   forTableColumn:(NSTableColumn *)tc 
			  row:(NSInteger)row 
{
    if ([[tc identifier] isEqualToString:@"visible"]) {
		[liveView setVisible:[objectValue boolValue] forLayer:row];
	
    } else	if ([[tc identifier] isEqualToString:@"solo"]) {
		// TODO: implementare
    } else	if ([[tc identifier] isEqualToString:@"color"]) {
	}
}



@end



/*#pragma mark -

@implementation ECNMaskVisualizer

- (id) init
{
	return [self initWithRenderer: nil TextureWidth:0 textureHeight:0 openGLContext:nil threshold: 0.0];
}


- (ECNMaskVisualizer*)	initWithRenderer: (OfflineRenderer *)renderer TextureWidth: (unsigned) width textureHeight: (unsigned) height openGLContext: (NSOpenGLContext *) openGLContext threshold: (float) threshold
{
	_renderer = renderer;
	
	_visMatrix = nil;
	
	_color = [[NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:1.0f] autorelease];

	_newGranularity = gridWidth;
	_newThreshold = (unsigned)255/threshold;
	_bNeedsToBeUpdated = true;
	[self _updateGridBuffer];
	
	return self;
	
}

- (void) setColor: (NSColor *)color
{
//	_color = color;
	_color = [[color colorUsingColorSpaceName:NSCalibratedRGBColorSpace] autorelease];
}

- (void) setGranularity: (unsigned) granularity
{
	if (granularity <1) 
		_newGranularity = 16;
	else
		_newGranularity = granularity;
	_bNeedsToBeUpdated = true;
}

- (void) setThreshold: (float) threshold
{
	_newThreshold = (unsigned)255.0 * threshold;
}

- (void) _updateGridBuffer
{

	unsigned newGridWidth = [_renderer size].width / round ([_renderer size].width / _newGranularity / [[ECNLiveViewerController sharedECNLiveViewerController] getRenderAspectRatio]);
	unsigned newGridHeight = [_renderer size].height / round ([_renderer size].height / _newGranularity);
	// TODO: commisurare altezzagriglia con pixel aspect ratio
	
	NSLog(@"%i, %i, %i, %i", _newGranularity, newGridWidth, newGridHeight, _threshold);
	if (_visMatrix) free(_visMatrix);
	_visMatrix = calloc (([_renderer size].height / newGridHeight) * ([_renderer size].width / newGridWidth), sizeof(unsigned char));
	_gridWidth = newGridWidth;
	_gridHeight = newGridHeight;

	_bNeedsToBeUpdated = false;
	
	return;
}

- (unsigned char) calcWeight: (void *)pixelBuffer x: (unsigned) x y: (unsigned) y gridWidth1: (unsigned) gWidth gridHeight1: (unsigned) gHeight bufferWidth: (unsigned) bWidth bufferHeight: (unsigned) bHeight
{
	void *startQuad;
	startQuad = pixelBuffer + ((x * gWidth +  (y * gHeight) * bWidth)) * 4;
	void *pixel = startQuad;
	float weight;
	
	int j,k;
	float alpha;
	weight = 0.0;
	
	for (k=0;k<gHeight;k++)
	{	
		for (j=0;j<gWidth;j++)
		{
		
			alpha = (float)*(GLubyte*)(pixel+3) / 255;
			weight += alpha;
			pixel+= 4;

		}
		pixel = startQuad + (bWidth * 4) * k;

	}
	
	return (unsigned char)(weight / (gWidth * gHeight) * 255);
}

- (BOOL) updateTextureForTime:(NSTimeInterval)time
{
	void *pixelBuffer = [_renderer CPUmemPixelBuffer];
	if (pixelBuffer==nil) return false;
	
	if (_bNeedsToBeUpdated) [self _updateGridBuffer];
	if (_newThreshold != _threshold) 
	{
		_threshold = _newThreshold;
		NSLog(@"threshold: %i", _threshold);
	}
	
	unsigned i,j;
	unsigned gWidth = _gridWidth;
	unsigned gHeight = _gridHeight;
//	NSString *str = [[NSString alloc] initWithString: @""];
	
//	float *matrix[[_renderer textureHeight] / gHeight][[_renderer textureWidth] / gWidth];
	unsigned char *matrix = _visMatrix;
	
	unsigned pixelsWide = [_renderer size].width;
	unsigned pixelsHigh = [_renderer size].height;
	
	//NSLog(@"----------------");
	for (i=0; i <  pixelsHigh / gHeight; i++)
	{
		for (j=0; j <  pixelsWide / gWidth; j++)
		{	matrix = _visMatrix + (j + i * pixelsWide / _gridWidth);
			*matrix = [self calcWeight: pixelBuffer x:j y:i gridWidth1: gWidth gridHeight1: gHeight bufferWidth: pixelsWide bufferHeight: pixelsHigh ];
			if ((*matrix) < _threshold) *matrix = 0;
			
			//str = [str stringByAppendingString:[NSString stringWithFormat: @"%i, ", *matrix]];

		}
		//NSLog(str);
		//str = @"";

	}
		  
	return true;
}


- (void) drawGridInOpenGLContext: (NSOpenGLContext *)openGLContext
{
	GLint saveMode;
	NSPoint startPoint, endPoint;
	
	CGLContextObj cgl_ctx = [openGLContext CGLContextObj];
	
	glGetIntegerv(GL_MATRIX_MODE, &saveMode);
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
	
	glBegin(GL_LINES);
	glEnable(GL_LINE_SMOOTH);
	
	GLfloat sizes[2];  // Store supported line width range
	GLfloat step;     // Store supported line width increments
	
	glGetFloatv(GL_LINE_WIDTH_RANGE, sizes);
	glGetFloatv(GL_LINE_WIDTH_GRANULARITY, &step);
	
	
	glColor3f(0.3, 0.3, 0.3);
	
	unsigned i,j;
	float multFactorX, multFactorY;
		
	unsigned pixelsWide = [_renderer size].width;
	unsigned pixelsHigh = [_renderer size].height;
	
	multFactorX = (float)_gridWidth / pixelsWide * 2;
	multFactorY = (float)_gridHeight / pixelsHigh * 2;
	
	for (i=0; i <  pixelsHigh / _gridHeight; i++)
	{
		glVertex2f(-1.0, 1.0 - i * multFactorY);
		glVertex2f(1.0,  1.0 - i * multFactorY);	

		for (j=0; j <  pixelsWide / _gridWidth; j++)
		{				
			glVertex2f(- 1.0 + j*multFactorX, -1.0);
			glVertex2f(- 1.0 + j*multFactorX, 1.0);	
		}		
	}
	
	
	glEnd();
	
	//After drawing, restore original OpenGL states.
    glPopMatrix();
    glMatrixMode(saveMode);
	
    // Check for errors.
    glGetError();
}

- (void) drawInOpenGLContext: (NSOpenGLContext *)openGLContext
{
	GLint saveMode;
	NSPoint startPoint, endPoint;
	
	CGLContextObj cgl_ctx = [openGLContext CGLContextObj];

	glGetIntegerv(GL_MATRIX_MODE, &saveMode);
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
	
	glBegin(GL_LINES);
	glEnable(GL_LINE_SMOOTH);
	
	GLfloat sizes[2];  // Store supported line width range
	GLfloat step;     // Store supported line width increments
	
	glGetFloatv(GL_LINE_WIDTH_RANGE, sizes);
	glGetFloatv(GL_LINE_WIDTH_GRANULARITY, &step);
	
	
	float red, green, blue;
	red = [_color redComponent];
	green = [_color greenComponent];
	blue = [_color blueComponent];
	glColor3f(red , green, blue);

	
	unsigned i,j;
	float curXCenter, curYCenter;
	float multFactorX, multFactorY;
	float curValueX, curValueY ;
	
	unsigned char *matrix = _visMatrix;
	unsigned pixelsWide = [_renderer size].width;
	unsigned pixelsHigh = [_renderer size].height;
	
	multFactorX = (float)_gridWidth / pixelsWide * 2;
	multFactorY = (float)_gridHeight / pixelsHigh * 2;
	
	for (i=0; i <  pixelsHigh / _gridHeight; i++)
	{
		for (j=0; j <  pixelsWide / _gridWidth; j++)
		{	
			
			matrix = _visMatrix + (j + i * pixelsWide / _gridWidth) ;

			curXCenter = j * multFactorX + (multFactorX/2.0) - 1;
			curYCenter = i * multFactorY + (multFactorY/2.0) - 1;

			curValueX = (float)*matrix/255 * multFactorX / 2;
			curValueY = (float)*matrix/255 * multFactorY / 2;
			glVertex2f(curXCenter - curValueX, curYCenter- curValueY);
			glVertex2f(curXCenter+ curValueX, curYCenter + curValueY);	
			
			glVertex2f(curXCenter - curValueX, curYCenter+ curValueY);
			glVertex2f(curXCenter+ curValueX, curYCenter - curValueY);	
			//*matrix = [self calcWeight: pixelBuffer x:j y:i gridWidth1: gWidth gridHeight1: gHeight bufferWidth: [_renderer textureWidth] bufferHeight: [_renderer textureHeight] ];
			//str = [str stringByAppendingString:[NSString stringWithFormat: @"%i, ", *matrix]];
			
		}
		//NSLog(str);
		//str = @"";
		
	}

		
	glEnd();
	
	//After drawing, restore original OpenGL states.
    glPopMatrix();
    glMatrixMode(saveMode);
	
    // Check for errors.
    glGetError();
}

- (void)dealloc {
	
	free (_visMatrix);
	
	[super dealloc];

}


@end*/
