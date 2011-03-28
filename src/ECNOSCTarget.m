//
//  ECNOSCTarget.m
//  kineto
//
//  Created by Andrea Cremaschi on 05/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ECNOSCTarget.h"
#import <VVOSC/VVOSC.h>

@implementation ECNOSCTarget

// +  + Elements specific properties  +
NSString *ECNOSCTargetHostKey = @"host";
NSString *ECNOSCTargetPortKey = @"port";
NSString *ECNOSCTargetOSCLabelKey = @"label";
// +  +  +  +  +  +  +  +  +  +  +  +


// +  + Default values  +  +  +  +  +
NSString *ECNOSCTargetClassValue = @"OSCTarget";
NSString *OSCTargetNameDefaultValue = @"localhost";
NSString *OSCTargetLabelDefaultValue = @"/kinetoData";
int OSCTargetPortDefaultValue = 5000;

// +  +  +  +  +  +  +  +  +  +  +  +


#pragma mark init

- (id) init
{	
	self = [super init];
	
	_host = [[[NSString  alloc] initWithString: @"localhost"] autorelease];
	_port = 1000;
	_OSCLabel = [[[NSString  alloc] initWithString: @"/kinetoData"] autorelease];
	_lastValueSent = 0;
	_OSCOutPort = nil;
	_bBundle=true;
	return self;
}

- (NSMutableDictionary *) attributesDictionary	{
	
	NSMutableDictionary* dict = [super attributesDictionary];
	
	// set default attributes values
	[dict setValue: ECNOSCTargetClassValue forKey: ECNObjectClassKey];
	
	// define class specific attributes	
	NSDictionary *propertiesDict = [NSDictionary dictionaryWithObjectsAndKeys:
									@"127.0.0.1", ECNOSCTargetHostKey, 
									[NSNumber numberWithInt: 5000], ECNOSCTargetPortKey,
									OSCTargetLabelDefaultValue, ECNOSCTargetOSCLabelKey,
									nil];
	
	[[dict objectForKey: ECNPropertiesKey] addEntriesFromDictionary: propertiesDict ];
	
	return dict;
	
	
}

- (OSCManager *)getOSCManager	{
	return _OSCmanager;
}


- (id) initWithProjectDocument: (ECNProjectDocument *)document 
				withOSCManager: (OSCManager *)OSCmanager 
						  host: (NSString *)host 
						  port: (int) OSCport 
						 label: (NSString*)OSClabel
{
	self = [super initWithProjectDocument:document];
	
	if (self)	{
		_host = [[[NSString  alloc] initWithString: host] autorelease];
		_port = OSCport;
		_OSCLabel = [[NSString  alloc] initWithString: OSClabel] ;
		_lastValueSent = 0;
		_OSCmanager = OSCmanager;
		if (_OSCmanager) [_OSCmanager retain];
	}
	
	return self;
	
}


- (void) dealloc
{	
	[_host release];
	[_OSCLabel release];
	[_OSCOutPort release];
	[_OSCmanager release];
	
	[super dealloc];
}

#pragma mark Constructors
+ (ECNOSCTarget *)oscTargetWithDocument: (ECNProjectDocument *)document {
	ECNOSCTarget *newTarget = [[[ECNOSCTarget alloc] initWithProjectDocument: document] autorelease];
	
	if (newTarget != nil)	{
		[newTarget setValue: OSCTargetNameDefaultValue forPropertyKey: ECNObjectNameKey];
	}
	return newTarget;
	
}

#pragma mark Accessors

- (NSString*) OSCLabel {
	return [[[NSString alloc] initWithString: _OSCLabel] autorelease] ; }

- (float) lastValueSent	{
	return _lastValueSent;
}

- (NSString*) host {
	return [[[NSString alloc] initWithString: _host] autorelease] ;
}

- (int) port	{
	return _port;
}

- (void) setOSCLabel: (NSString *)OSCLabel	{
	if (_OSCLabel) [_OSCLabel release];
	_OSCLabel = [[[NSString alloc] initWithString: OSCLabel] retain];
	
	
}

- (void) setHost: (NSString *)host	{
	if (_host) [_host release];	
	_host = [[[NSString alloc] initWithString: host] retain];
	

}

- (void) setPort: (int) port	{
	_port = port;
}

- (NSString *) stringValue	{

	NSString *newString = [NSString stringWithFormat:@"%@%@%@", [self host], @":", [NSString stringWithFormat: @"%i", [self port]]];
	return newString;
}


- (bool) openOutportOnManager: (OSCManager *)oscManager	{
	if (_OSCmanager) {
		[_OSCmanager release];
		_OSCmanager = nil;
	}
	_OSCmanager = [oscManager retain];
	_OSCOutPort = [[oscManager createNewOutputToAddress:_host
												 atPort:_port 
											  withLabel: _OSCLabel
					] retain];
	
	return (_OSCOutPort != nil);	
	
}

- (bool) closeOutport	{
	if (_OSCOutPort)	{
		[_OSCOutPort release];
		_OSCOutPort = nil;
		return true;
	}
	else {
		return false;
	}

}

- (void) setBundle: (bool) bundle	{
	
	_bBundle = bundle;
}

- (bool) bundle { return _bBundle;}

#pragma mark *** Persistence ***



- (NSMutableDictionary *)propertyListRepresentation {
	
    NSMutableDictionary *dict = [super propertyListRepresentation];
	
	[dict setObject:_host forKey:ECNOSCTargetHostKey];
	[dict setObject:[NSString stringWithFormat:@"%i", _port] forKey:ECNOSCTargetPortKey];
	[dict setObject:_OSCLabel forKey:ECNOSCTargetOSCLabelKey];

	
    return dict;
}


+ (id)oscTargetWithPropertyListRepresentation:(NSDictionary *)dict {
	id theOSCTarget = [[[ECNOSCTarget allocWithZone:NULL] init] autorelease];
	if (theOSCTarget) 
		[theOSCTarget loadPropertyListRepresentation:dict];
	return theOSCTarget;
}
 
 
- (void)loadPropertyListRepresentation:(NSDictionary *)dict {
	id obj;
 
	[super loadPropertyListRepresentation: dict];

	obj = [dict objectForKey:ECNOSCTargetHostKey];
	if (obj)	[self setHost: obj];
	
	obj = [dict objectForKey:ECNOSCTargetOSCLabelKey];
	if (obj)	[self setOSCLabel: obj];

	obj = [dict objectForKey:ECNOSCTargetPortKey];
	if (obj)	[self setPort: [obj intValue]];
	
	return;

	
}


#pragma mark Methods


- (void) sendValue: (float) value	{
	
	
	//NSLog(@"%s",__func__);
	
	
	OSCMessage		*msg = nil;
//	OSCBundle		*bundle = nil;
	OSCPacket		*packet = nil;
	
	//	make a message to the specified address
	msg = [OSCMessage createWithAddress: _host];
	
	[msg addFloat: value];
	
	
	//	if i'm sending as a bundle...
	if (_bBundle)	{
		//	make a bundle
		OSCBundle *bundle = [OSCBundle create];
		//	add the message to the bundle
		[bundle addElement:msg];
		//	make the packet from the bundle
		packet = [OSCPacket createWithContent:bundle];
	 }
	 //	else if i'm just sending the msg
	 else	{
		 //	make the packet from the msg
		 packet = [OSCPacket createWithContent:msg];
	}	
	
	
	[_OSCOutPort sendThisPacket: packet];
	
	_lastValueSent = value;
}

@end
