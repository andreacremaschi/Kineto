//
//  ECNTrigger.m
//  kineto
//
//  Created by Andrea Cremaschi on 16/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECNTrigger.h"
#import "ECNAction.h"


@interface ECNTrigger (PrivateMethods)	
	- (bool) checkIfHasToBeActivated;
	- (void) startLatencyPeriod;
	- (void) _exitLatencyPeriod: (NSTimer*) timer;
	- (bool) checkIfHasToBeDeactivated;
@end

@implementation ECNTrigger

// +  + Elements specific properties  +

NSString *ECNTriggerPortToObserveKey = @"port_to_observe"; // port to observe. The way this is identified is defined in subclasses

NSString *ECNTriggerLatencyKey = @"latency"; // the time the trigger will be inactive after activating

NSString *ECNTriggerActivationThresholdKey = @"activation_threshold"; // Activation threshold
NSString *ECNTriggerDeactivationThresholdKey = @"deactivation_threshold"; // Deactivation threshold

NSString *ECNTriggerActivationActionsListKey = @"activation_actions";
NSString *ECNTriggerDeactivationActionsListKey = @"deactivation_actions";

// +  +  +  +  +  +  +  +  +  +  +  +


// +  + Default values  +  +  +  +  +
NSString *ECNTriggerClassValue = @"ECNTrigger";
// +  +  +  +  +  +  +  +  +  +  +  +


#pragma mark -
#pragma mark = Initialization and class methods
#pragma mark -

- (id) init {
	self = [super init];
	if (self) {
		_flags.isActive	=false;
		_flags.shouldCommitActivationActions=false;
		//_flags.triggerTime = [[NSDate alloc] init];
	}
	return self;
}

- (NSMutableDictionary *) attributesDictionary	{
	
	NSMutableDictionary *dict = [super attributesDictionary];
	
	// set default attributes values
	[dict setValue: ECNTriggerClassValue forKey: ECNObjectClassKey];
	
	NSDictionary *propertiesDict = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNull null], ECNTriggerPortToObserveKey, 
									[NSNumber numberWithFloat: 0.0], ECNTriggerLatencyKey, 
									[NSNumber numberWithFloat: 0.5], ECNTriggerActivationThresholdKey, 
									[NSNumber numberWithFloat: 0.5], ECNTriggerDeactivationThresholdKey,
									[NSMutableArray arrayWithCapacity: 0], ECNTriggerActivationActionsListKey,
									[NSMutableArray arrayWithCapacity: 0], ECNTriggerDeactivationActionsListKey,
									nil];
	
	//[_attributes addEntriesFromDictionary: attributesDict];
	[[dict objectForKey: ECNPropertiesKey] addEntriesFromDictionary: propertiesDict ];
	
	// NO default values: ECNElement and ECNShape are abstract classes without constructors!
	
	
	/*	[dict setValue: ElementClassValue forKey: ECNObjectClassKey];
	 [dict setValue: ElementNameDefaultValue forPropertyKey: ECNObjectNameKey];*/
	
	return dict;
	
	
}

- (void) dealloc {
	
	//[_flags.triggerTime release];
	[super dealloc];
}

#pragma mark Constructors
+ (ECNTrigger *)triggerWithDocument: (ECNProjectDocument *)document	{
	//NB ELEMENT is an abstract class, that should never return an instance
	return nil;
	
}



#pragma mark -
#pragma mark = Property edit
#pragma mark -
#pragma mark Accessors

- (void) setPortToObserve: (ECNPort *)port_to_observe	{
	[self setValue: port_to_observe forPropertyKey: ECNTriggerPortToObserveKey];
}

- (ECNPort *) portToObserve	{
	return [self valueForPropertyKey: ECNTriggerPortToObserveKey];
}

#pragma mark Action arrays management

- (NSArray *) activationActions {
	return [self valueForPropertyKey: ECNTriggerActivationActionsListKey];
}

- (NSArray *)deactivationActions	{
	return [self valueForPropertyKey: ECNTriggerDeactivationActionsListKey];
}


- (void) addActivationAction: (ECNAction*) newAction	{

	if (!newAction) return;
	
	NSMutableArray *activationActionArray = [self valueForPropertyKey: ECNTriggerActivationActionsListKey];
	[activationActionArray addObject: newAction];
	 
}
	
#pragma mark -
#pragma mark = Playback
#pragma mark -


- (id) lastValue	{
	return _flags.lastValue;
}

#pragma mark Observing port for value changes


