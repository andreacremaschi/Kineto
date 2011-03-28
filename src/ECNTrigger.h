//
//  ECNTrigger.h
//  kineto
//
//  Created by Andrea Cremaschi on 16/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import "ECNElement.h"



// +  + Elements specific properties  +

extern NSString *ECNTriggerElementToObserveKey; //element to observe.
extern NSString *ECNTriggerPortToObserveKey; // port to observe. The way this is identified is defined in subclasses

extern NSString *ECNTriggerLatencyKey; // the time the trigger will be inactive after activating

extern NSString *ECNTriggerActivationThresholdKey; // Activation threshold
extern NSString *ECNTriggerDeactivationThresholdKey; // Deactivation threshold
extern NSString *ECNTriggerBindThresholdValuesKey; // force threshold values to be the same

extern NSString *ECNTriggerActivationActionsListKey;
extern NSString *ECNTriggerDeactivationActionsListKey;

// +  +  +  +  +  +  +  +  +  +  +  +



@class ECNAction;
@interface ECNTrigger : ECNObject {

	struct __triggerFlags {
        bool isActive;
		bool shouldBeDeactivated;
		bool shouldCommitActivationActions;
		bool shouldCommitDeactivationActions;
		id lastValue;
	//	NSDate *triggerTime;
    } _flags;
	NSTimer *latencyTimer;
}

@property (retain) NSTimer * latencyTimer;

+ (ECNTrigger *)triggerWithDocument: (ECNProjectDocument *)document;

- (void) addActivationAction: (ECNAction*) newAction;
- (void) addDeactivationAction: (ECNAction*) newAction;

- (bool) isActive;

#pragma mark Accessors
- (void) setElementToObserve: (ECNElement *)element atPort: (NSString *)portKey;
- (NSString *) keyOfPortToObserve;
- (NSArray *)activationActions;
- (NSArray *)deactivationActions;

#pragma mark Playback
- (void) beginObservingElement;
- (void) endObservingElement;
- (BOOL) executeAtTime:(NSTimeInterval)time;

- (void) triggerElement;
- (void) triggerOffElement;

- (id) lastValue;


- (bool) shouldCommitActions;	
- (NSArray *)actionsToCommit;


@property NSUInteger activationState;

@end
