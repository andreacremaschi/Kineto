//
//  ECNPlayerCont/Users/andreacremaschi/Desktop/realta aumentata/eyeconmacosx/eyeconmacosx/ECNPlayerController.m:18:0 /Users/andreacremaschi/Desktop/realta aumentata/eyeconmacosx/eyeconmacosx/ECNPlayerController.m:18: error: 'kRendererFPS' undeclared (first use in this function)roller.m
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 04/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ECNPlayerController.h"
//#define kRendererEventMask (NSLeftMouseDownMask | NSLeftMouseDraggedMask | NSLeftMouseUpMask | NSRightMouseDownMask | NSRightMouseDraggedMask | NSRightMouseUpMask | NSOtherMouseDownMask | NSOtherMouseUpMask | NSOtherMouseDraggedMask | NSKeyDownMask | NSKeyUpMask | NSFlagsChangedMask | NSScrollWheelMask | NSTabletPointMask | NSTabletProximityMask)
#define kRendererFPS 30.0
/*#define kFramesCacheMaxSize 10
#define kFramesCacheInputKey @"Frames"
*/

@implementation ECNPlayerController



- (void) initTimer {
	
	
	
	
	//Create a timer which will regularly call our rendering method
	_renderTimer = [[NSTimer scheduledTimerWithTimeInterval:(1.0 / (NSTimeInterval)kRendererFPS) target:self selector:@selector(_render:) userInfo:nil repeats:YES] retain];
	if(_renderTimer == nil) {
		NSLog(@"Cannot create NSTimer");
		[NSApp terminate:nil];
	}
}

@end
