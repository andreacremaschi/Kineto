//
//  ECNShapeTrigger.m
//  kineto
//
//  Created by Andrea Cremaschi on 16/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import "ECNShapeTrigger.h"


@implementation ECNShapeTrigger

// +  + Elements specific properties  +
NSString *ECNMaskToObserveKey = @"mask_to_observe"; 
// +  +  +  +  +  +  +  +  +  +  +  +

// +  + Default values  +  +  +  +  +
NSString *ECNShapeTriggerClassValue = @"ECNShapeTrigger";
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
		[newTrigger setValue: [NSNumber numberWithFloat: 0.3] forPropertyKey:  ECNTriggerActivationThresholdKey];
		[newTrigger setValue: [NSNumber numberWithFloat: 0.3] forPropertyKey:  ECNTriggerDeactivationThresholdKey];
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

	// get the observed port
	id observedPortKey = [self valueForPropertyKey: ECNTriggerPortToObserveKey];
	id observedElement = [self valueForPropertyKey: ECNTriggerElementToObserveKey];
	
	// check if observed element is valid, and if its value is a ECNElement
	if ((observedElement == [NSNull null]) || (![observedElement isKindOfClass: [ECNElement class]])) return 0.0;

	// check if port is valid, and if its value is a NSNumber
	if ((observedPortKey == [NSNull null]) || (![observedPortKey isKindOfClass: [NSString class]])) return 0.0;
	
	NSObject *valueObject  = [observedElement valueForOutputKey: observedPortKey];
	if (![valueObject isKindOfClass: [NSNumber class]]) return 0.0;
	
	// return port value as a float
	value = [(NSNumber *)valueObject floatValue];
	return value;
}	

- (bool) checkIfHasToBeActivated	{
	float activationThreshold = [[self valueForPropertyKey:ECNTriggerActivationThresholdKey] floatValue];
	return ([self observedValue] > activationThreshold); 
}

- (bool) checkIfHasToBeDeactivated	{
	float deactivationThreshold = [[self valueForPropertyKey:ECNTriggerDeactivationThresholdKey] floatValue];	
	float observedValue = [self observedValue];
	return (observedValue <= deactivationThreshold); 
}


#pragma mark -
#pragma mark ### ECNTrigger overrides ###


#pragma mark Drawing methods
- (void) drawInCGContext: (CGContextRef)context
				withRect: (CGRect) rect	
{
	if (_flags.isActive) {
	
		ECNElement *elementToObserve = [self valueForPropertyKey: ECNTriggerElementToObserveKey];
		CGMutablePathRef elementPath = [elementToObserve quartzPathInRect: rect];
		
		
		//	NSColor *objectColor = [self strokeColor];
		
		
		CGContextSetRGBStrokeColor (context,
									0.0, 0.0, 1.0, 1.0
									);
		CGContextSetLineWidth (context, rect.size.width / 160.0 * 2.5);
		
		CGContextBeginPath(context);
		CGContextAddPath(context, elementPath);
		CGContextStrokePath( context);	
	}
	
	
	
}

@end
