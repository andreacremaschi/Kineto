//
//  ECNObject.m
//  kineto
//
//  Created by Andrea Cremaschi on 10/01/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import "ECNObject.h"
#import "ECNObjectTypes.h"

#import "ECNActions.h"

#import "ECNProjectDocument.h"

// +  + Private key for Coding protocol  +
NSString *ECNAttributesKey = @"attributes";

// +  + Object attributes  +
NSString *ECNObjectUniqueIDKey = @"id";
NSString *ECNObjectClassKey = @"class";
NSString *ECNPropertiesKey = @"properties";
NSString *ECNInputPortsKey = @"inputPorts";
NSString *ECNOutputPortsKey = @"outputPorts";

// +  + Object specific properties  +
NSString *ECNObjectNameKey = @"name";

// +  + Object default values  +
NSString *ObjectClassValue = @"Undefined object";
NSString *ObjectNameDefaultValue = @"Undefined object";
// +  +  +  +  +  +  +  +  +  +  +  +

@interface ECNObject (PrivateMethods)
- (id) initWithID: (NSNumber *)ID;
- (void)setDocument:(ECNProjectDocument *)document; 
- (id) propertiesDictRepresentationForObject: (id) objectToSerialize;
- (id) representationForObject: (id)curObject;
@end

@implementation ECNObject

#pragma mark  Initialization
- (id) initWithProjectDocument: (ECNProjectDocument *)document
{
	self = [self initWithID: [NSNumber numberWithInt:[document incIDCounter]] ];
	if (self) {
		[self setDocument: document];
//		[self setValue: [NSNumber numberWithInt:[document incIDCounter]] forAttributeKey: @"ID"]; 
	}
	return self;	
}

//used in serialization
- (id) initWithProjectDocument: (ECNProjectDocument *)document 
						withID: (NSNumber *)ID	{
	self = [self initWithID: ID ];
	if (self) {
		[self setDocument: document];
//		[self setValue: ID forAttributeKey: @"ID"]; 
	}
	return self;	
}	


- (void) initPorts {
}

- (id) initWithID: (NSNumber *)ID {
	self = [self init];
	if (self)	{
		_document = nil;

		NSMutableDictionary *dict = [self attributesDictionary];
		if (dict == nil)	{
			NSLog (@"Error initializing dictionary!");
			[self release];
			return nil;
		}
		[dict setValue: ID forKey: ECNObjectUniqueIDKey];
		_attributes = [[NSDictionary dictionaryWithDictionary: dict] retain];
		[self initPorts];
		
	}
	return self;
}



- (void) dealloc	{
	
	[_attributes release];
	
	[super dealloc];
}

	
- (NSMutableDictionary *) attributesDictionary	{
	// define class specific attributes
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInt: -1], ECNObjectUniqueIDKey, 
						  ObjectClassValue, ECNObjectClassKey, 
						  [NSMutableDictionary dictionaryWithCapacity: 0], ECNPropertiesKey, 
						  [NSMutableArray arrayWithCapacity: 0], ECNInputPortsKey, 
						  [NSMutableArray arrayWithCapacity: 0], ECNOutputPortsKey, 
						  nil];
	
	NSMutableDictionary *propertiesDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										   ObjectNameDefaultValue, ECNObjectNameKey,
										   nil];
	
	//_attributes = [dict retain];
	[[dict valueForKey: ECNPropertiesKey] addEntriesFromDictionary: propertiesDict ];

	return dict;
		
		
}

#pragma mark Constructors

	
+ (ECNObject *)objectWithDocument: (ECNProjectDocument *)document {
	
	ECNObject *newObject = [[[ECNObject alloc] initWithProjectDocument: document] autorelease];
	
	if (newObject != nil)	{
		
	
	}
	return newObject;
		
}

#pragma mark Accessors 

// private, called once in initWithProjectDocument:
- (void)setDocument:(ECNProjectDocument *)document {	
	NSAssert (document != nil, @"ERROR: can't set document to nil in method -[ECNObject setDocument:]"); 
	//if (document == nil) return;

	_document = [document retain];
	[_document addObject: self];
	
}

