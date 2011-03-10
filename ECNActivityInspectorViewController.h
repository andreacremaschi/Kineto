//
//  ECNActivityInspector.h
//  kineto
//
//  Created by Andrea Cremaschi on 12/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ECNElement;
@interface ECNActivityInspectorViewController : NSViewController {
	ECNElement *_element;
	IBOutlet NSTextField *		oTxtElementName;
	IBOutlet NSTextField*		oActivityLabel;
	IBOutlet NSLevelIndicator *	oActivityIndicator;
	IBOutlet NSButton *			oIsLocked;
}

+ (ECNActivityInspectorViewController *) initWithElement: (ECNElement *)element;
- (ECNElement *)element;
- (void) resetControls;
- (void) updateActivityLevels;

- (bool) isLocked;

@end
