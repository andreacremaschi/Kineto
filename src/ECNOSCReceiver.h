//
//  ECNLine.h
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 31/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ECNElement.h"

@interface ECNOSCReceiver : ECNElement {
@private
    NSImage *_image;
    NSImage *_cachedImage;
	
}

// *** Representation methods and properties
- (void)setImage:(NSImage *)image;
- (NSImage *)image;
- (NSImage *)transformedImage;

@end
