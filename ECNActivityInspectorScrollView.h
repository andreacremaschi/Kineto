//
//  ECNActivityInspectorScrollView.h
//  kineto
//
//  Created by Andrea Cremaschi on 12/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ECNActivityInspectorViewController;

@interface ECNActivityInspectorScrollView : NSScrollView {
	NSMutableSet * _viewControllersList;
	IBOutlet  ECNActivityInspectorViewController * oActivityInspector;
}

- (void) setElementsList: (NSSet *)elementsList;
- (void) updateActivityInspectors;

@end
