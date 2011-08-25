//
//  ECNElement.m
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 28/10/10.
//  Copyright 2010 AndreaCremaschi. All rights reserved.
//

#import "ECNElement.h"
#import "KCue.h"
#import "ECNProjectDocument.h"
#import "ElementsView.h"

#import "ECNAction.h"
#import "ECNTrigger.h"

#import "KIncludes.h"

NSString *ECNElementDidChangeNotification = @"ECNElementDidChange";

// +  + Elements specific properties  +
NSString *ECNElementBoundsKey = @"bounds";
NSString *ECNElementStrokeColorKey = @"stroke_color";

NSString *ECNElementVisibleKey = @"visible";
NSString *ECNElementEnabledKey = @"enabled";

NSString *ECNElementSceneKey = @"cue";
NSString *ECNElementActiveWhenSceneOpensKey = @"active_when_scene_opens";

NSString *ECNElementTriggersListKey = @"triggers";
// +  +  +  +  +  +  +  +  +  +  +  +


// +  + Default values  +  +  +  +  +
NSString *ElementClassValue = @"Undefined element";
NSString *ElementNameDefaultValue = @"Undefined element";
// +  +  +  +  +  +  +  +  +  +  +  +

// private methods
@interface ECNElement (PrivateMethods)
	
- (void) updateOutputPorts;
- (void) addTrigger: (ECNTrigger *)trigger;
@end


@implementation ECNElement

#pragma mark *** Initialization ***


- (NSMutableDictionary *) attributesDictionary	{

	NSMutableDictionary *dict = [super attributesDictionary];
	
	// set default attributes values
	[dict setValue: ElementClassValue forKey: ECNObjectClassKey];

	NSDictionary *propertiesDict = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSValue valueWithRect: NSMakeRect(0.1f, 0.1f, 0.9f, 0.9f)], ECNElementBoundsKey,
									[NSColor blackColor], ECNElementStrokeColorKey,
									[NSNumber numberWithBool: true], ECNElementVisibleKey,
									[NSNumber numberWithBool: true], ECNElementEnabledKey,
									[NSNull null], ECNElementSceneKey,
									[NSNumber numberWithBool: true], ECNElementActiveWhenSceneOpensKey,
									[NSMutableArray arrayWithCapacity: 0], ECNElementTriggersListKey,
									nil];
	
	//[_attributes addEntriesFromDictionary: attributesDict];
	[[dict objectForKey: ECNPropertiesKey] addEntriesFromDictionary: propertiesDict ];

	// NO default values: ECNElement and ECNShape are abstract classes without constructors!

	
	/*	[dict setValue: ElementClassValue forKey: ECNObjectClassKey];
	[dict setValue: ElementNameDefaultValue forPropertyKey: ECNObjectNameKey];*/
	
	return dict;
	
	
}


- (id)init {
    self = [super init];
    if (self) {
        _document = nil;

			
		[self setVisible: true]; // initially visible in editor
        [self setStrokeColor:[NSColor blackColor]];

        _origBounds = NSZeroRect;
        _gFlags.manipulatingBounds = NO;
		
	}
    return self;
}



- (id) initWithProjectDocument: (ECNProjectDocument *)document
{
	self = [super initWithProjectDocument: document];
	if (self) {
		// add a first empty trigger		
		Class triggerClass = [ [self class] triggerClass ];
		ECNTrigger * trigger = [triggerClass triggerWithDocument: document];
		if (triggerClass == nil)	{
			NSLog(@"Be careful: triggerClass has not been implemented in class '%@'. Please do it!", [self class]);
		} else	{
			if (![[[self class] defaultTriggerPortKey] isEqual: @""])
				[trigger setElementToObserve: self atPort: [[self class] defaultTriggerPortKey] ];
			else 
				NSLog(@"Be careful: defaultTriggerKey has not been implemented in class '%@'. Please do it!", [self class]);

			[self addTrigger: trigger];
						
		}
	}
	return self;	
}


- (void)dealloc {
//    [_fillColor release];
 //   [_strokeColor release];
//	[_strName release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    id newObj = [[[self class] allocWithZone:zone] init];
	
    // Document is not "copied".  The new element will need to be inserted into a document.
  /*  [newObj setBounds:[self bounds]];
    [newObj setStrokeColor: [self strokeColor]];*/
/*    [newObj setFillColor:[self fillColor]];
    [newObj setDrawsFill:[self drawsFill]];
    [newObj setDrawsStroke:[self drawsStroke]];
    [newObj setStrokeLineWidth:[self strokeLineWidth]];
	*/
    return newObj;
}

// returns the type of trigger that should be set for this class
// (used to link ECNElement subclasses to the correct ECNTrigger subclasses)
+ (Class) triggerClass		{
	return [ECNTrigger class];
}

+ (NSString*) defaultTriggerPortKey		{
	return @"";
}

#pragma mark Constructors
+ (ECNElement *)elementWithDocument: (ECNProjectDocument *)document	{
	//NB ELEMENT is an abstract class, that should never return an instance
	return nil;
	
}

