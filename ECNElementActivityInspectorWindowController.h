//
//  ECNElementActivityInspectorWindowController.h
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 18/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ElementsView;

@interface ECNActivityIndicator: NSView {
	float _activity;
	float _triggerThreshold;
}

- (void) setActivity: (float) activity Threshold: (float) triggerThreshold;

@end

@interface ECNElementActivityInspectorWindowController : NSWindowController {
    @private
	IBOutlet NSTextField*	elementNameLabel;
	IBOutlet NSTextField*	activityLabel;
	IBOutlet ECNActivityIndicator *		activityIndicator;

	ElementsView *_inspectingElementsView;
    BOOL needsUpdate;
	
	
	
}
+ (ECNElementActivityInspectorWindowController *) sharedECNElementActivityInspectorWindowController;

- (void) updateActivityLevels;

@end
