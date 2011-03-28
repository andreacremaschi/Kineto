//
//  ECNSceneWindowController.h
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 21/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ElementsView;
@class ECNScene;
@class ECNElement;
@class ECNObject;

@interface ECNSceneWindowController : NSWindowController  <NSTableViewDataSource> {
@private
	IBOutlet ElementsView *elementsView;
	IBOutlet NSTableView *elementsListView;

	IBOutlet NSButton *oBGCheckbox;

	IBOutlet NSTextField *mDebugLabel;
		
	IBOutlet NSArrayController *oElementsListArrayController;
	
	IBOutlet NSPanel *oElementPropertyInspectorPanel;

	IBOutlet NSArrayController *oSelectedElementPropertyKeys;
	
	ECNScene *_scene;
	
	float _aspectRatio;
	bool _bTableviewSelectionIsUpdating;
}

+ (ECNSceneWindowController *)windowWithScene: (ECNScene *)scene;


- (ECNScene *)scene;
- (NSArray *)sceneObjects;

- (void)invalidateScene:(ECNScene *)scene;
- (void)invalidateElement:(ECNElement *)element;

- (IBAction) bgCheckbox: (id)sender;
- (IBAction) editElementSettings: (id)sender;
- (IBAction) createNewElement: (id)sender;
- (IBAction) editElementSettings: (id)sender;

- (IBAction) addAssetToScene: (id)sender;

- (ECNElement *)selectedObject;
- (NSArray *)selectedObjectPropertyKeys;
- (NSArray *)selectedElements;

//- (IBAction)switchAspectRatio: (id) sender;
@end

