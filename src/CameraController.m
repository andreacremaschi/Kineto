//
//  CameraController.m
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 13/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CameraController.h"
#import "QTVisualContextKit.h"
#import "OpenGLQuad.h"
#import "CVImageBuffer.h"

@implementation CameraController

NSString *CCReceivedNewFrameNotification = @"cameraControllerReceivedNewFrame";
NSString *CCDroppedFrameNotification = @"cameraControllerDroppedAFrame";



- (void) dealloc {

	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	@synchronized (self)
    {
        CVBufferRelease(_currentFrame);
        _currentFrame = nil;
    }
	
	[_captureSession release];
	[_captureDeviceInput release];	
	[_captureDevice release];
	[cameraControl release];
	
	
	[super dealloc];
	
}

- (void)closeStream	{
	
	if ([_captureSession isRunning]) {
		

		// remove outputs
		[self delegateForVideoOutput: nil];
		[self setVisualContext: nil];
		
		QTCaptureOutput *output;
		for (output in [_captureSession outputs])
			[_captureSession removeOutput: output];
		
		
		// delete visual context and remove output		
		QTCaptureInput *input;
		for (input in [_captureSession inputs])
			[_captureSession removeInput: input];

	
		[_captureSession stopRunning];
	}
	
	if ((_captureDevice) && ([_captureDevice isOpen]))	{
		[_captureDevice close];
	}
	
}

#pragma mark Setup

- (BOOL)setUpCameraStreamWithCaptureDevice:(QTCaptureDevice*)captureDevice {
	
	BOOL success;
	NSError *error;
	
	// Create the capture session. 
	_captureSession = [[[QTCaptureSession alloc] init] retain];
	
	// Find a video device  
    _captureDevice = captureDevice;
    success = [_captureDevice open:&error];
    
    if (!success) {
        _captureDevice = nil;
        return false;
    }
    
    if (_captureDevice) {
		//Add the video device to the session as a device input
		
		_captureDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:_captureDevice];
		success = [_captureSession addInput:_captureDeviceInput error:&error];
		
		if (!success) {
			// Handle error
			NSLog (@"Add the video device to the session error");
			
			return false;
			
		}
		
		//observe captureDevice and call captureDeviceFormatDescriptionsDidChange when video format changes or is initialized
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureDeviceFormatDescriptionsDidChange:) name:QTCaptureDeviceFormatDescriptionsDidChangeNotification object:_captureDevice ];
		
		// Associate your capture view in the UI with the session and start it running.
		[_captureSession startRunning];
		
		
		// Setup QTCaptureVideoPreviewOutput to get each frame
		
		QTCaptureVideoPreviewOutput *captureVideoPreviewOutput = [[[QTCaptureVideoPreviewOutput alloc] init] autorelease];
		[_captureSession addOutput: captureVideoPreviewOutput error: & error];
		[self delegateForVideoOutput: self];
		
		
		// Setting a lower resolution for the CaptureOutput here, since otherwise QTCaptureView
		// pulls full-res frames from the camera, which is slow. This is just for cosmetics.
		
		/* NSDictionary * pixelBufferAttr = [NSDictionary dictionaryWithObjectsAndKeys:
		 [NSNumber numberWithInt:640], kCVPixelBufferWidthKey,
		 [NSNumber numberWithInt:400], kCVPixelBufferHeightKey, nil];
		 [[[_captureSession outputs] objectAtIndex:0] setPixelBufferAttributes:pixelBufferAttr];*/
		
		// aspect ratio di default, ma dovrebbe essere modificato dal metodo capturedeviceformatdescriptionsdidchange
		//		_cameraAspectRatio=1.33f;
	}	
	return success;
	
} // setUpCameraStreamWithCaptureDevice



