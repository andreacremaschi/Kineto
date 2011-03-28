//
//  LiveInputSelectorView.m
//  kineto
//
//  Created by Andrea Cremaschi on 25/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CameraControllerInQCMaskRendererView.h"
#import "LiveInputRenderer.h"
#import "CameraController.h"
#import "QCMaskRenderer.h"
#import "OpenGLTexture.h"
#import "OpenGLQuad.h"
#import "MemObject.h"
#import "AlertPanelKit.h"

#include <OpenGL/CGLMacro.h>

NSString *NewFrameHasBeenProcessedNotification = @"NewFrameHasBeenProcessed";
NSString *FramerateHasChangedNotification = @"FramerateHasChanged";

@implementation CameraControllerInQCMaskRendererView


//---------------------------------------------------------------------------
//
// We need a lock around our draw function so two different threads don't
// try and draw at the same time
//
//---------------------------------------------------------------------------

- (void) newRecursiveLock
{
	lock = [NSRecursiveLock new];
} // newRecursiveLock




- (id)initWithCoder:(NSCoder *)decoder		{
	
	self = [super initWithCoder: decoder];
	
	if (self)	{		
		[self newRecursiveLock];
		_targetOpenGLTexture = nil;
		_liveInputRenderer = nil;
		_bAsynchronousMode = true;
		_FPSCounterLastReset = 0;

	}
	return self;
} // initWithCoder




- (void) dealloc	{
	
	if (_liveInputRenderer!=nil) 
		[_liveInputRenderer release];
	
	[super dealloc];
}

#pragma mark *** Timers: rendertimer and fpscounter


/*- (NSTimer *) initTimer {
	
	return [[NSTimer scheduledTimerWithTimeInterval: 4.0
											target: self
										  selector: @selector(timerTick:)
										  userInfo: nil
										   repeats: YES] retain];	
	
}*/ // initTimer
/*
- (void) timerTick: (NSTimer *) timer	{
	
	_FPS = (float)_fpsCounter/4.0;	
	_fpsCounter = 0;
	[[NSNotificationCenter defaultCenter] postNotificationName: FramerateHasChangedNotification object:self];
//	NSLog(@"FPS counter reset!");
}
*/

#pragma mark *** setup methods
/*- (void)setupSharedContext // WithPixelFormat: (NSOpenGLPixelFormat *)pixelFormat
{
	
	NSOpenGLPixelFormatAttribute	attributes[] = {
		NSOpenGLPFAAccelerated, 
		NSOpenGLPFANoRecovery, 
		NSOpenGLPFADoubleBuffer, 
		NSOpenGLPFADepthSize, 24, 
		0};
	GLint	swapInterval = 1;// 1 waits for the monitor retrace before swapping

	// init OpenGL Pixel Format
	NSOpenGLPixelFormat* sharedPixelFormat = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];

	// init OpenGL Context
	NSOpenGLContext * sharedGLContext = [[[NSOpenGLContext alloc] initWithFormat: sharedPixelFormat shareContext:nil] autorelease];

	// bind to NSOpenGLView ...
    [self setOpenGLContext: sharedGLContext]; //[[[NSOpenGLContext alloc] initWithFormat: [NSOpenGLView defaultPixelFormat] shareContext:nil] retain]];
	[self setPixelFormat: sharedPixelFormat];
	[[self openGLContext] setValues: &swapInterval forParameter:NSOpenGLCPSwapInterval];
	[[self openGLContext] setView: self];
	
	//contextIsInitialized=true;	
	NSLog(@"Shared context initialized!");

}*/


- (void) setupRendererWithLiveInput: (LiveInputRenderer *)liveInput	{
	
	NSString *compositionPath;
	
	// get path to Quartz Composer patch 
	if ([[NSBundle mainBundle] pathForResource: [self qcPatchName] ofType:@"qtz"])
		compositionPath = [[[NSString alloc] initWithString: [[NSBundle mainBundle] pathForResource: [self qcPatchName] ofType:@"qtz"]] autorelease];
	else
		compositionPath = [[[NSString alloc] initWithString: [[NSBundle mainBundle] pathForResource:@"null" ofType:@"qtz"]] autorelease];
	
	NSAssert (![compositionPath isEqual: @""], @"compositionPath not valid and 'null' mask not found!"); 
	
	NSLog(@"Loading composition \"%s\"...\n", [[compositionPath lastPathComponent] UTF8String]);
	
	
	_renderer = [[QCMaskRenderer createFilterWithCompositionPath: compositionPath
													usingRenderer: liveInput] retain];

	
	//not safe to feed input now: the QTVisualContext has just been created
	//and we're not sure that it has already fed with a videoframe
	//[_renderer feedVideoInputWithOutputOfRenderer: liveInput];
	
	
	
}


