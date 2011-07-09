//
//  ECNShapeTrigger.m
//  kineto
//
//  Created by Andrea Cremaschi on 16/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import "ECNShapeTrigger.h"
#import "ECNShape.h"

@implementation ECNShapeTrigger

// +  + Elements specific properties  +
NSString *ECNMaskToObserveKey = @"mask_to_observe"; 
// +  +  +  +  +  +  +  +  +  +  +  +

// +  + Default values  +  +  +  +  +
NSString *ECNShapeTriggerClassValue = @"ECNShapeTrigger";
// +  +  +  +  +  +  +  +  +  +  +  +


#pragma mark *** Initialization ***


- (NSMutableDictionary *) attributesDictionary	{
	
	NSMutableDictionary *dict = [super attributesDictionary];
	
	// set default attributes values
	[dict setValue: ECNShapeTriggerClassValue forKey: ECNObjectClassKey];
	
	NSDictionary *propertiesDict = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithInt: 0], ECNMaskToObserveKey,
									nil];
	
	//[_attributes addEntriesFromDictionary: attributesDict];
	[[dict objectForKey: ECNPropertiesKey] addEntriesFromDictionary: propertiesDict ];
	
	// NO default values: ECNElement and ECNShape are abstract classes without constructors!
	
	
	/*	[dict setValue: ElementClassValue forKey: ECNObjectClassKey];
	 [dict setValue: ElementNameDefaultValue forPropertyKey: ECNObjectNameKey];*/
	
	return dict;
	
	
}

#pragma mark Constructors


+ (ECNShapeTrigger *)shapeTriggerWithDocument: (ECNProjectDocument *)document {
	ECNShapeTrigger *newTrigger = [[[ECNShapeTrigger alloc] initWithProjectDocument: document] autorelease];
	if (newTrigger != nil)	{
		
		// set default values
		// default port to observe is set in method initWithProjectDocument in ECNShape.m
		[newTrigger setValue: [NSNull null] forPropertyKey:  ECNTriggerPortToObserveKey]; 
		[newTrigger setValue: [NSNumber numberWithFloat: 0.1] forPropertyKey:  ECNTriggerLatencyKey];
		[newTrigger setValue: [NSNumber numberWithFloat: 0.3] forPropertyKey:  ECNTriggerActivationThresholdKey];
		[newTrigger setValue: [NSNumber numberWithFloat: 0.3] forPropertyKey:  ECNTriggerDeactivationThresholdKey];
	}
	return newTrigger;
	
}


+ (ECNTrigger *)triggerWithDocument: (ECNProjectDocument *)document	{
	return [ECNShapeTrigger shapeTriggerWithDocument: document];
	
}

#pragma mark -
#pragma mark Accessors

- (int)maskToMonitor	{
	return [[self valueForPropertyKey: ECNMaskToObserveKey] intValue];	
}


#pragma mark -
#pragma mark = Playback
#pragma mark -
#pragma mark Playback methods

- (float) observedValue	{
	float value = 0.0;

	// get the observed port
	id observedPortKey = [self valueForPropertyKey: ECNTriggerPortToObserveKey];
	id observedElement = [self valueForPropertyKey: ECNTriggerElementToObserveKey];
	
	// check if observed element is valid, and if its value is a ECNElement
	if ((observedElement == [NSNull null]) || (![observedElement isKindOfClass: [ECNElement class]])) return 0.0;

	// check if port is valid, and if its value is a NSNumber
	if ((observedPortKey == [NSNull null]) || (![observedPortKey isKindOfClass: [NSString class]])) return 0.0;
	
	NSObject *valueObject  = [observedElement valueForOutputKey: observedPortKey];
	if (![valueObject isKindOfClass: [NSNumber class]]) return 0.0;
	
	// return port value as a float
	value = [(NSNumber *)valueObject floatValue];
	return value;
}	

