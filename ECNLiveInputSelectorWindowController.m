//
//  ECNLiveInputSelectorWindowController.m
//  kineto
//
//  Created by Andrea Cremaschi on 18/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "SynthesizeSingleton.h"
#import <QTKit/QTKit.h>

#import "ECNLiveInputSelectorWindowController.h"
#import "ECNLiveViewerController.h"
#import "CameraController.h"
#import "LiveInputSelectorView.h"
#import "LiveInputRenderer.h"

#import "UVCCameraControl.h"

@implementation ECNLiveInputSelectorWindowController
SYNTHESIZE_SINGLETON_FOR_CLASS(ECNLiveInputSelectorWindowController);

- (id) init {
	
	if (![self initWithWindowNibName: @"LiveInputSelector"])
	{

		NSLog(@"Could not init Live input selector!");
		return nil;
	}
	_timedOut=false;
	_cameraController = nil;
	return self;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[videoDevices release];
	videoDevices=nil;
	[_videoResolutions release];
	_videoResolutions=nil;
	
	if (_cameraController != nil) [_cameraController release];
	[super dealloc];
	
}

- (void) startObservingDevices {
		
	[self enableControls: false];
	
	// Register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(devicesDidChange:) name:QTCaptureDeviceWasConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(devicesDidChange:) name:QTCaptureDeviceWasDisconnectedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionFormatWillChange:) name:QTCaptureConnectionFormatDescriptionWillChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionFormatDidChange:) name:QTCaptureConnectionFormatDescriptionDidChangeNotification object:nil];
	
}

- (void) stopObservingDevices {

	[[NSNotificationCenter defaultCenter] removeObserver:self  name: CCReceivedNewFrameNotification object: _cameraController];
	

	if (videoDevices != nil) {
		[videoDevices release];
		videoDevices=nil;
	}	
}



- (NSDictionary *) videoResolutionDictWithName: (NSString *)dictName
									 withWidth: (int)width
									withHeight: (int)height{
	
	
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInt:width], kCVPixelBufferWidthKey,
						  [NSNumber numberWithInt:height], kCVPixelBufferHeightKey, 
						  dictName, @"resolutionDescription",
						  nil];
	return dict;
	
}


- (void) windowDidLoad	{
	
	_videoResolutions = [[[NSMutableArray alloc] init] retain];
	
	[_videoResolutions addObject: [self videoResolutionDictWithName: @"640 x 480" 
														 withWidth: 640 
														withHeight: 480]];
	[_videoResolutions addObject: [self videoResolutionDictWithName: @"1280 x 800" 
														 withWidth: 1280 
														withHeight: 800]];
	[_videoResolutions addObject: [self videoResolutionDictWithName: @"320 x 240" 
														 withWidth: 320 
														withHeight: 240]];

	
	[super windowDidLoad];

}



- (NSArray *)videoResolutions	{

	return _videoResolutions;
}

- (void)windowWillClose:(NSNotification *)notification
{
	// Close open device
	[self setSelectedVideoDevice:nil];
	
}


#pragma mark Observing

- (void)selectedLiveReceivedFirstFrame:(NSNotification *)notification {

	//only the first frame will invoke this method!
	[[NSNotificationCenter defaultCenter] removeObserver:self  name: CCReceivedNewFrameNotification object: _cameraController];

	_timedOut = false;
	/*if ([[[oQCCaptureView liveInput] cameraController] nativeResolution].width == 0)
		[self refreshNativeResolution];*/
	
	if (_bGetDefaultCameraAndExit)	{
		_bShouldOpenLiveViewerAndTerminate = true;
	}
	else { 
		_firstFrameReceived = true;
		[self loadUVCCameraControlsDefaults];
		[self setUVCCameraControlsToCameraData ];
		[self willChangeValueForKey:@"currentFrameSize"];
		[self didChangeValueForKey:@"currentFrameSize"];

	}
}
#pragma mark Media format summary

- (NSString *)cameraNativeResolution
{
	NSSize nativeResolution = [[[oQCCaptureView liveInput] cameraController] nativeResolution];
	return [NSString stringWithFormat:@"%.f x %.f", nativeResolution.width, nativeResolution.height];
	
}

