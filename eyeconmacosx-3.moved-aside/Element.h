//
//  Element.h
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 19/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Element : NSObject {

	abstract drawElement(CGLContextObj *cgl_ctx);
	
}

@end
