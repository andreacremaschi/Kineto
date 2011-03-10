//
//  CVImageBuffer.h
//  kineto
//
//  Created by Andrea Cremaschi on 24/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MemObject.h"


typedef struct CVImageBufferAttributes *CVImageBufferAttributesRef;

@class OpenGLQuad;
@interface CVImageBuffer : MemObject {
@private
	//CoreVideo imagebuffer
	CVImageBufferAttributesRef	_imageBuffer;

}


- (id) initWithCVImageBuffer:	(CVImageBufferRef)	imageBuffer;

- (id) initWithCVOpenGLTexture:	(CVOpenGLTextureRef)	openGLTexture;
- (id) initWithCVOpenGLBuffer:	(CVOpenGLBufferRef)	openGLBuffer;
- (id) initWithCVPixelBuffer:	(CVPixelBufferRef)	pixelBuffer;

- (void) setCVImage: (CVImageBufferRef) imageBuffer;

- (void) lock;
- (bool) isLocked;

- (CIImage *)createCIImage;
- (CVImageBufferRef) imageRef;
- (void)	drawInOpenGLContext: (NSOpenGLContext *)openGLContext	
					withQuad: (OpenGLQuad *) quad;	

@end
