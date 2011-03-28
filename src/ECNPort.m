//
//  ECNPort.m
//  kineto
//
//  Created by Andrea Cremaschi on 14/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECNPort.h"

@implementation NSColor(NSColorHex)

-(NSString *)hexValue{
	
	float redFloatValue, greenFloatValue, blueFloatValue;
	
	int redIntValue, greenIntValue, blueIntValue;
	
	NSString *redHexValue, *greenHexValue, *blueHexValue;
	
	NSColor *convertedColor=[self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	
	if(convertedColor)
		
	{
		
		// Get the red, green, and blue components of the color
		
		//[convertedColor getRed:&redFloatValue green:&greenFloatValue blue:&blueFloatValue alpha:NULL];
		
		redFloatValue =[convertedColor redComponent];
		
		blueFloatValue=[convertedColor blueComponent];
		
		greenFloatValue=[convertedColor greenComponent];
		
		// Convert the components to numbers (unsigned decimal integer) between 0 and 255
		
		redIntValue=redFloatValue*255.99999f;
		
		greenIntValue=greenFloatValue*255.99999f;
		
		blueIntValue=blueFloatValue*255.99999f;
		
		// Convert the numbers to hex strings
		
		redHexValue=[NSString stringWithFormat:@"%02x", redIntValue];
		
		greenHexValue=[NSString stringWithFormat:@"%02x", greenIntValue];
		
		blueHexValue=[NSString stringWithFormat:@"%02x", blueIntValue];
		
		// Concatenate the red, green, and blue components' hex strings together with a "#"
		
		return [NSString stringWithFormat:@"%@%@%@", redHexValue, greenHexValue, blueHexValue];
		
	}
	
	return nil;
	
}
@end

@implementation ECNPort

// +  + Port attributes  +

 NSString* const ECNPortAttributeTypeKey = @"Port type";
 NSString* const ECNPortAttributeNameKey = @"Name";
 NSString* const ECNPortAttributeMinimumValueKey  = @"Min value"; //For Number ports only
 NSString* const ECNPortAttributeMaximumValueKey  = @"Max value"; //For Index and Number ports only

 NSString* const ECNPortAttributeDefaultValueKey = @"Default value"; //For value ports only (Boolean, Number, Color and String)

// +  +  +  +  +  +  +  +  +  +  +  +

/* Values for QCPortAttributeTypeKey corresponding to the possible types of input / output ports */
 NSString* const ECNPortTypeBoolean = @"boolean";
 NSString* const ECNPortTypeNumber  = @"float";
 NSString* const ECNPortTypeString  = @"string";
 NSString* const ECNPortTypeColor  = @"color";
 NSString* const ECNPortTypeImage  = @"image";
 NSString* const ECNPortTypeStructure  = @"structure";
// +  +  +  +  +  +  +  +  +  +  +  +


- (id) initWithObject: (ECNObject *)object
			 withType: (NSString *)type
			 withName: (NSString *)name	{
	
	self = [super init];
	if (self)	{
		_object = [object retain];
		
		NSMutableDictionary *dict = [ECNPort attributesDictionary];
		if (dict == nil)	{
			NSLog (@"Error initializing port dictionary!");
			[self release];
			return nil;
		}
		
		// setup ummodificable values
		[dict setValue: type forKey: ECNPortAttributeTypeKey];
		[dict setValue: name forKey: ECNPortAttributeNameKey];
		
		_attributes = [[NSMutableDictionary dictionaryWithDictionary: dict] retain];
		_isValid = false;
		
	}
	return self;
}

- (void) dealloc	{
	[_object release];
	[_attributes release];
	
	[super dealloc];
	
}

+ (NSMutableDictionary *) attributesDictionary	{
	// define class specific attributes
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								 @"", ECNPortAttributeTypeKey,
								 @"",  ECNPortAttributeNameKey,
								 [NSNumber numberWithFloat: 0.0],  ECNPortAttributeMinimumValueKey, //For Number ports only
								 [NSNumber numberWithFloat: 1.0],  ECNPortAttributeMaximumValueKey, //For Number ports only
								 [NSNull null],  ECNPortAttributeDefaultValueKey, //For value ports only (Boolean, Number, Color and String)
								 nil];
			
	return dict;
	
}


#pragma mark *** Constructor

