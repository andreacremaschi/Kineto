//
//  ECNElement.h
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 28/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ECNObject.h"


// +  + Object specific properties  +

extern NSString *ECNElementVisibleKey;
extern NSString *ECNElementEnabledKey;

extern NSString *ECNElementSceneKey;
extern NSString *ECNElementActiveWhenSceneOpensKey;

extern NSString *ECNElementTriggersListKey;

extern NSString *ECNElementBoundsKey;
extern NSString *ECNElementStrokeColorKey ;
// +  +  +  +  +  +  +  +  +  +  +  +



@class ECNProjectDocument;
@class ECNScene;
@class ECNAction;
@class ECNTrigger;

enum {
    NoKnob = 0,
    UpperLeftKnob,
    UpperMiddleKnob,
    UpperRightKnob,
    MiddleLeftKnob,
    MiddleRightKnob,
    LowerLeftKnob,
    LowerMiddleKnob,
    LowerRightKnob,
};

enum {
    NoKnobsMask = 0,
    UpperLeftKnobMask = 1 << UpperLeftKnob,
    UpperMiddleKnobMask = 1 << UpperMiddleKnob,
    UpperRightKnobMask = 1 << UpperRightKnob,
    MiddleLeftKnobMask = 1 << MiddleLeftKnob,
    MiddleRightKnobMask = 1 << MiddleRightKnob,
    LowerLeftKnobMask = 1 << LowerLeftKnob,
    LowerMiddleKnobMask = 1 << LowerMiddleKnob,
    LowerRightKnobMask = 1 << LowerRightKnob,
    AllKnobsMask = 0xffffffff,
};

extern NSString *ECNElementDidChangeNotification;

@interface ECNElement : ECNObject <NSCopying> {
@private
	//ECNScene *_scene;
    NSRect _origBounds;
	
    struct __gFlags {
        unsigned int drawsFill:1;
        unsigned int drawsStroke:1;
        unsigned int manipulatingBounds:1;
        unsigned int _pad:29;
    } _gFlags;
		

}

- (id)init;
+ (ECNElement *)elementWithDocument: (ECNProjectDocument *)document;
+ (Class) triggerClass;

// ========================= Document accessors and conveniences =========================
- (void)setScene:(ECNScene *)scene;
- (ECNScene *)scene;
- (NSUndoManager *)undoManager;

- (bool)isEnabled;
- (void) setEnabled: (bool)isEnabled;

- (bool)isVisible;
- (void) setVisible: (bool)isVisible;

- (void) setActiveWhenSceneOpens: (bool) activeWhenSceneOpens;
- (bool) activeWhenSceneOpens;

// =================================== Primitives ===================================
- (void)didChange;
// This sends the did change notification.  All change primitives should call it.

- (void)setBounds:(NSRect)bounds;
- (NSRect)bounds;

- (NSRect) calcDrawingBoundsInView: (NSView *) view;
- (NSRect) calcPixelBoundsInView: (NSView *) view;
- (NSRect) calcPixelBoundsInRect: (NSRect )rect;

- (void)setStrokeColor:(NSColor *)strokeColor;
- (NSColor *)strokeColor;

// =================================== Primitives ===================================
- (void) updateElementViewBounds;

// =================================== Extended mutation ===================================
- (void)startBoundsManipulation;
- (void)stopBoundsManipulation;
- (void)moveBy:(NSPoint)vector;
- (void)moveBy:(NSPoint)vector inView:(NSView *)view;
- (void)flipHorizontally;
- (void)flipVertically;
- (int)resizeByMovingKnob:(int)knob toPoint:(NSPoint)point inView:(NSView *)view;
- (void)makeNaturalSize;

// =================================== Subclass capabilities ===================================
- (BOOL)canDrawStroke;
- (BOOL)canDrawFill;
- (BOOL)hasNaturalSize;

// =================================== Persistance ===================================
- (NSMutableDictionary *)propertyListRepresentation;
+ (id)elementWithPropertyListRepresentation:(NSDictionary *)dict withScene: (ECNScene *)scene;
- (void)loadPropertyListRepresentation:(NSDictionary *)dict;
- (void)	bindElementsActionsTargetsUsingIDs;

@end



@interface ECNElement (ECNDrawing)

- (NSRect)drawingBounds;
- (NSBezierPath *)bezierPathInRect: (NSRect )rect;
- (void)drawInView:(NSView *)view isSelected:(BOOL)flag;
- (unsigned)knobMask;
- (int)knobUnderPoint:(NSPoint)point inView:(NSView *)view;
- (void)drawHandleAtPoint:(NSPoint)point inView:(NSView *)view;
- (void)drawHandlesInView:(NSView *)view;

//funzione di disegno per il playback!
- (void) drawInOpenGLContext: (NSOpenGLContext *)openGLContext;
@end



@interface ECNElement (ECNEventHandling)

+ (NSCursor *)creationCursor;

- (BOOL)createWithEvent:(NSEvent *)theEvent inScene:(ECNScene *)scene inView:(NSView *)view;

//- (BOOL)isEditable;
//- (void)startEditingWithEvent:(NSEvent *)event inView:(ElementsView *)view;
- (void)endEditingInView:(NSView *)view;

- (BOOL)hitTest:(NSPoint)point isSelected:(BOOL)isSelected inView:(NSView *)view;

@end


// === Playback handling ===
@interface ECNElement (ECNPlaybackHandling)
- (bool) prepareForPlayback;
- (void) commitActionsForActiveTriggers;
- (void) setActivationState: (bool) active;
- (bool) activationState;
- (BOOL) executeAtTime:(NSTimeInterval)time;

@end

@interface ECNElement (ECNTriggers)

- (ECNTrigger *)firstTrigger; // returns the first trigger in the list 
							// NB this is temporary, but it has to be a list of trigger, not just one!
- (NSArray *)triggers;
+ (NSString *)defaultTriggerPortKey;

@end