#pragma mark -
#pragma mark *** Document accessors and conveniences ***

- (void)setCue:(KCue *)scene {
    [self setValue: scene forPropertyKey: ECNElementSceneKey];
}

- (KCue *)cue {
    return [self valueForPropertyKey: ECNElementSceneKey];
}

- (NSString *)position	{
	return [NSString stringWithFormat: @"%@:%@", [[self cue] name], [self valueForPropertyKey: ECNObjectNameKey]];
}


#pragma mark *** ECNElement Property accessors 

- (bool)isEnabled						
	{	return [[self valueForPropertyKey: ECNElementEnabledKey] floatValue];	}

- (void) setEnabled: (bool)isEnabled	
	{	[self setValue: [NSNumber numberWithBool: isEnabled] forPropertyKey: ECNElementEnabledKey]; }

- (bool)isVisible						//{	return _bIsVisible;	}
{	return [[self valueForPropertyKey: ECNElementVisibleKey] floatValue];	}

- (void) setVisible: (bool)isVisible	//{	_bIsVisible = isVisible;	}
{	[self setValue: [NSNumber numberWithBool: isVisible] forPropertyKey: ECNElementVisibleKey]; 

}


- (void)setStrokeColor:(NSColor *)strokeColor {    
	[self setValue: strokeColor forPropertyKey: ECNElementStrokeColorKey];
}

- (NSColor *)strokeColor {
    return [self valueForPropertyKey: ECNElementStrokeColorKey];
}


/*- (float)sensitivity {
	return _fSensitivity;
}

- (void) setSensitivity: (float)sensitivity {
	_fSensitivity = sensitivity;
}*/

/*- (NSString *)name					//{	return [[[NSString alloc] initWithString: _strName] autorelease]; }
{	[self setValue: [NSNumber numberWithBool: isEnabled] forPropertyKey: ECNElementEnabledKey]; }

- (void) setName: (NSString *)name	{	_strName = [[[NSString alloc] initWithString: name] autorelease]; [_strName retain]; } */

/*- (float)latency						//{	return _fLatency; }
{	return [[self valueForPropertyKey: ECNElementLatencyKey] floatValue];	}
	//	return _fTriggerThreshold;	}
	
- (void) setLatency: (float)latency	//{	_fLatency = latency;	}
{	[self setValue: [NSNumber numberWithFloat: latency] forPropertyKey: ECNElementLatencyKey]; }
*/

- (void) setActiveWhenSceneOpens: (bool) activeWhenSceneOpens //{	_bActiveWhenSceneOpens = activeWhenSceneOpens; }
{	[self setValue: [NSNumber numberWithBool: activeWhenSceneOpens] forPropertyKey: ECNElementActiveWhenSceneOpensKey]; }

- (bool) activeWhenSceneOpens// {	return _bActiveWhenSceneOpens;  }
{	return [[self valueForPropertyKey: ECNElementActiveWhenSceneOpensKey] boolValue];	}


#pragma mark -

- (NSUndoManager *)undoManager {
    return [[self document] undoManager];
}

- (NSString *)elementType {
    return NSStringFromClass([self class]);
}

#pragma mark *** Primitives ***

- (void)didChange {
    [[self cue]	invalidateElement:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:ECNElementDidChangeNotification object:self];
}

- (void)setBounds:(NSRect)bounds {
   
	if (!NSEqualRects(bounds, [self bounds])) {
        if (!_gFlags.manipulatingBounds) {
            // Send the notification before and after so that observers who invalidate display in views will wind up invalidating both the original rect and the new one.
            [self didChange];
            [[[self undoManager] prepareWithInvocationTarget:self] setBounds: [self bounds]];
        }
		
		
//        _bounds = bounds;
		[self setValue: [NSValue valueWithRect: bounds] forPropertyKey: ECNElementBoundsKey];
		//[self calcNormBounds];

        if (!_gFlags.manipulatingBounds) {
            [self didChange];
        }
		
	}
}


- (NSRect)bounds {
	return [[self valueForPropertyKey: ECNElementBoundsKey] rectValue];
}

/*- (void)calcNormBounds {
	float vW = [[self scene] viewBounds].size.width;
	float vH = [[self scene] viewBounds].size.height;
	float X = vW>0 ? (_bounds.origin.x / vW)*2.0f - 1.0f : 0;
	float Y = vH>0 ? (1.0f - 2.0f * (_bounds.origin.y / vH)): 0;		
	float W = vW>0 ? _bounds.size.width / vW * 2.0f: 0;
	float H = vH>0 ? _bounds.size.height / vH * 2.0f: 0;		
	
	// ricalcola le coordinate normalizzate
	_normBounds = NSMakeRect(X, Y, W, H);
	// NSLog(@"curElement bound coord is %fx:%fy, %fw:%fh ", _normBounds.origin.x, _normBounds.origin.y, _normBounds.size.width, _normBounds.size.height);
}*/