- (UVCCameraControl *) setupUVCCameraControl {
	
	// Ok, this might be all kinds of wrong, but it was the only way I found to map a 
	// QTCaptureDevice to a IOKit USB Device. The uniqueID method seems to always(?) return 
	// the locationID as a HEX string in the first few chars, but the format of this string 
	// is not documented anywhere and (knowing Apple) might change sooner or later.
	//
	// In most cases you'd be probably better of using the UVCCameraControls
	// - (id)initWithVendorID:(long) productID:(long) 
	// method instead. I.e. for the Logitech QuickCam9000:
	// cameraControl = [[UVCCameraControl alloc] initWithVendorID:0x046d productID:0x0990];
	//
	// You can use USB Prober (should be in /Developer/Applications/Utilities/USB Prober.app) 
	// to find the values of your camera.
	
	unsigned int locationID = 0;
	sscanf( [[_captureDevice uniqueID] UTF8String], "0x%8x", &locationID );
	
	UVCCameraControl *tempCameraControl = [[[UVCCameraControl alloc] initWithLocationID:locationID] autorelease];
	
	[tempCameraControl setAutoExposure:YES];
	[tempCameraControl setAutoWhiteBalance:YES];
	
	return tempCameraControl;
}

/*
- (QTVisualContextKit *) createVisualContextWithOpenGL: (NSOpenGLContext *)openGLContext
					   withPixelFormat: (NSOpenGLPixelFormat *)pixelFormat	{
	
	
	QTVisualContextKit *visualContext;
	
	// Instantiate a new qt visual context object
	visualContext = [[[QTVisualContextKit alloc] initQTVisualContextWithSize:		_cameraSize
																		type:		kQTOpenGLTextureContext
																	 context:	openGLContext
																 pixelFormat:	pixelFormat] autorelease];
	
	NSLog (@"QT Visual Context created on CGLContext: %i", [openGLContext CGLContextObj]);
	
	// Set the created visual context for each connection of the camera controller
	
	[self setVisualContext: [visualContext context]];
	 
	// init openGL quad to render to
	_quad = [OpenGLQuad quadWithSize: &_cameraSize range:1];
	return visualContext;
}*/


- (void) setVisualContext: 	(QTVisualContextRef) visualContext	{

	
	QTCaptureOutput * captureOutput;
	for (captureOutput in [_captureSession outputs])	{
		NSEnumerator *connectionEnumerator = [[ captureOutput connections] objectEnumerator];
		QTCaptureConnection *connection;
		// iterate over each output connection for the capture session and specify the visual context
		if ([captureOutput isKindOfClass: [QTCaptureVideoPreviewOutput class]])
			while ((connection = [connectionEnumerator nextObject])) {
				[(QTCaptureVideoPreviewOutput *)captureOutput setVisualContext: visualContext
																 forConnection:  connection];
		}		 
	}
}

#pragma mark *** Initialization

- (void) delegateForVideoOutput: (NSObject *) delegate	{
	QTCaptureOutput * captureOutput;
	for (captureOutput in [_captureSession outputs])	{
		// iterate over each output connection for the capture session and specify the visual context
		if ([captureOutput isKindOfClass: [QTCaptureVideoPreviewOutput class]])
			[(QTCaptureVideoPreviewOutput *)captureOutput setDelegate:delegate ];
	}	
}

- (id) initWithQTCaptureDevice: (QTCaptureDevice*)captureDevice	{
	
	self = [super init];
	
	if (self) {

		_bKeystone = false;
		_bFlipImage = false;
		_quad = nil;
		_currentFrame = nil;
		_nativeResolution = NSMakeSize(0,0);
		
		//init camera stream
		if (![self setUpCameraStreamWithCaptureDevice: captureDevice])	{
			NSLog(@"There has been an error initializing the selected capture device.");
			[self release];
			return nil;
		}
		
		// init timer
		/*mFPSCounterTimer = [self initTimer];
		 if (!mFPSCounterTimer) NSLog(@"Error initializing FPS timer counter!");*/
		
		//init camera control
		cameraControl = [[self setupUVCCameraControl] retain];
		if (!cameraControl) NSLog(@"Error initializing UVCCameraControl!");		
	}
	return self;
	
}

#pragma mark Keystone and flip setup

- (void) setKeystone: (bool) keystone	{
	_bKeystone = keystone;
}