- (ECNProjectDocument *)document {
    return _document;
}

- (NSNumber *) ID	{
	return [_attributes valueForKey: ECNObjectUniqueIDKey];
}

#pragma mark -
#pragma mark  <NSCoding> protocol implementation

- (void)encodeWithCoder:(NSCoder *)coder {
    //[super encodeWithCoder:coder];
    [coder encodeObject:_attributes forKey: ECNAttributesKey];
}

- (id)initWithCoder:(NSCoder *)coder {
   // self = [super initWithCoder:coder];
	self = [self init];
	_attributes = [[coder decodeObjectForKey: ECNAttributesKey] retain];
    return self;
}

#pragma mark -
#pragma mark  Persistance



- (id) representationForObject: (id)curObject	{

	if (curObject == nil) return [NSNull null];
	
		
	id curObjectRepresentation;
	if ([curObject respondsToSelector: @selector(representation)])
		curObjectRepresentation = [curObject representation];
	else if ([curObject isKindOfClass: [ECNObject class]] ||
		[curObject isKindOfClass: [ECNPort class]] ||
		[curObject isKindOfClass: [NSArray class]] ||
		[curObject isKindOfClass: [NSDictionary class]])
		curObjectRepresentation = [self propertiesDictRepresentationForObject: curObject];
	else
		if ([curObject isKindOfClass: [NSDate class]] || 
			[curObject isKindOfClass: [NSNumber class]] ||
			[curObject isKindOfClass: [NSString class]] || 
			[curObject isKindOfClass: [NSData class]])
			curObjectRepresentation = curObject ;
		else
			//archive binary data
			curObjectRepresentation = [NSArchiver archivedDataWithRootObject:curObject];

	return curObjectRepresentation;
	
}

// this function process the property dictionary 
// and "packs" pointers to ECNObject and ECNPorts,
// replacing them with NSDictionary, with keys "ID" and "class".
// Returns an array or a dictionary
- (id) propertiesDictRepresentationForObject: (id) objectToSerialize	{
	
	id representation;

	// NSDictionary
	if ([objectToSerialize isKindOfClass: [NSDictionary class]])	{

		representation = [[[NSMutableDictionary alloc] init] autorelease];
		
		// todo: check that [_attributes valueForKey: ECNPropertiesKey] is a NSDictionary
		NSEnumerator *enumerator = [objectToSerialize keyEnumerator];
		id key;
		
		while ((key = [enumerator nextObject])) {
			id curObject = [objectToSerialize valueForKey: key];
			id curObjectRepresentation = [self representationForObject: curObject];			
			[representation setObject: curObjectRepresentation forKey: key];
		}
		
	} // end NSDictionary
	
		// NSArray
		else if ([objectToSerialize isKindOfClass: [NSArray class]])	{

		representation = [[NSMutableArray alloc] init];

		for (id curObject in objectToSerialize)	{
			id curObjectRepresentation = [self representationForObject: curObject];
			//NSLog(@"%@", curObjectRepresentation);
			[representation addObject: curObjectRepresentation];
		} 
	
	} //end NSArray
		
		// ECNObject	
		else if ([objectToSerialize isKindOfClass: [ECNObject class]])	{
		
		representation = [[[NSMutableDictionary alloc] init] autorelease];
	
		[representation setObject: [[objectToSerialize ID] stringValue]
				 forKey: ECNObjectUniqueIDKey];
		[representation setObject: NSStringFromClass([objectToSerialize class])
				 forKey: ECNObjectClassKey];
	} //end ECNObject
		 
		// ECNPort
		else if ([objectToSerialize isKindOfClass: [ECNPort class]])	{
		
		representation = [[[NSMutableDictionary alloc] init] autorelease];
		
		[representation setObject: NSStringFromClass([objectToSerialize class])
						   forKey: ECNObjectClassKey];
		[representation setObject: [[[objectToSerialize object] ID] stringValue]
						   forKey: ECNObjectUniqueIDKey];
		[representation setObject: [objectToSerialize name]
						   forKey: ECNPortAttributeNameKey];
	} // end ECNPort
	else representation = [[[NSMutableDictionary alloc] init] autorelease]; // default to empty dictionary

	return representation;

}

