//
//  ECNOSCTargetAssetInstance.m
//  kineto
//
//  Created by Andrea Cremaschi on 28/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import "ECNOSCTxAssetInstance.h"
#import "ECNOSCTargetAsset.h"
#import "KBNFOSCArgument.h"
#import "KIncludes.h"


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
		oscArgumentsCache = [[NSMutableArray array] retain];
	}
	return self;	
}

- (void)dealloc {	
	if (nil!= lastPacketSent) 
		[lastPacketSent release];
	[oscArgumentsCache release];
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
	
	ECNOSCTxAssetInstance *oscTxInstance = [[[ECNOSCTxAssetInstance alloc] initWithAsset: asset ] autorelease];
	
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


#pragma mark -
#pragma mark Overrides
#pragma mark - ECNObject overrides


- (bool) willReturnAfterLoadingWithError: (NSError **)error	{
	NSMutableArray *bnfArgumentsArray = [NSMutableArray array];

	// convert strings loaded from file to [KBNFOSCArgument class]s
	bool result=true;
	for (id argument in [self argumentsArray])
		if ([argument isKindOfClass: [NSString class]])	{
			id bnfObject = [KBNFOSCArgument scriptWithString: argument  withDocument: [self document]];
			if (nil != bnfObject) 
				[bnfArgumentsArray addObject: bnfObject];
			else  {
				result=false;
				*error = [NSError errorWithDomain:KErrorDomain
											 code:KErrorOSCArgumentParsing
										 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
												   KLocalizedString(@"KErrorFailedParsingOSCArgumentDesc", @"KErrorFailedParsingOSCArgumentDesc"),
												   NSLocalizedDescriptionKey,
												   KLocalizedString(@"KErrorFailedParsingOSCArgumentReason", @"KErrorFailedParsingOSCArgumentReason"),
												   NSLocalizedFailureReasonErrorKey,
												   KLocalizedString(@"KErrorFailedParsingOSCArgumentRecovery", @"KErrorFailedParsingOSCArgumentRecovery"),
												   NSLocalizedRecoverySuggestionErrorKey,
												   [NSNumber numberWithInteger:NSUTF8StringEncoding],
												   NSStringEncodingErrorKey,
												   nil]];
				NSLocalizedString(@"Error: couldn't parse the osc argument: %@", bnfObject);

			}
		}
	[self setArgumentsArray: bnfArgumentsArray];
	return result;
}


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
		
		if ([valuesArray count] > 0) {
			NSLog (@"%@", valuesArray);
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

- (void) drawInCGContext: (CGContextRef)context withRect: (CGRect) rect {
	
	
}


@end
