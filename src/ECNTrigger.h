//
//  ECNTrigger.h
//  kineto
//
//  Created by Andrea Cremaschi on 16/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECNObject.h"



// +  + Elements specific properties  +

extern NSString *ECNTriggerPortToObserveKey; // port to observe. The way this is identified is defined in subclasses

extern NSString *ECNTriggerLatencyKey; // the time the trigger will be inactive after activating

extern NSString *ECNTriggerActivationThresholdKey; // Activation threshold
extern NSString *ECNTriggerDeactivationThresholdKey; // Deactivation threshold

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
	
}

+ (ECNTrigger *)triggerWithDocument: (ECNProjectDocument *)document;

- (void) addActivationAction: (ECNAction*) newAction;
- (bool) isActive;

#pragma mark Accessors
- (void) setPortToObserve: (ECNPort *)port_to_observe;
- (ECNPort *) portToObserve;
- (NSArray *)activationActions;
- (NSArray *)deactivationActions;

#pragma mark Playback
- (void) beginObservingElement;
- (void) endObservingElement;

- (void) triggerElement;

- (id) lastValue;


- (bool) shouldCommitActions;	
- (NSArray *)actionsToCommit;

@end
