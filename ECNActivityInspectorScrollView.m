//
//  ECNActivityInspectorScrollView.m
//  kineto
//
//  Created by Andrea Cremaschi on 12/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECNActivityInspectorScrollView.h"
#import "ECNActivityInspectorViewController.h"


@implementation ECNActivityInspectorScrollView


- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
}

- (void) dealloc {
	[_viewControllersList release];
	[super dealloc];
}

#pragma mark *** Accessors

- (void) setElementsList: (NSSet *)elementsList	{

	if (_viewControllersList == nil) 
		_viewControllersList = [[[NSMutableSet alloc] initWithCapacity: 0] retain];

	NSMutableSet *lockedControllersList = [[[NSMutableSet alloc] initWithCapacity: 0] autorelease];
	
	// remove every subview in scrollview
	ECNActivityInspectorViewController *viewController;
	for (viewController in _viewControllersList)
		if (![viewController isLocked])
			[[viewController view] removeFromSuperview];
		else {
			[lockedControllersList addObject: viewController];
		}

	[_viewControllersList removeAllObjects];	
	
	ECNElement *element;
	NSView *subview;
	int ypos = 0;
	
	//calculate height of locked items and reposition them
	for (viewController in lockedControllersList)
	{
		ypos += [[viewController view] bounds].size.height;
		[[viewController view] setFrameOrigin: NSMakePoint(0, [[self documentView] bounds].size.height - ypos) ];
	}
	
	bool jumpthis;
	for (element in elementsList) {
		jumpthis=false;
		for (viewController in lockedControllersList)
			if (element == [viewController element] ) jumpthis=true;
		if (!jumpthis) // the element is locked and is already in the scrollview; no need to add it
		{
			viewController = [ECNActivityInspectorViewController initWithElement: element];
			subview = [viewController view];

			ypos += [subview bounds].size.height;
			[[self documentView] addSubview: subview];
			[subview setFrameOrigin: NSMakePoint(0, [[self documentView] bounds].size.height - ypos) ];
		
			[viewController resetControls];
		
			[_viewControllersList addObject: viewController];
		}
	}	
	
	// TODO adjust NSScrollView content size to fit the correct height
	//[[self contentView] setFrameSize: NSMakeSize ([[self contentView] bounds].size.width, ypos) ];
	
	[_viewControllersList unionSet: lockedControllersList];
	
	//[self setFrameSize: NSMakeSize( [self bounds].size.width, ypos )];
	
}

#pragma mark *** Draw

- (void) updateActivityInspectors	{
	
	ECNActivityInspectorViewController *viewController;
	for (viewController in _viewControllersList)
		[viewController updateActivityLevels];
	
}

@end
