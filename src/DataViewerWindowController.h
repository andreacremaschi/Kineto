//
//  DataViewerWindowController.h
//  kineto
//
//  Created by Andrea Cremaschi on 14/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ECNElement;
@class ECNPort;
@interface DataViewerWindowController : NSWindowController {

	IBOutlet QCView *oQCView;

	// data binding controllers
	IBOutlet NSObjectController * oElementController;
	IBOutlet NSArrayController * oPortsArrayController;
	
	IBOutlet NSComboBox * oObservedPort;
	
	ECNPort *_observedPort;
	NSString *_oldBinding;
	NSDate * _startTime;
}

+ (DataViewerWindowController *)sharedDataViewerWindowController;

@property (retain) id value;

//Accessors
- (void) setElementToObserve: (ECNElement *)element;
- (ECNPort *)selectedPort;

//Start/stop rendering
- (void) startRendering;
- (void) stopRendering;


@end
