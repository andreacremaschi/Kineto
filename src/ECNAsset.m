//
//  ECNAsset.m
//  kineto
//
//  Created by Andrea Cremaschi on 11/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import "ECNAsset.h"
#import "KIncludes.h"


@interface ECNAsset (PrivateMethods)
- (bool) checkIfAssetExists	;

@end

@implementation ECNAsset

// +  + Object specific properties  +
NSString *AssetFilePathKey = @"file_path";


// +  + Default values  +  +  +  +  +
NSString *AssetClassValue = @"Asset";
NSString *AssetNameDefaultValue = @"New asset";

// +  +  +  +  +  +  +  +  +  +  +  +


#pragma mark *** Init methods

- (NSMutableDictionary *) attributesDictionary	{
	
	NSMutableDictionary* dict = [super attributesDictionary];
	
	// set default attributes values
	[dict setValue: AssetClassValue forKey: ECNObjectClassKey];
	
	NSDictionary *propertiesDict = [NSDictionary dictionaryWithObjectsAndKeys:
									@"", AssetFilePathKey,
									nil];
	
	//[_attributes addEntriesFromDictionary: attributesDict];
	[[dict objectForKey: ECNPropertiesKey] addEntriesFromDictionary: propertiesDict ];
	
	return dict;
	
	
}

- (id) initAssetWithProjectDocument: (ECNProjectDocument *)document
					   withFilePath: (NSString *)filePath	{
	
	[document willChangeValueForKey: @"assets"];
	self = [super initWithProjectDocument: document];
	
	[self setValue:filePath forPropertyKey: AssetFilePathKey]; 
	
	if (self)	{
		// check if file exists and load it
		if (![self checkIfAssetExists])	{
			[self release];
			return nil;
		}
	}
	[document didChangeValueForKey: @"assets"];
	
	return self;
}

#pragma mark *** Constructors ***

/*	// this is an abstract class, so: no constructor!
+ (ECNAsset *)assetWithDocument: (ECNProjectDocument *)document {
	ECNAsset *newAsset = [[ECNAsset alloc] initWithProjectDocument: document];
	
	if (newAsset != nil)	{
		[newAsset setValue: AssetNameDefaultValue forPropertyKey: ECNObjectNameKey];
	}
	return newAsset;
	
}*/

+ (Class) instanceClass { return nil; } // this has to be overridden in subclasses

#pragma mark *** Asset methods

- (void) addDelegate: (id) delegate	{
	TFThrowMethodNotImplementedException();
	
	return;
}
- (void) removeDelegate: (id) delegate {
	TFThrowMethodNotImplementedException();
	
	return ;
}

- (NSString *)position	{
	return 	[self valueForPropertyKey: AssetFilePathKey];
}

- (bool) checkIfAssetExists	{
	// TODO: implementare
	return true;	
}


- (id) loadAsset	{
	return nil;
}

- (bool) loadAssetWithError: (NSError*)error {
	TFThrowMethodNotImplementedException();
	
	return false;
	
}


#pragma mark - ECNObject overrides

- (bool) willReturnAfterLoadingWithError: (NSError **)error	{
	//return [self loadAssetWithError: error];
	return true;
}

@end
