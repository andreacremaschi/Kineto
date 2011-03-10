//
//  AppController.m
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 18/10/10.
//  Copyright __MyCompanyName__ 2010 . All rights reserved.
//

#import "AppController.h"
#import "ECNLiveViewerController.h"
#import "ECNDrawingToolbar.h"
#import "ECNPlaybackWindowController.h"
#import "ECNLiveInputSelectorWindowController.h"
#import "DataViewerWindowController.h"
#import "ECNOSCManager.h"
#import "MyExceptionAlertController.h"

#pragma mark -
#pragma mark *** NSWindowController Conveniences ***
#pragma mark -
@interface NSWindowController(ECNConvenience)
- (BOOL)isWindowShown;
- (void)showOrHideWindow;
@end


@implementation NSWindowController(ECNConvenience)


- (BOOL)isWindowShown {
	
    // Simple.
    return [[self window] isVisible];
	
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


@end

#pragma mark -
#pragma mark *** AppController implementation ***
#pragma mark -

@implementation AppController
 


#pragma mark *** Launching ***

- (void) applicationWillFinishLaunching: (NSNotification *)aNotification
{
	
	/*// show splash screen
	
	NSWindowController *splashScreen = [[[NSWindowController alloc] init] retain];
	
	if (![splashScreen initWithWindowNibName: @"splash_screen"])
	{
		NSLog(@"Could not init splash_screen!");
		return ;
	}
	
	[splashScreen showWindow: self];
	[splashScreen release];*/
	
}

// Conformance to the NSObject(NSApplicationNotifications) informal protocol.
- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	
	//NSWindow *dummyWindow;

	[[oSplashWindow windowController] showWindow:self];
	
    // load singleton panels
	//dummyWindow = [[ECNLiveInputSelectorWindowController sharedECNLiveInputSelectorWindowController] window];
	[[ECNLiveViewerController sharedECNLiveViewerController] window];
	[[ECNDrawingToolbarController sharedECNDrawingToolbarController] window];
	[[ECNPlaybackWindowController sharedECNPlaybackWindowController] window];
	//[[ECNOSCManager sharedECNOSCManager] window];
	[[DataViewerWindowController sharedDataViewerWindowController] window];
	
	[[oSplashWindow windowController] orderOut: self];

	// show only some of them
	[[ECNLiveViewerController sharedECNLiveViewerController] showWindow:self];
	[[ECNPlaybackWindowController sharedECNPlaybackWindowController] showWindow:self];
    [[ECNDrawingToolbarController sharedECNDrawingToolbarController] showWindow:self];
	[[DataViewerWindowController sharedDataViewerWindowController] showWindow: self];		 
}


#pragma mark *** Preferences ***



- (void)windowWillClose:(NSNotification *)notification 
{
	[NSApp terminate:self];
}


#pragma mark other

/*- (void)selectedToolDidChange:(NSNotification *)notification {
    // Just set the correct cursor
    Class theClass = [[ECNDrawingToolbar sharedECNDrawingToolbarController] currentElementClass];
    NSCursor *theCursor = nil;
    if (theClass) {
        theCursor = [theClass creationCursor];
    }
    if (!theCursor) {
        theCursor = [NSCursor arrowCursor];
    }
    [[_elementsView enclosingScrollView] setDocumentCursor:theCursor];
}*/



-(void)showOrHideSingletonPanel: (NSWindowController *)singletonPanel menuItem: (id) menuItem	{
	[singletonPanel showOrHideWindow];
	[menuItem setState: [[singletonPanel window] isVisible] ];
	
}

- (IBAction)showOrHideLiveViewer:(id)sender {
	
    // We always show the same live view panel. Its controller doesn't get deallocated when the user closes it.
	[self showOrHideSingletonPanel:  [ECNLiveViewerController sharedECNLiveViewerController]
						  menuItem: sender];
	
}

- (IBAction)showOrHideDrawingToolbar:(id)sender {
	
    // We always show the same live view panel. Its controller doesn't get deallocated when the user closes it.
	[self showOrHideSingletonPanel:  [ECNDrawingToolbarController sharedECNDrawingToolbarController]
						  menuItem: sender];
	
}

- (IBAction) showOrHidePlaybackController:(id)sender {
    // We always show the same playback panel. Its controller doesn't get deallocated when the user closes it.
	[self showOrHideSingletonPanel:  [ECNPlaybackWindowController sharedECNPlaybackWindowController]
						  menuItem: sender];
	
}



- (IBAction) showOrHideOSCManager:(id)sender {
    // We always show the same playback panel. Its controller doesn't get deallocated when the user closes it.
	[self showOrHideSingletonPanel:  [ECNOSCManager sharedECNOSCManager]
						  menuItem: sender];
	
}



@end
