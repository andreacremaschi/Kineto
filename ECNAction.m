//
//  ECNAction.m
//  kineto
//
//  Created by Andrea Cremaschi on 16/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECNAction.h"
#import "ECNElementAction.h"
#import "ECNSceneAction.h"

@implementation ECNAction

// +  + Elements specific properties  +
NSString *ECNActionTargetKey = @"target"; // target that will be hit by this action
NSString *ECNActionNameKey = @"action_name"; // target that will be hit by this action
// +  +  +  +  +  +  +  +  +  +  +  +

// +  + Default values  +  +  +  +  +
NSString *ECNActionClassValue = @"Action";
NSString *ECNActionDefaultName = @"Generic action";
// +  +  +  +  +  +  +  +  +  +  +  +




#pragma mark *** Initialization ***


- (NSMutableDictionary *) attributesDictionary	{
	
	NSMutableDictionary *dict = [super attributesDictionary];
	
	// set default attributes values
	[dict setValue: ECNActionClassValue forKey: ECNObjectClassKey];
	
	NSDictionary *propertiesDict = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNull null], ECNActionTargetKey,
									ECNActionDefaultName, ECNActionNameKey,
									nil];
	
	//[_attributes addEntriesFromDictionary: attributesDict];
	[[dict objectForKey: ECNPropertiesKey] addEntriesFromDictionary: propertiesDict ];
	
	// NO default values: ECNElement and ECNShape are abstract classes without constructors!
	
	return dict;
	
	
}

+ (NSString *) actionName	{
	return ECNActionDefaultName;
}

+ (Class ) targetType	{
	return nil;
}

- (NSString *)description	{
	id target = [self valueForPropertyKey: ECNActionTargetKey];
	
	// questo controllo non funziona in caso di data binding
	// perchè target è di classe NSKVONotifying_xxx
	//if ([target isKindOfClass: [ECNObject class]]) return @"";
	

	NSString *description = [[[self class] actionName] stringByAppendingString: @" "];
	return [description stringByAppendingString: [target name]];
}

#pragma mark Constructors
+ (ECNAction *)actionWithDocument: (ECNProjectDocument *)document withTarget: (ECNObject *)target	{
	//NB ELEMENT is an abstract class, that should never return an instance
	return nil;
	
}

+ (NSArray *)availableActionClasses	{
	NSMutableArray *array = [NSMutableArray arrayWithCapacity: 0];
	[array addObject: [ECNElementActivateAction class]];
	[array addObject: [ECNElementDeactivateAction class]];
	[array addObject: [ECNElementToggleAction class]];
	[array addObject: [ECNSceneActivateAction class]];
	[array addObject: [ECNSceneDeactivateAction class]];
	[array addObject: [ECNSceneToggleAction class]];
	return array;
}

// create an array of available actions for an object of class objectType
+ (NSArray *)actionListForObjectType: (Class ) objectType {
	id dummyObject = [[objectType alloc] autorelease];
	if (![dummyObject isKindOfClass: [ECNObject class]]) return nil;
	
	NSArray *actionsArray = [ECNAction availableActionClasses];
	NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity: 0];
	for (Class actionClass in actionsArray)	{
		//dummyObject = [[actionClass alloc] autorelease];
		if (([dummyObject isEqual: [actionClass targetType]]) || ([dummyObject isKindOfClass: [actionClass targetType]]))
			[resultArray addObject: actionClass];
		
	}
	
	return resultArray;
		  
}


#pragma mark KVC/KVO methods
- (ECNObject *)target	{
	return [self valueForPropertyKey: ECNActionTargetKey];
}

- (void) setTarget: (ECNObject *)target	{
	if (![target isKindOfClass: [[self class] targetType]]) return;
	
	[self setValue: target forPropertyKey: ECNActionTargetKey];
	
}

#pragma mark -
#pragma mark Action methods

- (void) performAction	{
	
}


@end
