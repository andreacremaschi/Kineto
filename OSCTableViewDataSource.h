//
//  OSCTableViewDataSource.h
//  kineto
//
//  Created by Andrea Cremaschi on 01/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ECNProjectDocument;
@interface OSCTableViewDataSource : NSObject <NSTableViewDataSource> {
	
	NSMutableArray * _OSCObservedTargets;
	NSMutableArray *_hostlist;
	ECNProjectDocument *_observedDocument;
	
}

//- (void) setOSCTargets: (NSArray *)oscTargets;
- (void) setDocument: (ECNProjectDocument *)document;
- (NSArray *)hostlist;

@end
