//
//  ECNObject.h
//  kineto
//
//  Created by Andrea Cremaschi on 10/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

#import "ECNPort.h"

// +  + Object specific properties  +
extern NSString *ECNObjectUniqueIDKey;
extern NSString *ECNObjectClassKey;
extern NSString *ECNObjectNameKey;

// +  +  +  +  +  +  +  +  +  +  +  +

// NB ho messo qui queste chiavi per velocità, in realtà
// vorrei evitare che classi non derivate da ECNObject possano accedere direttamente agli array
// delle Proprietà e delle Outports
extern NSString *ECNPropertiesKey;
extern NSString *ECNOutputPortsKey ;


@class ECNProjectDocument;
@interface ECNObject : NSObject  {
	int _uniqueID;
	ECNProjectDocument *_document;
	
	NSMutableDictionary *_attributes;
	
}


// =================================== Init ===================================
- (id) initWithProjectDocument: (ECNProjectDocument *)document;
- (id) initWithProjectDocument: (ECNProjectDocument *)document withID: (NSNumber *)ID;
- (NSMutableDictionary *) attributesDictionary;


// =================================== Accessors ===================================
- (ECNProjectDocument *)document;

// =================================== Persistence ===================================
- (NSMutableDictionary *)propertyListRepresentation;
- (void)loadPropertyListRepresentation:(NSDictionary *)dict;
- (void) unpackObjectReferences;
+ (ECNObject *)objectWithDataDictionary:(NSDictionary *)dict withDocument: (ECNProjectDocument *)document ;

// ================================ Unique identifier =================================
/*- (void) setID: (int) objectID;*/
- (NSNumber *) ID;



// === properties and output ports ===

- (BOOL)setValue:(id)value forPropertyKey:(NSString *)key;
- (BOOL)setValue:(id)value forInputKey:(NSString *)key;
- (BOOL)setValue:(id)value forOutputKey:(NSString *)key;

- (id)valueForPropertyKey:(NSString *)key;
- (NSArray *)propertyKeys;

- (void) addInputPortWithType:(NSString*)type forKey:(NSString*)key withAttributes:(NSDictionary*)attributes;
- (void) addOutputPortWithType:(NSString*)type forKey:(NSString*)key withAttributes:(NSDictionary*)attributes;
- (NSArray *)outputKeys;
- (NSArray *)outputPorts;

- (ECNPort *)outputPortWithKey:(NSString *)key;

- (id)valueForOutputKey:(NSString *)key;
- (id)valueForInputKey:(NSString *)key;

- (NSDictionary *)attributes;

- (bool) isOutputPortValueStillValidForKey: (NSString *)string;

@end
