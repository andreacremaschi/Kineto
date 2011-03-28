//
//  ECNDrawingToolbar.m
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 21/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ECNDrawingToolbar.h"
#import "SynthesizeSingleton.h"
#import "ECNLine.h"
#import "ECNRectangle.h"
#import "ECNOSCTarget.h"
#import "ECNOSCReceiver.h"

enum {
    ECNArrowToolRow = 0,
    ECNLineToolRow,
	ECNRectToolRow,
    ECNTimerToolRow,
    ECNOSCToolRow,
};


NSString *ECNSelectedToolDidChangeNotification = @"ECNSelectedToolDidChange";


@implementation ECNDrawingToolbarController
SYNTHESIZE_SINGLETON_FOR_CLASS(ECNDrawingToolbarController);


- (id)init {
	
	if (![self initWithWindowNibName: @"DrawingToolbar"])
	{
		NSLog(@"Could not init DrawingToolbar!");
	}
	

    //[[self window] makeKeyAndOrderFront:nil];
	
    return self;
}

- (void)showOrHideWindow {
	
    // Simple.
    NSWindow *window = [self window];
    if ([window isVisible]) {
		[window orderOut:self];
    } else {
		[self showWindow:self];
    }
	
}


- (void)windowDidLoad {
	
/*	BOOL success;
	NSError *error;*/
	
	[super windowDidLoad];
	
	
}

- (void)selectArrowTool {
    [toolButtons selectCellAtRow:ECNArrowToolRow column:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:ECNSelectedToolDidChangeNotification object:self];
}

- (Class)currentElementClass {
    int row = [toolButtons selectedRow];
    Class theClass = nil;
    if (row == ECNLineToolRow) {
        theClass = [ECNLine class];
    } else if (row == ECNRectToolRow) {
        theClass = [ECNRectangle class];
    } else if (row == ECNOSCToolRow) {
		theClass = [ECNOSCReceiver class];
	}
	return theClass;
}

- (NSColor *)currentColor
{
	return [colorWell color];
}


- (IBAction)selectToolAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:ECNSelectedToolDidChangeNotification object:self];
}

@end
