//
//  ECNTrigger.m
//  kineto
//
//  Created by Andrea Cremaschi on 16/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import "ECNTrigger.h"
#import "ECNAction.h"
#import "KIncludes.h"


@interface ECNTrigger (PrivateMethods)	
	- (bool) checkIfHasToBeActivated;
	- (void) startLatencyPeriod;
	- (void) _exitLatencyPeriod: (NSTimer*) timer;
	- (bool) checkIfHasToBeDeactivated;
@end

@implementation ECNTrigger
@synthesize latencyTimer;

// +  + Elements specific properties  +

NSString *ECNTriggerElementToObserveKey = @"element_to_observe"; // port to observe. The way this is identified is defined in subclasses
NSString *ECNTriggerPortToObserveKey = @"port_to_observe"; // port to observe. The way this is identified is defined in subclasses

NSString *ECNTriggerLatencyKey = @"latency"; // the time the trigger will be inactive after activating

NSString *ECNTriggerActivationThresholdKey = @"activation_threshold"; // Activation threshold
NSString *ECNTriggerDeactivationThresholdKey = @"deactivation_threshold"; // Deactivation threshold
NSString *ECNTriggerBindThresholdValuesKey = @"bind_threshold_values"; // force threshold values to be the same


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
									[NSNull null], ECNTriggerElementToObserveKey,
									[NSNumber numberWithFloat: 0.0], ECNTriggerLatencyKey, 
									[NSNumber numberWithFloat: 0.5], ECNTriggerActivationThresholdKey, 
									[NSNumber numberWithFloat: 0.5], ECNTriggerDeactivationThresholdKey,
									[NSNumber numberWithBool: true], ECNTriggerBindThresholdValuesKey,
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


- (void) setActive: (bool) active {

	// no state change, return
	if (active == _flags.isActive) return;
	
	[self willChangeValueForKey: @"isActive"];
	// trigger deactivating
	if (active == false)	{
		_flags.isActive = false;
		_flags.shouldBeDeactivated=false;
		_flags.shouldCommitDeactivationActions = true;
	}
	else {
		// the trigger should commit activation actions!
		// set the flag 
		_flags.shouldCommitActivationActions = true;
		_flags.shouldBeDeactivated = false;
		_flags.isActive = true;
		
//		[self startLatencyPeriod];
		
	}
	[self didChangeValueForKey: @"isActive"];

}

- (NSNumber *) activation_threshold {
	return [self valueForPropertyKey: ECNTriggerActivationThresholdKey];	
}

- (void) setActivation_threshold: (NSNumber *)newValue {	
	[self setValue: newValue 
	forPropertyKey: ECNTriggerActivationThresholdKey];	
}

- (NSNumber *) deactivation_threshold {
	return [self valueForPropertyKey: ECNTriggerDeactivationThresholdKey];	
}

- (void) setDeactivation_threshold: (NSNumber *)newValue {	
	[self setValue: newValue 
	forPropertyKey: ECNTriggerDeactivationThresholdKey];	
}




/*
- (void) setActivationState: (NSUInteger) activationState	{
	if (activationState == NSOnState || NSOffState)
		// on or off state; 
		[self setActive: (activationState == NSOnState)];
	else {
		// mixed state: reset trigger
		[self willChangeValueForKey:@"isActive"];
		_flags.isActive = NSOffState;
		_flags.shouldBeDeactivated = false;
		_flags.shouldCommitActivationActions = false;
		_flags.shouldCommitDeactivationActions = false;
		[self didChangeValueForKey:@"isActive"];
	}
}*/

- (bool) isActive	{
	//element not set or element not active:return mixed state
	//ECNElement *elementToObserve = [self valueForPropertyKey: ECNTriggerElementToObserveKey];
	//if (!elementToObserve || (![elementToObserve activationState]) ) return NSMixedState;

	return _flags.isActive; // ? NSOnState : NSOffState;
}

- (void) setElementToObserve: (ECNElement *)element atPort: (NSString *)portKey	{
	[self setValue: portKey forPropertyKey: ECNTriggerPortToObserveKey];
	[self setValue: element forPropertyKey: ECNTriggerElementToObserveKey];
}

- (ECNElement*) elementToObserve {
	return [self valueForPropertyKey: ECNTriggerElementToObserveKey];
}


