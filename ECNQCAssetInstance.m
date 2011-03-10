//
//  ECNQCAssetInstance.m
//  kineto
//
//  Created by Andrea Cremaschi on 22/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECNQCAssetInstance.h"
#import "ECNProjectDocument.h"

#import "ECNQCAsset.h"

// +  + Elements specific properties   +

// +  +  +  +  +  +  +  +  +  +  +  +  +

// +  +  + QC renderer input ports +  +  +
// +  +  +  +  +  +  +  +  +  +  +  +

// +  +  + QC renderer output ports +  +  +

// +  +  +  +  +  +  +  +  +  +  +  +


// +  + Default values  +  +  +  +  +
NSString *QCAssetInstanceClassValue = @"ECNQCAssetInstance";
NSString *QCAssetInstanceDefaultNameValue = @"Quartz Composer patch";
NSString *AssetInstanceQCIconDefaultValue = @"assets_qcpatch";
// +  +  +  +  +  +  +  +  +  +  +  +



@implementation ECNQCAssetInstance


- (NSMutableDictionary *) attributesDictionary	{
	
	
	NSMutableDictionary* dict = [super attributesDictionary];
	
	// set default attributes values
	[dict setValue: QCAssetInstanceClassValue forKey: ECNObjectClassKey];
	
	NSDictionary *propertiesDict = [NSDictionary dictionaryWithObjectsAndKeys:
									nil];
	
	
	//[_attributes addEntriesFromDictionary: attributesDict];
	[[dict objectForKey: ECNPropertiesKey] addEntriesFromDictionary: propertiesDict ];
		
	return dict;
	
	
}

- (id) initWithAsset: (ECNAsset *)asset
{
	self = [super initWithAsset: asset];
	if (self) {

		// Quartz Composer asset instance has the same port as the Quartz Composer patch!

		// INPUT PORTS
		for (NSDictionary *dict in [asset valueForPropertyKey: QCAssetInputPortsKey])
			[self addInputPortWithType: ECNPortTypeImage
								forKey: [dict valueForKey: QCAssetPortKey]
						withAttributes: nil];
		
		// OUTPUT PORTS
		for (NSDictionary *dict in [asset valueForPropertyKey: QCAssetOutputPortsKey])
			[self addOutputPortWithType: ECNPortTypeImage
								forKey: [dict valueForKey: QCAssetPortKey]
						withAttributes: nil];
		
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
	return [ECNQCAsset class];
}

+ (NSString *)iconName	{
	return AssetInstanceQCIconDefaultValue;
}

#pragma mark Constructors
+ (ECNQCAssetInstance *)qcAssetInstanceWithAsset: (ECNAsset *) asset	{
//	ECNProjectDocument *document = [asset document];
	
	ECNQCAssetInstance *qcInstance = [[ECNQCAssetInstance alloc] initWithAsset: asset ];
									   
	if (qcInstance != nil)	{
		[qcInstance setValue: QCAssetInstanceClassValue forPropertyKey: ECNObjectClassKey];
		[qcInstance setValue: QCAssetInstanceDefaultNameValue forPropertyKey: ECNObjectNameKey];
	}
	return qcInstance;
	
	return nil;
	
}

+ (ECNAssetInstance *)assetInstanceWithAsset: (ECNAsset *) asset	{	
	return [ECNQCAssetInstance qcAssetInstanceWithAsset: asset];
	
}

#pragma mark Accessors 
- (ECNQCAsset *)qcAsset {
	return (ECNQCAsset *)[self valueForPropertyKey: AssetKey];
}


#pragma mark -
#pragma mark Overrides
#pragma mark - ECNObject overrides

#pragma mark - ECNElement overrides

- (bool) prepareForPlayback	{
	ECNQCAsset* asset = [self qcAsset];
	
	QCRenderer *renderer = [asset loadAsset];
	
	if (renderer)	{
		_renderer = [renderer retain];
		return true;	
	} else 
		return false;
}

// ovverride of method called by [super executeAtTime:(NSTimeInterval)time] during playback
- (BOOL) executeAtTime:(NSTimeInterval)time {
	if (!_renderer) return false;
	
	[_renderer renderAtTime: time arguments: nil];
	return [super executeAtTime: time ];
}



@end
