//
//  ECNAction.h
//  kineto
//
//  Created by Andrea Cremaschi on 16/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECNObject.h"

@class ECNElement;
@interface ECNAction : ECNObject {

}

+ (ECNAction *)actionWithDocument: (ECNProjectDocument *)document withTarget: (ECNObject *)target;

+ (NSArray *)actionListForObjectType: (Class ) objectType;
+ (NSArray *)availableActionClasses;

+ (Class ) targetType;
+ (NSString *) actionName;
- (NSString *)description;

- (ECNObject *)target;
- (void) setTarget: (ECNObject *)target;

- (void) performAction;

@end