- (NSRect) calcPixelBoundsInRect: (NSRect )rect	{
	NSRect drawingBounds = [self bounds];

	drawingBounds.origin.x *= rect.size.width;
	drawingBounds.origin.y *= rect.size.height ;
	drawingBounds.size.width *= rect.size.width;
	drawingBounds.size.height *= rect.size.height;
	return drawingBounds;
}

- (NSRect) calcPixelBoundsInView: (NSView *)view	{
	NSRect viewBounds = [view bounds];
	
	return [self calcPixelBoundsInRect: viewBounds];
	
}

- (NSRect) calcDrawingBoundsInView: (NSView *) view {
	
	float inset = -ECN_HALF_HANDLE_WIDTH;
    
	float halfLineWidth = (1.0 / 2.0) + 1.0;
	if (-halfLineWidth < inset)
		inset = -halfLineWidth;
	
    inset += -1.0;
    //return NSInsetRect([self bounds], inset, inset);
	

	
	return NSInsetRect([self calcPixelBoundsInView: view], inset, inset);
}


- (NSRect) normalizeBounds: (NSRect)bounds fromRect: (NSRect) viewBounds {
	
	NSRect normBounds = bounds;
	
	normBounds.origin.x /= viewBounds.size.width ;
	normBounds.origin.y /= viewBounds.size.height;
	normBounds.size.width /= viewBounds.size.width;
	normBounds.size.height /= viewBounds.size.height;
	
	
/*	float X = vW>0 ? (_bounds.origin.x / vW)*2.0f - 1.0f : 0;
	float Y = vH>0 ? (1.0f - 2.0f * (_bounds.origin.y / vH)): 0;		
	float W = vW>0 ? _bounds.size.width / vW * 2.0f: 0;
	float H = vH>0 ? _bounds.size.height / vH * 2.0f: 0;		*/
	
	return normBounds;
}


/*
- (void)setNormBounds:(NSRect)bounds {
	
	if (!NSEqualRects(bounds, _normBounds)) {
        if (!_gFlags.manipulatingBounds) {
            // Send the notification before and after so that observers who invalidate display in views will wind up invalidating both the original rect and the new one.
            [self didChange];
            [[[self undoManager] prepareWithInvocationTarget:self] setNormBounds: _normBounds];
        }
		
        _normBounds = bounds;
        if (!_gFlags.manipulatingBounds) 
            [self didChange];
        
		// [self calcNormBounds];
	}
}*/
/*
- (NSRect)normBounds {
    return _normBounds;
}
*/
/*- (void)setDrawsFill:(BOOL)flag {
    if (_gFlags.drawsFill != flag) {
        [[[self undoManager] prepareWithInvocationTarget:self] setDrawsFill:_gFlags.drawsFill];
        _gFlags.drawsFill = (flag ? YES : NO);
        [self didChange];
    }
}

- (BOOL)drawsFill {
    return _gFlags.drawsFill;
}

- (void)setFillColor:(NSColor *)fillColor {
    if (_fillColor != fillColor) {
        [[[self undoManager] prepareWithInvocationTarget:self] setFillColor:_fillColor];
        [_fillColor autorelease];
        _fillColor = [fillColor retain];
        [self didChange];
    }
    if (_fillColor) {
        [self setDrawsFill:YES];
    } else {
        [self setDrawsFill:NO];
    }
}

- (NSColor *)fillColor {
    return _fillColor;
}*/

- (void)setDrawsStroke:(BOOL)flag {
    if (_gFlags.drawsStroke != flag) {
        [[[self undoManager] prepareWithInvocationTarget:self] setDrawsStroke:_gFlags.drawsStroke];
        _gFlags.drawsStroke = (flag ? YES : NO);
        [self didChange];
    }
}
/*
- (BOOL)drawsStroke {
    return _gFlags.drawsStroke;
}
*/
/*- (void)setStrokeLineWidth:(float)width {
    if (_lineWidth != width) {
        [[[self undoManager] prepareWithInvocationTarget:self] setStrokeLineWidth:_lineWidth];
        if (width >= 0.0) {
            [self setDrawsStroke:YES];
            _lineWidth = width;
        } else {
            [self setDrawsStroke:NO];
            _lineWidth = 0.0;
        }
        [self didChange];
    }
}

- (float)strokeLineWidth {
    return _lineWidth;
}*/

