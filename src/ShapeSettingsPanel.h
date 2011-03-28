//
//  ElementSettingsPanel.h
//  kineto
//
//  Created by Andrea Cremaschi on 14/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ECNElement;
@class ECNObject;
@class ECNAction;

@interface ShapeSettingsPanel : NSWindowController {
	ECNElement *_element;
	NSInteger _state;

	IBOutlet NSObjectController *oElementToInspect;
	IBOutlet NSTableView *activationActionsTableView;
	IBOutlet NSTableView *deactivationActionsTableView;
	
	IBOutlet NSArrayController *activationActionsList;
	IBOutlet NSArrayController *deactivationActionsList;
		
	// new action members
	NSArray *availableTargets;
	NSArray *availableActionForSelectedTarget;
	ECNObject *_selectedTarget;
	Class actionClass;
	ECNAction * selectedActivationAction;
	ECNAction * selectedDeactivationAction;
}

@property Class actionClass;
@property (assign) ECNAction * selectedActivationAction;
@property (assign) ECNAction *  selectedDeactivationAction;

- (IBAction) ok:	(id)sender;
- (IBAction) cancel:(id)sender;
- (IBAction) addActivationAction:	(id)sender;
- (IBAction) removeActivationAction:(id)sender;
- (IBAction) addDeactivationAction:	(id)sender;
- (IBAction) removeDeactivationAction:(id)sender;

+ (ShapeSettingsPanel *) settingsPanelWithElement: (ECNElement *)elementToModify;
- (NSInteger)runModal;
- (NSArray *)actionsList;


- (void)refreshAvailableTargets;



// KVC methods 
- (ECNObject *)selectedTarget;
- (void)setSelectedTarget: (ECNObject *)selectedTarget;

- (NSArray *)masks;

@end