- (NSMutableDictionary *)propertyListRepresentation {
//	NSLog(@"%@", [self attributes]);
	NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								  
								  NSStringFromClass([self class]), ECNObjectClassKey,
								  [[self ID] stringValue], ECNObjectUniqueIDKey,
								  [self propertiesDictRepresentationForObject: [_attributes valueForKey: ECNPropertiesKey]],  ECNPropertiesKey,
								  nil];
	
    return dict;
}

// pointers to other objects are saved in file as nsdictionaries, with keys "Class" and "ID".
// search for these dictionaries and replace them with real objects!
- (id) unpackCollection: (id) collection	{
	
	//NSDictionary
	if ([collection isKindOfClass: [NSDictionary class]])	{

		NSArray *propertyKeys = [collection allKeys];
		
		// check if dictionary is a placeholder for a pointer to an object
		// (i.e. when the dictionary has a "id" and a "class" keys couple 
		if (([propertyKeys containsObject: ECNObjectClassKey]) &&
			([propertyKeys containsObject: ECNObjectUniqueIDKey]))	{

			// search the target object.
			NSNumber * objectID = [NSNumber numberWithInteger: [[collection valueForKey: ECNObjectUniqueIDKey] integerValue]];
			NSString * objectClass = [collection valueForKey: ECNObjectClassKey];
			NSLog(@"    processing object with ID: %@ and of class: %@", objectID, objectClass);
			id ecnObject = [[self document] objectWithID: objectID];
			NSLog(@"             checking class type");
			NSLog (@"      Unpacking object: %@", NSStringFromClass([ecnObject class]));
			
			if ([objectClass isEqual: @"ECNPort"])	{
				// this is a pointer to a port. Find it!
				NSAssert ([propertyKeys containsObject: ECNPortAttributeNameKey], @"Error: port in value without key port name");
				ECNPort * ecnPort = [ecnObject outputPortWithKey: [collection valueForKey: ECNPortAttributeNameKey ]];
				NSAssert (ecnPort != nil, @"Error: port not found!");
				return ecnPort;
				
			} else
				 {
					 NSAssert ([ecnObject isKindOfClass: NSClassFromString([collection valueForKey: ECNObjectClassKey])  ],   @"Error: file is corrupted. Aborting.");
					 NSLog(@"             ok, it is the right one");
					 return ecnObject;
				 }
		} else {
				// the dictionary is not a placeholder.
				// enumerate it and search for other nsdictionaries or arrays
			NSEnumerator *enumerator = [collection keyEnumerator];
			id key;

			NSMutableArray *substArray = [NSMutableArray array];
			
			//enumerate the dictionary
			while ((key = [enumerator nextObject])) {
				NSLog(@"    processing key: %@", key);
				id newObject = [collection valueForKey: key];
				if ([newObject isKindOfClass: [NSArray class]] || 
					[newObject isKindOfClass: [NSDictionary class]])	{
					id unpackedObject = [self unpackCollection: newObject];
					if (unpackedObject) {
						[substArray addObject: [NSDictionary dictionaryWithObjectsAndKeys: 
												unpackedObject, @"object", 
												key, @"subst_key",
												nil]];												
						NSLog(@"		Link created for key: %@", key); 
					}
				}
			}
			// replace the values
			for (NSDictionary* object in substArray)	{
				[collection setValue: [object valueForKey: @"object"] 
							  forKey: [object valueForKey: @"subst_key"]];
				NSLog(@"		Correctly replaced placeholder in dictionary for object: %@", [object valueForKey: @"subst_key"]); 
			}
			
		}
			
	} //NSDictionary
	
	//NSArray
	else if ([collection isKindOfClass: [NSArray class]])	{
		
		NSMutableArray *substArray = [NSMutableArray array];

		// enumerate the array and try to unpack it
		NSInteger index;
		for (index = 0; index < [collection count]; index++)	{
//		for (id property in collection)	{
			id property = [collection objectAtIndex: index];
			if ([property isKindOfClass: [NSArray class]] || 
				[property isKindOfClass: [NSDictionary class]])	{
					id unpackedObject = [self unpackCollection: property];
					if (unpackedObject) {
						[substArray addObject: [NSDictionary dictionaryWithObjectsAndKeys: 
												unpackedObject, @"object", 
												[NSNumber numberWithInteger: index], @"index",
												nil]];																		
						NSLog(@"		Link created in array"); 
					}
				
			}
		}
		
		// replace the values
		for (NSDictionary* object in substArray)	{
			[collection replaceObjectAtIndex: [[object valueForKey: @"index"] integerValue]
								  withObject: [object valueForKey: @"object"] ];
			NSLog(@"		Correctly replaced placeholder in array for object: %@", [object valueForKey: @"index"]); 
		}
		
	}
	return nil;
}


