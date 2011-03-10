//
//  ECNAction.m
//  kineto
//
//  Created by Andrea Cremaschi on 24/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ECNAction.h"
#import "ECNOSCTarget.h"
#import "ECNElement.h"
#import "ECNScene.h"
#import "ECNProjectDocument.h"

NSString *kACTStringValue_OSCSendMessage = @"OSC action";
NSString *kACTStringValue_ElementChange = @"Element action";
NSString *kACTStringValue_SceneChange = @"Scene action";
NSString *kACTStringValue_TimerChange = @"Timer action";

NSString *ECNActiveElementsSetIsChangedNotification = @"ECNActiveElementsSetIsChanged";

@implementation ECNAction

- (id) init
{
    self = [super init];
	return self;
}

- (id) initWithTarget: (ECNObject *)target elementOwner: (ECNElement *)elementOwner action: (unsigned char) action
{
	self = [self init];
	if (self)
	{
		_target = target;
		_elementOwner = elementOwner;
		_performAction = action;
		
		[_target retain];
		[_elementOwner retain];
		
	}
	return self;
}

- (void)dealloc {
	[_target release];
	[_elementOwner release];
    [super dealloc];
}

- (void) setElement: (ECNElement *) element
{	_elementOwner = element;
	[_elementOwner retain];
}

- (void) setTarget: (ECNObject *) target
{	_target = target;
	[_target retain];
}

- (ECNElement *)elementOwner	{ return _elementOwner;}

- (bool) commitAction
{
	return false;
}

- (NSString *)stringValue	{

	return @"Generic action";

}

- (int) actionType	{
	
	if ([self isKindOfClass: [ECNAction_OSCSend class]]) return kACTTypeOSCSend;
	else if ([self isKindOfClass: [ECNAction_ChangeElementState class]]) return kACTTypeChangeElementState;
	else if ([self isKindOfClass: [ECNAction_ChangeSceneState class]]) return kACTTypeChangeSceneState;
	else if ([self isKindOfClass: [ECNAction_ChangeTimerState class]]) return kACTTypeChangeTimerState;
	else return -1;
}


+ (ECNAction *)createActionOfType: (int) actionType withDocument: (ECNProjectDocument *)document; {
	
	
	if (actionType == -1) return nil;
	
	
	ECNAction *newAction = nil;
	
	switch (actionType) {			
			
		case kACTTypeOSCSend:
			newAction = [[[ECNAction_OSCSend alloc] initWithProjectDocument: document] autorelease];
			break;
			
		case kACTTypeChangeElementState:
			newAction = [[[ECNAction_ChangeElementState alloc] initWithProjectDocument: document] autorelease];
			break;
			
		case kACTTypeChangeSceneState:
			newAction = [[[ECNAction_ChangeSceneState alloc] initWithProjectDocument: document] autorelease];
			break;
			
		case kACTTypeChangeTimerState:			
			newAction = [[[ECNAction_ChangeTimerState alloc] initWithProjectDocument: document] autorelease];
			break;
			
	}
	
	return newAction;
	
	
}


#pragma mark *** Persistence ***

NSString *ECNActionClassKey = @"Class";
NSString *ECNActionElementOwnerIDKey = @"ElementOwnerID";
NSString *ECNActionTargetIDKey = @"TargetID";
NSString *ECNActionToPerformKey = @"ActionToPerform";


- (NSMutableDictionary *)propertyListRepresentation {
	
    NSMutableDictionary *dict = [super propertyListRepresentation];

    NSString *className = NSStringFromClass([self class]);	
    [dict setObject:className forKey:ECNActionClassKey];

//    [dict setObject:[_elementOwner ...] forKey:ECNActionElementOwnerIDKey];
    [dict setObject:[NSNumber numberWithInt: [_target ID]] forKey:ECNActionTargetIDKey];
    [dict setObject:[NSNumber numberWithInt: _performAction ] forKey:ECNActionToPerformKey];
	
	
    return dict;
}


+ (id)actionWithPropertyListRepresentation:(NSDictionary *)dict  withElement: (ECNElement*)element {
    if (element==nil) return nil;

    Class theClass = NSClassFromString([dict objectForKey:ECNActionClassKey]);
    id theAction = nil;
    
    if (theClass) {
        theAction = [[[theClass allocWithZone:NULL] initWithProjectDocument: [element document]] autorelease];
        if (theAction) {
			[theAction setElement: element];
            [theAction loadPropertyListRepresentation:dict];
		}
        
    }
    return theAction;
}


- (void)loadPropertyListRepresentation:(NSDictionary *)dict {
	id obj;
 
	[super loadPropertyListRepresentation: dict];

	obj = [dict objectForKey:ECNActionToPerformKey];
	if (obj) 
		_performAction = [obj intValue];

	obj = [dict objectForKey:ECNActionTargetIDKey];
	if (obj) 
		targetID = [obj intValue];

	return;
}

- (void) bindActionToTarget	{
	_target = [[_elementOwner document] objectWithID: targetID];
}

@end





# pragma mark -


@implementation ECNAction_OSCSend


- (id) initWithOSCTarget: (ECNOSCTarget *) target element: (ECNElement *)elementOwner
{
    self = [super initWithTarget: target elementOwner: elementOwner action: -1];

	return self;
}


