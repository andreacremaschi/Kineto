//
//  ECNProjectWindowController.h
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 28/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class ECNScene;
@interface ECNProjectWindowController : NSWindowController <NSTableViewDataSource> {

	IBOutlet NSTableView* scenesTableView; 
	IBOutlet NSTableView* assetsTableView; 
	IBOutlet NSArrayController *assetArrayController;
	IBOutlet NSArrayController *scenesArrayController;
//	IBOutlet ElementsView * scenePreview;
}


- (IBAction) ECNnewScene: (id)sender;
- (IBAction) importFile: (id) sender;

- (NSArray *)selectedAssets;

@end
