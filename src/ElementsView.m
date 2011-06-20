//
//  ElementsView.m
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 19/10/10.
//  Copyright 2010 AndreaCremaschi. All rights reserved.
//

//#import <OpenGL/CGLMacro.h>  // Set up using macros
#import "ElementsView.h"
#import "ECNElement.h"
#import "KCue.h"
#import "ECNProjectDocument.h"
#import "ECNFoundationExtras.h"
#import "KCueEditorViewController.h"

NSString *ElementsViewSelectionDidChangeNotification = @"ElementsViewSelectionDidChange";
NSString *ElementsViewDoubleClicOnElementNotification = @"ElementsViewNewElementToEditNotification";

@implementation ElementsView
@synthesize scene;
@synthesize bgOpacity;
@synthesize currentElementClass;
@synthesize currentColor;
@synthesize backgroundImage;

static float ECNDefaultPasteCascadeDelta = 10.0;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		NSMutableArray *dragTypes = [NSMutableArray arrayWithObjects:NSColorPboardType, NSFilenamesPboardType, nil];
        [dragTypes addObjectsFromArray:[NSImage imagePasteboardTypes]];
        [self registerForDraggedTypes:dragTypes];
        _selectedElements = [[NSMutableArray allocWithZone:[self zone]] init];
        _creatingElement = nil;
        _rubberbandRect = NSZeroRect;
        _rubberbandElements = nil;
        _gvFlags.rubberbandIsDeselecting = NO;
        _gvFlags.initedRulers = NO;
        _editingElement = nil;
        //_editorView = nil;
        _pasteboardChangeCount = -1;
        _pasteCascadeNumber = 0;
        _pasteCascadeDelta = NSMakePoint(ECNDefaultPasteCascadeDelta, ECNDefaultPasteCascadeDelta);
        _gvFlags.snapsToGrid = NO;
        _gvFlags.showsGrid = NO;
        _gvFlags.knobsHidden = NO;
        _gridSpacing = 8.0;
        _gridColor = [[NSColor lightGrayColor] retain];
        _unhideKnobsTimer = nil;
		_background = nil;
		useBackground = true;
    }
    return self;
}

- (void)dealloc {
   // [self endEditing];
    [_selectedElements release];
    [_rubberbandElements release];
    [_gridColor release];
	[_background release];
	//[[self scene] release];
    [super dealloc];
}

#pragma mark ***  accessors and convenience methods ***


- (void) setCurrentElementClass: (Class )newClass {
	NSAssert (newClass == nil || [newClass isSubclassOfClass: [ECNElement class]], @"ElementsView error: tried to set a creation class that is not a subclass of ECNElement and that is not nil.");
								  currentElementClass = newClass;
	
	
}
/*- (NSArray *)scenes {
    return [(ECNProjectDocument *)[[self sceneWindowController] document] scenes];
}*/

/*- (void)setScene:(ECNScene *)scene {
	[self scene] = scene;
	[[self scene] retain];
}*/

/*- (ECNScene *)scene {
	return [self scene];
}*/

- (void)setUseBackground:(bool)bUseBG {
	useBackground = bUseBG;	
	[self setNeedsDisplay: YES];
}



- (void) setBackgroundImage:(NSImageRep *) bgImage {
	NSImageRep *oldImage = backgroundImage;
	backgroundImage = [bgImage retain];
	[oldImage release];
	[self setNeedsDisplay: YES];
}

- (void) setBgOpacity: (NSNumber *)newOpacity {
	bgOpacity = [newOpacity retain];
	[self setNeedsDisplay: true];
}

#pragma mark *** ECNSceneWindowController accessors and convenience methods
/*- (void)setSceneWindowController:(ECNSceneWindowController *)theController {
    controller = theController;
}*/

/*- (ECNSceneWindowController *)sceneWindowController {
    return [[self window] windowController];
}*/

/*- (ECNScene *)scene {
//	NSLog (@"ElementsView owner is of class kind: %@", [[self sceneWindowController] class]);
	return [[[self window] windowController] scene];
}*/

