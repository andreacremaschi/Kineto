//
//  ECNOSCTargetAsset.m
//  kineto
//
//  Created by Andrea Cremaschi on 28/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//
#import "ECNProjectDocument.h"

#import "ECNOSCTargetAsset.h"
#import "ECNOSCTxAssetInstance.h"
#import "KOSCManager.h"



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
	[super dealloc];
}

#pragma mark *** Constructors ***
+ (ECNOSCTargetAsset *)assetWithDocument: (ECNProjectDocument *)document 
				  withOSCTargetIP: (NSString *)targetIP
				withOSCTargetPort: (NSNumber *)oscport	{
	
	ECNOSCTargetAsset *newOSCAsset = [[[ECNOSCTargetAsset alloc] initAssetWithProjectDocument: document
																				 withFilePath: @""] autorelease];
	
	if (newOSCAsset != nil)	{
		[self willChangeValueForKey: @"position"];
		[newOSCAsset setValue: OSCAssetNameDefaultValue forPropertyKey: ECNObjectNameKey];		
		[newOSCAsset setValue: targetIP forPropertyKey: OSCAssetHostKey];		
		[newOSCAsset setValue: oscport forPropertyKey: OSCAssetPortKey];		
		[self didChangeValueForKey: @"position"];		
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

- (bool) loadAssetWithError: (NSError*)error {
	
	return [self openWithError: error];
}

#pragma mark OSC methods

- (bool) sendValues: (NSArray *) values	
		  toAddress: (NSString *)addressPattern
			  error: (NSError **)error {
	

	NSString *host = [self valueForPropertyKey: OSCAssetHostKey];
	int osc_portNumber = [[self valueForPropertyKey:OSCAssetPortKey] intValue];
	
	return [[KOSCManager sharedKOSCManager] sendValues: values
												toHost: host
											  withPort: osc_portNumber
										   withAddress: addressPattern
												 error: error];

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

- (bool) openWithError: (NSError **)error	{
	NSString *host = [self valueForPropertyKey: OSCAssetHostKey];
	int nPort = [[self valueForPropertyKey: OSCAssetPortKey] intValue];
	
	return (![[KOSCManager sharedKOSCManager] openConnectionWithHost: host
										 withPort: nPort
											error: error]);
	
}

- (bool) closeWithError: (NSError **)error {
	
	NSString *host = [self valueForPropertyKey: OSCAssetHostKey];
	int osc_portNumber = [[self valueForPropertyKey:OSCAssetPortKey] intValue];
	
	return (![[KOSCManager sharedKOSCManager] closeConnectionWithHost: host
									 withPort: osc_portNumber
											error: error]);
}

@end
