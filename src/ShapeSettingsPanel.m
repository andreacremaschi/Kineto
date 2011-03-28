//
//  ElementSettingsPanel.m
//  kineto
//
//  Created by Andrea Cremaschi on 14/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import "ShapeSettingsPanel.h"
#import "ECNAction.h"
#import "ECNElement.h"

#import "ECNProjectDocument.h"
#import "KCue.h"
#import "ECNTrigger.h"

@implementation ShapeSettingsPanel

@synthesize actionClass;
@synthesize selectedActivationAction;
@synthesize selectedDeactivationAction;

- (id)init {
	
	if (![self initWithWindowNibName: @"ElementSettings"])
	{
		NSLog(@"Could not init Element settings panel!");
		return nil;
	}
    
	[self setWindowFrameAutosaveName:@"Element settings"];
	
	
	return self;
}


- (id) initWithElement: (ECNElement*)element {
	self = [self init];
	if (self)	{
		_element = [element retain];
		availableTargets= [NSArray array];
		availableActionForSelectedTarget = [NSArray array];
		
	}							  
	return self;
}

- (void) dealloc {
	
	[_element release];
	[availableTargets release];
	[availableActionForSelectedTarget release];
	[super dealloc];
	
}


- (void) windowDidLoad	{
	
	[super windowDidLoad];
	
	//bind data
	[self refreshAvailableTargets];
	[oElementToInspect setContent: _element];

}

#pragma mark *** Load content

- (void )refreshAvailableTargets	{
	NSMutableArray *targetsArray = [NSMutableArray arrayWithCapacity: 0];
	
	[targetsArray addObjectsFromArray: [[_element document] cues]];
	[targetsArray addObjectsFromArray: [[_element scene] elements]];
	
	[self willChangeValueForKey:@"availableTargets"];

	if (availableTargets != nil) [availableTargets release];
	availableTargets = [targetsArray retain];

	[self didChangeValueForKey:@"availableTargets"];
	
	if ([targetsArray count] > 0)
		[self setSelectedTarget: [targetsArray objectAtIndex: 0]];
	
}

- (void) resetContent	{	
	[oElementToInspect setContent: _element];	
	[self refreshAvailableTargets];
}

#pragma mark *** Constructors
+ (ShapeSettingsPanel *) settingsPanelWithElement: (ECNElement *)elementToModify	{
	ShapeSettingsPanel *panel = [[[ShapeSettingsPanel alloc] initWithElement: elementToModify] autorelease];

	[panel window];	
	[panel resetContent];
	
	return panel;
}



#pragma mark *** 
- (NSInteger)runModal	{
	
	
	
	_state = NSRunContinuesResponse;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	
	NSModalSession modalSession = [NSApp beginModalSessionForWindow: [self window]];
	NSUInteger result;
	for (;;) {
		NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
		
		result = [NSApp runModalSession:modalSession];
		if (result != NSRunContinuesResponse)
			break;
		
		[loopPool drain];
	}
	
	[NSApp endModalSession:modalSession];
	
	[[self window] close];
	
	// Do whatever cleanup is needed. (This is here primarly for LiveInputRenderer
	[pool drain];
	
	return _state;
}


- (NSArray *)actionsList	{
	
	return [ECNAction actionListForObjectType: [ECNElement class]];
}


#pragma mark *** UI events
- (IBAction) ok: (id)sender	{
	_state = NSOKButton;
	[NSApp stopModal];
}
- (IBAction) cancel: (id)sender		{
	_state = NSCancelButton;
	[NSApp abortModal];
}


- (void) refreshTableView: (NSTableView *)tableView	{
	
	
	[activationActionsTableView reloadData];
	
}


- (IBAction) addActivationAction:	(id)sender;
{
		
	ECNAction *newAction = [actionClass actionWithDocument: [_element document] withTarget: [self selectedTarget]];

	[activationActionsList addObject: newAction];
}

- (IBAction) removeActivationAction:(id)sender;
{
	[activationActionsList removeObjectAtArrangedObjectIndex:[activationActionsList selectionIndex]];
}

- (IBAction) addDeactivationAction:	(id)sender;
{
	
	ECNAction *newAction = [actionClass actionWithDocument: [_element document] withTarget: [self selectedTarget]];
	
	[deactivationActionsList addObject: newAction];
}

- (IBAction) removeDeactivationAction:(id)sender;
{
	[deactivationActionsList removeObjectAtArrangedObjectIndex:[deactivationActionsList selectionIndex]];
}


#pragma mark  -
#pragma mark *** KVC/KVO methods			
- (ECNObject *)selectedTarget	{
	return _selectedTarget;
}

- (void)setSelectedTarget: (ECNObject *)selectedTarget {

	if (_selectedTarget != nil) [_selectedTarget release];
	_selectedTarget = [selectedTarget retain];
	
	//refresh available actions for current object class
	[self willChangeValueForKey:@"availableActionForSelectedTarget"];
	[availableActionForSelectedTarget release];
	if ((!_selectedTarget) || ![_selectedTarget isKindOfClass: [ECNObject class]]) {
		availableActionForSelectedTarget = [[NSArray array] retain];
	} else {
		Class objectClass = [[[_selectedTarget document] objectWithID: [_selectedTarget ID]] class];
		availableActionForSelectedTarget =  [[ECNAction actionListForObjectType: objectClass] retain];
		if ([availableActionForSelectedTarget count] >0) 
			[self setActionClass: [availableActionForSelectedTarget objectAtIndex: 0]];

	}
	[self didChangeValueForKey:@"availableActionForSelectedTarget"];
	
	//set the first available action in popup button
	
}

-(NSArray *)masks	{
	return [NSArray arrayWithObjects:
			[NSDictionary dictionaryWithObjectsAndKeys:
			 [NSNumber numberWithInt:0], @"mask_to_observe",
			 @"Difference mask", @"mask_name", 
			 nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
			 [NSNumber numberWithInt:1], @"mask_to_observe",
			 @"Motion mask", @"mask_name", 
			 nil],
			nil];
	
}
		

@end
