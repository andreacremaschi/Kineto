//
//  ECNAction.h
//  kineto
//
//  Created by Andrea Cremaschi on 24/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ECNObject.h"

@class ECNElement;
@class ECNOSCTarget;
@class ECNScene;
@class ECNTimer;

extern NSString *ECNActiveElementsSetIsChangedNotification;

#define kACTActivate 0
#define kACTDeactivate 1
#define kACTToggle 2


enum {
    kACTTypeOSCSend = 0,
    kACTTypeChangeElementState,
	kACTTypeChangeSceneState,
    kACTTypeChangeTimerState
    
};

@class ECNProjectDocument;
@interface ECNAction : ECNObject {
	ECNElement * _elementOwner;
	ECNObject * _target;
	unsigned char _performAction;
	
	int targetID; //used for persistance purposes
}

- (id) initWithTarget: (ECNObject *)target elementOwner: (ECNElement *)elementOwner action: (unsigned char)action;
+ (ECNAction *)createActionOfType: (int) actionType withDocument: (ECNProjectDocument *)document;

- (int) actionType;
- (void) setElement: (ECNElement *) element;
- (void) setTarget: (ECNObject *) target;

- (ECNElement *)elementOwner;
- (NSString *) stringValue;

- (bool) commitAction;

// Persistance
+ (id)actionWithPropertyListRepresentation:(NSDictionary *)dict withElement: (ECNElement*)element;
- (NSMutableDictionary *)propertyListRepresentation;
- (void) bindActionToTarget;

@end




// ###########  OSC send  #################

@interface ECNAction_OSCSend : ECNAction {
//	ECNOSCTarget * _target;

}

- (id) initWithOSCTarget: (ECNOSCTarget *) target element: (ECNElement *) elementOwner;

- (void) setOSCTarget: (ECNOSCTarget *)oscTarget;
- (ECNOSCTarget *)oscTarget;
- (NSArray *)oscTargetsList;

- (unsigned char)actionToPerform;
- (void) setActionToPerform: (unsigned char) action;


@end



// ###########  Change element state  #################

@interface ECNAction_ChangeElementState : ECNAction {

}

- (id) initWithAction: (unsigned char)action element: (ECNElement *)elementTarget elementOwner: (ECNElement *)elementOwner  ;
- (void) setElementTarget: (ECNElement *)element;
- (ECNElement *)elementTarget;
- (NSArray *)elementsList;

- (unsigned char)actionToPerform;
- (void) setActionToPerform: (unsigned char) action;

@end

// ###########  Change scene state  #################

@interface ECNAction_ChangeSceneState : ECNAction {
//	ECNScene * _target;
//	unsigned char _performAction;
}

- (id) initWithAction: (unsigned char)action scene: (ECNScene *)sceneTarget elementOwner: (ECNElement *)elementOwner  ;
- (void) setSceneTarget: (ECNScene *)scene;
- (ECNScene *)sceneTarget;
- (NSArray *)scenesList;

- (unsigned char)actionToPerform;
- (void) setActionToPerform: (unsigned char) action;

@end

// ###########  Change timer state  #################

@interface ECNAction_ChangeTimerState : ECNAction {
//	ECNTimer * _target;
//	unsigned char _performAction;
}

- (id) initWithAction: (unsigned char)action scene: (ECNTimer *)target elementOwner: (ECNElement *)elementOwner  ;

@end