- (NSString *)currentFrameSize
{
	CameraController * cameraController;
	if (_cameraController)	{
		cameraController = _cameraController;
	}
	else {
		cameraController = [[oQCCaptureView liveInput] cameraController];
	}

	if (cameraController == nil) return @"no camera selected";

	return [NSString stringWithFormat:@"%.f x %.f", [cameraController cameraSize].width, [cameraController cameraSize].height];
	
}

- (int) frameScaleFactor	{
	
	return _frameScaleFactor;
}

- (NSString *)mediaFormatSummary
{
	if (!_cameraController)
		return nil;
	if (![_cameraController captureDeviceInput])
		return nil;
	
	NSMutableString *mediaFormatSummary = [NSMutableString stringWithCapacity:0];
	
	NSEnumerator *videoConnectionEnumerator = [[[_cameraController captureDeviceInput] connections] objectEnumerator];
	QTCaptureConnection *videoConnection;
	while ((videoConnection = [videoConnectionEnumerator nextObject])) {
		[mediaFormatSummary appendString:[[videoConnection formatDescription] localizedFormatSummary]];
		[mediaFormatSummary appendString:@"\n"];
	}
	

	
	return mediaFormatSummary;
}


- (void)connectionFormatWillChange:(NSNotification *)notification
{
	id owner = [[notification object] owner];
	if (owner == [_cameraController captureDeviceInput])  {
		[self willChangeValueForKey:@"mediaFormatSummary"];
	}
	
}

- (void)connectionFormatDidChange:(NSNotification *)notification
{
	id owner = [[notification object] owner];
	if (owner == [_cameraController captureDeviceInput ])  {
		[self didChangeValueForKey:@"mediaFormatSummary"];
	}
			
}


#pragma mark UVC Controls

-(void) setUVCCameraControlsToCameraData	{
	
	UVCCameraControl * uvcCameraControl = [[[oQCCaptureView liveInput] cameraController] uvcCameraControl];
	
	_exposureAuto = [uvcCameraControl getAutoExposure];

	[self willChangeValueForKey:@"_exposureLevel"];
	_exposureLevel = 1- [uvcCameraControl getExposure];
	[self didChangeValueForKey:@"_exposureLevel"];
	
	_wbAuto = [uvcCameraControl getAutoWhiteBalance];

	[self willChangeValueForKey:@"_wbLevel"];
	_wbLevel=[uvcCameraControl getWhiteBalance];
	[self didChangeValueForKey:@"_wbLevel"];

//	[oWhiteBalanceLevel setFloatValue: [uvcCameraControl getWhiteBalance]];
	//_wbLevel = [uvcCameraControl getWhiteBalance];
	[self willChangeValueForKey:@"_gainLevel"];
	_gainLevel=[uvcCameraControl getGain];
	[self didChangeValueForKey:@"_gainLevel"];
	
	
	
}

- (void) loadUVCCameraControlsDefaults {

	UVCCameraControl * uvcCameraControl = [[[oQCCaptureView liveInput] cameraController] uvcCameraControl];
	
	[uvcCameraControl setAutoExposure: false];
	[uvcCameraControl setWhiteBalance: false];
}


#pragma mark Device selection


- (void)refreshDevices
{
	[self willChangeValueForKey:@"videoDevices"];
	[videoDevices release];
	
	videoDevices = [[[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo] arrayByAddingObjectsFromArray:[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeMuxed]] retain];
	[self didChangeValueForKey:@"videoDevices"];
	
	if (![videoDevices containsObject:[self selectedVideoDevice]]) {
		[self setSelectedVideoDevice:nil];
	}
	

}

- (void)devicesDidChange:(NSNotification *)notification
{
	[self refreshDevices];
}

- (NSArray *)videoDevices
{
	if (!videoDevices)
		[self refreshDevices];
	
	return videoDevices;
}


- (QTCaptureDevice *)selectedVideoDevice
{
	return [_cameraController captureDevice];
}