#pragma mark *** Accessors
- (QCRenderer *)renderer{
	return [_renderer renderer];
}

- (LiveInputRenderer *)liveInput {
	return _liveInputRenderer ;
}


- (float) FPS	{
	return _FPS;
}

#pragma mark *** Mouse handlng
- (bool) isLeftButtonDown	{
	return _bLeftButtonDown;
}
- (NSPoint) curMousePos	{
	return NSMakePoint (_curMousePositionX, _curMousePositionY);
}

- (void)selectAndTrackMouseWithEvent:(NSEvent *)theEvent {
	
	// track mouse movements to set keystone knobs position
    // and debug hot spot
	while (1) {
		
        theEvent = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
		NSPoint curPoint = [self convertPoint: [theEvent locationInWindow] fromView:nil];
		
		float maxYCoord = _aspectRatio - 1.0; // è una semplificazione della formula (x-y) / y
		
		_curMousePositionX = (float)(curPoint.x / [self bounds].size.width) * 2.0 - 1.0;
		_curMousePositionY = ((float)(curPoint.y / [self bounds].size.height)) * 2.0  - 1.0;
		_curMousePositionY /= _aspectRatio ; // perché? trovato per tentativi
		
		_curMousePositionX = _curMousePositionX > 1.0 ? 1.0 : _curMousePositionX;
		_curMousePositionX = _curMousePositionX < -1.0 ? -1.0 : _curMousePositionX;
		_curMousePositionY = _curMousePositionY > maxYCoord ? maxYCoord : _curMousePositionY;
		_curMousePositionY = _curMousePositionY < -maxYCoord ? -maxYCoord : _curMousePositionY;

		// NSLog (@"X: %.2f, Y: %.2f, aspect ratio: %.2f", _curMousePositionX, _curMousePositionY, _aspectRatio);

		_bLeftButtonDown = true;
		
		//NSLog (@"%f, %f", _curMousePositionX, _curMousePositionY);
		
        if ([theEvent type] == NSLeftMouseUp) {
			
			[[self window] setAcceptsMouseMovedEvents:NO];
			_bLeftButtonDown = false;
			break;
        }
    }
}

- (void)mouseMoved:(NSEvent *)theEvent
 {
 //	theEvent = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
 NSPoint curPoint = [self convertPoint: [theEvent locationInWindow] fromView:nil];
 
 _curMousePositionX = (float)(curPoint.x / [self bounds].size.width) * 2.0 - 1.0;
 _curMousePositionY = ((float)(curPoint.y / [self bounds].size.height)) * 2.0 - 1.0;
 
 _curMousePositionX = _curMousePositionX > 1.0 ? 1.0 : _curMousePositionX;
 _curMousePositionX = _curMousePositionX < -1.0 ? -1.0 : _curMousePositionX;
 _curMousePositionY = _curMousePositionY > 1.0 ? 1.0 : _curMousePositionY;
 _curMousePositionY = _curMousePositionY < -1.0 ? -1.0 : _curMousePositionY;
 
 NSLog (@"%f, %f", _curMousePositionX, _curMousePositionY);
 
 }


 - (void)mouseDown:(NSEvent *)theEvent
 {
 if ([theEvent window] == [self window])
 [self selectAndTrackMouseWithEvent: theEvent ];
 return;
 
 }



#pragma mark *** Camera controller hook methods

- (void) hookToCameraController: (CameraController*)cameraController {
	
	bHasReceivedNewFrame = false;

	//[self setupSharedContext];
	//[lock lock];
//	@synchronized (self) {
	[[super openGLContext] makeCurrentContext];

	NSSize theSize;
	theSize = [cameraController cameraSize];

	_aspectRatio = [cameraController aspectRatio];
	NSLog(@"Received a device input with size: %.2f x %.2f. Aspect ratio: %.2f", theSize.width, theSize.height, [cameraController aspectRatio]);
	
	//NSLog(@"Frame size: %.2f x %.2f. Setting to: %.2f x %.2f", [[self window] frame].size.width, framesize.height, framesize.width, framesize.height);
	
	if (_liveInputRenderer != nil)
		[_liveInputRenderer release];
	_liveInputRenderer = [[LiveInputRenderer createWithCameraController: cameraController
													  withOpenGLContext: [self openGLContext]
														withPixelFormat: [self pixelFormat]] retain] ;
	_bShouldRelease = false;
	_fpsCounter	=0;
		
	// init openGL quad to render to
	if (_quad != nil) [_quad release];
	_quad = [[OpenGLQuad quadWithSize:&theSize range:1] retain];

	[self setupRendererWithLiveInput: _liveInputRenderer];

	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(_receivedNewFrame:) 
												 name:CCReceivedNewFrameNotification 
											   object: _liveInputRenderer ];
	
	//[lock unlock];
