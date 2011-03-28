//
//  OSCTxAssetInstanceSettingsPanel.h
//  kineto
//
//  Created by Andrea Cremaschi on 14/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ECNOSCTxAssetInstance;
@class ECNObject;
@class ECNAction;

@class OSCManager;

@interface OSCTxAssetInstanceSettingsPanel : NSWindowController {
	ECNOSCTxAssetInstance *_element;
	NSInteger _state;

	IBOutlet NSObjectController *oElementToInspect;
	IBOutlet NSArrayController *oOutputPortsList;

	IBOutlet NSMatrix *oMtxOSCTargetKind;

	IBOutlet NSTextField *oTxtFieldHost;
	IBOutlet NSTextField *oTxtFieldPort;
	IBOutlet NSPopUpButton *oPopupExistingServers;
	IBOutlet NSPopUpButton *oPopupBonjourServers;
	
	OSCManager *_oscManager;

}
- (OSCManager *)oscManager;

- (IBAction) ok:	(id)sender;
- (IBAction) cancel:(id)sender;
- (IBAction)add:(id)sender;

- (IBAction) popupSelectionDidChange: (id)sender;


- (IBAction)changeRadioSelection:(id)sender;

+ (OSCTxAssetInstanceSettingsPanel *) settingsPanelWithElement: (ECNOSCTxAssetInstance *)elementToModify;
- (NSInteger)runModal;

- (NSArray *)OSCTargetsList;

- (void) setupChanged;

@end
