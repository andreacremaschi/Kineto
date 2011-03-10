//
//  CVImageBuffer.m
//  kineto
//
//  Created by Andrea Cremaschi on 24/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CVImageBuffer.h"
#import "AlertPanelKit.h"
#import "OpenGLQuad.h"

enum CVBufferType
{
	kImageBuffer = 1,
	kOpenGLTexture,
	kOpenGLBuffer,
	kPixelBuffer
};

typedef enum CVBufferType CVBufferType;

struct CVImageBufferAttributes
{
	CVBufferRef ref;
	bool lock;
	CVBufferType type;
	NSSize size;
};



typedef struct CVImageBufferAttributes   CVImageBufferAttributes;

@implementation CVImageBuffer


#pragma mark *** Init

- (id) init
{
	
	
	self = [super initMemoryWithType:kMemAlloc 
								size:sizeof(CVImageBufferAttributes)];
	
	if (self)	{
		
		_imageBuffer = (CVImageBufferAttributesRef)[self pointer];
		
		if ( [self isPointerValid] )		
			return self;
		else
			[[AlertPanelKit withTitle:@"CoreVideo Image buffer" 
							  message:@"Failure Allocating Memory For Core Video Image Buffer Attributes"
								 exit:NO] displayAlertPanel];
	}
	return nil;
	
} // init

- (id) initWithCVImageBuffer:	(CVImageBufferRef)	imageBuffer	{
	
	self = [self init];
	
	if (self)
	{	_imageBuffer->ref = imageBuffer;
		_imageBuffer->lock = false;
		_imageBuffer->type = kImageBuffer;
		CVBufferRetain (imageBuffer);
	}	
	return self;	
} // initWithCVImageBuffer



- (id) initWithCVOpenGLTexture: (CVOpenGLTextureRef) CVTexture	{
	
	self = [self init];
	
	if (self)
	{	_imageBuffer->ref = CVTexture;
		_imageBuffer->lock = false;
		_imageBuffer->type = kOpenGLTexture;
		CVOpenGLTextureRetain (CVTexture);
	}	
	return self;	
} // initWithCVOpenGLTexture


- (id) initWithCVOpenGLBuffer: (CVOpenGLBufferRef) CVOpenGLBuffer	{
	
	self = [self init];
	
	if (self)
	{	_imageBuffer->ref = CVOpenGLBuffer;
		_imageBuffer->lock = false;
		_imageBuffer->type = kOpenGLBuffer;
		CVOpenGLBufferRetain (CVOpenGLBuffer);
	}	
	return self;	
} // initWithCVOpenGLBuffer

- (id) initWithCVPixelBuffer: (CVPixelBufferRef) CVPixelBuffer	{
	
	self = [self init];
	
	if (self)
	{	_imageBuffer->ref = CVPixelBuffer;
		_imageBuffer->lock = false;
		_imageBuffer->type = kOpenGLBuffer;
		CVPixelBufferRetain (CVPixelBuffer);
	}	
	return self;	
} // initWithCVPixelBuffer



#pragma mark *** Accessors
- (bool) isLocked	{
	return _imageBuffer->lock;	
}

#pragma mark *** Draw

- (void) drawInOpenGLContext: (NSOpenGLContext *)openGLContext	
					withQuad: (OpenGLQuad *) quad	{
	
	CGLContextObj	cgl_ctx = [openGLContext CGLContextObj]; //By using CGLMacro.h there's no need to set the current OpenGL context

	// get the texture target	
	GLenum target = CVOpenGLTextureGetTarget( _imageBuffer->ref );
	
	// get the texture target name
	GLint name = CVOpenGLTextureGetName( _imageBuffer->ref );
	
	// bind to the CoreVideo texture
	glBindTexture( target, name );
	
	// draw the quad
	//NSUInteger quadIndex = CVOpenGLTextureIsFlipped( _imageBuffer->ref );
	
	[quad draw];
	
	// Unbind the CoreVideo texture
	glBindTexture( target, 0 );
	
} // render

#pragma mark *** Lock and release

- (void) lock	{
	_imageBuffer->lock = true;	
}


- (CIImage *)createCIImage	{
	return [CIImage imageWithCVImageBuffer: _imageBuffer->ref];
}

- (CVImageBufferRef) imageRef	{
	CVImageBufferRef imageRef;
	imageRef = _imageBuffer->ref;
	return imageRef;
}

#pragma mark dealloc

- (void) dealloc 
{
	//Destroy the imagebuffer 
	if(_imageBuffer->ref)
		switch (_imageBuffer->type)	{
			case 	kImageBuffer:
				CVBufferRelease (_imageBuffer->ref);
				break;
			case 	kOpenGLTexture:
				CVOpenGLTextureRelease (_imageBuffer->ref);
				break;
			case	kOpenGLBuffer:
				CVOpenGLBufferRelease (_imageBuffer->ref);
				break;
			case	kPixelBuffer:
				CVPixelBufferRelease (_imageBuffer->ref);
				break;
		}
	[super dealloc];
	
}

@end