- (void) beginObservingElement	{

	_flags.isActive = false;
	_flags.shouldCommitActivationActions = false;
	_flags.shouldCommitDeactivationActions = false;
	
	// register self for port changes notification
	[[self valueForPropertyKey: ECNTriggerPortToObserveKey] addObserver: self
		   forKeyPath: @"value"
			  options: NSKeyValueObservingOptionNew
			  context: nil];
	
}


- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context	{

	
	
	// 1. in latency period:
	// ACHTUNG: this check shouldn't be done here! 
	// this method is called only when values change, but the deactivation should happen 
	// independently from value changes
	if ((_flags.isActive) && (_flags.shouldBeDeactivated) && [self checkIfHasToBeDeactivated]) {
		_flags.isActive = false;
		_flags.shouldBeDeactivated=false;
		_flags.shouldCommitDeactivationActions = true;
	}

	// 2. not in latency period:
	// store current value as in latency period it will not be updated!
	if (!(_flags.isActive) && [self portToObserve]) {
		id tempValue = _flags.lastValue;
		_flags.lastValue = [[[self portToObserve] value] retain];
		[tempValue release];
	}
	
	// 3. entering in latency period:
	// if not in latency period,
	// check (in subclass method) if trigger has to be activated
	if (!(_flags.isActive) && [self checkIfHasToBeActivated])	{

		// the trigger should commit activation actions!
		// set the flag 
		_flags.shouldCommitActivationActions = true;
		_flags.shouldBeDeactivated = true;
		_flags.isActive = true;

		// start latency period
		[self startLatencyPeriod];
		
	}
	return;
}

- (void) endObservingElement	{
	
	// unregister self for port changes notification
	[[self valueForPropertyKey: ECNTriggerPortToObserveKey] removeObserver:self 
																forKeyPath:@"value"];
	
}


#pragma mark State modifications

- (bool) isActive	{
	return _flags.isActive;
	
}

#pragma mark Latency period

- (void) startLatencyPeriod
{
	NSTimeInterval latencyPeriod = [[self valueForPropertyKey: ECNTriggerLatencyKey] floatValue];
	if (latencyPeriod > 0)	{
		_flags.shouldBeDeactivated = false;
		//NSLog(@"latency period begins: %.2f", latencyPeriod);
		[[NSRunLoop currentRunLoop] addTimer: [NSTimer timerWithTimeInterval: latencyPeriod
																	 target: self
																   selector: @selector(_exitLatencyPeriod:)
																   userInfo: nil
																	repeats: false]
									 forMode: NSDefaultRunLoopMode];
	}
	else _flags.shouldBeDeactivated = true;
	

/*	[_flags.triggerTime release];
	_flags.triggerTime = [[NSDate date] retain];
	[_flags.triggerTime retain];*/
	
}

/*
- (bool) checkIfLatencyPeriodIsOver: (NSDate *)time {
	NSNumber *latency = [self valueForPropertyKey: ECNTriggerLatencyKey];
	NSTimeInterval passedTime = [time timeIntervalSinceDate: _flags.triggerTime] - [latency floatValue];
	bool latencyPeriodIsOver = (passedTime > 0);
	//NSLog (@"%.2f", [_triggerTime timeIntervalSinceDate: time] - _lLatency);
	if (latencyPeriodIsOver) [self exitLatencyPeriod];
	return latencyPeriodIsOver;
}*/


- (void) _exitLatencyPeriod: (NSTimer*) timer {
	_flags.shouldBeDeactivated = true;
}

#pragma mark Playback methods

- (void)triggerElement	{
	
	[self startLatencyPeriod];
	_flags.isActive=true;
	_flags.shouldCommitActivationActions = true;
	
}

- (bool) checkIfHasToBeActivated	{
	
	return false; // abstract class: check if triggered in subclasses
}

- (bool) checkIfHasToBeDeactivated	{
	
	return true; // abstract class: check if triggered in subclasses
}

- (bool) shouldCommitActions	{	
	return (_flags.shouldCommitActivationActions || _flags.shouldCommitDeactivationActions);
}

- (NSArray *)actionsToCommit	{
	NSArray *actionToCommit = [NSArray array];
	
	if (_flags.shouldCommitActivationActions)	{
		actionToCommit = [NSArray arrayWithArray: [self valueForPropertyKey: ECNTriggerActivationActionsListKey]];
		_flags.shouldCommitActivationActions = false;
	}
	if (_flags.shouldCommitDeactivationActions)	{
		actionToCommit = [actionToCommit arrayByAddingObjectsFromArray: [self valueForPropertyKey: ECNTriggerDeactivationActionsListKey]];
		_flags.shouldCommitDeactivationActions = false;
	}
	
	return actionToCommit;
}

@end
