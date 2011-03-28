//
//  ECNOSCTargetAsset.m
//  kineto
//
//  Created by Andrea Cremaschi on 28/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "ECNProjectDocument.h"

#import "ECNOSCTargetAsset.h"
#import "ECNOSCTxAssetInstance.h"
#import <VVOSC/VVOSC.h>


@interface OSCMessage (ECNConvenience)
- (void) addObjectValue: (id) value;
@end

@implementation OSCMessage (ECNConvenience)
- (void) addObjectValue: (id) objectValue	{
	if (objectValue == nil) return;
	if ([objectValue isKindOfClass: [NSNumber class]])	{
		[self addFloat: [objectValue floatValue]];
		
	} else 
		if ([objectValue isKindOfClass: [NSString class]])	{
			[self addString: objectValue];
		}
	return;
}
@end

@implementation ECNOSCTargetAsset

// +  + Object specific properties  +
NSString *OSCAssetHostKey = @"osc_host";
NSString *OSCAssetPortKey = @"osc_port";

// +  + Default values  +  +  +  +  +
NSString *OSCAssetClassValue = @"OSCTargetAsset";
NSString *OSCAssetNameDefaultValue = @"OSC target";

NSString *DefaultHost = @"127.0.0.1";
NSString *DefaultPort = @"5000";

// +  +  +  +  +  +  +  +  +  +  +  +


#pragma mark *** Init methods

- (NSMutableDictionary *) attributesDictionary	{
	
	NSMutableDictionary* dict = [super attributesDictionary];
	
	// set default attributes values
	[dict setValue: OSCAssetClassValue forKey: ECNObjectClassKey];
	
	NSDictionary *propertiesDict = [NSDictionary dictionaryWithObjectsAndKeys:	
									DefaultHost,  OSCAssetHostKey, 
									[NSNumber numberWithInt: [DefaultPort intValue]],  OSCAssetPortKey, 
									nil];
	
	//[_attributes addEntriesFromDictionary: attributesDict];
	[[dict objectForKey: ECNPropertiesKey] addEntriesFromDictionary: propertiesDict ];
	
	return dict;
	
	
}

- (void) dealloc {
	if (_OSCOutputPort) [_OSCOutputPort release];
	[super dealloc];
}

#pragma mark *** Constructors ***
+ (ECNOSCTargetAsset *)assetWithDocument: (ECNProjectDocument *)document 
				  withOSCTargetIP: (NSString *)targetIP
				withOSCTargetPort: (NSNumber *)oscport	{
	
	ECNOSCTargetAsset *newOSCAsset = [[[ECNOSCTargetAsset alloc] initAssetWithProjectDocument: document
																				 withFilePath: @""] autorelease];
	
	if (newOSCAsset != nil)	{
		
		[newOSCAsset setValue: OSCAssetNameDefaultValue forPropertyKey: ECNObjectNameKey];		
		[newOSCAsset setValue: targetIP forPropertyKey: OSCAssetHostKey];		
		[newOSCAsset setValue: oscport forPropertyKey: OSCAssetPortKey];		
		
	}
	return newOSCAsset;
	
}

+ (Class) instanceClass {
	return [ECNOSCTxAssetInstance class];	
}

#pragma mark -
#pragma mark ECNAsset overrides

- (NSString *)position	{
	return 	[NSString stringWithFormat: @"%@:%@", 
			 [self valueForPropertyKey: OSCAssetHostKey],
			 [self valueForPropertyKey: OSCAssetPortKey] ];
}

#pragma mark OSC methods

