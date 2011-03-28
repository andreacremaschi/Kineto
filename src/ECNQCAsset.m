//
//  ECNQCAsset.m
//  kineto
//
//  Created by Andrea Cremaschi on 11/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Quartz/Quartz.h>

#import "ECNQCAsset.h"
#import "ECNQCAssetInstance.h"


@implementation ECNQCAsset



// +  + Object specific properties  +
NSString *QCAssetRenderSizeKey = @"QC render size";
NSString *QCAssetInputPortsKey = @"qc_input_ports";
NSString *QCAssetOutputPortsKey = @"qc_output_ports";

NSString *QCAssetPortKey = @"qc_input_ports";
NSString *QCAssetPortType = @"qc_input_ports";

// +  + Default values  +  +  +  +  +
NSString *QCAssetClassValue = @"QCAsset";
NSString *QCAssetNameDefaultValue = @"Quartz Composer patch";

// +  +  +  +  +  +  +  +  +  +  +  +


#pragma mark *** Init methods

- (NSMutableDictionary *) attributesDictionary	{
	
	NSMutableDictionary* dict = [super attributesDictionary];
	
	// set default attributes values
	[dict setValue: QCAssetClassValue forKey: ECNObjectClassKey];
	
	NSDictionary *propertiesDict = [NSDictionary dictionaryWithObjectsAndKeys:	
									NSStringFromSize(NSMakeSize(640, 400)),  QCAssetRenderSizeKey, 
									[NSMutableArray arrayWithCapacity: 0],  QCAssetInputPortsKey, 
									[NSMutableArray arrayWithCapacity: 0],  QCAssetOutputPortsKey, 
									nil];
	
	//[_attributes addEntriesFromDictionary: attributesDict];
	[[dict objectForKey: ECNPropertiesKey] addEntriesFromDictionary: propertiesDict ];
	
	return dict;
	
	
}

#pragma mark *** Constructors ***

+ (ECNQCAsset *)assetWithDocument: (ECNProjectDocument *)document 
					withQCFilePath: (NSString *)filePath	{
	
	ECNQCAsset *newQCAsset = [[[ECNQCAsset alloc] initAssetWithProjectDocument: document
															withFilePath: filePath] autorelease];
	
	if (newQCAsset != nil)	{

		[newQCAsset setValue: QCAssetNameDefaultValue forPropertyKey: ECNObjectNameKey];
		
		// try to load Quartz Composer file
		QCRenderer *renderer = [newQCAsset loadAsset];
		if (renderer == nil)		{
			return nil;			
		}
		
		// gets all the input ports for selected patch and create a list of key/type pairs to store in asset property list
		NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
		for (NSString *keyName in [renderer inputKeys])	{
			//id portValue = [renderer valueForInputKey: keyName];
			NSDictionary * dict =  [NSDictionary dictionaryWithObjectsAndKeys:	
									keyName,  QCAssetPortKey, 
								//	[[portValue class] description],  QCAssetPortType, 
									nil];	
			NSLog (@"QC asset has input port: %@", keyName);
			[array addObject: dict];
		}
		[[newQCAsset valueForPropertyKey: QCAssetInputPortsKey] addObjectsFromArray: array];
		
		// do the same with output ports
		array = [NSMutableArray arrayWithCapacity:0];
		for (NSString *keyName in [renderer outputKeys])	{
			//id portValue = [renderer valueForOutputKey: keyName];
			NSDictionary * dict =  [NSDictionary dictionaryWithObjectsAndKeys:	
									keyName,  QCAssetPortKey, 
								//	[[portValue class] description],  QCAssetPortType, 
									nil];		
			NSLog (@"QC asset has output port: %@", dict);
			[array addObject: dict];
		}
		
		[[newQCAsset valueForPropertyKey: QCAssetOutputPortsKey] addObjectsFromArray: array];
		
		
	}
	return newQCAsset;
	
}

+ (Class) instanceClass {
	return [ECNQCAssetInstance class];	
}


# pragma mark *** ECNObject overrides
/*- (NSArray *)propertyKeys	{

	NSMutableArray *pKeys = [NSMutableArray arrayWithArray: [super propertyKeys]];
	
//	return [pKeys arrayByAddingObjectsFromArray: [_qcRenderer inputKeys] ];	
}

- (NSArray *)outputKeys	{
	
	NSMutableArray *oKeys = [NSMutableArray arrayWithArray: [super outputKeys]];
	
//	return [oKeys arrayByAddingObjectsFromArray: [_qcRenderer outputKeys] ];	
}
*/



# pragma mark *** ECNAsset overrides

- (id) loadAsset	{

	QCRenderer *renderer;
	NSSize renderSize = NSSizeFromString( [self valueForPropertyKey: QCAssetRenderSizeKey]  );
	NSString *filePath = [self valueForPropertyKey: AssetFilePathKey];

	@try {
				
		CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName( kCGColorSpaceGenericRGB);
		renderer = [[QCRenderer alloc] initOffScreenWithSize:	renderSize
															   colorSpace:	colorSpace
															  composition:	[QCComposition compositionWithFile: filePath]
								 ];
		
		CGColorSpaceRelease(colorSpace);
		
		NSLog (@"ECNQCAsset created: %@", filePath);
		
		if(renderer == nil) {
			NSLog(@"Cannot create QCRenderer");
			//[self release];
			return nil;
		}

		return renderer;
		
	}
	@catch (NSException * exception) {
		
		// can't load Quartz Composition: release and return error!
		NSLog(@"Error loading Quartz Composition '%@': %@", filePath, exception);			
		//[self release];
		return nil;
		
	}
	
	//should never arrive here
	return renderer;
	
}


@end