- (void)setScene:(KCue *)newScene {
	/*if (scene){
		[self removeObserver: scene
				  forKeyPath: @"elements"];

	}
	
	[newScene addObserver: self
		   forKeyPath: ECNSceneElementsListKey
			  options: NSKeyValueObservingOptionNew
			  context: nil
	 ];*/
	scene = newScene;
	
}
/*
 // KVO implementation
- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object
						change:(NSDictionary *)change 
					   context:(void *)context {

	[self setNeedsDisplay:true];
}*/

- (ECNProjectDocument *)ecnProjectDocument {
    return [[self scene] document];
}

- (NSArray *)elements {
    return [[self scene] elements];
}


#pragma mark *** Display invalidation
- (void)invalidateElement:(ECNElement *)element {
    [self setNeedsDisplayInRect:[element calcDrawingBoundsInView: self]];
    if (![[self elements] containsObject:element]) {
        [self deselectElement:element];  // deselectElement will call invalidateElement, too, but only if the element is in the selection and since the element is removed from the selection before this method is called again the potential infinite loop should not happen.
    }
}

- (void)invalidateElements:(NSArray *)elements {
    unsigned i, c = [elements count];
    for (i=0; i<c; i++) {
        [self invalidateElement:[elements objectAtIndex:i]];
    }
}

#pragma mark *** Selection primitives
- (NSArray *)selectedElements {
    return _selectedElements;
}

static int ECN_orderElementsFrontToBack(id element1, id element2, void *gArray) {
    NSArray *elements = (NSArray *)gArray;
    unsigned index1, index2;
	
    index1 = [elements indexOfObjectIdenticalTo:element1];
    index2 = [elements indexOfObjectIdenticalTo:element2];
    if (index1 == index2) {
        return NSOrderedSame;
    } else if (index1 < index2) {
        return NSOrderedAscending;
    } else {
        return NSOrderedDescending;
    }
}

- (NSArray *)orderedSelectedElements  {
    return [[self selectedElements] sortedArrayUsingFunction:ECN_orderElementsFrontToBack context:[self elements]];
}

- (BOOL)elementIsSelected:(ECNElement *)element {
    return (([_selectedElements indexOfObjectIdenticalTo:element] == NSNotFound) ? NO : YES);
}

- (void)selectElement:(ECNElement *)element {
    NSUInteger curIndex = [_selectedElements indexOfObjectIdenticalTo:element];
    if (curIndex == NSNotFound) {
        [[[self undoManager] prepareWithInvocationTarget:self] deselectElement:element];
        [[[self ecnProjectDocument] undoManager] setActionName:NSLocalizedStringFromTable(@"Selection Change", @"UndoStrings", @"Action name for selection changes.")];
        [_selectedElements addObject:element];
        [self invalidateElement:element];
        _pasteCascadeDelta = NSMakePoint(ECNDefaultPasteCascadeDelta, ECNDefaultPasteCascadeDelta);
        [[NSNotificationCenter defaultCenter] postNotificationName:ElementsViewSelectionDidChangeNotification object:self];
        //[self updateRulers];
    }	
}

- (void)deselectElement:(ECNElement *)element {
    NSUInteger curIndex = [_selectedElements indexOfObjectIdenticalTo:element];
    if (curIndex != NSNotFound) {
        [[[self undoManager] prepareWithInvocationTarget:self] selectElement:element];
        [[[self ecnProjectDocument] undoManager] setActionName:NSLocalizedStringFromTable(@"Selection Change", @"UndoStrings", @"Action name for selection changes.")];
        [_selectedElements removeObjectAtIndex:curIndex];
        [self invalidateElement:element];
        _pasteCascadeDelta = NSMakePoint(ECNDefaultPasteCascadeDelta, ECNDefaultPasteCascadeDelta);
        [[NSNotificationCenter defaultCenter] postNotificationName:ElementsViewSelectionDidChangeNotification object:self];
        //[self updateRulers];
    }
}