- (void) unpackObjectReferences	{
	NSLog (@"Will unpack object: %@", [self valueForPropertyKey: ECNObjectNameKey]);
	[self unpackCollection: [_attributes valueForKey: ECNPropertiesKey]];
}


+ (id) convertObject: (id)objectToConvert toType: (Class) dataType	{

	id convertedValue;

	NSString *originalType = NSStringFromClass([objectToConvert class]);
	NSString *readDataType = NSStringFromClass(dataType);
	
	NSLog(@"		Converting item of type: %@ to type: %@", originalType, readDataType);  

	if (([originalType isEqual: readDataType]) || ([readDataType isEqual: @"NSNull"]))	{
		convertedValue = objectToConvert;
	} else if ([readDataType isEqual: @"NSCFString"])	{
		convertedValue = objectToConvert;
	} else if ([readDataType isEqual: @"NSCFNumber"])	{
		convertedValue = [NSNumber numberWithFloat: [objectToConvert floatValue]];
	} else if ([readDataType isEqual: @"NSCFDate"])	{
		convertedValue = [NSDate dateWithString: objectToConvert];
	} else if ([readDataType isEqual: @"NSCFBoolean"])	{
		convertedValue = [NSNumber numberWithBool: [objectToConvert boolValue] ];
	} else if ([readDataType isEqual: @"NSCFColor"])	{
//		convertedValue = [NSValue valueWithBytes: cStringUsingEncoding char objCType:(const char *)type
	} else if ([originalType isEqual: @"NSCFData"])	{
		convertedValue = [NSUnarchiver unarchiveObjectWithData: objectToConvert];
		//		convertedValue = [NSValue valueWithBytes: cStringUsingEncoding char objCType:(const char *)type
	} else
	{
		//TODO: throw exception
		convertedValue = nil;
	}
	return convertedValue;
	
	
}

- (bool) willReturnAfterLoadingWithError: (NSError **)error	{
	return true;	
}

