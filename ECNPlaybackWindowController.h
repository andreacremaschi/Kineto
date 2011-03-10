//
//  ECNPlaybackWindowController.h
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 05/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class ECNScene;
@class ECNProjectDocument;
@class OSCManager;
@class ECNActivityInspectorScrollView;

enum {
    kECNPlayEntireDocument = 0,
    kECNPause,
	kECNStop,
	kECNTestMode
	
};

#define kPlaybackFPS 30

extern NSString *PlaybackNewFrameHasBeenProcessedNotification;

@interface ECNPlaybackWindowController : NSWindowController {

	IBOutlet NSMatrix* mPlaybackSelectorMatrix;
	IBOutlet NSBox* _controlsBox;
	unsigned char _mPlaybackState;
	bool _mBMasksDidChange;
	
	ECNProjectDocument *_curProjectDocument;
	ECNScene *_curScene;
	
	NSTimer *	_playbackTimer;
	NSDate *_startTime;
	// activity inspector scrollview
//	IBOutlet ECNActivityInspectorScrollView * oScrollViewActivityInspector;
	
	NSSet * _activeElementsSet;
	bool _activeElementsSetShouldUpdate;

	OSCManager *_OSCManager;

	NSBitmapImageRep *_onePixelBitmap;
	NSGraphicsContext *_onePixelContext;
	CIFilter *_areaAverageFilter;
}

+ (ECNPlaybackWindowController *)sharedECNPlaybackWindowController;
- (void)showOrHideWindow;


// --- NIB interface
- (IBAction) changePlaybackState: (id)sender;
- (IBAction) toggleActivityInspectorScrollview: (id)sender;

// --- Playback methods
- (void) drawPlaybackElements;


@end