- (void)clearSelection {
    int i, c = [_selectedElements count];
    id curElement;
    
    if (c > 0) {
        for (i=0; i<c; i++) {
            curElement = [_selectedElements objectAtIndex:i];
            [[[self undoManager] prepareWithInvocationTarget:self] selectElement:curElement];
            [self invalidateElement:curElement];
        }
        [[[self ecnProjectDocument] undoManager] setActionName:NSLocalizedStringFromTable(@"Selection Change", @"UndoStrings", @"Action name for selection changes.")];
        [_selectedElements removeAllObjects];
        _pasteCascadeDelta = NSMakePoint(ECNDefaultPasteCascadeDelta, ECNDefaultPasteCascadeDelta);
        [[NSNotificationCenter defaultCenter] postNotificationName:ElementsViewSelectionDidChangeNotification object:self];
        //[self updateRulers];
    }
}

#pragma mark *** Editing
/*- (void)setEditingElement:(ECNElement *)element editorView:(NSView *)editorView {
    // Called by a ECNElement that is told to start editing.  ECNElementView doesn't do anything with editorView, just remembers it.
    _editingElement = element;
    _editorView = editorView;
}

- (ECNElement *)editingElement {
    return _editingElement;
}

- (NSView *)editorView {
    return _editorView;
}

- (void)startEditingElement:(ECNElement *)element withEvent:(NSEvent *)event {
    [element startEditingWithEvent:event inView:self];
}

- (void)endEditing {
    if (_editingElement) {
        [_editingElement endEditingInView:self];
        _editingElement = nil;
        _editorView = nil;
    }
}*/

#pragma mark *** Geometry calculations
- (ECNElement *)elementUnderPoint:(NSPoint)point {

    NSArray *elements = [[self scene] elements];
    ECNElement *curElement = nil;
	
	for (curElement in elements)

        if (	[self mouse:point inRect:[curElement calcDrawingBoundsInView: self]]
				&& [curElement hitTest:point isSelected:[self elementIsSelected:curElement] inView: self] 
				&& [curElement isVisible]) 
            break;

	return curElement;

}

- (NSSet *)elementsIntersectingRect:(NSRect)rect {
    NSArray *elements = [self elements];
    unsigned i, c = [elements count];
    NSMutableSet *result = [NSMutableSet set];
    ECNElement *curElement;
	
    for (i=0; i<c; i++) {
        curElement = [elements objectAtIndex:i];
        if (NSIntersectsRect(rect, [curElement calcDrawingBoundsInView: self]) && 
			[curElement isVisible]) {
            [result addObject:curElement];
        }
    }
    return result;
}

- (NSPoint) normalizeCoord: (NSPoint)coord {
	
	// trasforma le coordinate dallo spazio della finestra allo spazio (0.0:1.0),(0.0:1.0)
	return NSMakePoint (coord.x / [self bounds].size.width, coord.y / [self bounds].size.height);
}

- (NSRect) calcDrawingRect: (NSRect) normBounds {
	
	NSRect drawingBounds = normBounds;
	NSRect viewBounds = [self bounds];
	
	drawingBounds.origin.x *= viewBounds.size.width;
	drawingBounds.origin.y *= viewBounds.size.height;
	drawingBounds.size.width *= viewBounds.size.width;
	drawingBounds.size.height *= viewBounds.size.height;
	
	return drawingBounds;
}

#pragma mark *** Drawing and mouse tracking
- (BOOL)isFlipped {
    return YES;
}

- (BOOL)isOpaque {
    return YES;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    //[self updateRulers];
    return YES;
}

- (void)rightMouseDown: (NSEvent *)theEvent {
	NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	ECNElement *element = [self elementUnderPoint:curPoint];
	if (element) // && [element isEditable]) 
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:ElementsViewDoubleClicOnElementNotification object:self];
		return;
	}
	
}


