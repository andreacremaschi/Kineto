//
//  ECNOSCManager.h
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 18/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OSCTableViewDataSource;
@interface ECNOSCManager : NSWindowController <NSTableViewDataSource> {
    @private


	IBOutlet NSTableView * OSCtargetsTableView;
	
//	NSArray *_OSCObservedTargets;
	
	IBOutlet OSCTableViewDataSource *OSCListDataSource;
	
	bool needsUpdate;
	
	
	NSMutableArray * _OSCObservedTargets;
}



+ (ECNOSCManager *) sharedECNOSCManager;
- (NSArray *)hostlist;
- (NSArray *)OSCObservedTargets;

@end