//	}
	[[self openGLContext] update];

}

- (CameraController *) releaseCameraController	{
	_bShouldRelease = true;

	// stop receiving frames and rendering
	[[NSNotificationCenter defaultCenter] removeObserver:self  name: CCReceivedNewFrameNotification object: _liveInputRenderer ];
    [[NSNotificationCenter defaultCenter] removeObserver:self  name: CCDroppedFrameNotification object: _liveInputRenderer ];

	// camera controller visual context is bound to this viewer, release it or prepare to leak!
//	[_liveInputRenderer releaseVisualContext];
	CameraController *cameraController = [_liveInputRenderer cameraController];
	[_liveInputRenderer releaseCameraController];
	
	// release camera controller
	if (_liveInputRenderer != nil)	{
		[_liveInputRenderer release];
		_liveInputRenderer  = nil;
	}
	
	// release previous QC Renderer
	if (_renderer!= nil) {
		[_renderer release];
		_renderer = nil;
	}
	
	if (_quad!= nil) {
		[_quad release];
		_quad = nil;
	}
	
	return cameraController;
}

- (void) startRendering	{
	
	_renderTimer = [[NSTimer timerWithTimeInterval:(1.0 / (NSTimeInterval)30) 
											target:self 
										  selector:@selector(updateRenderView:) 
										  userInfo:nil 
										   repeats:YES] retain];
	[[NSRunLoop currentRunLoop] addTimer:_renderTimer forMode:NSDefaultRunLoopMode];
	[[NSRunLoop currentRunLoop] addTimer:_renderTimer forMode:NSModalPanelRunLoopMode];
	[[NSRunLoop currentRunLoop] addTimer:_renderTimer forMode:NSEventTrackingRunLoopMode];
	_startTime = -1.0;
	

}

- (void)stopRendering	{

	if (_renderTimer) {
		[_renderTimer invalidate];
		[_renderTimer release];
		_renderTimer = nil;
	}
	
}


#pragma mark *** Methods to override in subclasses od CameraControllerInQCMaskRendererView

- (NSString *) qcPatchName {
	
	return @"null";
	
}

- (void) prepareRenderingWithFrame: (id) currentFrame	{
	
	
}

- (void) willFlushGLContextObj: (CGLContextObj) cgl_ctx	{
	
}


#pragma mark *** Draw methods


// vecchia e funzionante!
/*- (void) updateRenderView: (NSTimer*) timer {
	NSTimeInterval			time = [NSDate timeIntervalSinceReferenceDate];
	
	BOOL success;
	
	//if (_bShouldRelease) return ;
	//if (_targetOpenGLTexture==nil) return;
		
	if (!bHasReceivedNewFrame) return ;
	bHasReceivedNewFrame = false;

	_fpsCounter++;


	[[self openGLContext] makeCurrentContext];

	CVImageBufferRef currentFrame = CVBufferRetain([_liveInputRenderer getCurrentFrame]);
	if (currentFrame == nil) return;
//	NSLog(@"new frame processed ! CVBufferRef: %i", currentFrame);
	[lock lock];
//	@synchronized (self){
		
		//Compute the local time
		if(_startTime < 0.0)	{
			_startTime = time;
			_FPSCounterLastReset = 0;
			_fpsCounter = 0;
		}
		time = time - _startTime;
			
		[_renderer setValue: currentFrame forInputKey: @"VideoInput"];
		
		[self prepareRenderingWithFrame: currentFrame];
		
		[_renderer updateTextureForTime: time];	
	
		CVBufferRelease(currentFrame);	

		[_liveInputRenderer task];

		//reset FPS counter timer
		if ((time - _FPSCounterLastReset) > 4)	{
			_FPS = (float)_fpsCounter / 4.0;
			_fpsCounter = 0;
			_FPSCounterLastReset = time;
			[[NSNotificationCenter defaultCenter] postNotificationName: FramerateHasChangedNotification object:self];
		}
//	}

	[self setNeedsDisplay: YES];
	[[NSNotificationCenter defaultCenter] postNotificationName: NewFrameHasBeenProcessedNotification object:self];
	[lock unlock];

	return ;
}*/