#pragma mark *** Persistence ***
/*
- (NSMutableDictionary *)propertyListRepresentation {
	
    NSMutableDictionary *dict = [super propertyListRepresentation];
	
    NSString *className = NSStringFromClass([self class]);
	
    [dict setObject:className forKey:ECNObjectClassKey];
   // [dict setObject:NSStringFromRect(_normBounds) forKey:ECNElementBoundsKey];
//    [dict setObject:_strName forKey:ECNObjectNameKey];
	
    // ASPECT PROPERTIES
    if ([self strokeColor]) {
        [dict setObject:[NSArchiver archivedDataWithRootObject:[self strokeColor]] forKey:ECNElementStrokeColorKey];
    }
	//    [dict setObject:[NSString stringWithFormat:@"%.3f", [self strokeLineWidth]] forKey:ECNElementStrokeLineWidthKey];
	
	
    // PLAYBACK BEHAVIOUR PROPERTIES
    //[dict setObject:(_bIsVisible ? @"YES" : @"NO") forKey: ECNElementVisibleKey];
   // [dict setObject:(_bEnabled ? @"YES" : @"NO") forKey: ECNElementEnabledKey];
    // [dict setObject:(_bActiveWhenSceneOpens ? @"YES" : @"NO") forKey: ECNElementActiveWhenSceneOpensKey];
	
    // [dict setObject:[NSString stringWithFormat:@"%.3f", _fTriggerThreshold] forKey:ECNElementThresholdKey];
    //[dict setObject:[NSString stringWithFormat:@"%.3f", _fLatency] forKey:ECNElementLatencyKey];
	
	//	ACTIONS
	
    return dict;
}

+ (id)elementWithPropertyListRepresentation:(NSDictionary *)dict  withScene: (ECNScene *)scene{

    if (scene==nil) return nil;
	
	Class theClass = NSClassFromString([dict objectForKey:ECNObjectClassKey]);
    id theElement = nil;
    
    if (theClass) {
        theElement = [[[theClass allocWithZone:NULL] initWithProjectDocument: [scene document]] autorelease];
        if (theElement) {
			[theElement setScene: scene];
            [theElement loadPropertyListRepresentation:dict];
		}
        
    }
    return theElement;
}


- (void)loadPropertyListRepresentation:(NSDictionary *)dict {
    id obj;
	
	[super loadPropertyListRepresentation: dict];
	
    obj = [dict objectForKey:ECNObjectNameKey];
    if (obj) [self setName: obj];
	
    obj = [dict objectForKey:ECNElementBoundsKey];
	 
	 obj = [dict objectForKey:ECNElementStrokeColorKey];
	 if (obj)	[self setStrokeColor:[NSUnarchiver unarchiveObjectWithData:obj]];
	 
	
	obj = [dict objectForKey:ECNElementVisibleKey];
    if (obj)	[self setVisible:[obj isEqualToString:@"YES"]];
	
	obj = [dict objectForKey:ECNElementEnabledKey];
    if (obj)	[self setEnabled:[obj isEqualToString:@"YES"]];
	
	obj = [dict objectForKey:ECNElementActiveWhenSceneOpensKey];
    if (obj)	[self setActiveWhenSceneOpens:[obj isEqualToString:@"YES"]];
	
	
	
	
	// ACTIONS
	NSArray *actionsDicts = [dict objectForKey:ECNElementActionsListKey];
	unsigned i, c = [actionsDicts count];
	NSMutableArray *actions = [NSMutableArray arrayWithCapacity:c];
	
	for (i=0; i<c; i++) 
		[actions addObject:[ECNAction actionWithPropertyListRepresentation:[actionsDicts objectAtIndex:i] withElement: self]];
	
	
    return;
}
*/

#pragma mark *** Extended mutation ***
+ (int)flipKnob:(int)knob horizontal:(BOOL)horizFlag {
    static BOOL initedFlips = NO;
    static int horizFlips[9];
    static int vertFlips[9];
	
    if (!initedFlips) {
        horizFlips[UpperLeftKnob] = UpperRightKnob;
        horizFlips[UpperMiddleKnob] = UpperMiddleKnob;
        horizFlips[UpperRightKnob] = UpperLeftKnob;
        horizFlips[MiddleLeftKnob] = MiddleRightKnob;
        horizFlips[MiddleRightKnob] = MiddleLeftKnob;
        horizFlips[LowerLeftKnob] = LowerRightKnob;
        horizFlips[LowerMiddleKnob] = LowerMiddleKnob;
        horizFlips[LowerRightKnob] = LowerLeftKnob;
        
        vertFlips[UpperLeftKnob] = LowerLeftKnob;
        vertFlips[UpperMiddleKnob] = LowerMiddleKnob;
        vertFlips[UpperRightKnob] = LowerRightKnob;
        vertFlips[MiddleLeftKnob] = MiddleLeftKnob;
        vertFlips[MiddleRightKnob] = MiddleRightKnob;
        vertFlips[LowerLeftKnob] = UpperLeftKnob;
        vertFlips[LowerMiddleKnob] = UpperMiddleKnob;
        vertFlips[LowerRightKnob] = UpperRightKnob;
        initedFlips = YES;
    }
    if (horizFlag) {
        return horizFlips[knob];
    } else {
        return vertFlips[knob];
    }
}

- (void)startBoundsManipulation {
    // Save the original bounds.
    _gFlags.manipulatingBounds = YES;
    _origBounds = [self bounds];
}