- (bool) checkIfHasToBeActivated	{
	float activationThreshold = [[self valueForPropertyKey:ECNTriggerActivationThresholdKey] floatValue];
	return ([self observedValue] > activationThreshold); 
}

- (bool) checkIfHasToBeDeactivated	{
	float deactivationThreshold = [[self valueForPropertyKey:ECNTriggerDeactivationThresholdKey] floatValue];	
	float observedValue = [self observedValue];
	return (observedValue <= deactivationThreshold); 
}


#pragma mark -
#pragma mark ### ECNTrigger overrides ###


#pragma mark Drawing methods



- (void) drawLineFromPoint: (NSPoint) startPoint 
				   toPoint: (NSPoint )endPoint	
				 inContext: (CGContextRef) context	{
	
	CGMutablePathRef path = CGPathCreateMutable();
	
	CGPathMoveToPoint(path, 
					  nil,
					  startPoint.x,
					  startPoint.y );
	CGPathAddLineToPoint (path,
						  nil,
						  endPoint.x,
						  endPoint.y );
	
	CGPathCloseSubpath ( path);
	
	CGContextBeginPath(context);
	CGContextAddPath(context, path);
	CGContextStrokePath( context);	
	
	
}
- (void) drawInCGContext: (CGContextRef)context
				withRect: (CGRect) rect	
{
	ECNElement *elementToObserve = [self valueForPropertyKey: ECNTriggerElementToObserveKey];

	if (_flags.isActive) {
	
		CGMutablePathRef elementPath = [elementToObserve quartzPathInRect: rect];
		
		
		//	NSColor *objectColor = [self strokeColor];
		
		
		CGContextSetRGBStrokeColor (context,
									0.0, 0.0, 1.0, 1.0
									);
		CGContextSetLineWidth (context, rect.size.width / 160.0 * 2.5);
		
		CGContextBeginPath(context);
		CGContextAddPath(context, elementPath);
		CGContextStrokePath( context);	
	}
	
	
	//draw representation for observed port
	
	NSString *portToObserve = [self valueForPropertyKey: ECNTriggerPortToObserveKey];
	id lastValue = _flags.lastValue;
	
	if ((nil == lastValue) || 
		!([lastValue isKindOfClass: [NSNumber class]]))
		return;
	
	// draw line for observed port
	if (![portToObserve isEqualTo: ShapeOutputExtension])	{
		
		NSRect drawingBounds = [elementToObserve calcPixelBoundsInRect: NSRectToCGRect( rect )]; 
		
		// CG contexts are upside down in respect of NS graphics contexts!
		drawingBounds.origin.y = rect.size.height - drawingBounds.origin.y - drawingBounds.size.height;

		
		if ( ([portToObserve isEqualTo: ShapeOutputHighest]) ||
			([portToObserve isEqualTo: ShapeOutputLowest]) ||
			([portToObserve isEqualTo: ShapeOutputMiddleVertical]) ) {

			CGFloat lineYPos = drawingBounds.size.height * [lastValue floatValue];
			[self drawLineFromPoint: NSMakePoint( NSMinX(drawingBounds), drawingBounds.origin.y + lineYPos)
							toPoint: NSMakePoint( NSMaxX(drawingBounds), drawingBounds.origin.y + lineYPos)
						  inContext: context];
			
			
		}
		else 
			if ( ([portToObserve isEqualTo: ShapeOutputRightmost]) ||
				([portToObserve isEqualTo: ShapeOutputLeftmost]) ||
				([portToObserve isEqualTo: ShapeOutputMiddleHorizontal]) ) {

				CGFloat lineXPos = drawingBounds.size.width * [lastValue floatValue];
				[self drawLineFromPoint: NSMakePoint( NSMinX(drawingBounds) + lineXPos, NSMinY(drawingBounds) )
								toPoint: NSMakePoint( NSMinX(drawingBounds) + lineXPos, NSMaxY(drawingBounds) ) 
							  inContext: context];

			}
		
		
	}
	
	
	
}

@end