- (void)mouseDown:(NSEvent *)theEvent {
    Class theClass = currentElementClass;
   /* if ([self editingElement]) {
        [self endEditing];
    }*/
    if ([theEvent clickCount] > 1) {
        NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        ECNElement *element = [self elementUnderPoint:curPoint];
        if (element) // && [element isEditable]) 
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:ElementsViewDoubleClicOnElementNotification object:self];
//            [self startEditingElement:element withEvent:theEvent];
            return;
        }
    }
    if (theClass) {
        [self clearSelection];
        [self createElementOfClass:theClass withEvent:theEvent];
    } else {
        [self selectAndTrackMouseWithEvent:theEvent];
    }
}






- (void)drawRect:(NSRect)rect {
	//ECNSceneWindowController *sceneWindowController = [self sceneWindowController];


    ECNElement *curElement;
    BOOL isSelected;
    NSRect drawingBounds;
    NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
	
    NSRect viewBounds = [self bounds];
	
	// *** DRAW THE BACKGROUND!!!***
	
	[[NSColor whiteColor] set];
    NSRectFill(rect);
	if ((nil != backgroundImage) && (useBackground))
	{	NSSize imgRectSize = [backgroundImage size];
		
	/*	NSRect srcRect;
		float xFact = imgRectSize.width / viewBounds.size.width;
		float yFact = imgRectSize.height / viewBounds.size.height;
		
		srcRect.origin.x = rect.origin.x * xFact;
		srcRect.origin.y = rect.origin.y * yFact;
		srcRect.size.width = rect.size.width * xFact;
		srcRect.size.height = rect.size.height * yFact;
		
	*/
		[backgroundImage drawInRect: viewBounds
						   fromRect: NSMakeRect(0,0, imgRectSize.width, imgRectSize.height)
						  operation: NSCompositeSourceOver  
						   fraction: [bgOpacity floatValue]
					 respectFlipped: YES hints: nil];
	}
	
  // if ([self showsGrid]) {
    //    ECNDrawGridWithSettingsInRect([self gridSpacing], [self gridColor], rect, NSZeroPoint);
    //}

	// *** DRAW EVERY ELEMENT !!!***

	if ([self scene] != nil) {
	
		
	/*elements = [[self scene] elements];
    i = [elements count];
		
    while (i-- > 0) {*/
	for (curElement in [[self scene] elements])	{
//        curElement = [elements objectAtIndex:i];
		
		if ([curElement isVisible])
		{	
			drawingBounds = [curElement calcDrawingBoundsInView: self ];

			//if (NSIntersectsRect(rect, drawingBounds)) {
				if (!_gvFlags.knobsHidden && (curElement != _editingElement)) {
					// Figure out if we should draw selected.
					isSelected = [self elementIsSelected:curElement];
					// Account for any current rubberband selection state
					if (_rubberbandElements && (isSelected == _gvFlags.rubberbandIsDeselecting) && [_rubberbandElements containsObject:curElement]) {
						isSelected = (isSelected ? NO : YES);
					}
				} else {
					// Do not draw handles on elements that are editing.
					isSelected = NO;
				}
				[currentContext saveGraphicsState];
				[NSBezierPath clipRect:drawingBounds];
				[curElement drawInView:self isSelected:isSelected];
				[currentContext restoreGraphicsState];
			//}
		}
    }
	
    if (_creatingElement) {
		drawingBounds = [_creatingElement calcDrawingBoundsInView: self] ;
//        drawingBounds = [_creatingElement drawingBounds];
	//	NSLog("Rect: %@ DrawingRect: %@", NSStringFromRect (rect), NSStringFromRect (drawingBounds));
      //  if (NSIntersectsRect(rect, drawingBounds)) {
            [currentContext saveGraphicsState];
            [NSBezierPath clipRect:drawingBounds];
            [_creatingElement drawInView:self isSelected:NO];
            [currentContext restoreGraphicsState];
     //   }
    }
    if (!NSEqualRects(_rubberbandRect, NSZeroRect)) {
        [[NSColor knobColor] set];
        NSFrameRect(_rubberbandRect);
    }
	}
}