- (void)stopBoundsManipulation {
    if (_gFlags.manipulatingBounds) {
        // Restore the original bounds, then set the new bounds.
        if (!NSEqualRects(_origBounds, [self bounds])) {
            NSRect temp;
			
            _gFlags.manipulatingBounds = NO;
            temp = [self bounds];
            [self setBounds: _origBounds];
            [self setBounds:temp];
        } else {
            _gFlags.manipulatingBounds = NO;
        }
    }
}

#pragma mark *** methods using viewport coords ***


- (void)moveBy:(NSPoint)vector  {
    [self setBounds:NSOffsetRect([self bounds], vector.x, vector.y)];
//	NSLog( @"Element moved by: %.2f x, &.2f y", vector.x, vector.y);
}

- (void)moveBy:(NSPoint)vector inView:(NSView *)view	{
	[self moveBy: NSMakePoint (vector.x / [view bounds].size.width, vector.y /[view bounds].size.height)];
}

- (int)resizeByMovingKnob:(int)knob toPoint:(NSPoint)point inView:(NSView *)view {
   
	// convert normalized to view coordinates
	NSRect rect = [view bounds];
	NSRect bounds = [self calcPixelBoundsInView: view];
	
    if ((knob == UpperLeftKnob) || (knob == MiddleLeftKnob) || (knob == LowerLeftKnob)) {
        // Adjust left edge
        bounds.size.width = NSMaxX(bounds) - point.x;
        bounds.origin.x = point.x;
    } else if ((knob == UpperRightKnob) || (knob == MiddleRightKnob) || (knob == LowerRightKnob)) {
        // Adjust left edge
        bounds.size.width = point.x - bounds.origin.x;
    }
    if (bounds.size.width < 0.0) {
        knob = [ECNElement flipKnob:knob horizontal:YES];
        bounds.size.width = -bounds.size.width;
        bounds.origin.x -= bounds.size.width;
        [self flipHorizontally];
    }
	
    if ((knob == UpperLeftKnob) || (knob == UpperMiddleKnob) || (knob == UpperRightKnob)) {
        // Adjust top edge
        bounds.size.height = NSMaxY(bounds) - point.y;
        bounds.origin.y = point.y;
    } else if ((knob == LowerLeftKnob) || (knob == LowerMiddleKnob) || (knob == LowerRightKnob)) {
        // Adjust bottom edge
        bounds.size.height = point.y - bounds.origin.y;
    }
    if (bounds.size.height < 0.0) {
        knob = [ECNElement flipKnob:knob horizontal:NO];
        bounds.size.height = -bounds.size.height;
        bounds.origin.y -= bounds.size.height;
        [self flipVertically];
    }
	
    [self setBounds: [self normalizeBounds: bounds fromRect: rect]];
	
    return knob;
}


- (int)knobUnderPoint:(NSPoint)point inView:(NSView *)ecnView {
    NSRect bounds = [self calcPixelBoundsInView: ecnView ];
    unsigned knobMask = [self knobMask];
    NSRect handleRect;
	
    handleRect.size.width = ECN_HANDLE_WIDTH;
    handleRect.size.height = ECN_HANDLE_WIDTH;
	
    if (knobMask & UpperLeftKnobMask) {
        handleRect.origin.x = NSMinX(bounds) - ECN_HALF_HANDLE_WIDTH;
        handleRect.origin.y = NSMinY(bounds) - ECN_HALF_HANDLE_WIDTH;
        if (NSPointInRect(point, handleRect)) {
            return UpperLeftKnob;
        }
    }
    if (knobMask & UpperMiddleKnobMask) {
        handleRect.origin.x = NSMidX(bounds) - ECN_HALF_HANDLE_WIDTH;
        handleRect.origin.y = NSMinY(bounds) - ECN_HALF_HANDLE_WIDTH;
        if (NSPointInRect(point, handleRect)) {
            return UpperMiddleKnob;
        }
    }
    if (knobMask & UpperRightKnobMask) {
        handleRect.origin.x = NSMaxX(bounds) - ECN_HALF_HANDLE_WIDTH;
        handleRect.origin.y = NSMinY(bounds) - ECN_HALF_HANDLE_WIDTH;
        if (NSPointInRect(point, handleRect)) {
            return UpperRightKnob;
        }
    }
    if (knobMask & MiddleLeftKnobMask) {
        handleRect.origin.x = NSMinX(bounds) - ECN_HALF_HANDLE_WIDTH;
        handleRect.origin.y = NSMidY(bounds) - ECN_HALF_HANDLE_WIDTH;
        if (NSPointInRect(point, handleRect)) {
            return MiddleLeftKnob;
        }
    }
    if (knobMask & MiddleRightKnobMask) {
        handleRect.origin.x = NSMaxX(bounds) - ECN_HALF_HANDLE_WIDTH;
        handleRect.origin.y = NSMidY(bounds) - ECN_HALF_HANDLE_WIDTH;
        if (NSPointInRect(point, handleRect)) {
            return MiddleRightKnob;
        }
    }
    if (knobMask & LowerLeftKnobMask) {
        handleRect.origin.x = NSMinX(bounds) - ECN_HALF_HANDLE_WIDTH;
        handleRect.origin.y = NSMaxY(bounds) - ECN_HALF_HANDLE_WIDTH;
        if (NSPointInRect(point, handleRect)) {
            return LowerLeftKnob;
        }
    }
    if (knobMask & LowerMiddleKnobMask) {
        handleRect.origin.x = NSMidX(bounds) - ECN_HALF_HANDLE_WIDTH;
        handleRect.origin.y = NSMaxY(bounds) - ECN_HALF_HANDLE_WIDTH;
        if (NSPointInRect(point, handleRect)) {
            return LowerMiddleKnob;
        }
    }
    if (knobMask & LowerRightKnobMask) {
        handleRect.origin.x = NSMaxX(bounds) - ECN_HALF_HANDLE_WIDTH;
        handleRect.origin.y = NSMaxY(bounds) - ECN_HALF_HANDLE_WIDTH;
        if (NSPointInRect(point, handleRect)) {
            return LowerRightKnob;
        }
    }
	
    return NoKnob;
}