+ (ECNObject *)objectWithDataDictionary:(NSDictionary *)dict	withDocument: (ECNProjectDocument *)document {


	// check that dictionary data holds at least a ID and a Class keys
	NSString *errorString = [NSString stringWithFormat: @"Error: object data inconsistency found loading object: %@", [dict description]];
	NSAssert ( ([[dict allKeys] containsObject: ECNObjectClassKey] && [[dict valueForKey: ECNObjectClassKey] isKindOfClass: [NSString class]]), 
			  errorString);
	NSAssert ([[dict allKeys] containsObject: ECNObjectUniqueIDKey]  && [[dict valueForKey: ECNObjectUniqueIDKey] isKindOfClass: [NSString class]], 
			  errorString);
	
	// try to create a class of the type defined in file data
	Class objectClass = NSClassFromString([dict valueForKey: ECNObjectClassKey]);
	NSString *errString = [NSString stringWithFormat: @"Error: couldn't create class of type: '%@'", [dict valueForKey: ECNObjectClassKey]];
	NSAssert (objectClass, errString);

	NSNumber *objectID = [NSNumber numberWithInteger: [[dict valueForKey: ECNObjectUniqueIDKey] integerValue]];
	id newObject = [[[objectClass alloc] initWithProjectDocument: document 
																 withID: objectID] autorelease];
	NSLog(@"Creating object: %@ with ID: %@", [dict valueForKey: ECNObjectClassKey], [dict valueForKey: ECNObjectUniqueIDKey]);
	NSAssert (newObject, errString);
	
	//NSLog(@"Object loaded with data: %@", [newObject attributes]);
	
	// if a Properties key exists (and it should!), load data
	if ( [[dict allKeys] containsObject: ECNPropertiesKey]  && 
		 [[dict valueForKey: ECNPropertiesKey] isKindOfClass: [NSDictionary class]] )	{
	
		NSDictionary *propertiesDict = [dict valueForKey: ECNPropertiesKey];
		NSEnumerator *enumerator = [propertiesDict keyEnumerator];
		id key;

		// TODO: type conversion!
		while ((key = [enumerator nextObject])) {
			id curObject = [propertiesDict valueForKey: key];
			NSString *errString = [NSString stringWithFormat: @"Error: object data inconsistency found loading object: %@. Object %@ doesn't contain '%@' key.", [dict description], NSStringFromClass([newObject class]), key];
			
			NSAssert ([[newObject propertyKeys] containsObject: key], 
					  errString);

			// convert string value to the right type
			
			id convertedProperty = [self convertObject: curObject
												toType: [[newObject valueForPropertyKey: key] class]];
			[newObject setValue: convertedProperty forPropertyKey: key];
		}
	}
	
	//NSLog(@"Object loaded with data: %@", [newObject attributes]);
	// this invokation is here for final data preparing
	NSError *error = nil;
	if (![newObject willReturnAfterLoadingWithError: &error])
		NSLog( @"%@", [error description]);
	
	return newObject;
};


#pragma mark -

#pragma mark Attributes

- (NSDictionary *)attributes	{
	return [[_attributes copy] autorelease];
}

- (NSArray *)attributeKeys	{
	return [_attributes allKeys];	
}

/*
- (BOOL) setValue: (id)value forAttributeKey: (NSString *) key	{
	if (![[self attributeKeys] containsObject:key])	
		return false;		
	[_attributes  setObject: value forKey: key];
	NSLog(@"ECNObject: value set for attribute key: %@: %@", key, [value stringValue]);
	return true;
}
*/
#pragma mark -
#pragma mark Properties

- (NSArray *)propertyKeys	{
	return [[_attributes valueForKey: ECNPropertiesKey] allKeys];	
}

- (BOOL)setValue:(id)value forPropertyKey:(NSString *)key	{
	if (![[self propertyKeys] containsObject:key])	
		return false;
	if (value != nil) 
		[[_attributes valueForKey: ECNPropertiesKey] setObject: value forKey: key];
	else
		[[_attributes valueForKey: ECNPropertiesKey] setObject: [NSNull null] forKey: key];
	return true;
}

- (id)valueForPropertyKey:(NSString *)key	{
	if (![[self propertyKeys] containsObject:key])	
		return nil;	

	return [[_attributes valueForKey: ECNPropertiesKey] valueForKey: key];
}

#pragma mark Property convenience: specific property accessors
- (NSString *)name						
{	return [self valueForPropertyKey: ECNObjectNameKey] ;	}

- (void) setName: (NSString *)name	
{	[self willChangeValueForKey: ECNObjectNameKey];
	[self setValue: name forPropertyKey: ECNObjectNameKey]; 
	[self didChangeValueForKey: ECNObjectNameKey];
}