- (void)createElementOfClass:(Class)theClass withEvent:(NSEvent *)theEvent {

	ECNProjectDocument *document = [self ecnProjectDocument];
//    _creatingElement = [[theClass allocWithZone:[document zone]] initWithProjectDocument: [[self scene] document] ];
	_creatingElement = [theClass elementWithDocument: document];
	
    if ([_creatingElement createWithEvent:theEvent inScene:[self scene] inView:self]) {
		
        [[self scene] insertElement:_creatingElement atIndex:0];
		
        [self selectElement:_creatingElement];

		[_creatingElement setStrokeColor: currentColor];

        [[document undoManager] setActionName:[NSString stringWithFormat:NSLocalizedStringFromTable(@"Create %@", @"UndoStrings", @"Action name for newly created elements.  Class name is inserted at the substitution."), [[NSBundle mainBundle] localizedStringForKey:NSStringFromClass(theClass) value:@"" table:@"ElementClassNames"]]];
		
    }
    [_creatingElement release];
    _creatingElement = nil;
}

- (ECNElement *)creatingElement {
    return _creatingElement;
}

- (void)trackKnob:(int)knob ofElement:(ECNElement *)element withEvent:(NSEvent *)theEvent {
    NSPoint point;
    //BOOL snapsToGrid = [self snapsToGrid];
   // float spacing = [self gridSpacing];
  //  BOOL echoToRulers = [[self enclosingScrollView] rulersVisible];
	
    [element startBoundsManipulation];
   /* if (echoToRulers) {
        [self beginEchoingMoveToRulers:[element bounds]];
    }*/
    while (1) {
        theEvent = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		
		// clip coordinates in view bounds rectangle
		point.x = point.x < 0 ? 0 : point.x;
		point.y = point.y < 0 ? 0 : point.y;
		point.x = point.x > [self bounds].size.width ? [self bounds].size.width : point.x;
		point.y = point.y > [self bounds].size.height ? [self bounds].size.height : point.y;
		
        [self invalidateElement:element];
        /*if (snapsToGrid) {
            point.x = floor((point.x / spacing) + 0.5) * spacing;
            point.y = floor((point.y / spacing) + 0.5) * spacing;
        }*/
        knob = [element resizeByMovingKnob:knob toPoint:point  inView: self];
        [self invalidateElement:element];
        /*if (echoToRulers) {
            [self continueEchoingMoveToRulers:[element bounds]];
        }*/
        if ([theEvent type] == NSLeftMouseUp) {
            break;
        }
    }
   /* if (echoToRulers) {
        [self stopEchoingMoveToRulers];
    }*/
	
    [element stopBoundsManipulation];
	
    [[[self ecnProjectDocument] undoManager] setActionName:NSLocalizedStringFromTable(@"Resize", @"UndoStrings", @"Action name for resizes.")];
}

- (void)rubberbandSelectWithEvent:(NSEvent *)theEvent {
    NSPoint origPoint, curPoint;
    NSEnumerator *objEnum;
    ECNElement *curElement;
	
    _gvFlags.rubberbandIsDeselecting = (([theEvent modifierFlags] & NSAlternateKeyMask) ? YES : NO);
    origPoint = curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
    while (1) {
        theEvent = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        if (NSEqualPoints(origPoint, curPoint)) {
            if (!NSEqualRects(_rubberbandRect, NSZeroRect)) {
                [self setNeedsDisplayInRect:_rubberbandRect];
                [self performSelector:@selector(invalidateElement:) withEachObjectInSet:_rubberbandElements];
            }
            _rubberbandRect = NSZeroRect;
            [_rubberbandElements release];
            _rubberbandElements = nil;
        } else {
            NSRect newRubberbandRect = ECNRectFromPoints(origPoint, curPoint);
            if (!NSEqualRects(_rubberbandRect, newRubberbandRect)) {
                [self setNeedsDisplayInRect:_rubberbandRect];
                [self performSelector:@selector(invalidateElement:) withEachObjectInSet:_rubberbandElements];
                _rubberbandRect = newRubberbandRect;
                [_rubberbandElements release];
                _rubberbandElements = [[self elementsIntersectingRect:_rubberbandRect] retain];
                [self setNeedsDisplayInRect:_rubberbandRect];
                [self performSelector:@selector(invalidateElement:) withEachObjectInSet:_rubberbandElements];
            }
        }
        if ([theEvent type] == NSLeftMouseUp) {
            break;
        }
    }
	
    // Now select or deselect the rubberbanded elements.
    objEnum = [_rubberbandElements objectEnumerator];
    while ((curElement = [objEnum nextObject]) != nil) {
        if (_gvFlags.rubberbandIsDeselecting) {
            [self deselectElement:curElement];
        } else {
            [self selectElement:curElement];
        }
    }
    if (!NSEqualRects(_rubberbandRect, NSZeroRect)) {
        [self setNeedsDisplayInRect:_rubberbandRect];
    }
	
    _rubberbandRect = NSZeroRect;
    [_rubberbandElements release];
    _rubberbandElements = nil;
}