- (void) setKeystoneCoordsTopLeftX:	(double)topLeftX
 topLeftY: (double)topLeftY
 topRightX: (double)topRightX
 topRightY: (double)topRightY
 bottomLeftX: (double)bottomLeftX
 bottomLeftY: (double)bottomLeftY
 bottomRightX: (double)bottomRightX 
 bottomRightY: (double)bottomRightY {
 
/* [_quad release];
 
 NSSize theSize = [[_liveInput cameraController] cameraSize];
 _quad = [[OpenGLQuad keyStoneQuadWithSize: &theSize*/
	_topLeft= NSMakePoint (topLeftX, topLeftY) ;
	_topRight= NSMakePoint (topRightX, topRightY) ;
	_bottomRight= NSMakePoint (bottomRightX, bottomRightY);
	_bottomLeft= NSMakePoint (bottomLeftX, bottomLeftY);
/* range:1] retain];
 */
 
 }
 


- (NSPoint) topLeft {
	return _topLeft;
}
- (NSPoint) topRight {
	return _topRight;
}
- (NSPoint) bottomRight	{
	return _bottomRight;
}
- (NSPoint) bottomLeft	{
	return _bottomLeft;
}

- (void) setFlipImage: (bool)flipImage	{
	_bFlipImage=flipImage;	
}

#pragma mark Accessors
- (bool) keystone	{
	return _bKeystone;
}
- (bool) flipImage	{
	return _bFlipImage;
}

- (QTCaptureDevice *)captureDevice {
	return _captureDevice;
}
- (QTCaptureDeviceInput *)captureDeviceInput	{
	return _captureDeviceInput;
}

- (QTCaptureSession *)captureSession	{
	return _captureSession;
}

- (float) aspectRatio {
	NSSize frameSize = [self cameraSize];
	if ((_currentFrame == nil) || (frameSize.height == 0)) return 0.0;
	return frameSize.width / frameSize.height;
}

- (NSSize) cameraSize {
	if (_currentFrame == nil)
		return NSMakeSize (100, 100);
	return NSSizeFromCGSize( CVImageBufferGetEncodedSize(_currentFrame)); 
}

/*- (void)readCameraSizeFromCurrentFrame {

	if (!_currentFrame) return;
	_cameraSize= NSSizeFromCGSize( CVImageBufferGetEncodedSize(_currentFrame)); 
	if (_cameraSize.height != 0) _cameraAspectRatio = _cameraSize.width/_cameraSize.height;

}*/

- (void) setCameraSize: (NSSize) newSize {
	NSDictionary * pixelBufferAttr;
	pixelBufferAttr = [NSDictionary dictionaryWithObjectsAndKeys:
					   [NSNumber numberWithInt:newSize.width], kCVPixelBufferWidthKey,
					   [NSNumber numberWithInt:newSize.height], kCVPixelBufferHeightKey, nil];
	
	QTCaptureOutput * captureOutput;
	for (captureOutput in [_captureSession outputs])	
		// iterate over each output connection for the capture session and specify the visual context
		if ([captureOutput isKindOfClass: [QTCaptureVideoPreviewOutput class]])	
			[(QTCaptureVideoPreviewOutput *)captureOutput setPixelBufferAttributes:pixelBufferAttr];			
		
	
	
		
}
- (NSSize) nativeResolution	{
	return _nativeResolution;
}


- (void) setNativeResolution: (NSSize) newSize	{
	_nativeResolution = NSMakeSize(newSize.width, newSize.height);
}

- (CVBufferRef)  getCurrentFrame {
	
	return _currentFrame;
}


- (NSImage *) createSnapshotNSImage	{
	
	CIImage *ciImage = [CIImage imageWithCVImageBuffer: _currentFrame]; 
	
	NSImage *image = [[[NSImage alloc] initWithSize:
					   NSMakeSize([ciImage extent].size.width,
								  [ciImage extent].size.height)]
					  autorelease];
	[image lockFocus];
	[[[NSGraphicsContext currentContext] CIContext] drawImage: ciImage 
													  atPoint: CGPointMake(0, 0)
													 fromRect: [ciImage extent]];
	/*This appears to be the line that leaks*/
	[image unlockFocus];
	
	return image;
	
}

- (UVCCameraControl *) uvcCameraControl	{
	return cameraControl;
	
}

