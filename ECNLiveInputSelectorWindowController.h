//
//  ECNLiveInputSelectorWindowController.h
//  kineto
//
//  Created by Andrea Cremaschi on 18/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@class CameraController;
@class LiveInputSelectorView;

//typedef UVCCameraControlAttributes UVCCameraControlAttributes;

@interface ECNLiveInputSelectorWindowController : NSWindowController {
	IBOutlet LiveInputSelectorView *oQCCaptureView;	
	IBOutlet NSButton	*oBtnSelectThis;
	
	NSArray						*videoDevices;
	NSMutableArray						*_videoResolutions;
	
    //QTCaptureSession			*session;
	//QTCaptureDeviceInput		*videoDeviceInput;
	
	CameraController *_cameraController;
	
	bool _firstFrameReceived;
	// UVC Camera controller settings
	bool _exposureAuto;
	double _exposureLevel;
	bool _wbAuto;
	double _wbLevel;
	double _gainLevel;

	int _frameScaleFactor;
	NSSize _cameraNativeResolution;
	
	
	IBOutlet NSSlider *	oExposureLevel;
	IBOutlet NSSlider *	oWhiteBalanceLevel;
	IBOutlet NSSlider *	oGainLevel;

	IBOutlet NSSlider *	oFrameScaleFactor;

	IBOutlet NSButton *	oKeystoneEnable;
	IBOutlet NSButton *	oFlipImageEnable;

	// get default video stream and exit
	NSTimer *_timeOut;
	BOOL _bGetDefaultCameraAndExit;
	bool _bShouldOpenLiveViewerAndTerminate;
	bool _timedOut;
	bool _bKeystone;
}

+ (ECNLiveInputSelectorWindowController *)sharedECNLiveInputSelectorWindowController;

- (IBAction)selectCurrentLiveInput:(id)sender;
- (IBAction)checkBoxChanged:(id)sender;
- (IBAction)sliderChanged:(id)sender;


// Device selection
- (NSArray *)videoDevices;

- (QTCaptureDevice *)selectedVideoDevice;
- (void)setSelectedVideoDevice:(QTCaptureDevice *)selectedVideoDevice;

// Panel modal invoker
- (CameraController *) configDefaultDeviceInput;
- (CameraController *) configDeviceWithUniqueID: (NSString *)uniqueID;
- (CameraController *) configCameraController: (CameraController *)cameraController;

// Media format summary
- (NSString *)mediaFormatSummary;
- (NSString *)cameraNativeResolution;

@end