- (void) enableControls: (bool) enable	{
	
	[oBtnSelectThis setEnabled: enable];
	[oFrameScaleFactor setEnabled: enable];
}

- (void) setCameraScaleFactor: (int) frameScaleFactor {
	
	int nStep = [oFrameScaleFactor maxValue]; // numberoftickmarks returns strange values
	//float nativeResAspectRatio = _cameraNativeResolution.width / _cameraNativeResolution.height; 
	float stepWidth = ([[[oQCCaptureView liveInput] cameraController] nativeResolution].width - 320) / nStep;
	float stepHeight = ([[[oQCCaptureView liveInput] cameraController] nativeResolution].height - 200) / nStep ;
	
	NSSize newSize = NSMakeSize((nStep -frameScaleFactor)* stepWidth + 320,
								(nStep-frameScaleFactor) * stepHeight + 200);
	NSLog( @"Trying to set resolution: %.f x %.f (with a step of %.fx%.f)", newSize.width, newSize.height, stepWidth, stepHeight);
	
	[oQCCaptureView stopRendering];
	_cameraController = [[oQCCaptureView releaseCameraController] retain];
	
	_firstFrameReceived = false;
	[self enableControls: false];
	
	[_cameraController setCameraSize: newSize];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedLiveReceivedFirstFrame:) name:CCReceivedNewFrameNotification object: _cameraController];

}

- (void)setSelectedVideoDevice:(QTCaptureDevice *)selectedVideoDevice
{
	NSError *error = nil;

	@synchronized (self) {
	//if (videoDeviceInput) {


		[oQCCaptureView stopRendering];
		CameraController *cameraController = [oQCCaptureView releaseCameraController];
		[cameraController closeStream];

		if (selectedVideoDevice)	{
			_firstFrameReceived = false;
		
			[self enableControls: false];
			_cameraController = [[CameraController alloc] initWithQTCaptureDevice: selectedVideoDevice]; 
			if (_cameraController == nil)	{
			
				[[NSAlert alertWithError:error] beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
				//todo: free resources
				return;
			}

			[self willChangeValueForKey:@"frameScaleFactor"];
			_frameScaleFactor = 0;
			[self didChangeValueForKey:@"frameScaleFactor"];
			
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedLiveReceivedFirstFrame:) name:CCReceivedNewFrameNotification object: _cameraController];

		}
	}

}





#pragma mark ** UI events
- (IBAction)selectCurrentLiveInput:(id)sender	{
	

	[oQCCaptureView stopRendering];
	_cameraController = [oQCCaptureView releaseCameraController];
	_bShouldOpenLiveViewerAndTerminate = true;

	
}

- (IBAction)checkBoxChanged:(id)sender	{
	UVCCameraControl * uvcCameraControl = [[[oQCCaptureView liveInput] cameraController] uvcCameraControl];
	
	if( [sender isEqualTo:oKeystoneEnable] ) {		
		[oQCCaptureView setKeystoneEnabled: [sender state]== NSOnState];
	}
	else if( [sender isEqualTo:oFlipImageEnable] ) {		
		[oQCCaptureView setFlipEnabled: [sender state]== NSOnState];
	} else {
		[uvcCameraControl setAutoExposure: _exposureAuto];
		[uvcCameraControl setAutoWhiteBalance: _wbAuto];
	}

	

		
}


- (IBAction)sliderChanged:(id)sender	{

	if (sender == oFrameScaleFactor)	{
		
		[self setCameraScaleFactor: _frameScaleFactor];
	
	}
	else	{
		UVCCameraControl * uvcCameraControl = [[[oQCCaptureView liveInput] cameraController] uvcCameraControl];

		[uvcCameraControl setExposure: 1- _exposureLevel];
		[uvcCameraControl setWhiteBalance: _wbLevel];		
		[uvcCameraControl setGain: _gainLevel];
	}
}


