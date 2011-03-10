//
//  ECNSceneAction.m
//  kineto
//
//  Created by Andrea Cremaschi on 16/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECNSceneAction.h"
#import "ECNScene.h"

#import "ECNProjectDocument.h"

// +  + Scenes specific properties  +
// +  +  +  +  +  +  +  +  +  +  +  +

// +  + Default values  +  +  +  +  +
NSString *SceneActivateActionClassValue = @"ECNSceneActivateAction";
NSString *SceneActivateActionNameValue = @"Activate scene";

NSString *SceneDeactivateActionClassValue = @"ECNSceneDeactivateAction";
NSString *SceneDeactivateActionNameValue = @"Deactivate scene";

NSString *SceneToggleActionClassValue = @"ECNSceneToggleAction";
NSString *SceneToggleActionNameValue = @"Toggle scene";
// +  +  +  +  +  +  +  +  +  +  +  +



@implementation ECNSceneActivateAction

+ (NSString *) actionName	{
	return SceneActivateActionNameValue;
}

+ (Class ) targetType	{
	return [ECNScene class];
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
	if (![target isKindOfClass: [ECNSceneActivateAction targetType]]) 
		return nil;
	ECNAction *newAction = [ECNSceneActivateAction activateActionWithDocument: document];
	[newAction setTarget: target];
	return newAction;	
}

- (void) performAction	{
	id target =[self target];
	NSAssert ([target isKindOfClass: [ECNScene class]], @"Action received a wrong object type!");
	
	[(ECNProjectDocument *)[target document] setSceneActivationState: target active: true];
}

@end


@implementation ECNSceneDeactivateAction

+ (NSString *) actionName	{
	return SceneDeactivateActionNameValue;
}

+ (Class ) targetType	{
	return [ECNScene class];
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
	if (![target isKindOfClass: [ECNSceneDeactivateAction targetType]]) 
		return nil;
	ECNAction *newAction = [ECNSceneDeactivateAction deactivateActionWithDocument: document];
	[newAction setTarget: target];
	return newAction;	
}

- (void) performAction	{
	id target =[self target];
	NSAssert ([target isKindOfClass: [ECNScene class]], @"Action received a wrong object type!");
	
	[(ECNProjectDocument *)[target document] setSceneActivationState: target active: false];
}

@end


@implementation ECNSceneToggleAction

+ (NSString *) actionName	{
	return SceneToggleActionNameValue;
}

+ (Class ) targetType	{
	return [ECNScene class];
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
	if (![target isKindOfClass: [ECNSceneToggleAction targetType]]) 
		return nil;
	ECNAction *newAction = [ECNSceneToggleAction toggleActionWithDocument: document] ;
	[newAction setTarget: target];
	return newAction;	
}


- (void) performAction	{
	id target =[self target];
	NSAssert ([target isKindOfClass: [ECNScene class]], @"Action received a wrong object type!");
	
	[(ECNProjectDocument *)[target document] setSceneActivationState: target active: ![[target document] isSceneActive: target]];
}

@end
