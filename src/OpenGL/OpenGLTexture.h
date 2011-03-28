//
//  OpenGLTexture.h
//  kineto
//
//  Created by Andrea Cremaschi on 20/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

#import "MemObject.h"

typedef struct OpenGLTextureAttributes *OpenGLTextureAttributesRef;

@class OpenGLQuad;
@interface OpenGLTexture : MemObject {
	
	//OpenGL texture
	OpenGLTextureAttributesRef	_texture;

}



+ (id) createTextureWithOpenGLContext:	(NSOpenGLContext *)openGLContext 
						  textureType:	(GLenum)target;


- (void) drawPixelBuffer: (NSOpenGLPixelBuffer *)pixelBuffer inQuad: (OpenGLQuad *)quad;	
//- (void) drawCVImageBuffer: (CVImageBufferRef)imageBuffer inQuad: (OpenGLQuad *)quad;	
- (void) enable;
- (void) disable;
- (CIImage *) ciImageWithSize: (NSSize *)imageSize;


@end
