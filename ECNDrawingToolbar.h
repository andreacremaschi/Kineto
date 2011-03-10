//
//  ECNDrawingToolbar.h
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 21/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ECNDrawingToolbarController : NSWindowController {
    IBOutlet NSMatrix *toolButtons;
    IBOutlet NSColorWell *colorWell;
}

+ (ECNDrawingToolbarController *) sharedECNDrawingToolbarController;

- (IBAction)selectToolAction:(id)sender;

- (Class)currentElementClass;
- (NSColor *)currentColor;

- (void)showOrHideWindow;

- (void)selectArrowTool;

extern NSString *ECNSelectedToolDidChangeNotification;


@end