- (void)drawHandleAtPoint:(NSPoint)point inView:(NSView *)view {
    NSRect handleRect;
	
    handleRect.origin.x = point.x - ECN_HALF_HANDLE_WIDTH + 1.0;
    handleRect.origin.y = point.y - ECN_HALF_HANDLE_WIDTH + 1.0;
    handleRect.size.width = ECN_HANDLE_WIDTH - 1.0;
    handleRect.size.height = ECN_HANDLE_WIDTH - 1.0;
    handleRect = [view centerScanRect:handleRect];
    [[NSColor controlDarkShadowColor] set];
    NSRectFill(handleRect);
    handleRect = NSOffsetRect(handleRect, -1.0, -1.0);
    [[NSColor knobColor] set];
    NSRectFill(handleRect);
}

#pragma mark *** Resize function!! ***
/*- (void) updateElementViewBounds {
	
	NSSize newView = [[self scene] viewBounds].size;
	
	_bounds.size.width = _normBounds.size.width * newView.width / 2.0f;
	_bounds.size.height =  _normBounds.size.height * newView.height / 2.0f;	
	_bounds.origin.x = (_normBounds.origin.x + 1.0f) / 2.0f * newView.width;
	_bounds.origin.y = (1.0f - _normBounds.origin.y) / 2.0f  * newView.height;

	
//	_origBounds.size.width = _normOrigBounds.size.width * newView.width;
//	_origBounds.size.height = _normOrigBounds.size.height * newView.height;
//	_origBounds.origin.x = _normOrigBounds.origin.x * newView.width;
//	_origBounds.origin.y = _normOrigBounds.origin.y * newView.height;
}*/


#pragma mark *** other ***


- (void)flipHorizontally {
    // Some subclasses need to know.
    return;
}

- (void)flipVertically {
    // Some subclasses need to know.
    return;
}



- (void)makeNaturalSize {
    // Do nothing by default
}

#pragma mark *** Subclass capabilities ***

// Some subclasses will not ever have a stroke or fill or a natural size.  Overriding these methods in such subclasses allows the Inspector and Menu items to better reflect allowable actions.

- (BOOL)canDrawStroke {
    return YES;
}

- (BOOL)canDrawFill {
    return YES;
}

- (BOOL)hasNaturalSize {
    return YES;
}


#pragma mark *** Drawing ***

/*- (NSRect)drawingBounds {
    float inset = -ECN_HALF_HANDLE_WIDTH;
    
	float halfLineWidth = (1.0 / 2.0) + 1.0;
	if (-halfLineWidth < inset)
		inset = -halfLineWidth;
	
    inset += -1.0;
    return NSInsetRect([self bounds], inset, inset);
}*/

- (NSBezierPath *)bezierPath {
    // Subclasses that just have a simple path override this to return it.  The basic drawInView:isSelected: implementation below will stroke and fill this path.  Subclasses that need more complex drawing will just override drawInView:isSelected:.
    return nil;
}


- (CGMutablePathRef)quartzPathInRect: (CGRect) rect {
	TFThrowMethodNotImplementedException();
	return nil;
}

- (NSBezierPath *)bezierPathInRect: (NSRect )rect {
	TFThrowMethodNotImplementedException();
	return nil;
}

/*- (void)drawInCurrentOpenGLContext:(NSRect)rect {

	//to override!!!
	
}*/

- (void) drawInCGContext: (CGContextRef)context withRect: (CGRect) rect {

	TFThrowMethodNotImplementedException();

}

- (void)drawInView:(NSView *)view isSelected:(BOOL)flag {
    NSBezierPath *path = [self bezierPathInRect: [view bounds]];
    if (path) {
		[[self strokeColor] set];
		[path stroke];
    }
    if (flag) {
        [self drawHandlesInView:view];
    }
}

