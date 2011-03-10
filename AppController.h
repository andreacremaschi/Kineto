//
//  AppController.h
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 18/10/10.
//  Copyright __MyCompanyName__ 2010 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ElementsView.h>

@interface AppController : NSObject
{
	IBOutlet NSWindow* oSplashWindow;

}

- (IBAction) showOrHideLiveViewer:(id)sender;
- (IBAction) showOrHideDrawingToolbar:(id)sender;
- (IBAction) showOrHidePlaybackController:(id)sender;
//- (IBAction) showOrHideElementActivityInspector:(id)sender;
//- (IBAction) showOrHideElements:(id)sender;
- (IBAction) showOrHideElementInspector:(id)sender;
- (IBAction) showOrHideOSCManager:(id)sender;


@end
