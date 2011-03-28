//
//  DataViewerWindowController.m
//  kineto
//
//  Created by Andrea Cremaschi on 14/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataViewerWindowController.h"
#import "SynthesizeSingleton.h"

#import "ECNPlaybackWindowController.h"

#import "ECNElement.h"

#pragma mark *** NSWindowController Conveniences ***

@implementation DataViewerWindowController
SYNTHESIZE_SINGLETON_FOR_CLASS(DataViewerWindowController);


- (id)init {
	
	if (![self initWithWindowNibName: @"DataViewer"])
	{
		NSLog(@"Could not init DataViewer!");
	}

	_oldBinding = @"";
	_startTime = [[NSDate date] retain];
    return self;
}

-(void) dealloc {
	[_oldBinding release];
	[_startTime release];
	[super dealloc];
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



-(void) awakeFromNib	{
	
	[oPortsArrayController addObserver: self
								   forKeyPath: @"selection"
									  options: NSKeyValueObservingOptionNew
									  context: NULL];
	
/*	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(_newFrameToProcess:) 
												 name:PlaybackNewFrameHasBeenProcessedNotification 
											   object:[ECNPlaybackWindowController sharedECNPlaybackWindowController]];*/
	
}

#pragma mark *** Data binding ***

- (void) setValue:(id)value	{
	if ((!_oldBinding) || [_oldBinding isEqual: @""])  return;
	
	[oQCView setValue: value forInputKey: _oldBinding];

}

- (id) value	{
	if ((!_oldBinding) || [_oldBinding isEqual: @""])  return nil;
	return [oQCView valueForInputKey: _oldBinding];
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context
{
	NSLog(@"Table section changed: keyPath = %@, %@", keyPath, [object selectionIndexes]);
	
	ECNPort *observedPort = [self selectedPort];
	if (observedPort == nil) return;
	
	NSString *portType, *qcInputType;
	
	portType = [observedPort valueForKey: @"type"];
	//	NSString *name = [observedPort valueForKey: @"name"];
	int index = -1;
	
	if (portType == ECNPortTypeNumber) 
	{	qcInputType = @"number"; index = 2;}
	else if (portType == ECNPortTypeImage) 
	{	qcInputType = @"image"; index = 1;}	
	else if (portType == ECNPortTypeColor) 
	{	qcInputType = @"color";	 index = 3;}
	else if (portType == ECNPortTypeBoolean) 
	{	qcInputType = @"boolean"; index = 0;}
	else if (portType == ECNPortTypeString) 
	{	qcInputType = @"string"; index = 4;}
	else if (portType == ECNPortTypeStructure) 
	{	qcInputType = @"structure"; index = 5;}
	else return;
	
	[oQCView setValue: [NSNumber numberWithInt:index]
		  forInputKey: @"show_type"
	 ];
	
	[oQCView setValue: [observedPort valueForKey: @"value"]
		  forInputKey: qcInputType
	 ];
	
	if (_oldBinding != @"")	{
		[oQCView unbind: _oldBinding];
		[_oldBinding release];
	}
		
	[self bind: @"value"
		 toObject: oPortsArrayController
	  withKeyPath: @"selection.value"
		  options: nil
	 ];

	//NSDate *oldStartTime = [_startTime autorelease];
	
	_startTime = [[NSDate date] retain];
	_oldBinding = [qcInputType retain];
	
}


#pragma mark *** Observing
/*
- (void) _newFrameToProcess: (NSNotification *) notification {
	ECNPort *observedPort = [self selectedPort];
	if (observedPort == nil) return;
	
	NSString *portType, *qcInputType;
	
	portType = [observedPort valueForKey: @"type"];
//	NSString *name = [observedPort valueForKey: @"name"];
	int index = -1;
	
	if (portType == ECNPortTypeNumber) 
	{	qcInputType = @"number"; index = 2;}
	else if (portType == ECNPortTypeImage) 
	{	qcInputType = @"image"; index = 1;}	
	else if (portType == ECNPortTypeColor) 
	{	qcInputType = @"color";	 index = 3;}
	else if (portType == ECNPortTypeBoolean) 
	{	qcInputType = @"boolean"; index = 0;}
	else if (portType == ECNPortTypeString) 
	{	qcInputType = @"string"; index = 4;}
	else return;
		
	[oQCView setValue: [NSNumber numberWithInt:index]
		  forInputKey: @"show_type"
	 ];
	
	[oQCView setValue: [observedPort valueForKey: @"value"]
		  forInputKey: qcInputType
	 ];
	
	//NSLog(@"visualizing input type: %@", qcInputType);
}
*/

#pragma mark *** Accessors

- (void) setElementToObserve: (ECNElement *)element {
	
	[oElementController setContent: element];	
}

- (ECNPort *)selectedPort	{
	return [oPortsArrayController selection];
}

#pragma mark *** Start / stop rendering

- (void) startRendering	{
	[oQCView startRendering];
}

- (void) stopRendering	{
	[oQCView stopRendering];
}



@end
