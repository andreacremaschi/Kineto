//
//  ECNLine.h
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 31/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ECNElement.h"

#define kOSCDefaultPort 5000

@interface ECNOSCReceiver : ECNElement {
@private
    NSImage *_image;
    NSImage *_cachedImage;
	
	int _inPort;
	
	
	// playback flags and osc buffer
	bool _oscReceiverIsActive;
}

// *** Accessors
- (void) setInPort: (int) inPort;
- (int) inPort;

// *** Representation methods and properties
- (void)setImage:(NSImage *)image;
- (NSImage *)image;
- (NSImage *)transformedImage;

@end
