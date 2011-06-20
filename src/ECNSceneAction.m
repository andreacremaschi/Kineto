//
//  ECNSceneAction.m
//  kineto
//
//  Created by Andrea Cremaschi on 16/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import "ECNSceneAction.h"
#import "KCue.h"
#import "KPlaybackPipeline.h"

#import "ECNProjectDocument.h"

// +  + Scenes specific properties  +
// +  +  +  +  +  +  +  +  +  +  +  +

// +  + Default values  +  +  +  +  +
NSString *SceneActivateActionClassValue = @"ECNSceneActivateAction";
NSString *SceneActivateActionNameValue = @"Play cue";
NSString *SceneActivateActionIcon = @"Cross";

NSString *SceneDeactivateActionClassValue = @"ECNSceneDeactivateAction";
NSString *SceneDeactivateActionNameValue = @"Stop cue";
NSString *SceneDeactivateActionIcon = @"Cross";

NSString *SceneToggleActionClassValue = @"ECNSceneToggleAction";
NSString *SceneToggleActionNameValue = @"Toggle cue";
NSString *SceneToggleActionIcon = @"Cross";

NSString *SceneResetActionClassValue = @"ECNSceneResetAction";
NSString *SceneResetActionNameValue = @"Reset cue";
NSString *SceneResetActionIcon = @"reset";

// +  +  +  +  +  +  +  +  +  +  +  +



@implementation ECNSceneActivateAction

+ (NSString *) actionName	{
	return SceneActivateActionNameValue;
}

+ (Class ) targetType	{
	return [KCue class];
}

+ (NSString *)icon_name	{
	return @"play"; //ECNSceneActivateActionIcon; //default icon
}

+ (ECNSceneActivateAction *)activateActionWithDocument: (ECNProjectDocument *)document {
	ECNSceneActivateAction *newAction = [[[ECNSceneActivateAction alloc] initWithProjectDocument: document] autorelease];
	if (newAction != nil)	{
		[newAction setValue: SceneActivateActionClassValue forPropertyKey: ECNObjectClassKey];
		[newAction setValue: SceneActivateActionNameValue forPropertyKey: ECNObjectNameKey];
		
	}
	return newAction;
	
}

+ (ECNAction *)actionWithDocument: (ECNProjectDocument *)document withTarget: (ECNObject *) target {
	if (target && ![target isKindOfClass: [ECNSceneActivateAction targetType]]) 
		return nil;
	ECNAction *newAction = [ECNSceneActivateAction activateActionWithDocument: document];
	[newAction setTarget: target];
	return newAction;	
}

- (void) performActionOnPipeline: (KPlaybackPipeline *)pipeline	{
	if ((id)[self target] == [NSNull null]) return;
	NSAssert ([[self target] isKindOfClass: [KCue class]], @"Action received a wrong object type!");
	KCue *target = (KCue *)[self target];	
//	[(ECNProjectDocument *)[target document] setSceneActivationState: target active: true];
	
	[pipeline activateCue: target];
}

@end


@implementation ECNSceneDeactivateAction

+ (NSString *) actionName	{
	return SceneDeactivateActionNameValue;
}

+ (Class ) targetType	{
	return [KCue class];
}

+ (NSString *)icon_name	{
	return @"stop"; //ECNSceneDeactivateActionIcon; //default icon
}

+ (ECNSceneDeactivateAction *)deactivateActionWithDocument: (ECNProjectDocument *)document {
	ECNSceneDeactivateAction *newAction = [[[ECNSceneDeactivateAction alloc] initWithProjectDocument: document] autorelease];
	if (newAction != nil)	{
		[newAction setValue: SceneDeactivateActionClassValue forPropertyKey: ECNObjectClassKey];
		[newAction setValue: SceneDeactivateActionNameValue forPropertyKey: ECNObjectNameKey];
		
	}
	return newAction;
	
}

