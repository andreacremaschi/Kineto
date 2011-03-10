//
//  CameraController.h
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 13/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import <QuickTime/QuickTime.h>


#import "UVCCameraControl.h"


extern NSString *CCReceivedNewFrameNotification;
extern NSString *CCDroppedFrameNotification;

@class QTVisualContextKit;
@class OpenGLQuad;
@class CVImageBuffer;
@interface CameraController : UVCCameraControl {

	// QTKit classes
	QTCaptureDevice *_captureDevice;
	QTCaptureSession *_captureSession;
	QTCaptureDeviceInput *_captureDeviceInput;
//	QTCaptureVideoPreviewOutput *_mCaptureVideoPreviewOutput;
	
	CVBufferRef _currentFrame;	

	//CVImageBufferRef * _newFrame;	
	
	//QTVisualContextKit       *_visualContext;
	OpenGLQuad	*_quad;
	
	// controller openGL!!!!
	/*NSOpenGLContext     *_mSharedOpenGLContext;
	NSOpenGLPixelFormat *_mPixelFormat;*/
	
	// camera settings...
	UVCCameraControl * cameraControl;
	
	//FPS counter
	int fpsCounter;
	NSTimer *mFPSCounterTimer;
	int _FPS;
	
	bool _bKeystone;
	bool _bFlipImage;
	NSSize _cameraSize;
	NSSize _nativeResolution;
	float _cameraAspectRatio;

	NSPoint _topLeft;
	NSPoint _topRight ;
	NSPoint _bottomRight; 
	NSPoint _bottomLeft;
	
}

// init
- (id) initWithQTCaptureDevice: (QTCaptureDevice*)captureDevice;
- (void)closeStream;

//keystone and flip setup
- (void) setKeystoneCoordsTopLeftX:	(double)topLeftX
						  topLeftY: (double)topLeftY
						 topRightX: (double)topRightX
						 topRightY: (double)topRightY
					   bottomLeftX: (double)bottomLeftX
					   bottomLeftY: (double)bottomLeftY
					  bottomRightX: (double)bottomRightX 
					  bottomRightY: (double)bottomRightY;
- (NSPoint) topLeft ;
- (NSPoint) topRight ;
- (NSPoint) bottomRight; 
- (NSPoint) bottomLeft;



- (void) setKeystone: (bool) keystone;
- (void) setFlipImage: (bool)flipImage;

// Accessors
- (float) aspectRatio;
- (NSSize) cameraSize;
- (NSSize) nativeResolution;
- (bool) keystone;
- (bool) flipImage;

- (QTCaptureDevice *)captureDevice;
- (QTCaptureDeviceInput *)captureDeviceInput;
- (QTCaptureSession *)captureSession;


- (void) setCameraSize: (NSSize) newSize;
- (NSSize) setNativeResolution: (NSSize) newSize;;

//- (void) readCameraSizeFromCurrentFrame;  

- (int) getFPS;
- (CVOpenGLTextureRef)  getCurrentFrame;
- (NSImage *) createSnapshotNSImage;

- (void) setVisualContext: 	(QTVisualContextRef) visualContext;
- (QTVisualContextKit *) createVisualContextWithOpenGL: (NSOpenGLContext *)openGLContext
					   withPixelFormat: (NSOpenGLPixelFormat *)pixelFormat;

- (void)copyCurrentFrameToBuffer:(void *)buffer;

//- (void) releaseVisualContext;

- (void) delegateForVideoOutput: (NSObject *)delegate;

- (UVCCameraControl *) uvcCameraControl;

@end