- (void)moveSelectedElementsWithEvent:(NSEvent *)theEvent {
    NSPoint lastPoint, curPoint;
    NSArray *selElements = [self selectedElements];
    unsigned i, c;
    ECNElement *element;
    BOOL didMove = NO, isMoving = NO;
//    NSPoint selOriginOffset = NSZeroPoint;
//    NSPoint boundsOrigin;
 //   BOOL snapsToGrid = [self snapsToGrid];
//    float spacing = [self gridSpacing];
//    BOOL echoToRulers = [[self enclosingScrollView] rulersVisible];
    NSRect selBounds = [[self scene] boundsForElements:selElements];
	
	//convert selected bounds rect to view coordinates
	selBounds.origin.x *= [self bounds].size.width;
	selBounds.origin.y *= [self bounds].size.height;
	selBounds.size.width *= [self bounds].size.width;
	selBounds.size.height *= [self bounds].size.height;
	
    c = [selElements count];
	
    lastPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
   /* if (snapsToGrid || echoToRulers) {
        selOriginOffset = NSMakePoint((lastPoint.x - selBounds.origin.x), (lastPoint.y - selBounds.origin.y));
    }*/
    /*if (echoToRulers) {
        [self beginEchoingMoveToRulers:selBounds];
    }*/
	
    while (1) {
        theEvent = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        if (!isMoving && ((fabs(curPoint.x - lastPoint.x) >= 2.0) || (fabs(curPoint.y - lastPoint.y) >= 2.0))) {
            isMoving = YES;
            [selElements makeObjectsPerformSelector:@selector(startBoundsManipulation)];
            _gvFlags.knobsHidden = YES;
        }
        if (isMoving) {
            /*if (snapsToGrid) {
                boundsOrigin.x = curPoint.x - selOriginOffset.x;
                boundsOrigin.y = curPoint.y - selOriginOffset.y;
                boundsOrigin.x = floor((boundsOrigin.x / spacing) + 0.5) * spacing;
                boundsOrigin.y = floor((boundsOrigin.y / spacing) + 0.5) * spacing;
                curPoint.x = boundsOrigin.x + selOriginOffset.x;
                curPoint.y = boundsOrigin.y + selOriginOffset.y;
            }*/
            if (!NSEqualPoints(lastPoint, curPoint)) {

				int deltax, deltay;

				NSSize viewSize = [self bounds].size;
				
				// clip movements to view bounds
				deltax =  selBounds.origin.x + (curPoint.x - lastPoint.x) > 0 ? (curPoint.x - lastPoint.x) : -selBounds.origin.x ;
				deltay = selBounds.origin.y + (curPoint.y - lastPoint.y) > 0 ? (curPoint.y - lastPoint.y) : -selBounds.origin.y ;
				deltax = selBounds.origin.x + selBounds.size.width + deltax > viewSize.width ? viewSize.width - selBounds.size.width - selBounds.origin.x : deltax;
				deltay = selBounds.origin.y + selBounds.size.height + deltay > viewSize.height ? viewSize.height - selBounds.size.height - selBounds.origin.y : deltay;
				 
				selBounds.origin.x +=  deltax;
				selBounds.origin.y +=  deltay;

				
				for (i=0; i<c; i++) {
                    element = [selElements objectAtIndex:i];
                    [self invalidateElement:element];
										
					//NSLog (@"%.2f, %.2f", selBounds.origin.x, selBounds.origin.y);
                    [element moveBy:NSMakePoint(deltax, deltay ) inView: self];
                    [self invalidateElement:element];
                    /*if (echoToRulers) {
                        [self continueEchoingMoveToRulers:NSMakeRect(curPoint.x - selOriginOffset.x, curPoint.y - selOriginOffset.y, NSWidth(selBounds),NSHeight(selBounds))];
                    }*/
                    didMove = YES;
                }
                // Adjust the delta that is used for cascading pastes.  Pasting and then moving the pasted element is the way you determine the cascade delta for subsequent pastes.
                _pasteCascadeDelta.x += (curPoint.x - lastPoint.x);
                _pasteCascadeDelta.y += (curPoint.y - lastPoint.y);
            }
            lastPoint = curPoint;
        }
        if ([theEvent type] == NSLeftMouseUp) {
            break;
        }
    }
	
    /*if (echoToRulers)  {
        [self stopEchoingMoveToRulers];
    }*/
    if (isMoving) {
		
		//   aaaaaaaH!!!!
        [selElements makeObjectsPerformSelector:@selector(stopBoundsManipulation)];
        _gvFlags.knobsHidden = NO;
		
        if (didMove) {
            // Only if we really moved.
            [[[self ecnProjectDocument] undoManager] setActionName:NSLocalizedStringFromTable(@"Move", @"UndoStrings", @"Action name for moves.")];
        }
    }
}