+ (ECNPort *) portWithObject: (ECNObject *)object
					withType: (NSString*)type 
				  withName: (NSString*)name  {

	ECNPort * ecnPort = [[[ECNPort alloc] initWithObject: object
											   withType: type
											   withName: name] autorelease];

	return ecnPort;
	
}

#pragma mark *** Accessors
- (ECNObject *)object	{
	return _object;
}


- (void) setDefaultValue: (id) defaultValue	{
	
}


- (id) value	{
	return _value;
}


- (id) portClass		{
	id classType;

	NSString *portType = [_attributes valueForKey: ECNPortAttributeTypeKey];
	if ((portType == ECNPortTypeBoolean) ||  (portType == ECNPortTypeNumber))
		classType = [NSNumber class];
	else if (portType == ECNPortTypeString) 
		classType = [NSString class];
	else if (portType == ECNPortTypeColor) 
		classType = [NSColor class];
	else if (portType == ECNPortTypeImage) 
		classType = [CIImage class];
	else if (portType == ECNPortTypeStructure) 
		classType = [NSObject class]; //NSArray or NSDictionary
	else classType = nil;
	
	return classType;
		
	
}


- (void) setValue:(id)value	{

	id portClass = [self portClass];
	
	// check if the value to be set is correct
	bool result = [value isKindOfClass: portClass];
	
	if (!result) return ;
	
	// if port is a number, check if min and max value are respected 
	if (portClass == [NSNumber class])	{
		NSNumber *numValue = (NSNumber *)value;
		if (([numValue floatValue] > [[_attributes valueForKey: ECNPortAttributeMaximumValueKey] floatValue]) ||
			([numValue floatValue] < [[_attributes valueForKey: ECNPortAttributeMinimumValueKey] floatValue]))
			return ;
	}
	
	[self willChangeValueForKey:@"value"];
	[self willChangeValueForKey:@"stringValue"];
	
	if (_value!=nil) [_value release];
	_value = [value retain];
	
	[self didChangeValueForKey:@"stringValue"];
	[self didChangeValueForKey:@"value"];
	
	
	return;	
}


- (NSString *)name {
	return [_attributes valueForKey: ECNPortAttributeNameKey];
}

- (NSString *)type	{
	return [_attributes valueForKey: ECNPortAttributeTypeKey];	
}

- (NSString *)stringValue	{
	NSString *result;
	NSString *portType = [_attributes valueForKey: ECNPortAttributeTypeKey];

	if (portType == ECNPortTypeBoolean) 
		result = [(NSNumber *)_value boolValue] ? @"true" : @"false"; 
	else if (portType == ECNPortTypeNumber)
		result = [NSString stringWithFormat: @"%.2f", [(NSNumber *)_value floatValue]];
	else if (portType == ECNPortTypeStructure)	{
		if ([_value isKindOfClass: [NSDictionary class]]) {
			NSEnumerator *enumerator = [_value keyEnumerator];
			NSString *formattedValue;
			id key, curValue;

			result = @"[";
			while ((key = [enumerator nextObject])) {
				curValue = [_value valueForKey: key];
				if ([curValue isKindOfClass: [NSNumber class]])
					formattedValue = [NSString stringWithFormat:@"%.2f", [curValue floatValue]];
				else
					formattedValue = curValue;
				
				if (![result isEqual: @"["]) result = [result stringByAppendingString:@", "]; 
				result = [result stringByAppendingFormat: @"%@: %@", key, formattedValue]	;		
			}
			result = [result stringByAppendingString: @"]"];

		} else
		result = @"structure";
	}
	else if (portType == ECNPortTypeString) 
		result = _value;
	else if (portType == ECNPortTypeColor) 
		result = [_value hexValue] ;
	else if (portType == ECNPortTypeImage) {
		NSRect rect = NSRectFromCGRect( [(CIImage *)_value extent] );
		result = NSStringFromSize( NSMakeSize(rect.size.width, rect.size.height) );
	}
	else result = nil;
	return result;
	
}

- (bool) isValid	{
	return _isValid;
}

- (void) invalidate {
	_isValid = false;
}

- (void) setMinValue: (id) minValue	{
	if ([minValue isKindOfClass: [NSNumber class]])
		[_attributes setValue: minValue forKey: ECNPortAttributeMinimumValueKey];

}

- (void) setMaxValue: (id) maxValue	{
	if ([maxValue isKindOfClass: [NSNumber class]])
		[_attributes setValue: maxValue forKey: ECNPortAttributeMaximumValueKey];
}

@end
