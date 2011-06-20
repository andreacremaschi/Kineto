//
//  ECNElementAction.m
//  kineto
//
//  Created by Andrea Cremaschi on 16/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import "ECNElementAction.h"
#import "ECNElement.h"
#import "KCue.h"
#import "KPlaybackPipeline.h"


// +  + Elements specific properties  +
// +  +  +  +  +  +  +  +  +  +  +  +

// +  + Default values  +  +  +  +  +
NSString *ElementActivateActionClassValue = @"ECNSceneActivateAction";
NSString *ElementActivateActionNameValue = @"Activate element";

NSString *ElementDeactivateActionClassValue = @"ECNSceneDeactivateAction";
NSString *ElementDeactivateActionNameValue = @"Deactivate element";

NSString *ElementToggleActionClassValue = @"ECNSceneToggleAction";
NSString *ElementToggleActionNameValue = @"Toggle element";

NSString *ElementTriggerActionClassValue = @"ECNElementTriggerAction";
NSString *ElementTriggerActionNameValue = @"Trigger element";

NSString *ElementTriggerOffActionClassValue = @"ECNElementTriggerOffAction";
NSString *ElementTriggerOffActionNameValue = @"Trigger element off";

// +  +  +  +  +  +  +  +  +  +  +  +



@implementation ECNElementActivateAction

+ (NSString *) actionName	{
	return ElementActivateActionNameValue;
}

+ (Class ) targetType	{
	return [ECNElement class];
}

+ (NSString *)icon_name	{
	return @"play"; //default icon
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
	if (target && ![target isKindOfClass: [ECNElementActivateAction targetType]]) 
		  return nil;
	ECNAction *newAction = [ECNElementActivateAction activateActionWithDocument: document];
	[newAction setTarget: target];
	return newAction;	
}

- (void) performActionOnPipeline: (KPlaybackPipeline *)pipeline	{
	id target = [self target];
	if (!target) return;
	if (![target isKindOfClass: [ECNElement class]]) return;

	[pipeline activateElement: target];
/*	KCue *scene = [(ECNElement *)target scene];
	[scene setElementActivationState: target active: true ];*/
}

@end


@implementation ECNElementDeactivateAction

+ (NSString *) actionName	{
	return ElementDeactivateActionNameValue;
}

+ (Class ) targetType	{
	return [ECNElement class];
}

+ (NSString *)icon_name	{
	return @"stop"; //default icon
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
	if (target && ![target isKindOfClass: [ECNElementDeactivateAction targetType]]) 
		return nil;
	ECNAction *newAction = [ECNElementDeactivateAction deactivateActionWithDocument: document];
	[newAction setTarget: target];
	return newAction;	
}

- (void) performActionOnPipeline: (KPlaybackPipeline *)pipeline	{
	id target = [self target];
	if (!target) return;
	if (![target isKindOfClass: [ECNElement class]]) return;

	[pipeline deactivateElement: target];
	/*KCue *scene = [(ECNElement *)target scene];
	[scene setElementActivationState: target active: false];*/

}


@end


@implementation ECNElementToggleAction

+ (NSString *) actionName	{
	return ElementToggleActionNameValue;
}

+ (Class ) targetType	{
	return [ECNElement class];
}

+ (NSString *)icon_name	{
	return  @"Cross"; //default icon
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
	if (target && ![target isKindOfClass: [ECNElementToggleAction targetType]]) 
		return nil;
	ECNAction *newAction = [ECNElementToggleAction toggleActionWithDocument: document] ;
	[newAction setTarget: target];
	return newAction;	
}


- (void) performActionOnPipeline: (KPlaybackPipeline *)pipeline	{
	id target = [self target];
	if (!target) return;
	if (![target isKindOfClass: [ECNElement class]]) return;
	
	[pipeline toggleElement: target];
	
/*	KCue *scene = [(ECNElement *)target scene];
	[scene setElementActivationState: target active: ! [scene isElementActive: target] ];*/

}
@end

@implementation ECNElementTriggerAction

+ (NSString *) actionName	{
	return ElementTriggerActionNameValue;
}

+ (Class ) targetType	{
	return [ECNElement class];
}

+ (NSString *)icon_name	{
	return  @"trigger_on"; //default icon
}

+ (ECNElementTriggerAction *)triggerActionWithDocument: (ECNProjectDocument *)document {
	ECNElementTriggerAction *newAction = [[[ECNElementTriggerAction alloc] initWithProjectDocument: document] autorelease];
	if (newAction != nil)	{
		[newAction setValue: ElementTriggerActionClassValue forPropertyKey: ECNObjectClassKey];
		[newAction setValue: ElementTriggerActionNameValue forPropertyKey: ECNObjectNameKey];
		
	}
	return newAction;
	
}

+ (ECNAction *)actionWithDocument: (ECNProjectDocument *)document withTarget: (ECNObject *) target {
	if (target && ![target isKindOfClass: [ECNElementTriggerAction targetType]]) 
		return nil;
	ECNAction *newAction = [ECNElementTriggerAction triggerActionWithDocument: document] ;
	[newAction setTarget: target];
	return newAction;	
}


- (void) performActionOnPipeline: (KPlaybackPipeline *)pipeline	{
	id target = [self target];
	if (!target) return;
	if (![target isKindOfClass: [ECNElement class]]) return;
/*	ECNScene *scene = [(ECNElement *)target scene];
	[scene setActivationState: ![scene activationState]];*/
	
	[pipeline triggerElement: target];
	//[[target firstTrigger] triggerElement];
	// TODO: trigger element's first trigger!
	
}
@end


@implementation ECNElementTriggerOffAction

+ (NSString *) actionName	{
	return ElementTriggerOffActionNameValue;
}

+ (Class ) targetType	{
	return [ECNElement class];
}

+ (NSString *)icon_name	{
	return  @"trigger_off"; //default icon
}

+ (ECNElementTriggerOffAction *)triggerOffActionWithDocument: (ECNProjectDocument *)document {
	ECNElementTriggerOffAction *newAction = [[[ECNElementTriggerOffAction alloc] initWithProjectDocument: document] autorelease];
	if (newAction != nil)	{
		[newAction setValue: ElementTriggerOffActionClassValue forPropertyKey: ECNObjectClassKey];
		[newAction setValue: ElementTriggerOffActionNameValue forPropertyKey: ECNObjectNameKey];
		
	}
	return newAction;
	
}

+ (ECNAction *)actionWithDocument: (ECNProjectDocument *)document withTarget: (ECNObject *) target {
	if (target && ![target isKindOfClass: [ECNElementTriggerOffAction targetType]]) 
		return nil;
	ECNAction *newAction = [ECNElementTriggerOffAction triggerOffActionWithDocument: document] ;
	[newAction setTarget: target];
	return newAction;	
}


- (void) performActionOnPipeline: (KPlaybackPipeline *)pipeline	{
	id target = [self target];
	if (!target) return;
	if (![target isKindOfClass: [ECNElement class]]) return;
	/*	ECNScene *scene = [(ECNElement *)target scene];
	 [scene setActivationState: ![scene activationState]];*/
	[pipeline triggerOffElement: target];

//	[[target firstTrigger] triggerOffElement];
	
}
@end