- (bool) sendValues: (NSArray *) values	
		  toAddress: (NSString *)addressPattern	{
	
	
	OSCMessage		*msg = nil;
	OSCPacket		*packet = nil;
	
	NSString *host = [self valueForPropertyKey: OSCAssetHostKey];
	int osc_portNumber = [[self valueForPropertyKey:OSCAssetPortKey] intValue];
	
	bool isBundle = [values count] > 0 ? true : false;
	
	
	//	make a message to the specified address
	msg = [OSCMessage createWithAddress: addressPattern];
	
	//	if i'm sending as a bundle...
	if (isBundle)	{
		
		//	make a bundle
		OSCBundle *bundle = [OSCBundle create];
		
		//	add the message to the bundle
		for (id value in values)	{
			[msg addObjectValue: value];
			[bundle addElement: msg];
		}
		
		//	make the packet from the bundle
		packet = [OSCPacket createWithContent:bundle];
	}
	//	else if i'm just sending the msg
	else	{
		//	make the packet from the msg
		[msg addObjectValue: [values objectAtIndex: 0]];
		packet = [OSCPacket createWithContent:msg];
	}	
	
	if (_OSCOutputPort == nil)	{
		// why _OSCOutputPort is nil? it should already be opened in openOutportOnManager: method!
		// raise an exception
		NSLog (@"Playback error: couldn't send a message to %@:%i because port hasn't been opened!", host, osc_portNumber);
		return false;
	}
	
	[_OSCOutputPort sendThisPacket: packet];
	
	return true;
}

- (NSArray *)oscOutputPorts {

	NSMutableArray *addressPatternArray = [NSMutableArray arrayWithCapacity: 0];
	
	// get a list of all address pattern array (/address_pattern) for this OSC server (IP:port)
	for (ECNOSCTxAssetInstance *txAssetInstance in [(ECNProjectDocument *)[self document] objectsOfKind: [ECNOSCTxAssetInstance class]])
		if ([txAssetInstance oscAsset] == self) 
			[addressPatternArray addObject: [txAssetInstance valueForPropertyKey: OSCTxAssetInstanceAddressPatternKey]];
	
	return addressPatternArray;
}

- (NSArray *)oscInputPorts {
	NSMutableArray *array = [NSMutableArray arrayWithCapacity: 0];
/*	for (ECNOSCTxAssetInstance *txAssetInstance in [[self document] objectsOfKind: [ECNOSCTxAssetInstance class]])
		if ([txAssetInstance asset] == self) [array addObject: txAssetInstance];*/
	return array;
}

- (bool) openOutportOnManager: (OSCManager *)oscManager	{
	
	NSString *host = [self valueForPropertyKey: OSCAssetHostKey];
	int osc_portNumber = [[self valueForPropertyKey:OSCAssetPortKey] intValue];

	if ((!host) || (osc_portNumber <=0) || (!oscManager)) return false;
	
	NSArray *outputPorts = [self oscOutputPorts];
	NSArray *inputPorts = [self oscInputPorts];	

	NSLog (@"Output ports for host: %@ are: %@", host, outputPorts);
	NSLog (@"Input ports for host: %@ are: %@", host, inputPorts);
	
	if ([outputPorts count] > 0)	{

		// check if port is not already open on osc manager
		_OSCOutputPort = [oscManager findOutputWithAddress: host 
												   andPort: osc_portNumber];
		
		if (_OSCOutputPort != nil) return true; // port is already open!
		
		// open the osc port
		_OSCOutputPort = [[oscManager createNewOutputToAddress: host atPort: osc_portNumber] retain];

		if (_OSCOutputPort == nil)	{
			//something went wrong
			//TODO raise an exception
			NSLog(@"OSC Error: couldn't open OSC port %i on host %@", osc_portNumber,  host);		
			
		}
	}
	return true;	
	
}


- (bool) closeOutportOnManager: (OSCManager *)oscManager	{
	NSString *host = [self valueForPropertyKey: OSCAssetHostKey];
	int osc_portNumber = [[self valueForPropertyKey:OSCAssetPortKey] intValue];
	
	if ((!host) || (osc_portNumber <=0) || (!oscManager)) return false;
		
	if (_OSCOutputPort == nil) return true;
	
	// check if port is effectively open 
	OSCOutPort *OSCOutputPort = [oscManager findOutputWithAddress: host 
											   andPort: osc_portNumber];
	if (OSCOutputPort == nil) {
		NSLog (@"Error: it was asked to close and OSC port that was not opened");
		return true; // port is not opened, why should it be closed? raise an exception
	}
	
	[oscManager removeOutput: OSCOutputPort];
	[_OSCOutputPort release];
	_OSCOutputPort=nil;
	return true;
}

@end
