//
//  LiveInputSelectorView.h
//  kineto
//
//  Created by Andrea Cremaschi on 28/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CameraControllerInQCMaskRendererView.h"

@interface LiveInputSelectorView : CameraControllerInQCMaskRendererView {
	bool _keystoneEnabled;
	bool _flipEnabled;
}
// specific methods
- (void) setKeystoneEnabled: (bool) keystoneEnabled;
- (void) setFlipEnabled: (bool) flipEnabled;

@end