+ (NSString *) objectIncrementalNameWithRoot: (NSString *) string 
									  ofType: (Class )type
								  inDocument: (ECNProjectDocument *)document	{
		
	NSString *root = string;
	NSString *name;
	bool nameExists;
	if ((nil == root) || (root == @"")) 
		root = ObjectNameDefaultValue;
	
	// get an array of objects of type "type"
	NSArray *typedObjectsArray;
	if (nil != type) {
		NSAssert ([type isSubclassOfClass: [ECNObject class]], @"Error in ECNObject.m: Kineto objects must be of KObject class type.");
		typedObjectsArray = [document objectsOfKind: type];
	}
	else 
		typedObjectsArray = [document objects];

	
	//check if root name exists in objects of type "type"
	NSString *suffix = @"";
		int i = 0;
	do 	{
		
		i++;
		if (i>0) suffix = [NSString stringWithFormat: @" %i", i];
		name = [root stringByAppendingString: suffix];
		nameExists = false;
		for (ECNObject *object in typedObjectsArray)
		{
			if ([[object name] isEqualToString: name]) {
				nameExists = true;
				break;
			}
		}
	} while (nameExists);
			  
	return name;
	
	
}


- (void) setIncrementalNameWithRootName: (NSString *)rootName	{
	NSString *objectName = [ECNObject objectIncrementalNameWithRoot: rootName
															 ofType: [self class]
														 inDocument: [self document]];
	[self setName: objectName];
}
#pragma mark -
#pragma mark Ports

- (void) invalidateOutputPorts {
	for (ECNPort *outputPort in [self outputPorts])
		[self didChangeValueForKey: [outputPort key]];
}

- (bool) isOutputPortValueStillValidForKey: (NSString *)string	{
	ECNPort *outputport = [self outputPortWithKey: string];
	if (outputport == nil) return false;
	
	return [outputport isValid];
	
}

- (ECNPort *)inputPortWithKey: (NSString *)key	{
	// search for an input port with name "key"
	ECNPort *inputPort;
	for (inputPort in [_attributes valueForKey: ECNInputPortsKey])
		if ([[inputPort name] isEqualTo: key]) break;
	
	return inputPort;	
}

- (BOOL)setValue:(id)value forInputKey:(NSString *)key	{

	ECNPort *inputPort = [self inputPortWithKey: key];
	if (inputPort) {
		// set the value
		[inputPort setValue: value];	
		
		// invalidate output ports
		for (ECNPort *outputPort in [self outputPorts])
			[outputPort invalidate];
		
		return true;
	}
	else return false;
}


- (ECNPort *)outputPortWithKey: (NSString *)key	{
	// search for an output port with name "key"
	ECNPort *outputPort;
	for (outputPort in [_attributes valueForKey: ECNOutputPortsKey])
		if ([[outputPort name] isEqualTo: key]) break;
	
	return outputPort;	
}

- (BOOL)setValue:(id)value forOutputKey:(NSString *)key	{
	
	ECNPort *outputPort = [self outputPortWithKey: key];
	if (outputPort) {
		
		// set the value
//		[self willChangeValueForKey: key];
		[outputPort setValue: value];	
//		[self didChangeValueForKey: key];

		return true;
	}
	else return false;
}

- (id)valueForOutputKey:(NSString *)key	{

	
	ECNPort *outputPort = [self outputPortWithKey: key];
	if (!outputPort) {
		return nil;
	}
	return [outputPort value];
}

- (id)valueForInputKey:(NSString *)key	{
	ECNPort *inputPort = [self inputPortWithKey: key];
	if (inputPort) {
		// set the value
		return [inputPort value];	
	}
	else return nil;
}


- (NSArray *)outputKeys	{


	NSArray *outputPorts = [self outputPorts];
	int i;
	int c = [outputPorts count];
	NSMutableArray *outputKeys = [NSMutableArray arrayWithCapacity:0];
	
	for (i=0;i<c;i++)	{
		ECNPort *curPort = [outputPorts objectAtIndex:i];
		[outputKeys addObject:[curPort name]];
	}
//		[outputKeys replaceObjectAtIndex: i withObject: [[outputPorts objectAtIndex:i] name]];
	return outputKeys; 
	
	//	return [[_attributes valueForKey: ECNOutputPortsKey] allKeys];
}

