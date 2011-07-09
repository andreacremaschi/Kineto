//
//  ECNObject.h
//  kineto
//
//  Created by Andrea Cremaschi on 10/01/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

#import "ECNPort.h"

#define ECNObjectDataType @"ECNObjectDataType"

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
@interface ECNObject : NSObject <NSCoding>  {
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
- (void) unpackObjectReferences;
+ (ECNObject *)objectWithDataDictionary:(NSDictionary *)dict withDocument: (ECNProjectDocument *)document ;
- (bool) willReturnAfterLoadingWithError: (NSError **)error;

// ================================ Unique identifier =================================
/*- (void) setID: (int) objectID;*/
- (NSNumber *) ID;
- (NSString *)name;
- (void)setName: (NSString *) name;
+ (NSString *) objectIncrementalNameWithRoot: (NSString *) string 
									  ofType: (Class )type
								  inDocument: (ECNProjectDocument *)document;
- (void) setIncrementalNameWithRootName: (NSString *)rootName;


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
- (NSArray *)numericOutputPorts;

- (ECNPort *)outputPortWithKey:(NSString *)key;

- (id)valueForOutputKey:(NSString *)key;
- (id)valueForInputKey:(NSString *)key;

- (NSDictionary *)attributes;

- (bool) isOutputPortValueStillValidForKey: (NSString *)string;

@end