+ (ECNAction *)actionWithDocument: (ECNProjectDocument *)document withTarget: (ECNObject *) target {
	if (target && ![target isKindOfClass: [ECNSceneDeactivateAction targetType]]) 
		return nil;
	ECNAction *newAction = [ECNSceneDeactivateAction deactivateActionWithDocument: document];
	[newAction setTarget: target];
	return newAction;	
}

- (void) performActionOnPipeline: (KPlaybackPipeline *)pipeline	{
	if ((id)[self target] == [NSNull null]) return;
	NSAssert ([[self target] isKindOfClass: [KCue class]], @"Action received a wrong object type!");
	KCue *target = (KCue *)[self target];	
	[pipeline deactivateCue: target];
//	[(ECNProjectDocument *)[target document] setSceneActivationState: target active: false];
}

@end


@implementation ECNSceneToggleAction

+ (NSString *) actionName	{
	return SceneToggleActionNameValue;
}

+ (Class ) targetType	{
	return [KCue class];
}

+ (NSString *)icon_name	{
	return @"Cross"; //ECNSceneToggleActionIcon; //default icon
}

+ (ECNSceneToggleAction *)toggleActionWithDocument: (ECNProjectDocument *)document {
	ECNSceneToggleAction *newAction = [[[ECNSceneToggleAction alloc] initWithProjectDocument: document] autorelease];
	if (newAction != nil)	{
		[newAction setValue: SceneToggleActionClassValue forPropertyKey: ECNObjectClassKey];
		[newAction setValue: SceneToggleActionNameValue forPropertyKey: ECNObjectNameKey];
		
	}
	return newAction;
	
}

+ (ECNAction *)actionWithDocument: (ECNProjectDocument *)document withTarget: (ECNObject *) target {
	if (target && ![target isKindOfClass: [ECNSceneToggleAction targetType]]) 
		return nil;
	ECNAction *newAction = [ECNSceneToggleAction toggleActionWithDocument: document] ;
	[newAction setTarget: target];
	return newAction;	
}


- (void) performActionOnPipeline: (KPlaybackPipeline *)pipeline	{
	if ((id)[self target] == [NSNull null]) return;
	NSAssert ([[self target] isKindOfClass: [KCue class]], @"Action received a wrong object type!");
	KCue *target = (KCue *)[self target];	
	[pipeline toggleCue: target];
//	[(ECNProjectDocument *)[target document] setSceneActivationState: target active: ![[target document] isSceneActive: target]];
}

@end

@implementation ECNSceneResetAction

+ (NSString *) actionName	{
	return SceneResetActionNameValue;
}

+ (Class ) targetType	{
	return [KCue class];
}

+ (NSString *)icon_name	{
	return SceneResetActionIcon; //ECNSceneToggleActionIcon; //default icon
}

+ (ECNSceneResetAction *)resetActionWithDocument: (ECNProjectDocument *)document {
	ECNSceneResetAction *newAction = [[[ECNSceneResetAction alloc] initWithProjectDocument: document] autorelease];
	if (newAction != nil)	{
		[newAction setValue: SceneResetActionClassValue forPropertyKey: ECNObjectClassKey];
		[newAction setValue: SceneResetActionNameValue forPropertyKey: ECNObjectNameKey];
		
	}
	return newAction;
	
}

+ (ECNAction *)actionWithDocument: (ECNProjectDocument *)document withTarget: (ECNObject *) target {
	if (target && ![target isKindOfClass: [ECNSceneResetAction targetType]]) 
		return nil;
	ECNAction *newAction = [ECNSceneResetAction resetActionWithDocument: document] ;
	[newAction setTarget: target];
	return newAction;	
}


- (void) performActionOnPipeline: (KPlaybackPipeline *)pipeline	{
	if ((id)[self target] == [NSNull null]) return;
	NSAssert ([[self target] isKindOfClass: [KCue class]], @"Action received a wrong object type!");
	KCue *target = (KCue *)[self target];	
	
	[pipeline resetCue: target];

//	[(ECNProjectDocument *)[target document] setSceneActivationState: target active: ![[target document] isSceneActive: target]];*/
	// TODO: IMPLEMENTARE!
}

@end

