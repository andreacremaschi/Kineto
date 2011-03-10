//
//  LiveInputSelectorView.h
//  kineto
//
//  Created by Andrea Cremaschi on 25/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "OpenGLViewKit.h"

@class CameraController;
@class LiveInputRenderer;
@class OpenGLQuad;
@class OpenGLTexture;
@class QCMaskRenderer;

extern NSString *NewFrameHasBeenProcessedNotification;
extern NSString *FramerateHasChangedNotification;

@interface CameraControllerInQCMaskRendererView : NSOpenGLView			{

@private	
	
	NSTimer *_renderTimer;
	NSTimeInterval _startTime;
	
	LiveInputRenderer *_liveInputRenderer;
	QCMaskRenderer		* _renderer;	

	OpenGLQuad *_quad;
	OpenGLTexture *_targetOpenGLTexture;
	
	// flags
	bool _bShouldRelease;
	bool _bAsynchronousMode;
	bool bHasReceivedNewFrame;

	int _fpsCounter, _droppedFrames;
	NSTimeInterval _FPSCounterLastReset;
	float  _FPS;
	
	NSRecursiveLock          *lock;
	
	//mouse event handling variables (should stay in a NSOpenGLView superclass!)
	bool _bLeftButtonDown;
	float _curMousePositionX, _curMousePositionY;
	float _aspectRatio;
}

//Accessors
- (QCRenderer *)renderer;
- (LiveInputRenderer *)liveInput;
- (float) FPS;

- (void) hookToCameraController: (CameraController*)cameraController;
- (CameraController *) releaseCameraController;
- (void) startRendering;
- (void) stopRendering;


// methods to override
- (NSString *) qcPatchName;
- (void) prepareRenderingWithFrame: (CVImageBufferRef) currentFrame;
- (void) willFlushGLContextObj: (CGLContextObj) cgl_ctx;

// mouse events accessors
- (bool) isLeftButtonDown;
- (NSPoint) curMousePos;

@end
