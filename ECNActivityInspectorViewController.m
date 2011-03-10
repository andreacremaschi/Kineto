//
//  ECNActivityInspector.m
//  kineto
//
//  Created by Andrea Cremaschi on 12/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECNActivityInspectorViewController.h"
#import "ECNElement.h"

@implementation ECNActivityInspectorViewController

NSString *const kActionViewControllerNibName = @"ActivityInspector";


#pragma mark *** Initialization

- (id) init	{
	[self initWithNibName: kActionViewControllerNibName bundle: nil];
	return self;
}

- (void) dealloc	{

	if (_element) [_element release];
	[super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.

}

+ (ECNActivityInspectorViewController *) initWithElement: (ECNElement *)element	{
	id newActivityInspector = [[[ECNActivityInspectorViewController allocWithZone:NULL] init] autorelease];
	
	[newActivityInspector setElement: element];
	
	
	return newActivityInspector;
	
}

#pragma mark *** Accessors

- (void) setElement: (ECNElement *)element {
	if (_element) [_element release];
	_element = element;
	[_element retain];	
}

- (ECNElement *)element	{ return _element;	}

#pragma mark *** Other methods

- (void) resetControls	{
	if (_element == nil) return;
	[oTxtElementName setStringValue: [_element name]];
	
}

- (void) updateActivityLevels {
	
	if (_element == nil) return;
	[oActivityLabel setStringValue: [[[NSString alloc ]initWithFormat: @"%.2f", 0] autorelease]];
//									  ([_element activity])] autorelease]];
	
	[oActivityIndicator setFloatValue: 0.0]; //[_element activity]];
	[oActivityIndicator setCriticalValue: 0.0]; //[_element triggerThreshold]];
//	[oActivityIndicator setActivity: [element activity]
//						 Threshold: [element _triggerThreshold]];
		
}			



- (bool) isLocked	{
	
	return (oIsLocked.state == NSOnState);
}

@end
