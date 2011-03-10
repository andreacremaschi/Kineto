//
//  ECNElementActivityInspectorWindowController.m
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 18/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SynthesizeSingleton.h"
#import "ECNOSCManager.h"
#import "ECNProjectWindowController.h"
#import "ECNProjectDocument.h"
#import "ECNOSCTarget.h"

#import "OSCTableViewDataSource.h"

@implementation ECNOSCManager

SYNTHESIZE_SINGLETON_FOR_CLASS(ECNOSCManager);

- (id)init {
	
	if (![self initWithWindowNibName: @"ECNOSCManager"])
	{
		NSLog(@"Could not init OSC Manager!");
		return nil;
	}
	
    needsUpdate = true;
	
	return self;
}



#pragma mark *** accessors ***
- (NSArray *)hostlist	{
	return [OSCListDataSource hostlist];
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
#pragma mark *** delegate of NSWindow ***


- (void)windowDidLoad {
	[super windowDidLoad];
	
	//We need to know when the rendering view frame changes so that we can update the OpenGL context
//	//   [self setMainWindow:[NSApp mainWindow]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowChanged:) name:NSWindowDidBecomeMainNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowResigned:) name:NSWindowDidResignMainNotification object:nil];
	
	// Setup the data source... 
//	OSCListDataSource = [[OSCTableViewDataSource alloc] init];
 //   [OSCtargetsTableView setDataSource: OSCListDataSource];
	
}

- (void)windowDidUpdate:(NSNotification *)notification {
	
}


#pragma mark *** Accessors for data bindings ***
- (NSArray *)OSCObservedTargets	{
	return _OSCObservedTargets;
	
}

#pragma mark *** change observed view and elements ***

- (void)setMainWindow:(NSWindow *)mainWindow {
    NSWindowController *controller = [mainWindow windowController];
	
    if (controller && [controller isKindOfClass:[ECNProjectWindowController class]]) {
	//	[OSCListDataSource setOSCTargets: [(ECNProjectDocument *)[(ECNProjectWindowController *)controller document] OSCtargets]];
		[OSCListDataSource setDocument: [(ECNProjectWindowController *)controller document]];
		/*	[self willChangeValueForKey:@"OSCObservedTargets"];
		_OSCObservedTargets = [(ECNProjectDocument *)[(ECNProjectWindowController *)controller document] OSCtargets];
			[self didChangeValueForKey:@"OSCObservedTargets"];*/
    } else {
		
		//[OSCListDataSource setOSCTargets: nil];
		//[OSCListDataSource setDocument: nil];

    }
    needsUpdate = YES;
	[OSCtargetsTableView reloadData];


}



#pragma mark *** notifications methods ***

- (void)mainWindowChanged:(NSNotification *)notification {
    [self setMainWindow:[notification object]];
}

- (void)mainWindowResigned:(NSNotification *)notification {
    [self setMainWindow:nil];
}


#pragma mark *** other methods ***



#pragma mark *** dealloc ***

- (void)dealloc {
	[OSCtargetsTableView setDataSource: nil];
	[OSCListDataSource release];
    [super dealloc];
}
@end


