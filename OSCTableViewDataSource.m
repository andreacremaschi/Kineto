//
//  OSCTableViewDataSource.m
//  kineto
//
//  Created by Andrea Cremaschi on 01/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OSCTableViewDataSource.h"
#import "ECNOSCTarget.h"
#import "ECNProjectDocument.h"

@implementation OSCTableViewDataSource



#pragma mark *** override of NSTableView ***

- (id) init	{
	self = [super init];
	if (self)	{
		_OSCObservedTargets = [[[NSArray alloc] init] retain];
		_hostlist = [[[NSMutableArray alloc] init] retain];

	}
	return self;
}

- (void) dealloc {
	[_OSCObservedTargets release];
	[_hostlist release];
	[super dealloc];
}

- (id)tableView:	(NSTableView *)aTableView 
objectValueForTableColumn: (NSTableColumn *)aTableColumn
			row: (NSInteger)rowIndex
{
	ECNOSCTarget *theRecord;
	id theValue;
	
	if (_OSCObservedTargets == nil) return nil;
	
	NSParameterAssert(rowIndex >= 0 && rowIndex < [_OSCObservedTargets count]);
	theRecord = [_OSCObservedTargets objectAtIndex:rowIndex];
	
	theValue = @"";
	if ([[aTableColumn identifier] isEqualToString: @"Host"])
	{	
		if( [theRecord document] == nil)	{
			NSRect rowRect = [aTableView rectOfRow:rowIndex];
			[[NSColor lightGrayColor] set];
			NSRectFill( rowRect );
		}
		theValue = [theRecord OSCLabel];
	}
	else if ([[aTableColumn identifier] isEqualToString: @"Label"])
	{	theValue = [theRecord host];	}
	else if ([[aTableColumn identifier] isEqualToString: @"Port"])
	{	theValue = [[[NSNumber alloc] initWithInt: [theRecord port]] autorelease];	}
	else if ([[aTableColumn identifier] isEqualToString: @"Bundle"])
	{	theValue = [[[NSNumber alloc] initWithBool: [theRecord bundle]] autorelease];	}
	
	
	//	theValue = [theRecord objectForKey:[aTableColumn identifier]];
	
	return theValue;
}

- (void)tableView:	(NSTableView *)aTableView 
   setObjectValue:(id)theValue 
   forTableColumn:(NSTableColumn *)aTableColumn 
			  row:(NSInteger)row 
{	
	
	ECNOSCTarget *theRecord;
	//id theValue;
	
	if (_OSCObservedTargets == nil) return;
	
	NSParameterAssert(row >= 0 && row < [_OSCObservedTargets count]);
	theRecord = [_OSCObservedTargets objectAtIndex:row];
	
	if ([theRecord document] == nil)	{
		
		ECNOSCTarget *newOSCTarget =  [_observedDocument createNewOSCTarget];
		[newOSCTarget setHost: [theRecord host]];
		[newOSCTarget setOSCLabel: [theRecord OSCLabel]];
		[newOSCTarget setPort: [theRecord port]];
		[newOSCTarget setBundle: [theRecord bundle]];
		theRecord = newOSCTarget;
		[aTableView setNeedsDisplay: YES];
	}
	
	
	if ([[aTableColumn identifier] isEqualToString: @"Host"])
	{	[theRecord setOSCLabel: [[[NSString alloc] initWithString: theValue] autorelease]];	
	}
	if ([[aTableColumn identifier] isEqualToString: @"Label"])
	{	//TODO: validate host
		[theRecord setHost: [[[NSString alloc] initWithString: theValue] autorelease]];	}
	if ([[aTableColumn identifier] isEqualToString: @"Port"])
	{	[theRecord setPort: [theValue intValue]];	}
	if ([[aTableColumn identifier] isEqualToString: @"Bundle"])
	{	[theRecord setBundle: [theValue boolValue]];	}
	
	
	
}

- (void)refreshHostList	{
//	NSString *host;
	ECNOSCTarget *oscTarget;
	
	
	[self willChangeValueForKey:@"_hostlist"];
	if (_hostlist) [_hostlist release];
	_hostlist = [[[NSMutableArray alloc] init] retain];
	
	if (_OSCObservedTargets == nil) return;
	
	for (oscTarget in _OSCObservedTargets)	{
		if (![_hostlist containsObject: [oscTarget host]]) {
			[_hostlist addObject: [oscTarget host]]; 
			//NSLog(@"%@", [oscTarget host]);
		}
	}
	
	[_hostlist addObject: [NSString stringWithString: @"new host"]];
	[self didChangeValueForKey:@"_hostlist"];

	return ;
	
}

- (NSArray *)hostlist {
	return _hostlist;
	
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [_OSCObservedTargets count];
}

- (void) setOSCTargets: (NSArray *)oscTargets	{
	if (_OSCObservedTargets) [_OSCObservedTargets release];
	_OSCObservedTargets = [[NSMutableArray arrayWithArray: oscTargets] retain]; 
//	[_OSCObservedTargets  addObjectsFromArray: oscTargets];

	ECNOSCTarget *newOSCTarget = [ECNOSCTarget oscTargetWithDocument:nil];
	//[[ECNOSCTarget createWithProjectDocument: nil withOSCManager: nil host: @"127.0.0.1" port: 5000 label: @"/newTarget"] autorelease];
	[_OSCObservedTargets addObject: newOSCTarget] ;
}


- (void) setDocument: (ECNProjectDocument*)document	{

	// release previous data
	if (_observedDocument) 
		[_observedDocument release];
	if (_OSCObservedTargets) 
		[_OSCObservedTargets release];
	_OSCObservedTargets = nil;
	_observedDocument = nil;
	
	// check document validity
	if (document == nil)	
		return;
	
	// retain data;
	_observedDocument = [document retain]; 
	//	[_OSCObservedTargets  addObjectsFromArray: oscTargets];
	
	[self setOSCTargets: [_observedDocument OSCtargets]];
	
	[self refreshHostList];
}
@end