- (void)selectAndTrackMouseWithEvent:(NSEvent *)theEvent {
    NSPoint curPoint;
    ECNElement *element = nil;
    BOOL isSelected;
	//BOOL isVisible;
    BOOL extending = (([theEvent modifierFlags] & NSShiftKeyMask) ? YES : NO);
	
    curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    element = [self elementUnderPoint:curPoint];
    isSelected = (element ? [self elementIsSelected:element] : NO);
	//isVisible = (element ? [element isVisible] : NO); 
	
    if (!extending && !isSelected) {
        [self clearSelection];
    }
	
    if (element) {
        // Add or remove this element from selection.
        if (extending) {
            if (isSelected) {
                [self deselectElement:element];
                isSelected = NO;
            } else {
                [self selectElement:element];
                isSelected = YES;
            }
        } else {
            if (isSelected) {
                int knobHit = [element knobUnderPoint:curPoint  inView: self];
                if (knobHit != NoKnob) {
                    [self trackKnob:knobHit ofElement:element withEvent:theEvent];
                    return;
                }
            }
            [self selectElement:element];
            isSelected = YES;
        }
    } else {
        [self rubberbandSelectWithEvent:theEvent];
        return;
    }
	
    if (isSelected) {
        [self moveSelectedElementsWithEvent:theEvent];
        return;
    }
	
    // If we got here then there must be nothing else to do.  Just track until mouseUp:.
    while (1) {
        theEvent = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        if ([theEvent type] == NSLeftMouseUp) {
            break;
        }
    }
}

#pragma mark ***  Action methods and other UI entry points

- (void)changeColor:(id)sender {
    NSArray *selElements = [self selectedElements];
    unsigned i, c = [selElements count];
    if (c > 0) {
        ECNElement *curElement;
		
        for (i=0; i<c; i++) {
            curElement = [selElements objectAtIndex:i];
//            [curElement setFillColor:color];
//            [curElement setDrawsFill:YES];
        }
        [[self undoManager] setActionName:NSLocalizedStringFromTable(@"Set Fill Color", @"UndoStrings", @"Action name for setting fill color.")];
    }
}

- (IBAction)selectAll:(id)sender {
    NSArray *elements = [[self scene] elements];
    [self performSelector:@selector(selectElement:) withEachObjectInArray:elements];
}

