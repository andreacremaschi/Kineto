//
//  ECNOSCTargetAssetInstance.m
//  kineto
//
//  Created by Andrea Cremaschi on 28/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import "ECNOSCTxAssetInstance.h"
#import "ECNOSCTargetAsset.h"
#import "KBNFWordObject.h"

// +  + Elements specific properties   +

NSString *OSCTxAssetInstanceAddressPatternKey = @"osc_addresspattern";
NSString *OSCTxAssetInstanceArgumentsKey = @"osc_arguments";
//NSString *OSCTxAssetInstancePacketComposerScriptKey = @"packet_composer_script";
//NSString *OSCTxAssetInstanceBundleKey = @"osc_bundle";


//NSString *OSCTxAssetInstanceMessagesArrayKey = @"osc_messages";
//NSString *OSCTxAssetInstanceObservedPortsArrayKey = @"observed_ports";

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
									//[NSArray array], OSCTxAssetInstanceMessagesArrayKey,
									AddressPatternDefaultValue, OSCTxAssetInstanceAddressPatternKey,
									[NSMutableArray array], OSCTxAssetInstanceArgumentsKey,
//									@"", OSCTxAssetInstancePacketComposerScriptKey,
									//[NSNumber numberWithBool: [BundleDefaultValue boolValue]], OSCTxAssetInstanceBundleKey,
									//[NSMutableArray arrayWithCapacity: 0], OSCTxAssetInstanceObservedPortsArrayKey,
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

- (void) setAddressPattern: (NSString*)pattern {
	[self setValue: pattern forPropertyKey: OSCTxAssetInstanceAddressPatternKey];

}

- (NSString *) addressPattern {
	return [self valueForPropertyKey:OSCTxAssetInstanceAddressPatternKey];
}

- (NSMutableArray *)argumentsArray {
	return [self valueForPropertyKey:OSCTxAssetInstanceArgumentsKey];
}

- (void)setArgumentsArray: (NSMutableArray*)array {
	[self setValue: array forPropertyKey:OSCTxAssetInstanceArgumentsKey];
}

/*- (void) setScriptObject: (KBNFMessageObject*)scrObject {
	[self setValue: scrObject forPropertyKey: OSCTxAssetInstancePacketComposerScriptKey];
	
}

- (KBNFMessageObject *) scriptObject {
	return [self valueForPropertyKey:OSCTxAssetInstancePacketComposerScriptKey];
}*/


/*- (void) addPortToObserve: (ECNPort *)outputport	{
	if (!outputport) return;
	[[self valueForPropertyKey: OSCTxAssetInstanceObservedPortsArrayKey] addObject: outputport];
	NSLog (@"added %@ port to list of port to observe", outputport);
}*/


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
		
	if (!asset) return false;
	
	bool result = true;
	NSMutableArray *lastValuesSent = [NSMutableArray array];

	NSError *error;
	NSString *addressPattern = [self valueForPropertyKey: OSCTxAssetInstanceAddressPatternKey];
	NSArray *argumentsArray = [self valueForPropertyKey: OSCTxAssetInstanceArgumentsKey];
	
	if ((nil != addressPattern) && (nil!= argumentsArray) && [argumentsArray count] >0) {
		
		NSMutableArray *valuesArray = [NSMutableArray array];
		
		for (id argument in argumentsArray)
			if ([argument isKindOfClass: [KBNFWordObject class]]) {
				id value = [argument evaluateWordObjectValue];
				if (nil!=value)
				[valuesArray addObject: value];
				
			}
		
		if ([valuesArray count] > 0)
		if (![asset sendValues: valuesArray
					 toAddress: addressPattern
						 error: &error])
			result = false;
		else 
			[lastValuesSent addObject: [NSDictionary dictionaryWithObjectsAndKeys: 
										valuesArray, @"message",
										addressPattern, @"address",
										nil]];
		
		
	}
	if (result)	{
		
		
		NSDictionary *oldPacket = lastPacketSent;
		lastPacketSent = [[NSDictionary dictionaryWithObjectsAndKeys:
						   lastValuesSent,@"values",
						   [NSNumber numberWithInt: time], @"timestamp",
						   nil] retain];
		
		if (oldPacket != nil) 
			[oldPacket release];
		
		return [super executeAtTime: time];
	}
	else {
		NSLog (@"Error sending OSC packet:");// %@", [error description]);
		return false;
	}
	
}
/*- (BOOL) executeAtTime:(NSTimeInterval)time {
	
	ECNOSCTargetAsset* asset = [self oscAsset];
	
	NSMutableArray *messagesArray = [self valueForKey: OSCTxAssetInstanceMessagesArrayKey];
	
	if (!asset) return false;

	bool result = true;
	NSMutableArray *lastValuesSent = [NSMutableArray array];
	for (id message in messagesArray) {
		NSError *error;
		NSString *addressPattern = [message valueForKey: OSCTxAssetInstanceAddressPatternKey];
		NSString *messagebundle = [message valueForKey: OSCTxAssetInstancePacketComposerScriptKey];
		if ((nil != addressPattern) && (nil!= messagebundle))
		if (![asset sendValues: [NSArray arrayWithObject: messagebundle ]
				toAddress: addressPattern
					error: &error])
			result = false;
		else 
			[lastValuesSent addObject: [NSDictionary dictionaryWithObjectsAndKeys: 
										messagebundle, @"message",
										addressPattern, @"address",
										nil]];
		

	}

	if (result)	{

		
		NSDictionary *oldPacket = lastPacketSent;
		lastPacketSent = [[NSDictionary dictionaryWithObjectsAndKeys:
						  lastValuesSent,@"values",
						  [NSNumber numberWithInt: time], @"timestamp",
						  nil] retain];
		
		if (oldPacket != nil) 
			[oldPacket release];
		
		return [super executeAtTime: time];
	}
	else {
		NSLog (@"Error sending OSC packet:");// %@", [error description]);
		return false;
	}
	
}
*/
- (void) drawInCGContext: (CGContextRef)context withRect: (CGRect) rect {
	
	
}


@end