#pragma mark *** fps count methods ***
/*
- (void) handleTimer: (NSTimer *) timer
{
	// NSLog(@"timer!");
	
	_FPS = fpsCounter;	
	fpsCounter = 0;
	
} // handleTimer


- (NSTimer *) initTimer {
	
	
	
	return [[NSTimer scheduledTimerWithTimeInterval: 2.0
														target: self
													  selector: @selector(handleTimer:)
													  userInfo: nil
													   repeats: YES] retain];	
	
} // initTimer
*/





#pragma mark *** Draw



#pragma mark *** delegate of QTCaptureVideoPreviewOutput ***




/*- (void)captureOutput:(QTCaptureOutput *)captureOutput
  didOutputVideoFrame:(CVImageBufferRef)videoFrame
     withSampleBuffer:(QTSampleBuffer *)sampleBuffer
       fromConnection:(QTCaptureConnection *)connection
{
	// There is no autorelease pool when this method is called because it will
	// be called from another thread it's important to create one or you will 
	// leak objects
	
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	CVImageBuffer *newFrame;
	CVImageBuffer *oldFrame;
	
	// Check for new frame
	
	if (( [_visualContext isValidVisualContext] ) 
		&&	([_visualContext isNewImageAvailable: NULL])) 
	{		
		
		// Get a frame from the visual context, indexed by the provided time
		newFrame = [[[[CVImageBuffer alloc] initWithCVOpenGLTexture: [_visualContext copyImageForTime:NULL]] autorelease] retain];
		
		// If we have a previous frame release it
		if (!_currentFrame) {
			oldFrame = _currentFrame;
			_currentFrame = newFrame;
			[oldFrame release];
		}
		else
		{	if ([_currentFrame isLocked])
			{
				if (_newFrame)
				{	[_newFrame release];
					[[NSNotificationCenter defaultCenter] postNotificationName:CCDroppedFrameNotification object:self];
				}
				_newFrame = newFrame;

			}
			else {
				// _currentFrame mai preso in carica!					
				
				oldFrame = _currentFrame;
				_currentFrame = newFrame;
				[oldFrame release];
				//[[NSNotificationCenter defaultCenter] postNotificationName:CCDroppedFrameNotification object:self];
			}

		}

	} // if
	

    [pool release];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:CCReceivedNewFrameNotification object:self];

	return;
} // captureOutput*/

- (void)copyCurrentFrameToBuffer:(void *)buffer
{
    CVImageBufferRef imageBuffer;
   // mtime_t pts;
	
    if(!_currentFrame)
        return;
	
    @synchronized (self)
    {
        imageBuffer = CVBufferRetain(_currentFrame);
      //  pts = previousPts = currentPts;
		
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        void * pixels = CVPixelBufferGetBaseAddress(imageBuffer);
        memcpy( buffer, pixels, CVPixelBufferGetBytesPerRow(imageBuffer) * CVPixelBufferGetHeight(imageBuffer) );
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    }
	
    CVBufferRelease(imageBuffer);
	
    return;
}