/*- (void) drawInOpenGLContext: (NSOpenGLContext *)openGLContext
{	TFThrowMethodNotImplementedException();
	return;
}*/


- (unsigned)knobMask {
    return AllKnobsMask;
}


- (void)drawHandlesInView:(NSView *)view {
    NSRect bounds = [self calcPixelBoundsInView: view];
    unsigned knobMask = [self knobMask];
	
    if (knobMask & UpperLeftKnobMask) {
        [self drawHandleAtPoint:NSMakePoint(NSMinX(bounds), NSMinY(bounds)) inView:view];
    }
    if (knobMask & UpperMiddleKnobMask) {
        [self drawHandleAtPoint:NSMakePoint(NSMidX(bounds), NSMinY(bounds)) inView:view];
    }
    if (knobMask & UpperRightKnobMask) {
        [self drawHandleAtPoint:NSMakePoint(NSMaxX(bounds), NSMinY(bounds)) inView:view];
    }
	
    if (knobMask & MiddleLeftKnobMask) {
        [self drawHandleAtPoint:NSMakePoint(NSMinX(bounds), NSMidY(bounds)) inView:view];
    }
    if (knobMask & MiddleRightKnobMask) {
        [self drawHandleAtPoint:NSMakePoint(NSMaxX(bounds), NSMidY(bounds)) inView:view];
    }
	
    if (knobMask & LowerLeftKnobMask) {
        [self drawHandleAtPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds)) inView:view];
    }
    if (knobMask & LowerMiddleKnobMask) {
        [self drawHandleAtPoint:NSMakePoint(NSMidX(bounds), NSMaxY(bounds)) inView:view];
    }
    if (knobMask & LowerRightKnobMask) {
        [self drawHandleAtPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds)) inView:view];
    }
}

- (NSImage *)icon {
	return [NSImage imageNamed: @"Cross"];// set a default icon. This should be overridden in subclasses
}

#pragma mark *** Event handling ***

+ (NSCursor *)creationCursor {
    // By default we use the crosshair cursor
    static NSCursor *crosshairCursor = nil;
    if (!crosshairCursor) {
        NSImage *crosshairImage = [NSImage imageNamed:@"Cross"];
        NSSize imageSize = [crosshairImage size];
        crosshairCursor = [[NSCursor allocWithZone:[self zone]] initWithImage:crosshairImage hotSpot:NSMakePoint((imageSize.width / 2.0), (imageSize.height / 2.0))];
    }
    return crosshairCursor;
}

