//
//  ECNLiveViewerController.h
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 20/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#pragma once

#import <Cocoa/Cocoa.h>

@class ECNLiveView;
@class CameraController;

extern NSString *ECNBackgroundDidChangeNotification;
extern NSString *MasksHasBeenUpdatedNotification;

@interface ECNLiveViewerController : NSWindowController <NSTableViewDataSource> {
	
	IBOutlet ECNLiveView* liveView;
	
	// masks tab
	IBOutlet NSSlider* oDiffBGThreshold;	
	IBOutlet NSSlider* oMotionMaskThreshold;
	IBOutlet NSSlider* oMotionMaskPersistence;
	IBOutlet NSTextField * txtDiffBGThreshold;
	IBOutlet NSTextField * txtMotionMaskThreshold;	
	IBOutlet NSTextField * txtMotionMaskPersistence;
	
	IBOutlet NSTableView * oKinetoLayersTableView;
	int _currentlyModifyingLayer;


	bool _bIsWindowResizing;
	
	float liveInputAspectRatio;

	
	NSString *_deviceInputUniqueID;

}


+ (ECNLiveViewerController *)sharedECNLiveViewerController;
		
- (void) setCameraController: (CameraController *)cameraController;


// tab 1
- (IBAction) openLiveInputSelectorModal: (id)sender;
- (IBAction) catturaSfondo: (id)sender;
- (IBAction) setDiffBGThreshold: (NSSlider *)sender;
- (IBAction) setMotionMaskThreshold: (NSSlider *)sender;
- (IBAction) setMotionMaskPersistence: (NSSlider *)sender;

// Appearence accessors
- (NSImage *)getBackground;
- (float) getRenderAspectRatio;


// Playback accessors
- (NSOpenGLContext *) openGLContext;

// mask data
/*- (CIImage*)diffMask;
- (	CIImage*)motionMask;*/
- (	CIImage*)cimask;
- (	CIImage*)videoframe;
- (CIContext *)CIContext;

@end

/*

@interface ECNMaskVisualizer : NSObject {
	NSMutableArray *grid;
	OfflineRenderer *_renderer;
	
	unsigned _gridWidth, _gridHeight;
	unsigned _threshold;

	unsigned char *_visMatrix;
	NSColor * _color;

	// TODO perché un puntatore?
	bool _bNeedsToBeUpdated;

	unsigned _newGranularity;
	unsigned _newThreshold;
}

- (ECNMaskVisualizer*)	initWithRenderer: (OfflineRenderer *)renderer TextureWidth: (unsigned) width textureHeight: (unsigned) height openGLContext: (NSOpenGLContext *) openGLContext  threshold: (float) threshold;
- (BOOL) updateTextureForTime:(NSTimeInterval)time;
- (void) drawInOpenGLContext: (NSOpenGLContext *)openGLContext;
- (void) drawGridInOpenGLContext: (NSOpenGLContext *)openGLContext;
- (void) setColor: (NSColor *)color;
- (void) setGranularity: (unsigned) granularity;
- (void) setThreshold: (float) threshold;

@end
 
 */