/*
 //
 //  TFQTKitCapture.m
 //  Touché
 //
 //  Created by Georg Kaindl on 4/1/08.
 //
 //  Copyright (C) 2008 Georg Kaindl
 
 - (void)captureOutput:(QTCaptureOutput*)captureOutput
  didOutputVideoFrame:(CVImageBufferRef)videoFrame 
	 withSampleBuffer:(QTSampleBuffer *)sampleBuffer 
	   fromConnection:(QTCaptureConnection *)connection
{
	uint64_t ht = CVGetCurrentHostTime(), iht = [[sampleBuffer attributeForKey:QTSampleBufferHostTimeAttribute] unsignedLongLongValue];
	double freq = CVGetHostClockFrequency(), hts = ht/freq, ihts = iht/freq;
	
	// If the frame latency has grown larger than the cutoff threshold, we drop the frame. 
	if (hts > ihts + framedropLatencyThreshold)
		return;
	
	TFPMStartTimer(TFPerformanceTimerCIImageAcquisition);
	
	if (_delegateCapabilities.hasDidCaptureFrame) {
		CVPixelBufferRef pixelBuffer = videoFrame;
        
		if (TFQTKitCaptureFormatConversionNone != self->_formatConversion)
			pixelBuffer = [self _formatConvertImageBuffer:videoFrame];
        
		CIImage* image = nil;
		
		if (_delegateCapabilities.hasWantedCIImageColorSpace) {
			id colorSpace = (id)[delegate wantedCIImageColorSpaceForCapture:self];
			if (nil == colorSpace)
				colorSpace = [NSNull null];
			
			image = [CIImage imageWithCVImageBuffer:pixelBuffer
											options:[NSDictionary dictionaryWithObject:colorSpace
																				forKey:kCIImageColorSpace]];
		} else
			image = [CIImage imageWithCVImageBuffer:pixelBuffer];
		
		if (TFQTKitCaptureFormatConversionNone != self->_formatConversion)
			image = [self _formatConvertCIImage:image];
		
		[_frameQueue enqueue:image];
		
		if (TFQTKitCaptureFormatConversionNone != self->_formatConversion)
			CVPixelBufferRelease(pixelBuffer);
	}
	
	TFPMStopTimer(TFPerformanceTimerCIImageAcquisition);
}

*/
- (void)captureOutput:(QTCaptureOutput *)captureOutput
  didOutputVideoFrame:(CVImageBufferRef)videoFrame
     withSampleBuffer:(QTSampleBuffer *)sampleBuffer
       fromConnection:(QTCaptureConnection *)connection
{
	
	// There is no autorelease pool when this method is called because it will
	// be called from another thread it's important to create one or you will 
	// leak objects
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	CVImageBufferRef oldFrame = nil;


	// Check for new frame
	

	@synchronized (self) {	
		
		oldFrame = _currentFrame;

/*		if ((_visualContext!= nil) && ( [_visualContext isValidVisualContext] )) {
			if ([_visualContext isNewImageAvailable: NULL]) 
					_currentFrame = [_visualContext copyImageForTime:NULL];
			else { 
				[pool release]; 
				return;
			}
		}
		else
		{*/
			CVBufferRetain(videoFrame);
			_currentFrame = videoFrame;
			NSLog(@"retaining videoframe");
//		}
	
		if (oldFrame!=nil)	{
			CVBufferRelease(oldFrame);
		}
	
		[[NSNotificationCenter defaultCenter] postNotificationName:CCReceivedNewFrameNotification object:self];
		[pool release];
	//	NSLog(@"new frame! CVBufferRef: %i", _currentFrame);
	}
	return;
} // captureOutput


- (void) captureDeviceFormatDescriptionsDidChange:(NSNotification*)notification
{
	//get the new formatDescriptions from the inputdevice.
	NSArray * formatArray = [_captureDevice formatDescriptions];
	NSEnumerator *enumerator = [formatArray objectEnumerator];
	id anObject;
	NSSize newSize;
	float newAspectRatio = 1.0;
	
	while (anObject = [enumerator nextObject])
	{
		QTFormatDescription* format = (QTFormatDescription*)anObject;
		newSize = [[format attributeForKey:(id)QTFormatDescriptionVideoCleanApertureDisplaySizeAttribute] sizeValue];
		
		// mah e adesso la dimensione del video va presa dall'ultimo descrittore e basta? speriamo.
		_cameraSize.width = newSize.width;
		_cameraSize.height = newSize.height;
		if (_cameraSize.height != 0) newAspectRatio = _cameraSize.width/_cameraSize.height;
		NSLog(@"camera is %f wide and %f tall", _cameraSize.width, _cameraSize.height);

	}
	
//	[[NSNotificationCenter defaultCenter] postNotificationName:CCDeviceFormatDescriptionDidChange object:self];
	
	if ((_nativeResolution.width == 0) || (_nativeResolution.height == 0))
			[self setNativeResolution: NSMakeSize(_cameraSize.width, _cameraSize.height)];
		
//	NSLog(@"camera is %f wide and %f tall", _cameraSize.width, _cameraSize.height);
	_cameraAspectRatio =	newAspectRatio;


}

@end