- (void) goModal {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	
	NSModalSession modalSession = [NSApp beginModalSessionForWindow: [self window]];
	NSUInteger result;
	for (;;) {
		NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
		
		result = [NSApp runModalSession:modalSession];
		if (result != NSRunContinuesResponse)
			break;
		if (_bShouldOpenLiveViewerAndTerminate) break;
		if ((_timedOut) && (_bGetDefaultCameraAndExit)) break;

		if ((_firstFrameReceived) && (!_bShouldOpenLiveViewerAndTerminate)) {
			_firstFrameReceived = false;

			NSLog(@"    ### LIVEINPUTSELECTOR: a new camera has been selected: setup ###");
			
			[self willChangeValueForKey:@"cameraNativeResolution"];
			[oQCCaptureView hookToCameraController: _cameraController];	
			[self didChangeValueForKey:@"cameraNativeResolution"];
			[oQCCaptureView startRendering];
			[_cameraController release];
			_cameraController = nil;
			[self enableControls: true];
		}
		
		[loopPool drain];
	}
	
	[NSApp endModalSession:modalSession];
	
	if (_timedOut)	{
		[NSApp runModalForWindow: [self window]];
	}
	else	{
		[self stopObservingDevices];
		[[self window] close];
	}
	
	// Do whatever cleanup is needed. (This is here primarly for LiveInputRenderer
	[pool drain];
	
}

#pragma mark Panel Loader methods



- (void) _setupDefaultDeviceInputWatchDog: (NSTimer *) timer	{
	_timedOut = true;
}

- (CameraController *) configDefaultDeviceInput	{
	
	_bGetDefaultCameraAndExit = true;
	
	//watchdog: if in 5 seconds no camera is setup, open a dialog window!
	_timeOut = [[NSTimer scheduledTimerWithTimeInterval: 5.0
									target: self
									selector: @selector(_setupDefaultDeviceInputWatchDog:)
									userInfo: nil
									repeats: NO] retain];	
		
	[self startObservingDevices];
	
	// Select devices if any exist
	NSArray *myVideoDevices = [self videoDevices];
	if ([myVideoDevices count] > 0) {
		[self setSelectedVideoDevice:[myVideoDevices objectAtIndex:0]];
	}
	_firstFrameReceived = false;
	[self goModal];
	
	NSLog(@"### LiveInputSelector panel will close! ###");
	return [_cameraController autorelease];
}


- (CameraController *) configCameraController: (CameraController *)cameraController	{
	
	
	[self startObservingDevices];
	
	_bGetDefaultCameraAndExit = false;
	_bShouldOpenLiveViewerAndTerminate=false;
	
	_timeOut = nil;
	_timedOut = false;
	
	// Select devices in devices list
	/*NSArray *myVideoDevices = [self videoDevices];
	
	QTCaptureDevice *device;
	
	for (device in myVideoDevices)
		if ([device uniqueID] == uniqueID) 
			[self setSelectedVideoDevice: device];*/
	
	
	if (cameraController == nil)	{
		// manage unexpected situation!
		return nil;
	}
	else	{
		_cameraController = [cameraController retain];
		_firstFrameReceived = true;
		
	}
/*	_cameraNativeResolution = NSMakeSize(0,0);
	
	[self willChangeValueForKey:@"frameScaleFactor"];
	_frameScaleFactor = 0;
	[self didChangeValueForKey:@"frameScaleFactor"];
*/	
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedLiveReceivedFirstFrame:) name:CCReceivedNewFrameNotification object: _cameraController];
	
	
	
	
	
	[self goModal];
	
	NSLog(@"### LiveInputSelector panel will close! ###");
	return [_cameraController autorelease];
	
}

- (CameraController *) configDeviceWithUniqueID: (NSString *)uniqueID {

		
	[self startObservingDevices];
	
	_bGetDefaultCameraAndExit = false;
	_bShouldOpenLiveViewerAndTerminate=false;
	
	_timeOut = nil;
	
	// Select devices if any exist
	NSArray *myVideoDevices = [self videoDevices];
	
	QTCaptureDevice *device;
	
	for (device in myVideoDevices)
		if ([device uniqueID] == uniqueID) 
			[self setSelectedVideoDevice: device];
	
	_firstFrameReceived = false;
	[self goModal];

	NSLog(@"### LiveInputSelector panel will close! ###");
	return [_cameraController autorelease];
}

@end
