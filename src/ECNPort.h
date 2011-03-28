//
//  ECNPort.h
//  kineto
//
//  Created by Andrea Cremaschi on 14/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/* Keys for input / output ports attributes */
extern NSString* const ECNPortAttributeTypeKey;
extern NSString* const ECNPortAttributeNameKey;
extern NSString* const ECNPortAttributeMinimumValueKey; //For Number ports only
extern NSString* const ECNPortAttributeMaximumValueKey; //For Index and Number ports only

extern NSString* const ECNPortAttributeDefaultValueKey; //For value ports only (Boolean, Number, Color and String)

/* Values for QCPortAttributeTypeKey corresponding to the possible types of input / output ports */
extern NSString* const ECNPortTypeBoolean;
extern NSString* const ECNPortTypeIndex;
extern NSString* const ECNPortTypeNumber;
extern NSString* const ECNPortTypeString;
extern NSString* const ECNPortTypeColor;
extern NSString* const ECNPortTypeImage;
extern NSString* const ECNPortTypeStructure;

@class ECNObject;

@interface ECNPort : NSObject {

	NSMutableDictionary *_attributes;
	ECNObject *_object;
	id _value;
	bool _isValid;
}

+ (ECNPort *) portWithObject: (ECNObject *)object
					withType: (NSString*)type 
					withName: (NSString*)name;

+ (NSMutableDictionary *) attributesDictionary;

- (void) setMinValue: (id) minValue;
- (void) setMaxValue: (id) maxValue;
- (void) setDefaultValue: (id) defaultValue;

- (NSString *)name;
- (NSString *)type;
- (NSString *)stringValue;

- (ECNObject *)object;

- (id) value;
- (void) setValue:(id)value;

- (void) invalidate;
- (bool) isValid;

@end
