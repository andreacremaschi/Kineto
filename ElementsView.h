//
//  ElementsView.h
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 19/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@class ECNScene;
@class ECNElement;
@class ECNProjectDocument;
@class ECNSceneWindowController;

#define ECN_HALF_HANDLE_WIDTH 4.0
#define ECN_HANDLE_WIDTH (ECN_HALF_HANDLE_WIDTH * 2.0)

extern NSString *ElementsViewSelectionDidChangeNotification;
extern NSString *ElementsViewDoubleClicOnElementNotification;

@interface ElementsView : NSView {
@private
    //IBOutlet ECNSceneWindowController *controller;
	//ECNScene * _scene;

    NSMutableArray *_selectedElements;
	
	
    ECNElement *_creatingElement;
    ECNElement *_editingElement;
    NSRect _rubberbandRect;
    NSSet *_rubberbandElements;

   // NSView *_editorView; //?
	
    int _pasteboardChangeCount;
    int _pasteCascadeNumber;
    NSPoint _pasteCascadeDelta;
   
	float _gridSpacing;
    NSColor *_gridColor;
    
	NSTimer *_unhideKnobsTimer; //?
    struct __gvFlags {
        unsigned int rubberbandIsDeselecting:1;
        unsigned int initedRulers:1;
        unsigned int snapsToGrid:1;
        unsigned int showsGrid:1;
        unsigned int knobsHidden:1;
        unsigned int _pad:27;
    } _gvFlags;
	
    NSRect _verticalRulerLineRect;
    NSRect _horizontalRulerLineRect;
	
	NSImage * _background;
	bool _bUseBackground;
	
}

// ECNSceneWindowController accessors and convenience methods
//- (void)setSceneWindowController:(ECNSceneWindowController *)theController;
//- (ECNSceneWindowController *)sceneWindowController;
//- (ECNProjectDocument *)ecnProjectDocument;
- (void)setScene:(ECNScene *)scene;
- (void)useBackground:(bool)bUseBG;

// recupera elenco scene ed elementi dalle classi superiori
/*- (NSArray *)scenes;
- (NSArray *)elements;
*/


- (void) setBackground: (NSImage *) newBackgroudn;

// Display invalidation
- (void)invalidateElement:(ECNElement *)element;

// Selection primitives
- (NSArray *)selectedElements;
- (NSArray *)orderedSelectedElements;
- (BOOL)elementIsSelected:(ECNElement *)element;
- (void)selectElement:(ECNElement *)element;
- (void)deselectElement:(ECNElement *)element;
- (void)clearSelection;

// Managing editoring elements
/*- (void)setEditingElement:(ECNElement *)element editorView:(NSView *)editorView;
- (ECNElement *)editingElement;
- (NSView *)editorView;
- (void)startEditingElement:(ECNElement *)element withEvent:(NSEvent *)event;
- (void)endEditing;*/

// Geometry calculations
- (ECNElement *)elementUnderPoint:(NSPoint)point;
- (NSSet *)elementsIntersectingRect:(NSRect)rect;

// Drawing and mouse tracking
- (void)drawRect:(NSRect)rect;

- (void)beginEchoingMoveToRulers:(NSRect)echoRect;
- (void)continueEchoingMoveToRulers:(NSRect)echoRect;
- (void)stopEchoingMoveToRulers;

- (void)createElementOfClass:(Class)theClass withEvent:(NSEvent *)theEvent;
- (ECNElement *)creatingElement;
- (void)trackKnob:(int)knob ofElement:(ECNElement *)element withEvent:(NSEvent *)theEvent;
- (void)rubberbandSelectWithEvent:(NSEvent *)theEvent;
- (void)moveSelectedElementsWithEvent:(NSEvent *)theEvent;
- (void)selectAndTrackMouseWithEvent:(NSEvent *)theEvent;
- (void)mouseDown:(NSEvent *)theEvent;

// Dragging
- (unsigned int)dragOperationForDraggingInfo:(id <NSDraggingInfo>)sender;
- (unsigned int)draggingEntered:(id <NSDraggingInfo>)sender;
- (unsigned int)draggingUpdated:(id <NSDraggingInfo>)sender;
- (void)draggingExited:(id <NSDraggingInfo>)sender;
- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender;
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
- (void)concludeDragOperation:(id <NSDraggingInfo>)sender;

// Ruler support
- (void)updateRulers;
- (BOOL)rulerView:(NSRulerView *)ruler shouldMoveMarker:(NSRulerMarker *)marker;
- (float)rulerView:(NSRulerView *)ruler willMoveMarker:(NSRulerMarker *)marker toLocation:(float)location;
- (void)rulerView:(NSRulerView *)ruler didMoveMarker:(NSRulerMarker *)marker;
- (BOOL)rulerView:(NSRulerView *)ruler shouldRemoveMarker:(NSRulerMarker *)marker;

// Action methods and other UI entry points
- (void)changeColor:(id)sender;

- (IBAction)selectAll:(id)sender;
- (IBAction)deselectAll:(id)sender;

- (IBAction)delete:(id)sender;
- (IBAction)bringToFront:(id)sender;
- (IBAction)sendToBack:(id)sender;
- (IBAction)alignLeftEdges:(id)sender;
- (IBAction)alignRightEdges:(id)sender;
- (IBAction)alignTopEdges:(id)sender;
- (IBAction)alignBottomEdges:(id)sender;
- (IBAction)alignHorizontalCenters:(id)sender;
- (IBAction)alignVerticalCenters:(id)sender;
- (IBAction)makeSameWidth:(id)sender;
- (IBAction)makeSameHeight:(id)sender;
- (IBAction)makeNaturalSize:(id)sender;
- (IBAction)snapsToGridMenuAction:(id)sender;
- (IBAction)showsGridMenuAction:(id)sender;
- (IBAction)gridSelectedElementsAction:(id)sender;

// Grid settings
- (BOOL)snapsToGrid;
- (void)setSnapsToGrid:(BOOL)flag;
- (BOOL)showsGrid;
- (void)setShowsGrid:(BOOL)flag;
- (float)gridSpacing;
- (void)setGridSpacing:(float)spacing;
- (NSColor *)gridColor;
- (void)setGridColor:(NSColor *)color;



@end

