//
//  ECNOSCTargetAssetInstance.m
//  kineto
//
//  Created by Andrea Cremaschi on 28/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECNOSCTxAssetInstance.h"
#import "ECNOSCTargetAsset.h"

// +  + Elements specific properties   +

NSString *OSCTxAssetInstanceAddressPatternKey = @"osc_addresspattern";
NSString *OSCTxAssetInstanceBundleKey = @"osc_bundle";


NSString *OSCTxAssetInstanceObservedPortsArrayKey = @"observed_ports";
// an array of labels of ECN Elements output ports:
// they will be used to create the bundle to send
//NSString *OSCTxAssetInstancePortKeysArrayKey = @"ports_key";

// +  +  +  +  +  +  +  +  +  +  +  +  +


// +  +  + QC renderer input ports +  +  +
// +  +  +  +  +  +  +  +  +  +  +  +


// +  +  + QC renderer output ports +  +  +

// +  +  +  +  +  +  +  +  +  +  +  +


// +  + Default values  +  +  +  +  +
NSString *OSCtxAssetInstanceClassValue = @"ECNOSCTxAssetInstance";
NSString *OSCtxAssetInstanceDefaultNameValue = @"OSC Client";

NSString *AddressPatternDefaultValue = @"/kineto_data";
NSString *BundleDefaultValue = @"false";
NSString *OSCIconDefaultValue = @"assets_osctx";

// +  +  +  +  +  +  +  +  +  +  +  +

@implementation ECNOSCTxAssetInstance

- (NSMutableDictionary *) attributesDictionary	{
	
	
	NSMutableDictionary* dict = [super attributesDictionary];
	
	// set default attributes values
	[dict setValue: OSCtxAssetInstanceClassValue forKey: ECNObjectClassKey];
	
	NSDictionary *propertiesDict = [NSDictionary dictionaryWithObjectsAndKeys:
									AddressPatternDefaultValue, OSCTxAssetInstanceAddressPatternKey,
									[NSNumber numberWithBool: [BundleDefaultValue boolValue]], OSCTxAssetInstanceBundleKey,
									[NSMutableArray arrayWithCapacity: 0], OSCTxAssetInstanceObservedPortsArrayKey,
									nil];
	
	
	//[_attributes addEntriesFromDictionary: attributesDict];
	[[dict objectForKey: ECNPropertiesKey] addEntriesFromDictionary: propertiesDict ];
	
	return dict;
		
}

- (id) initWithAsset: (ECNAsset *)asset
{
	self = [super initWithAsset: asset];
	if (self) {
		
	}
	return self;	
}

- (void)dealloc {	
    [super dealloc];
}

+ (Class) triggerClass		{
	return nil; //[ECNShapeTrigger class];
}

+ (Class )assetType	{
	return [ECNOSCTargetAsset class];
}


+ (NSString *)iconName	{
	return OSCIconDefaultValue;
}

#pragma mark Constructors
+ (ECNOSCTxAssetInstance *)oscTxAssetInstanceWithAsset: (ECNAsset *) asset	{
	//	ECNProjectDocument *document = [asset document];
	
	ECNOSCTxAssetInstance *oscTxInstance = [[ECNOSCTxAssetInstance alloc] initWithAsset: asset ];
	
	if (oscTxInstance != nil)	{
		[oscTxInstance setValue: OSCtxAssetInstanceDefaultNameValue forPropertyKey: ECNObjectNameKey];
	}
	return oscTxInstance;
	
}

+ (ECNAssetInstance *)assetInstanceWithAsset: (ECNAsset *) asset	{
	return [ECNOSCTxAssetInstance oscTxAssetInstanceWithAsset: asset];
}

#pragma mark Accessors 
- (ECNOSCTargetAsset *)oscAsset {
	return (ECNOSCTargetAsset *)[self valueForPropertyKey: AssetKey];
}


- (void) addPortToObserve: (ECNPort *)outputport	{
	if (!outputport) return;
	[[self valueForPropertyKey: OSCTxAssetInstanceObservedPortsArrayKey] addObject: outputport];
	NSLog (@"added %@ port to list of port to observe", outputport);
}


#pragma mark -
#pragma mark Overrides
#pragma mark - ECNObject overrides

#pragma mark - ECNElement overrides

- (bool) prepareForPlayback	{
	ECNOSCTargetAsset* asset = [self oscAsset];

	OSCOutPort	*OSCtarget = [asset loadAsset];

	if (OSCtarget)	{
//		_OSCOutPort = [OSCtarget retain];
		return true;	
	} else 
		return false;
}


// ovverride of method called by [super executeAtTime:(NSTimeInterval)time] during playback
- (BOOL) executeAtTime:(NSTimeInterval)time {
	
	ECNOSCTargetAsset* asset = [self oscAsset];
	NSArray *portkeysArray = [self valueForPropertyKey: OSCTxAssetInstanceObservedPortsArrayKey];
	NSString *addressPattern = [self valueForPropertyKey: OSCTxAssetInstanceAddressPatternKey];
	
	
	if ((!asset) || (!portkeysArray) || (!addressPattern) ) return false;
	
	int nPorts = [portkeysArray count];
	if (nPorts <=0) return true; // no values to send, exit
	
	// create an array to store values to send
	NSMutableArray *valuesArray = [NSMutableArray arrayWithCapacity: 0];
	
	// fill the array with output ports values
	int c;
	id portValue;
	for (c=0; c < nPorts; c++)	{
		portValue = [(ECNPort *)[portkeysArray objectAtIndex: c] value];
		portValue = portValue == nil ? [NSNull null] : portValue;
		[valuesArray addObject: portValue];
	}
	
	bool result = [asset sendValues: valuesArray toAddress: addressPattern];
	if (result)
		return [super executeAtTime: time];
	else 
		return false;
	
}


#pragma mark OSC methods

- (void) sendObservedValues	{
	
	
	//NSLog(@"%s",__func__);
	
	
/*	OSCMessage		*msg = nil;
	OSCBundle		*bundle = nil;
	OSCPacket		*packet = nil;*/
	

	
	//	make a message to the specified address
/*	msg = [OSCMessage createWithAddress: host];
	
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
	
	_lastValueSent = value;*/
}

@end