- (NSArray *)outputPorts	{
	return [_attributes valueForKey: ECNOutputPortsKey] ;
}

- (NSArray *)outputPortsOfType: (NSString *)portType	{
	id outports = [_attributes valueForKey: ECNOutputPortsKey];
	if ([outports isKindOfClass: [NSArray class]]) {
		NSMutableArray *numericoutports = [NSMutableArray array];
		for (id outPort in outports)
			if ([outPort isKindOfClass: [ECNPort class]] && [[outPort type] isEqualToString: portType]) {
				[numericoutports addObject: outPort];
			}
		return numericoutports;

	}
	return [NSArray array];
}
				 

- (NSArray *)numericOutputPorts {
	return [self outputPortsOfType: ECNPortTypeNumber];
}


- (void) addInputPortWithType:(NSString*)type forKey:(NSString*)key withAttributes:(NSDictionary*)attributes	{

	ECNPort *newInputPort = [ECNPort portWithObject: self
								   withType: type 
								   withName: key];
	
	NSArray *attributesKeys = [NSArray arrayWithArray: [attributes allKeys]];
	
	if ([attributesKeys containsObject: ECNPortAttributeMinimumValueKey])
		[newInputPort setMinValue: [attributes valueForKey: ECNPortAttributeMinimumValueKey]];

	if ([attributesKeys containsObject: ECNPortAttributeMaximumValueKey])
		[newInputPort setMaxValue: [attributes valueForKey: ECNPortAttributeMaximumValueKey]];

	
	[[_attributes valueForKey: ECNInputPortsKey] addObject: newInputPort];
	
}

- (void) addOutputPortWithType:(NSString*)type forKey:(NSString*)key withAttributes:(NSDictionary*)attributes {
	// create new output port
	ECNPort *newOutput = [ECNPort portWithObject: self
								   withType: type 
								   withName: key];	
	
	// check if attributes key contain default value for output port to be set
	NSArray *attributesKeys = [NSArray arrayWithArray: [attributes allKeys]];

	if ([attributesKeys containsObject: ECNPortAttributeDefaultValueKey])
		[newOutput setMaxValue: [attributes valueForKey: ECNPortAttributeMaximumValueKey]];

	// add output port to object output ports array
	[[_attributes valueForKey: ECNOutputPortsKey] addObject: newOutput];	
	
}

#pragma mark -
#pragma mark NSKeyCoding protocol implementations

- (void)setValue:(id)value forKey:(NSString *)key	{
	bool success;

	@synchronized (self) {
		
		[self willChangeValueForKey: key];
		// search the key in the property array
		success = [self setValue: value forPropertyKey:key];

		if (!success) {
			success = [self setValue: value forInputKey:key];
			if (!success)
				[super setValue: value forKey: key];
		
		}
		if (success)
			NSLog(@"ECNObject: value set for property key: %@: %@", key, value);
		else {
			NSLog(@"ECNObject: object doesn't have the property key: %@", key, value);

		}

		[self didChangeValueForKey: key];

		/*
			if (!success)
		{	//if ([value isKindOfClass: 
			@try {	// in case of null values!
				NSLog(@"ECNObject: value set for property key: %@: %@", key, value);
			} @catch(NSException *exception) {}
			[self didChangeValueForKey: key];
			return;
		}
		
		// search the key in the input array
		if (success)	{
			NSLog(@"ECNObject: value set for input key: %@: %@", key, value);
			[self didChangeValueForKey: key];
			return;
		}
		
		
		// if not in the property array, maybe the key is in the instance properties.
		if (!success)	
			[super setValue: value forKey: key];
	}*/
	}
}

- (id)valueForKey:(NSString *)key	{
	id value = [self valueForPropertyKey: key];
	if (value == nil)
		value = [self valueForOutputKey: key];		
	if (value == nil)
		value = [super valueForKey: key];
	if (value == nil)
		NSLog(@"ECNObject valueForKey error: no port with key name '%@'", key);

	return value;
}


@end
