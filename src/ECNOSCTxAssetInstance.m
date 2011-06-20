//
//  ECNOSCTargetAssetInstance.m
//  kineto
//
//  Created by Andrea Cremaschi on 28/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import "ECNOSCTxAssetInstance.h"
#import "ECNOSCTargetAsset.h"
 
// +  + Elements specific properties   +

NSString *OSCTxAssetInstanceAddressPatternKey = @"osc_addresspattern";
NSString *OSCTxAssetInstanceBundleKey = @"osc_bundle";
NSString *OSCTxAssetInstancePacketComposerScriptKey = @"packet_composer_script";

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
@synthesize lastPacketSent;

- (NSMutableDictionary *) attributesDictionary	{
	
	
	NSMutableDictionary* dict = [super attributesDictionary];
	
	// set default attributes values
	[dict setValue: OSCtxAssetInstanceClassValue forKey: ECNObjectClassKey];
	
	NSDictionary *propertiesDict = [NSDictionary dictionaryWithObjectsAndKeys:
									AddressPatternDefaultValue, OSCTxAssetInstanceAddressPatternKey,
									[NSNumber numberWithBool: [BundleDefaultValue boolValue]], OSCTxAssetInstanceBundleKey,
									[NSMutableArray arrayWithCapacity: 0], OSCTxAssetInstanceObservedPortsArrayKey,
									@"", OSCTxAssetInstancePacketComposerScriptKey,
									nil];
	
	
	//[_attributes addEntriesFromDictionary: attributesDict];
	[[dict objectForKey: ECNPropertiesKey] addEntriesFromDictionary: propertiesDict ];
	
	return dict;
		
}

- (id) initWithAsset: (ECNAsset *)asset
{
	self = [super initWithAsset: asset];
	if (self) {
		lastPacketSent= nil;	
	}
	return self;	
}

- (void)dealloc {	
	if (nil!= lastPacketSent) 
		[lastPacketSent release];
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

- (id) defaultValue	{
	return lastPacketSent;
	
}

- (NSImage *)icon {
	return [NSImage imageNamed: @"osc"];
}
- (bool) prepareForPlaybackWithError: (NSError **)error	{
	ECNOSCTargetAsset* asset = [self oscAsset];	
	return [asset loadAssetWithError: *error];

}


// ovverride of method called by [super executeAtTime:(NSTimeInterval)time] during playback
- (BOOL) executeAtTime:(NSTimeInterval)time {
	
	ECNOSCTargetAsset* asset = [self oscAsset];
	NSMutableArray *valuesArray = [NSMutableArray arrayWithCapacity: 0];
	 [valuesArray addObject: [self valueForPropertyKey: OSCTxAssetInstancePacketComposerScriptKey]];
	
	
	
	NSArray *portkeysArray = [self valueForPropertyKey: OSCTxAssetInstanceObservedPortsArrayKey];
	NSString *addressPattern = [self valueForPropertyKey: OSCTxAssetInstanceAddressPatternKey];
	
	
	if ((!asset) || (!portkeysArray) || (!addressPattern) ) return false;
	
	/*int nPorts = [portkeysArray count];
	if (nPorts <=0) return true; // no values to send, exit
	
	// create an array to store values to send
	NSMutableArray *valuesArray = [NSMutableArray arrayWithCapacity: 0];
	
	// fill the array with output ports values
	int c;
	id portValue;
	for (c=0; c < nPorts; c++)	{
		portValue = [(ECNPort *)[portkeysArray objectAtIndex: c] value];
		portValue = portValue == nil ? [NSNull null] : portValue;
		//NSLog (@"%@", portValue);
		[valuesArray addObject: portValue];
	}*/

	NSError *error;
	bool result = [asset sendValues: valuesArray 
						  toAddress: addressPattern
							  error: &error];
	if (result)	{

		
		NSDictionary *oldPacket = lastPacketSent;
		lastPacketSent = [[NSDictionary dictionaryWithObjectsAndKeys:
						  valuesArray,@"values",
						  [NSNumber numberWithInt: time], @"timestamp",
						  nil] retain];
		
		if (oldPacket != nil) 
			[oldPacket release];
		
		return [super executeAtTime: time];
	}
	else {
		NSLog (@"Error sending OSC packet: %@", [error description]);
		return false;
	}
	
}

- (void) drawInCGContext: (CGContextRef)context withRect: (CGRect) rect {
	
	
}

#pragma mark OSC methods

/*- (void) sendObservedValues	{
	
	
	//NSLog(@"%s",__func__);
	
	
	OSCMessage		*msg = nil;
	OSCBundle		*bundle = nil;
	OSCPacket		*packet = nil;
	

	
	//	make a message to the specified address
	msg = [OSCMessage createWithAddress: host];
	
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
}*/

@end