- (void) updateRenderView: (NSTimer*) timer {
	NSTimeInterval			time = [NSDate timeIntervalSinceReferenceDate];
	
	//CIImage *currentFrame;
	
	//if (_bShouldRelease) return ;
	//if (_targetOpenGLTexture==nil) return;
	
	if (!bHasReceivedNewFrame) return ;
	bHasReceivedNewFrame = false;
	
	_fpsCounter++;
	
	
	[[self openGLContext] makeCurrentContext];
	
	[lock lock];
	
	CVImageBufferRef currentFrame = CVBufferRetain([_liveInputRenderer getCurrentFrame]);
	if (currentFrame == nil) return;
	//	NSLog(@"new frame processed ! CVBufferRef: %i", currentFrame);
	
	//	@synchronized (self){
	
	//Compute the local time
	if(_startTime < 0.0)	{
		_startTime = time;
		_FPSCounterLastReset = 0;
		_fpsCounter = 0;
	}
	time = time - _startTime;
	
	[_renderer setValue: (id)currentFrame forInputKey: @"VideoInput"];
	
	[self prepareRenderingWithFrame: (id)currentFrame];
	
	[_renderer updateTextureForTime: time];	
	
	CVBufferRelease(currentFrame);	
	
	[_liveInputRenderer task];
	
	//reset FPS counter timer
	if ((time - _FPSCounterLastReset) > 4)	{
		_FPS = (float)_fpsCounter / 4.0;
		_fpsCounter = 0;
		_FPSCounterLastReset = time;
		[[NSNotificationCenter defaultCenter] postNotificationName: FramerateHasChangedNotification object:self];
	}
	//	}
	
	[self setNeedsDisplay: YES];
	[[NSNotificationCenter defaultCenter] postNotificationName: NewFrameHasBeenProcessedNotification object:self];
	[lock unlock];
	
	return ;
}


 
#pragma mark *** Observing _cameraController

- (void) _receivedNewFrame:(NSNotification *)notification	{
	if (_bShouldRelease) return;
	
	NSTimeInterval			time = [NSDate timeIntervalSinceReferenceDate];

	//Compute the local time
	time = time;
	//	[self setNextFrame: [_liveInputRenderer getCurrentFrame]];
	bHasReceivedNewFrame=true;
	if (!_bAsynchronousMode) [self updateRenderView:nil];
	
	
}

- (void)_liveInputHasDroppedAFrame:(NSNotification *)notification	{
	NSTimeInterval			time = [NSDate timeIntervalSinceReferenceDate];
	
	if(_startTime < 0.0)
		_startTime = time;
	time = time - _startTime;
	
	_droppedFrames++;
	NSLog(@"Another frame dropped! Dropped frame per second: %.2f",  _droppedFrames / time  );
	
	
}


#pragma mark *** NSOpenGLView overrides
/*
-(void)prepareOpenGL {
	[lock lock];
	CGLContextObj			cgl_ctx = [[self openGLContext] CGLContextObj]; 
	[[self openGLContext] makeCurrentContext];
	
    glClearColor(0, 0, 0, 1);
    glClearDepth(1);
	
	contextIsInitialized = true;
	
    // load textures here ???
    // (I wrote a texture manager class to do this)
	
//    glEnable(...);
	//[super prepareOpenGL];
	[lock unlock];
}*/
- (void) prepareOpenGL	{
	
	if (_targetOpenGLTexture == nil)	{
		[_targetOpenGLTexture release];		//think that this method is called more than once
		_targetOpenGLTexture = [[OpenGLTexture createTextureWithOpenGLContext: [self openGLContext]
																textureType: GL_TEXTURE_RECTANGLE_EXT] retain];
	}
	[super prepareOpenGL];
}

- (void) update {

	// The NSOpenGLView issues OpenGL calls in its update method. Therefore it is important to lock
    // around this call as it would otherwise run in conflict with our rendering thread

	[lock lock];
	[super update];
	[lock unlock];
	
}



-(void)reshape {
	CGLContextObj			cgl_ctx = [[self openGLContext] CGLContextObj]; 
	
	[lock lock];
	NSRect boundsInPixelUnits = [self convertRectToBase:[self bounds]];
    glViewport(0, 0, boundsInPixelUnits.size.width, boundsInPixelUnits.size.height);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();	
	
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
	[super reshape];
	[lock unlock];

}


-(void)drawRect:(NSRect)rect {

	[lock lock];
	
	CGLContextObj			cgl_ctx = [[self openGLContext] CGLContextObj]; 
	[[self openGLContext] makeCurrentContext];
	
	//Clear background
	glClearColor(0.25, 0.25, 0.25, 1);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
    glLoadIdentity();
	
	
	// draw stuff 
	[_targetOpenGLTexture drawPixelBuffer: [_renderer pixelBuffer] inQuad: _quad];
	
	[self willFlushGLContextObj: cgl_ctx];
	
//    glFlush();
	[[self openGLContext] flushBuffer];
	
    GLenum err = glGetError();
    if (err != GL_NO_ERROR)
        NSLog(@"glGetError(): %d", (int)err);

	[super drawRect:(NSRect)rect];
	
	[lock unlock];

		
	
}


@end

