//
//  ECNScene.h
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 28/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
// ECNScene.h
//

#import "ECNObject.h"

@class ElementsView;
@class ECNProjectDocument;
@class ECNElement;

extern NSString *ECNSceneDidChangeNotification;

// Properties
extern NSString *ECNSceneDescriptionKey;
extern NSString *ECNSceneActiveAtFirstKey;
extern NSString *ECNSceneAspectRatioKey;
extern NSString *ECNSceneElementsListKey;


@interface ECNScene : ECNObject <NSCopying> {
@private
	
	//Playback management
	NSMutableSet *_curActiveElements;
	NSMutableSet *_visibleElements; // test mode

}

- (id)init;


// ========================= Constructors =========================

+ (ECNScene *)sceneWithDocument: (ECNProjectDocument *)document;

// ========================= Document accessors and conveniences =========================


- (NSString *)description;
- (void)setDescription: (NSString *) description;


- (NSUndoManager *)undoManager;

- (NSArray *)elements;

// =================================== Primitives ===================================
- (void)didChange;
// This sends the did change notification.  All change primitives should call it.


// =================================== Elements array manipulation ===================================
- (void)invalidateElement:(ECNElement *)element ;
- (void)insertElement:(ECNElement *)element atIndex:(unsigned)index;
- (void)moveElement:(ECNElement *)element toIndex:(unsigned)newIndex;
- (void)removeElement:(ECNElement *)element;
- (void)removeElementAtIndex:(unsigned)index;
- (NSRect)boundsForElements:(NSArray *)elements;

// =================================== Persistance ===================================
+ (id)sceneWithPropertyListRepresentation:(NSDictionary *)dict  withDocument: (ECNProjectDocument *) document;

@end

@interface ECNScene (ECNDrawing)

- (void)drawInView:(ElementsView *)view isSelected:(BOOL)flag;
- (unsigned)knobMask;
- (int)knobUnderPoint:(NSPoint)point;
- (void)drawHandleAtPoint:(NSPoint)point inView:(ElementsView *)view;
- (void)drawHandlesInView:(ElementsView *)view;

@end

@interface ECNScene (ECNEventHandling)

//+ (NSCursor *)creationCursor;

//- (BOOL)createWithEvent:(NSEvent *)theEvent inView:(ElementsView *)view;
- (void)makeWindowControllers; 

//- (BOOL)isEditable;
//- (void)startEditingWithEvent:(NSEvent *)event inView:(ElementsView *)view;
//- (void)endEditingInView:(ElementsView *)view;

//- (BOOL)hitTest:(NSPoint)point isSelected:(BOOL)isSelected;

@end

// === playback management ===
@interface ECNScene (ECNPlaybackManagement)

- (NSSet *) activeElements;
- (void) resetToInitialState;

- (NSSet *) visibleElements;
- (void) populateVisibleElementsSet;

- (void) setElementActivationState: (ECNElement *)element active: (bool) active;
- (bool) isElementActive: (ECNElement *)element;

- (void) setActivationState;
- (bool) activationState;

@end