- (bool) commitAction
{
	
	[[self oscTarget] sendValue: [_elementOwner activity]];

	 return true;
}

- (NSString *)stringValue	{
	
	return kACTStringValue_OSCSendMessage;
	
}

- (NSArray *)oscTargetsList	{ return [[[_elementOwner scene] document] OSCtargets];}
- (ECNOSCTarget *)oscTarget { return (ECNOSCTarget *)_target; }
- (void) setOSCTarget: (ECNOSCTarget *)oscTarget { [super setTarget: oscTarget];	}


- (void) setElement: (ECNElement *) element
{	
	// set default osc target
	//if (_target == nil) [self setSceneTarget: [element scene]];
	[super setElement: element];
}


@end


#pragma mark

@implementation ECNAction_ChangeElementState

- (id) initWithAction: (unsigned char)action element: (ECNElement *)elementTarget elementOwner: (ECNElement *)elementOwner {
	
    self = [super initWithTarget: elementTarget elementOwner: elementOwner action: action];
	return self;
}



- (bool) commitAction
{
	if (_target == nil) return false;
	
	
	ECNElement *target = [self elementTarget];
	bool isActive = [[target scene] isElementActive: target];
	
	switch (_performAction) {
		case kACTActivate:
			if (!isActive)	{
				[[target scene] setElementActivationState: target active: true];
				[[NSNotificationCenter defaultCenter] postNotificationName:ECNActiveElementsSetIsChangedNotification object:self];
			}
			break;
		case kACTDeactivate:
			if (isActive)	{
				[[target scene] setElementActivationState: target active: false];
				[[NSNotificationCenter defaultCenter] postNotificationName:ECNActiveElementsSetIsChangedNotification object:self];
			}
			break;
		case kACTToggle:	
				[[target scene] setElementActivationState: target active: !isActive];
				[[NSNotificationCenter defaultCenter] postNotificationName:ECNActiveElementsSetIsChangedNotification object:self];
			break;
	}
	return true;	
}

- (NSString *)stringValue	{	return [[[NSString alloc] initWithString: kACTStringValue_ElementChange] autorelease];	}

- (NSArray *)elementsList	{ return [[_elementOwner scene] elements];	}
- (ECNElement *)elementTarget { return (ECNElement *)_target; }
- (void) setElementTarget: (ECNElement *)element	{ [super setTarget: element];	}
- (unsigned char)actionToPerform	{return _performAction; }
- (void) setActionToPerform: (unsigned char) action	{
	_performAction = action;
}

- (void) setElement: (ECNElement *) element
{	
	// default target to "self"
	if (_target == nil) [self setElementTarget: element];
	[super setElement: element];
}

@end

#pragma mark

@implementation ECNAction_ChangeSceneState 

- (id) initWithAction: (unsigned char)action scene: (ECNScene *)sceneTarget elementOwner: (ECNElement *)elementOwner {
    self = [super initWithTarget: sceneTarget elementOwner: elementOwner action: action];
	return self;
}



- (NSString *)stringValue	{	return [[[NSString alloc] initWithString: kACTStringValue_SceneChange] autorelease];	}

- (bool) commitAction
{
	if (_target == nil) return false;
	
	ECNScene* target = [self sceneTarget];
	bool isActive = [[target document] isSceneActive: target];
	
	switch (_performAction) {
		case kACTActivate:
			if (!isActive)	{
				[[target document] setSceneActivationState: target active: true];
				[[NSNotificationCenter defaultCenter] postNotificationName:ECNActiveElementsSetIsChangedNotification object:self];
			}
			break;
		case kACTDeactivate:
			if (isActive) {
				[[target document] setSceneActivationState: target active: false];
				[[NSNotificationCenter defaultCenter] postNotificationName:ECNActiveElementsSetIsChangedNotification object:self];
			}
			break;
		case kACTToggle:
				[[target document] setSceneActivationState: target active: !isActive];
				[[NSNotificationCenter defaultCenter] postNotificationName:ECNActiveElementsSetIsChangedNotification object:self];
			break;
	}
	return true;	
}
- (NSArray *)scenesList	{ return [[[_elementOwner scene] document] scenes];}
- (ECNScene *)sceneTarget { return (ECNScene *)_target; }
- (void) setSceneTarget: (ECNScene *)scene { [super setTarget: scene];	}

- (unsigned char)actionToPerform	{return _performAction; }
- (void) setActionToPerform: (unsigned char) action	{
	_performAction = action;
}

- (void) setElement: (ECNElement *) element
{	
	// default target to "current scene"
	if (_target == nil) [self setSceneTarget: [element scene]];
	[super setElement: element];
}

@end


#pragma mark

@implementation ECNAction_ChangeTimerState 

- (id) initWithAction: (unsigned char)action timer: (ECNTimer *)target elementOwner: (ECNElement *)elementOwner {
	
    self = [super initWithTarget: target elementOwner: elementOwner action: action];
	return self;
}


- (NSString *)stringValue	{	return [[[NSString alloc] initWithString: kACTStringValue_TimerChange] autorelease];	}

- (bool) commitAction
{
		return false;
}

@end
