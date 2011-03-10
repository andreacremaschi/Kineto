//
//  OpenGLTexture.m
//  kineto
//
//  Created by Andrea Cremaschi on 20/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenGLTexture.h"
#import "AlertPanelKit.h"
#import "OpenGLQuad.h"

struct OpenGLTextureAttributes
{
	CGLContextObj	cgl_ctx;
	GLenum			target;
	GLuint			name;
};

typedef struct OpenGLTextureAttributes   OpenGLTextureAttributes;

@implementation OpenGLTexture


- (void) generateAndBindTextureOfType: (GLenum) textureType 
					withOpenGLContext: (NSOpenGLContext *) openGLContext {
	
	CGLContextObj					cgl_ctx = [openGLContext CGLContextObj];
	GLint							saveTextureName;
	
	//Create the texture on the target OpenGL context
	_texture->target = textureType;
	// save cgl_ctx for future use
	_texture->cgl_ctx = cgl_ctx;
	
	
	glGenTextures(1, &_texture->name);
	
	//Configure the texture - For extra safety, we save and restore the currently bound texture
	glGetIntegerv((_texture->target == GL_TEXTURE_RECTANGLE_EXT ? GL_TEXTURE_BINDING_RECTANGLE_EXT : GL_TEXTURE_BINDING_2D), &saveTextureName);
	glBindTexture(_texture->target, _texture->name);
	glTexParameteri(_texture->target, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(_texture->target, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	if(_texture->target == GL_TEXTURE_RECTANGLE_EXT) {
		glTexParameteri(_texture->target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(_texture->target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	}
	else {
		glTexParameteri(_texture->target, GL_TEXTURE_WRAP_S, GL_REPEAT);
		glTexParameteri(_texture->target, GL_TEXTURE_WRAP_T, GL_REPEAT);
	}
	glBindTexture(_texture->target, saveTextureName);	


	
}


- (id) initTextureWithOpenGLContext:	(NSOpenGLContext *)openGLContext 
				   textureType:	(GLenum)target	{
	
	
	self = [super initMemoryWithType:kMemAlloc 
								size:sizeof(OpenGLTextureAttributes)];
	
	if (self)	{
		
		_texture = (OpenGLTextureAttributesRef)[self pointer];
		
		if ( [self isPointerValid] )
		{

			[self generateAndBindTextureOfType: target withOpenGLContext: openGLContext];
			return self;
			
		} // if
		else
		{
			[[AlertPanelKit withTitle:@"OpenGL Quad" 
							  message:@"Failure Allocating Memory For OpenGL Quad Attributes using size"
								 exit:NO] displayAlertPanel];
		} // else
	}
	
	return nil;
	
} // initTextureWithOpenGLContext: textureType:


#pragma mark *** Constructors

+ (id) createTextureWithOpenGLContext:	(NSOpenGLContext *)openGLContext 
					textureType:	(GLenum)target

{
	return  [[[OpenGLTexture allocWithZone:[self zone]] initTextureWithOpenGLContext:	openGLContext 
																		 textureType:	target] autorelease];
} // createTextureWithOpenGLContext: textureType:


#pragma mark *** OpenGLTexture methods

- (void) enable	{
	CGLContextObj	cgl_ctx = _texture->cgl_ctx; 

	glEnable(_texture->target);
	glBindTexture(_texture->target, _texture->name);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
}

- (void) disable	{
	CGLContextObj	cgl_ctx = _texture->cgl_ctx; 
	//glBindTexture( _texture->target, 0 ); // ci va questo o no? boh
	glDisable(_texture->target);
}


- (void) drawPixelBuffer: (NSOpenGLPixelBuffer *)pixelBuffer inQuad: (OpenGLQuad *)quad	{

	//IMPORTANT: We use the macros provided by <OpenGL/CGLMacro.h> which provide better performances and allows us not to bother with making sure the current context is valid
	CGLContextObj	cgl_ctx = _texture->cgl_ctx;
	GLint			saveTextureName;
	
	//Save the currently bound texture
	glGetIntegerv((_texture->target == GL_TEXTURE_RECTANGLE_EXT ? GL_TEXTURE_BINDING_RECTANGLE_EXT : GL_TEXTURE_BINDING_2D), &saveTextureName);
	
	//Bind the texture and update its contents
	glBindTexture(_texture->target, _texture->name);
	
	CGLError glErr = CGLTexImagePBuffer (	cgl_ctx,
										 [pixelBuffer CGLPBufferObj],
										 GL_FRONT
										 );
	
	if (glErr != kCGLNoError) 
	{	NSLog (@"loadPixelBuffer: OpenGL error n. %i", glErr);
		//Restore the previously bound texture
		glBindTexture(_texture->target, saveTextureName);
		return;
	}

	
	[self enable];
	//Draw textured quad
	[quad draw];		// NB le coordinate della quad sono in pixel, 
						// come anche le coordinate delle maschere  perché
						// inizializzate come GL_TEXTURE_RECTANGLE_EXT. 
						// Se fossero state inizializzate come GL_TEXTURE_2D le coord sarebbero espresse in 0-1

	[self disable];
	
	//Restore the previously bound texture
	glBindTexture(_texture->target, saveTextureName);

}


/*- (void) drawCVImageBuffer: (CVImageBufferRef)imageBuffer inQuad: (OpenGLQuad *)quad	{

	// non funziona. TODO: capire perché!!
	
	
	
	//IMPORTANT: We use the macros provided by <OpenGL/CGLMacro.h> which provide better performances and allows us not to bother with making sure the current context is valid
	CGLContextObj	cgl_ctx = _texture->cgl_ctx;
	GLint			saveTextureName;


	
	
	// get the texture target	
	GLenum target = CVOpenGLTextureGetTarget( imageBuffer );
	
	// get the texture target name
	GLint name = CVOpenGLTextureGetName( imageBuffer );
	
	//Save the currently bound texture
	glGetIntegerv((target == GL_TEXTURE_RECTANGLE_EXT ? GL_TEXTURE_BINDING_RECTANGLE_EXT : GL_TEXTURE_BINDING_2D), &saveTextureName);

	


	
	glEnable(target);
	//[self enable];

	// bind to the CoreVideo texture
	glBindTexture( target, name );

	glMatrixMode(GL_TEXTURE);
    glLoadIdentity();
	
	//Draw textured quad
	[quad draw];		// NB le coordinate della quad sono in pixel, 
	// come anche le coordinate delle maschere  perché
	// inizializzate come GL_TEXTURE_RECTANGLE_EXT. 
	// Se fossero state inizializzate come GL_TEXTURE_2D le coord sarebbero espresse in 0-1
	
	//[self disable];
	glDisable(target);
	
	//Restore the previously bound texture
	//glBindTexture(target, saveTextureName);

	
}*/


- (CIImage *) ciImageWithSize: (NSSize *)imageSize	{
	return [CIImage imageWithTexture:	_texture->name	//[_cameraController getCurrentFrame] 
						 size:	CGSizeMake(imageSize->width, imageSize->height ) 
					  flipped:	NO 
						  colorSpace:	nil];
	
}

- (void) dealloc 
{
	CGLContextObj	cgl_ctx = _texture->cgl_ctx;
	
	//Destroy the texture on the target OpenGL context
	if(_texture->name)
		glDeleteTextures(1, &_texture->name);
	
	[super dealloc];
	
}

@end
