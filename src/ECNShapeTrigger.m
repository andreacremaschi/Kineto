//
//  ECNShapeTrigger.m
//  kineto
//
//  Created by Andrea Cremaschi on 16/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECNShapeTrigger.h"


@implementation ECNShapeTrigger

// +  + Elements specific properties  +
NSString *ECNMaskToObserveKey = @"mask_to_observe"; 
// +  +  +  +  +  +  +  +  +  +  +  +

// +  + Default values  +  +  +  +  +
NSString *ECNShapeTriggerClassValue = @"ShapeTrigger";
// +  +  +  +  +  +  +  +  +  +  +  +


#pragma mark *** Initialization ***


- (NSMutableDictionary *) attributesDictionary	{
	
	NSMutableDictionary *dict = [super attributesDictionary];
	
	// set default attributes values
	[dict setValue: ECNShapeTriggerClassValue forKey: ECNObjectClassKey];
	
	NSDictionary *propertiesDict = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithInt: 0], ECNMaskToObserveKey,
									nil];
	
	//[_attributes addEntriesFromDictionary: attributesDict];
	[[dict objectForKey: ECNPropertiesKey] addEntriesFromDictionary: propertiesDict ];
	
	// NO default values: ECNElement and ECNShape are abstract classes without constructors!
	
	
	/*	[dict setValue: ElementClassValue forKey: ECNObjectClassKey];
	 [dict setValue: ElementNameDefaultValue forPropertyKey: ECNObjectNameKey];*/
	
	return dict;
	
	
}

#pragma mark Constructors


+ (ECNShapeTrigger *)shapeTriggerWithDocument: (ECNProjectDocument *)document {
	ECNShapeTrigger *newTrigger = [[[ECNShapeTrigger alloc] initWithProjectDocument: document] autorelease];
	if (newTrigger != nil)	{
		
		// set default values
		// default port to observe is set in method initWithProjectDocument in ECNShape.m
		[newTrigger setValue: [NSNull null] forPropertyKey:  ECNTriggerPortToObserveKey]; 
		[newTrigger setValue: [NSNumber numberWithFloat: 0.1] forPropertyKey:  ECNTriggerLatencyKey];
		[newTrigger setValue: [NSNumber numberWithFloat: 0.1] forPropertyKey:  ECNTriggerActivationThresholdKey];
		[newTrigger setValue: [NSNumber numberWithFloat: 0.9] forPropertyKey:  ECNTriggerDeactivationThresholdKey];
	}
	return newTrigger;
	
}


+ (ECNTrigger *)triggerWithDocument: (ECNProjectDocument *)document	{
	return [ECNShapeTrigger shapeTriggerWithDocument: document];
	
}

#pragma mark -
#pragma mark Accessors

- (int)maskToMonitor	{
	return [[self valueForPropertyKey: ECNMaskToObserveKey] intValue];	
}


#pragma mark -
#pragma mark = Playback
#pragma mark -
#pragma mark Playback methods
- (float) observedValue	{
	float value = 0.0;
	
	id observedPort = [self valueForPropertyKey: ECNTriggerPortToObserveKey];
	
	// check if port is valid, and if its value is a NSNumber
	if ((observedPort == [NSNull null]) || (![observedPort isKindOfClass: [ECNPort class]])) return 0.0;
	NSObject *valueObject  = [(ECNPort*)observedPort value];
	if (![valueObject isKindOfClass: [NSNumber class]]) return 0.0;
	
	value = [(NSNumber *)valueObject floatValue];
	return value;
}	

/*
- (float) observedValue	{
	float value = 0.0;
	
	int maskToMonitor = [self maskToMonitor];
	id observedPort = [self valueForPropertyKey: ECNTriggerPortToObserveKey];
	
	// check if port is valid, and if its value is a NSNumber
	if ((observedPort == [NSNull null]) || (![observedPort isKindOfClass: [ECNPort class]])) return 0.0;
	NSObject *valueObject  = [(ECNPort*)observedPort value];
	if (![valueObject isKindOfClass: [NSDictionary class]]) return 0.0;
	
	//TODO: implementare un controllo sulla maschera da osservare!!!!
	value = [[(NSDictionary *)valueObject valueForKey: @"diff_mask"] floatValue];
	return value;
}	
*/

- (bool) checkIfHasToBeActivated	{
	float activationThreshold = [[self valueForPropertyKey:ECNTriggerActivationThresholdKey] floatValue];
	return ([self observedValue] > activationThreshold); 
}

- (bool) checkIfHasToBeDeactivated	{
	float deactivationThreshold = [[self valueForPropertyKey:ECNTriggerDeactivationThresholdKey] floatValue];	
	return ([self observedValue] <= deactivationThreshold); 
}


@end