- (NSString *) keyOfPortToObserve	{
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
	
- (void) addDeactivationAction: (ECNAction*) newAction	{
	
	if (!newAction) return;
	
	NSMutableArray *deactivationActionArray = [self valueForPropertyKey: ECNTriggerDeactivationActionsListKey];
	[deactivationActionArray addObject: newAction];
	
}
#pragma mark -
#pragma mark = Playback
#pragma mark -


- (id) lastValue	{
	return _flags.lastValue;
}
- (NSTimeInterval) lastValueTime	{
	return _flags.lastValueTime;
}
- (void) setLastValue: (id) newValue 
			   atTime: (NSTimeInterval) time	{
	@synchronized (self) {
		[self willChangeValueForKey: @"lastValue"];
		id oldValue = _flags.lastValue ;
		_flags.lastValue = [newValue retain];
		_flags.lastValueTime = time;
		[oldValue release];
		[self didChangeValueForKey: @"lastValue"];
	}
}

#pragma mark Observing port for value changes


- (void) beginObservingElement	{

	_flags.isActive = false;
	_flags.shouldCommitActivationActions = false;
	_flags.shouldCommitDeactivationActions = false;
	
	/*// register self for port changes notification
	[[self valueForPropertyKey: ECNTriggerPortToObserveKey] addObserver: self
		   forKeyPath: @"value"
			  options: NSKeyValueObservingOptionNew
			  context: nil];*/
	
}

- (BOOL) executeAtTime:(NSTimeInterval)time {
	
	// 1. in latency period:
	if (_flags.isActive)  {	
		NSTimeInterval latencyPeriod = [[self valueForPropertyKey: ECNTriggerLatencyKey] floatValue];
		if (time - _flags.activationTime > latencyPeriod) {
			_flags.shouldBeDeactivated = true;
			//NSLog (@"Trigger off at time: %.2f", time);
		}
	}
	
	if ((_flags.isActive)							// this means: latency period
		&& (_flags.shouldBeDeactivated)				// this means: latency period is over
		&& [self checkIfHasToBeDeactivated])		// this means: current value is under deactivation threshold
		[self setActive: false];
	
	// 2. not in latency period:
	// store current value as in latency period it will not be updated!
	//if (!(_flags.isActive)) {
	[self setLastValue: [[[self elementToObserve] valueForOutputPort: [self keyOfPortToObserve]] copy]
				atTime: time] ;
	//}
	
	// 3. entering in latency period:
	// if not in latency period,
	// check (in subclass method) if trigger has to be activated
	if (!(_flags.isActive) && [self checkIfHasToBeActivated]) {
		// start latency period
		_flags.activationTime = time;
		[self setActive: true];
			//NSLog (@"Trigger on at time: %.2f with latency period of: %.2f", time,[[self valueForPropertyKey: ECNTriggerLatencyKey] floatValue]);
	}
	return true;
	

}

/*
- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context	{

	
}*/

- (void) endObservingElement	{
	
	// unregister self for port changes notification
	/*[[self valueForPropertyKey: ECNTriggerPortToObserveKey] removeObserver:self 
																forKeyPath:@"value"];
	*/
}


#pragma mark State modifications



/*
#pragma mark Latency period

- (void) startLatencyPeriod
{
	NSTimeInterval latencyPeriod = [[self valueForPropertyKey: ECNTriggerLatencyKey] floatValue];
	if (latencyPeriod > 0)	{
		_flags.shouldBeDeactivated = false;
		//NSLog(@"latency period begins: %.2f", latencyPeriod);
		if (latencyTimer) [latencyTimer invalidate];
		[self setLatencyTimer: [NSTimer timerWithTimeInterval: latencyPeriod
								target: self
							  selector: @selector(_exitLatencyPeriod:)
							  userInfo: nil
													  repeats: false]];
		[[NSRunLoop currentRunLoop] addTimer: latencyTimer
									 forMode: NSDefaultRunLoopMode];
	}
	else _flags.shouldBeDeactivated = true;
		
}
*/
/*
- (bool) checkIfLatencyPeriodIsOver: (NSDate *)time {
	NSNumber *latency = [self valueForPropertyKey: ECNTriggerLatencyKey];
	NSTimeInterval passedTime = [time timeIntervalSinceDate: _flags.triggerTime] - [latency floatValue];
	bool latencyPeriodIsOver = (passedTime > 0);
	//NSLog (@"%.2f", [_triggerTime timeIntervalSinceDate: time] - _lLatency);
	if (latencyPeriodIsOver) [self exitLatencyPeriod];
	return latencyPeriodIsOver;
}*/

/*
- (void) _exitLatencyPeriod: (NSTimer*) timer {
	_flags.shouldBeDeactivated = true;
}
*/
#pragma mark Playback methods

- (void)triggerElement	{
	
	[self startLatencyPeriod];
	[self setActive: true];
//	_flags.isActive=true;
//	_flags.shouldCommitActivationActions = true;
	
}

- (void)triggerOffElement	{
	
	if (latencyTimer) [latencyTimer invalidate];
	[self setActive: false];
//	_flags.isActive=false;
//	_flags.shouldCommitDeactivationActions = true;
	
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

#pragma mark Graphic Representation
#pragma mark Graphic representation

- (void) drawInCGContext: (CGContextRef)context withRect: (CGRect) rect	{
	TFThrowMethodNotImplementedException();
}

@end
