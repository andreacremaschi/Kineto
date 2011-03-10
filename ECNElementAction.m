//
//  ECNElementAction.m
//  kineto
//
//  Created by Andrea Cremaschi on 16/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECNElementAction.h"
#import "ECNElement.h"
#import "ECNScene.h"

// +  + Elements specific properties  +
// +  +  +  +  +  +  +  +  +  +  +  +

// +  + Default values  +  +  +  +  +
NSString *ElementActivateActionClassValue = @"ECNSceneActivateAction";
NSString *ElementActivateActionNameValue = @"Activate";

NSString *ElementDeactivateActionClassValue = @"ECNSceneDeactivateAction";
NSString *ElementDeactivateActionNameValue = @"Deactivate";

NSString *ElementToggleActionClassValue = @"ECNSceneToggleAction";
NSString *ElementToggleActionNameValue = @"Toggle";
// +  +  +  +  +  +  +  +  +  +  +  +



@implementation ECNElementActivateAction

+ (NSString *) actionName	{
	return ElementActivateActionNameValue;
}

+ (Class ) targetType	{
	return [ECNElement class];
}

+ (ECNElementActivateAction *)activateActionWithDocument: (ECNProjectDocument *)document {
	ECNElementActivateAction *newAction = [[[ECNElementActivateAction alloc] initWithProjectDocument: document] autorelease];
	if (newAction != nil)	{
		[newAction setValue: ElementActivateActionClassValue forPropertyKey: ECNObjectClassKey];
		[newAction setValue: ElementActivateActionNameValue forPropertyKey: ECNObjectNameKey];
		
	}
	return newAction;
	
}

+ (ECNAction *)actionWithDocument: (ECNProjectDocument *)document withTarget: (ECNObject *) target {
	if (![target isKindOfClass: [ECNElementActivateAction targetType]]) 
		  return nil;
	ECNAction *newAction = [ECNElementActivateAction activateActionWithDocument: document];
	[newAction setTarget: target];
	return newAction;	
}

- (void) performAction	{
	id target = [self target];
	if (![target isKindOfClass: [ECNElement class]]) return;
	ECNScene *scene = [(ECNElement *)target scene];
	[scene setElementActivationState: target active: true ];
}

@end


@implementation ECNElementDeactivateAction

+ (NSString *) actionName	{
	return ElementDeactivateActionNameValue;
}

+ (Class ) targetType	{
	return [ECNElement class];
}

+ (ECNElementDeactivateAction *)deactivateActionWithDocument: (ECNProjectDocument *)document {
	ECNElementDeactivateAction *newAction = [[[ECNElementDeactivateAction alloc] initWithProjectDocument: document] autorelease];
	if (newAction != nil)	{
		[newAction setValue: ElementDeactivateActionClassValue forPropertyKey: ECNObjectClassKey];
		[newAction setValue: ElementDeactivateActionNameValue forPropertyKey: ECNObjectNameKey];
		
	}
	return newAction;
	
}

+ (ECNAction *)actionWithDocument: (ECNProjectDocument *)document withTarget: (ECNObject *) target {
	if (![target isKindOfClass: [ECNElementDeactivateAction targetType]]) 
		return nil;
	ECNAction *newAction = [ECNElementDeactivateAction deactivateActionWithDocument: document];
	[newAction setTarget: target];
	return newAction;	
}

- (void) performAction	{
	id target = [self target];
	if (![target isKindOfClass: [ECNElement class]]) return;
	ECNScene *scene = [(ECNElement *)target scene];
	[scene setElementActivationState: target active: false ];
}


@end


@implementation ECNElementToggleAction

+ (NSString *) actionName	{
	return ElementToggleActionNameValue;
}

+ (Class ) targetType	{
	return [ECNElement class];
}

+ (ECNElementToggleAction *)toggleActionWithDocument: (ECNProjectDocument *)document {
	ECNElementToggleAction *newAction = [[[ECNElementToggleAction alloc] initWithProjectDocument: document] autorelease];
	if (newAction != nil)	{
		[newAction setValue: ElementToggleActionClassValue forPropertyKey: ECNObjectClassKey];
		[newAction setValue: ElementToggleActionNameValue forPropertyKey: ECNObjectNameKey];
		
	}
	return newAction;
	
}

+ (ECNAction *)actionWithDocument: (ECNProjectDocument *)document withTarget: (ECNObject *) target {
	if (![target isKindOfClass: [ECNElementToggleAction targetType]]) 
		return nil;
	ECNAction *newAction = [ECNElementToggleAction toggleActionWithDocument: document] ;
	[newAction setTarget: target];
	return newAction;	
}


- (void) performAction	{
	id target = [self target];
	if (![target isKindOfClass: [ECNElement class]]) return;
	ECNScene *scene = [(ECNElement *)target scene];
	[scene setElementActivationState: target active: ![target activationState] ];
}

@end