- (IBAction)deselectAll:(id)sender {
    [self clearSelection];
}


- (IBAction)delete:(id)sender {
    NSArray *selCopy = [[NSArray allocWithZone:[self zone]] initWithArray:[self selectedElements]];
    if ([selCopy count] > 0) {
        [[self scene] performSelector:@selector(removeElement:) withEachObjectInArray:selCopy];
        [selCopy release];
        [[[self ecnProjectDocument] undoManager] setActionName:NSLocalizedStringFromTable(@"Delete", @"UndoStrings", @"Action name for deletions.")];
		[self setNeedsDisplay:true];
		[[NSNotificationCenter defaultCenter] postNotificationName:ElementsViewSelectionDidChangeNotification object:self];

    }
}

#pragma mark ***  Grid settings
- (BOOL)snapsToGrid {
    return false; //_gvFlags.snapsToGrid;
}

- (void)setSnapsToGrid:(BOOL)flag {
    _gvFlags.snapsToGrid = flag;
}

- (BOOL)showsGrid {
    return _gvFlags.showsGrid;
}

- (void)setShowsGrid:(BOOL)flag {
    if (_gvFlags.showsGrid != flag) {
        _gvFlags.showsGrid = flag;
        [self setNeedsDisplay:YES];
    }
}

- (float)gridSpacing {
    return _gridSpacing;
}

- (void)setGridSpacing:(float)spacing {
    if (_gridSpacing != spacing) {
        _gridSpacing = spacing;
        [self setNeedsDisplay:YES];
    }
}

- (NSColor *)gridColor {
    return (_gridColor ? _gridColor : [NSColor lightGrayColor]);
}

- (void)setGridColor:(NSColor *)color {
    if (_gridColor != color) {
        [_gridColor release];
        _gridColor = [color retain];
        [self setNeedsDisplay:YES];
    }
}

#pragma mark ***   Keyboard commands
- (void)keyDown:(NSEvent *)event {
    // Pass on the key binding manager.  This will end up calling insertText: or some command selector.
    [self interpretKeyEvents:[NSArray arrayWithObject:event]];
}

- (void)insertText:(NSString *)str {
    NSBeep();
}

- (void)hideKnobsMomentarily {
    if (_unhideKnobsTimer) {
        [_unhideKnobsTimer invalidate];
        _unhideKnobsTimer = nil;
    }
    _unhideKnobsTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(unhideKnobs:) userInfo:nil repeats:NO];
    _gvFlags.knobsHidden = YES;
    [self invalidateElements:[self selectedElements]];
}

- (void)unhideKnobs:(NSTimer *)timer {
    _gvFlags.knobsHidden = NO;
    [self invalidateElements:[self selectedElements]];
    [_unhideKnobsTimer invalidate];
    _unhideKnobsTimer = nil;
}

- (void)moveSelectedElementsByPoint:(NSPoint)delta {
    NSArray *selection = [self selectedElements];
    unsigned i, c = [selection count];
    if (c > 0) {
        [self hideKnobsMomentarily];
        for (i=0; i<c; i++) {
            [[selection objectAtIndex:i] moveBy:delta inView: self];
        }
        [[self undoManager] setActionName:NSLocalizedStringFromTable(@"Nudge", @"UndoStrings", @"Action name for nudge keyboard commands.")];
    }
}

- (void)moveLeft:(id)sender {
    [self moveSelectedElementsByPoint:NSMakePoint(-1.0, 0.0)];
}

- (void)moveRight:(id)sender {
    [self moveSelectedElementsByPoint:NSMakePoint(1.0, 0.0)];
}

- (void)moveUp:(id)sender {
    [self moveSelectedElementsByPoint:NSMakePoint(0.0, -1.0)];
}

- (void)moveDown:(id)sender {
    [self moveSelectedElementsByPoint:NSMakePoint(0.0, 1.0)];
}
- (void)deleteForward:(id)sender {
    [self delete:sender];
}

- (void)deleteBackward:(id)sender {
    [self delete:sender];
}



@end