- (BOOL)createWithEvent:(NSEvent *)theEvent inScene:(KCue *)scene inView:(NSView *)view {
	
    // default implementation tracks until mouseUp: just setting the bounds of the new element.
    NSPoint point = [view convertPoint:[theEvent locationInWindow] fromView:nil];
	
    int knob = LowerRightKnob;
    NSRect bounds, drawingBounds, viewBounds;
    BOOL snapsToGrid = false; //[view snapsToGrid];
    float spacing = 0; //[view gridSpacing];
	//BOOL echoToRulers = false; //[[view enclosingScrollView] rulersVisible];
	
	viewBounds = [view bounds];	//suppose that the view will not resize until mouse is tracked to move object!
	
    [self startBoundsManipulation];
    if (snapsToGrid) {
        point.x = floor((point.x / spacing) + 0.5) * spacing;
        point.y = floor((point.y / spacing) + 0.5) * spacing;
    }
	
	[self setCue: scene];
    [self setBounds: [self normalizeBounds: NSMakeRect(point.x, point.y, 0.0, 0.0) fromRect: [view bounds]]];
   /* if (echoToRulers) {
        [view beginEchoingMoveToRulers:[self bounds]];
    }*/

    while (1) {
        theEvent = [[view window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        point = [view convertPoint:[theEvent locationInWindow] fromView:nil];
		
		// clip coordinates in view bounds rectangle
		point.x = point.x < 0 ? 0 : point.x;
		point.y = point.y < 0 ? 0 : point.y;
		point.x = point.x > viewBounds.size.width ? viewBounds.size.width : point.x;
		point.y = point.y > viewBounds.size.height ? viewBounds.size.height : point.y;
		
		drawingBounds = [self calcDrawingBoundsInView: view];
		
        /*if (snapsToGrid) {
            point.x = floor((point.x / spacing) + 0.5) * spacing;
            point.y = floor((point.y / spacing) + 0.5) * spacing;
        }*/
        [view setNeedsDisplayInRect: drawingBounds];
        knob = [self resizeByMovingKnob: knob toPoint:point inView: view];
        [view setNeedsDisplayInRect: drawingBounds];
        /*if (echoToRulers) {
            [view continueEchoingMoveToRulers:[self bounds]];
        }*/
        if ([theEvent type] == NSLeftMouseUp) {
            break;
        }
    }
    /*if (echoToRulers) {
        [view stopEchoingMoveToRulers];
    }*/
	
    [self stopBoundsManipulation];
    
    bounds = [self bounds];
    if ((bounds.size.width > 0.0) || (bounds.size.height > 0.0)) {
        return YES;
    } else {
        return NO;
    }
}

/*- (BOOL)isEditable {
    return NO;
}*/

/*- (void)startEditingWithEvent:(NSEvent *)event inView:(ElementsView *)view {
    return;
}*/

/*- (void)endEditingInView:(ElementsView *)view {
    return;
}*/

- (BOOL)hitTest:(NSPoint)point isSelected:(BOOL)isSelected inView:(NSView *)ecnView {
    if (isSelected && ([self knobUnderPoint:point inView: ecnView] != NoKnob)) {
        return YES;
    } else {
		
        NSBezierPath *path = [self bezierPathInRect: [ecnView bounds] ];
		
        if (path) {
            if ([path containsPoint: point]) {
                return YES;
            }
        } else {
            if (NSPointInRect(point, [self calcPixelBoundsInView: ecnView])) {
                return YES;
            }
        }
        return NO;
    }
}


@end

@implementation ECNElement (ECNScriptingExtras)

// These are methods that we probably wouldn't bother with if we weren't scriptable.

- (NSScriptObjectSpecifier *)objectSpecifier {
	
	//TODO: sistemare questa funzione: "element" è membro della classe Scene, a sua volta parte di un array "scenes" membro di ProjectDocument
	
    NSArray *scenes = [[self document] cues];
    long index1 = [scenes indexOfObjectIdenticalTo:[self cue]];
    if (index1 != NSNotFound) {
		NSArray *elements = [scenes objectAtIndex: index1];
		unsigned index2 = [elements indexOfObjectIdenticalTo:self];

		if (index2 != NSNotFound) {
			NSScriptObjectSpecifier *containerRef = [[self document] objectSpecifier];
			return [[[NSIndexSpecifier allocWithZone:[self zone]] initWithContainerClassDescription:[containerRef keyClassDescription] containerSpecifier:containerRef key:@"elements" index:index2] autorelease];

		} else {
			return nil;
		}

    } else {
        return nil;
    }
}

- (float)xPosition {
    return [self bounds].origin.x;
}

- (void)setXPosition:(float)newVal {
    NSRect bounds = [self bounds];
    bounds.origin.x = newVal;
    [self setBounds:bounds];
}

- (float)yPosition {
    return [self bounds].origin.y;
}

- (void)setYPosition:(float)newVal {
    NSRect bounds = [self bounds];
    bounds.origin.y = newVal;
    [self setBounds:bounds];
}

- (float)width {
    return [self bounds].size.width;
}

- (void)setWidth:(float)newVal {
    NSRect bounds = [self bounds];
    bounds.size.width = newVal;
    [self setBounds:bounds];
}

- (float)height {
    return [self bounds].size.height;
}

- (void)setHeight:(float)newVal {
    NSRect bounds = [self bounds];
    bounds.size.height = newVal;
    [self setBounds:bounds];
}
#pragma mark -
#pragma mark *** Triggers management

- (void) addTrigger: (ECNTrigger *)trigger {
	NSMutableArray *triggers = [self valueForPropertyKey: ECNElementTriggersListKey];
	[triggers addObject: trigger];
	
}

- (ECNTrigger *)firstTrigger	{
	NSArray *triggersArray = [self valueForPropertyKey: ECNElementTriggersListKey];
	return (triggersArray && [triggersArray count] > 0) ? [triggersArray objectAtIndex: 0] : nil;
}

- (NSArray *)triggers	{
	return [self valueForPropertyKey: ECNElementTriggersListKey] ;
}
#pragma mark -
#pragma mark = Playback
#pragma mark -

#pragma mark State modification
- (bool) prepareForPlaybackWithError: (NSError **)error	{
	return true;	
}
/*- (void) setActivationState: (NSUInteger) activationState {
	if ([self activationState] != activationState)	{
		
		[[self scene] setElementActivationState: self active: (activationState == NSOnState)];

		// tell triggers to begin observing self for value changes
		if (activationState == NSOnState)
			for (ECNTrigger *curTrigger in [self triggers])
				[curTrigger beginObservingElement];
		else 
			for (ECNTrigger *curTrigger in [self triggers]) 
				[curTrigger endObservingElement];
	}
	return;	
}

- (NSUInteger) activationState{
	return [[self scene] isElementActive: self];	
}*/

#pragma mark Playback methods
- (void) updateOutputPorts	{
	
	return;
	
}

- (BOOL) executeAtTime:(NSTimeInterval)time {
	for (ECNTrigger *curTrigger in [self triggers]) 
		[curTrigger executeAtTime: time];
	return true;
}


#pragma mark Port management
- (id) valueForOutputPort:(NSString *)portKey	{
	ECNPort *port = [self outputPortWithKey: portKey];
	return [port value];
}

// returns a default value for the current element
- (id) defaultValue	{
	TFThrowMethodNotImplementedException();

	return nil;
}

@end
