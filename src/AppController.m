//
//  AppController.m
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 18/10/10.
//  Copyright AndreaCremaschi 2010 . All rights reserved.
//

#import "AppController.h"

#import "KPlaybackViewController.h"

#import "KElementInspectorViewController.h"
//#import "ECNOSCManager.h"
#import "MyExceptionAlertController.h"
#import "LicensingWindowController.h"
#import "AppResources.h"
#import "KPreferencesStrings.h"

#import "Licensing.h"

#import "KLiveViewerController.h"

#import "KIncludes.h"

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
 


#pragma mark *** NSApplicationDelegate implementation ***

- (void) applicationWillFinishLaunching: (NSNotification *)aNotification
{
	
}

// Conformance to the NSObject(NSApplicationNotifications) informal protocol.
- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	
	//NSWindow *dummyWindow;

	//[[oSplashWindow windowController] showWindow:self];
	
    // load singleton panels
	//dummyWindow = [[ECNLiveInputSelectorWindowController sharedECNLiveInputSelectorWindowController] window];
	
	//old 32bit
	/*[[ECNLiveViewerController sharedECNLiveViewerController] window];
	[[ECNPlaybackWindowController sharedECNPlaybackWindowController] window];
	
	//[[ECNOSCManager sharedECNOSCManager] window];
	[[DataViewerWindowController sharedDataViewerWindowController] window];
	[[ECNElementInspector sharedECNElementInspector] window];

	[[KPlaybackViewController sharedKNewPlaybackWindowController] window];
//	[[KLiveViewerController sharedKLiveViewerWindowController] window];*/

	
	//load licensing information
	NSString *licenseFile = [AppResources loadDefaultsWithKey: @"License file" 
													   ofType: @"NSString"];
	if (licenseFile)	{
		// set application license file to selected one
		[[Licensing defaultLicensing] loadLicenseFromFilePath:  [NSString stringWithFormat: @"%@%@", [AppResources applicationSupportFolder], licenseFile]];
	} else {
		// application not yet authorized
		
	}

	
	
	
/*	[[oSplashWindow windowController] orderOut: self];

	// show only some of them
	//old 32bit
	[[ECNLiveViewerController sharedECNLiveViewerController] showWindow:self];
	[[ECNPlaybackWindowController sharedECNPlaybackWindowController] showWindow:self];
	
	[[DataViewerWindowController sharedDataViewerWindowController] showWindow: self];		 
	[[ECNElementInspector sharedECNElementInspector] showWindow: self];

	[[KPlaybackViewController sharedKNewPlaybackWindowController] showWindow: self];
//	[[KLiveViewerWindowController sharedKLiveViewerWindowController] showWindow: self];

	*/

	//[_pipeline startProcessing: &error];
	/*BOOL isFirstRun = [[NSUserDefaults standardUserDefaults] boolForKey: kIsFirstRunPreferenceKey];
	
	if (isFirstRun) {
		_appStatus = AppStatusWelcomeScreenRunning;
		[self _promoteViewToMainView:_welcomeView];
	} else {
		[self _loadPipelineAsync];
	}*/
	
	
}


#pragma mark *** Preferences ***



- (void)windowWillClose:(NSNotification *)notification 
{
	[NSApp terminate:self];
}


#pragma mark other


-(void)showOrHideSingletonPanel: (NSWindowController *)singletonPanel menuItem: (id) menuItem	{
	[singletonPanel showOrHideWindow];
	[menuItem setState: [[singletonPanel window] isVisible] ];
	
}

- (IBAction) showLicensingWindowController:(id)sender {
	LicensingWindowController * licensingWindow = [[[LicensingWindowController alloc] init] autorelease];
	[licensingWindow loadWindow];	
	
}


@end
