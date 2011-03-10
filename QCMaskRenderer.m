//
//  QCMaskRenderer.m
//  kineto
//
//  Created by Andrea Cremaschi on 18/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QCMaskRenderer.h"
#import "LiveInputRenderer.h"
#import <CoreVideo/CoreVideo.h>


@implementation QCMaskRenderer


#pragma mark init

- (bool) initWithCompositionPath:	(NSString *)compositionPath	{
	
	//Create the QuartzComposer Renderer with that OpenGL context and the specified composition file
	@try {
		
		_renderer = [[[QCRenderer alloc] initWithOpenGLContext:	[super openGLContext] 
												  pixelFormat:	[super pixelFormat]  
														 file:	compositionPath	] retain];
		NSLog (@"QCMaskRenderer created on CGLContext: %i", [[super openGLContext] CGLContextObj]);

		if(_renderer == nil) {
			NSLog(@"Cannot create QCRenderer");
			[self release];
			return false;
		}
		// TODO: check if the loaded Quartz Composition patch
		// has #VideoInput and #VideoOutput ports!
		
	}
	@catch (NSException * exception) {
		
		// can't load Quartz Composition: release and return error!
		NSLog(@"Error running Quartz Composition '%s': %@", compositionPath, exception);			
		[self release];
		return false;
		
	}
	
	//Update the texture immediately
	[self renderAtTime:0.0 arguments: nil];
	return true;
	
}

- (bool) initWithCompositionPath:	(NSString *)compositionPath	
				 inOpenGLContext: (NSOpenGLContext *)openGLContext
				 withPixelFormat: (NSOpenGLPixelFormat *)pixelFormat{
	
	//Create the QuartzComposer Renderer with that OpenGL context and the specified composition file
	@try {
		
		_renderer = [[[QCRenderer alloc] initWithOpenGLContext:	openGLContext
												   pixelFormat:	pixelFormat  
														  file:	compositionPath	] retain];
		NSLog (@"QCMaskRenderer created on CGLContext: %i", [openGLContext CGLContextObj]);
		
		if(_renderer == nil) {
			NSLog(@"Cannot create QCRenderer");
			[self release];
			return false;
		}
		// TODO: check if the loaded Quartz Composition patch
		// has #VideoInput and #VideoOutput ports!
		
	}
	@catch (NSException * exception) {
		
		// can't load Quartz Composition: release and return error!
		NSLog(@"Error running Quartz Composition '%s': %@", compositionPath, exception);			
		[self release];
		return false;
		
	}
	
	//Update the texture immediately
	[self renderAtTime:0.0 arguments: nil];
	return true;
	
}

+ (QCMaskRenderer *) createMaskWithCompositionPath: (NSString*)path	
							 usingRenderer: (OfflineRenderer *) renderer {
	
	if (![path length]) return nil;
	

	
	// 1. create generic renderer 
	/*QCMaskRenderer *newMaskRenderer = [[[QCMaskRenderer alloc] initWithOpenGLContext:	[renderer openGLContext]
																		 pixelsWide:	[renderer size].width
																		 pixelsHigh:	[renderer size].height
																		  depthSize:	8] autorelease];*/
	
	QCMaskRenderer *newMaskRenderer = [[[QCMaskRenderer alloc] initPixelsWide:	[renderer size].width
																   pixelsHigh:	[renderer size].height
																	depthSize:	8
																  pixelFormat: [renderer pixelFormat]
																openGLContext: [renderer openGLContext] ] autorelease];
	
	
	
	// 2. create actual Quartz Composer renderer	
	if (newMaskRenderer) {
		[newMaskRenderer initWithCompositionPath:	path	
								 inOpenGLContext: [renderer openGLContext]
								 withPixelFormat: [renderer pixelFormat]];
//		[newMaskRenderer initWithCompositionPath:	path];
	}
	return newMaskRenderer;
}

+ (QCMaskRenderer *) createFilterWithCompositionPath: (NSString*)path	
									 usingRenderer: (OfflineRenderer *) renderer {
	
	if (![path length]) return nil;
	
	
	
	// 1. create generic renderer 
	QCMaskRenderer *newMaskRenderer = [[[QCMaskRenderer alloc] initPixelsWide:	[renderer size].width
																   pixelsHigh:	[renderer size].height
																	depthSize:	24
																  pixelFormat: [renderer pixelFormat]
																openGLContext: [renderer openGLContext] ] autorelease];
	
	
	/*QCMaskRenderer *newMaskRenderer = [[[QCMaskRenderer alloc] initWithOpenGLContext:	[renderer openGLContext]
																		 pixelsWide:	[renderer size].width
																		 pixelsHigh:	[renderer size].height
																		  depthSize:	24
																		 pixelFormat: [renderer pixelFormat]] autorelease];*/
															// TODO: adeguare la depthSize a quella della sorgente
	
	// 2. create actual Quartz Composer renderer	

	if (newMaskRenderer) {
		NSAssert ([newMaskRenderer initWithCompositionPath:	path	
								 inOpenGLContext: [renderer openGLContext]
								 withPixelFormat: [renderer pixelFormat]], @"QCMaskrenderer: trouble while initializating!");
		//		[newMaskRenderer initWithCompositionPath:	path];
	}
	return newMaskRenderer;
}




- (void) dealloc {
	
	[super dealloc];
	
	//Destroy the renderer
	[_renderer release];
	
	
}

#pragma mark Accessors
- (QCRenderer *)renderer {
	return _renderer;
}

#pragma mark Quartz Composer methods

- (BOOL) renderAtTime:(NSTimeInterval)time arguments:(NSDictionary*)arguments	{
	CGLContextObj					cgl_ctx = [_openGLContext CGLContextObj];
	bool success = [_renderer renderAtTime:(NSTimeInterval)time arguments:(NSDictionary*)arguments];
	
	glFlushRenderAPPLE();
	
	GLenum error;
	if(error = glGetError())
		NSLog(@"%@: OpenGL error 0x%04X", error);
	
	return success;
}

- (BOOL) updateTextureForTime:(NSTimeInterval)time	{
	return [self renderAtTime: time arguments:nil];
}

- (id) createSnapshotImageOfType:(NSString*)type {
	return [[_renderer createSnapshotImageOfType: type] autorelease];
	
}

- (id) valueForOutputKey:(NSString*)key	{
	return [_renderer valueForOutputKey:key];
}

- (id) valueForOutputKey:(NSString*)key ofType:(NSString*)type {
	return [_renderer valueForOutputKey:key ofType: type];
}

- (BOOL) feedVideoInputWithOutputOfRenderer: (OfflineRenderer *)srcRenderer {

	bool success = false;
	
	if ([srcRenderer isKindOfClass: [QCMaskRenderer class]])
	{	success = [_renderer setValue: [(QCMaskRenderer*)srcRenderer valueForOutputKey: @"VideoOutput" ofType: @"QCImage"] forInputKey: @"VideoInput"];
	}
	else if ([srcRenderer isKindOfClass: [LiveInputRenderer	class]])	{
		// TODO: get the live input image and use it to feed the QCRenderer
		success = [self feedVideoInputWithCVPixelBuffer: [(LiveInputRenderer *)srcRenderer getCurrentFrame]];
		
	}
	return success;
	
}

- (BOOL) setValue: (id)value forInputKey:(NSString *)inputKey {
	
	return [_renderer setValue: value forInputKey: inputKey];
	
}

/*- (BOOL) updateTextureForTime:(NSTimeInterval)time
{
	//IMPORTANT: We use the macros provided by <OpenGL/CGLMacro.h> which provide better performances and allows us not to bother with making sure the current context is valid
	CGLContextObj					cgl_ctx = [_openGLContext CGLContextObj];
	BOOL							success;
	
	//Render a frame from the composition at the specified time in the pBuffer
	success = [_renderer renderAtTime:time arguments:nil];
	
	//IMPORTANT: Make sure all OpenGL rendering commands were sent to the pBuffer OpenGL context
	glFlush();
	
	//Update the texture in the target OpenGL context from the contents of the pBuffer
	// [super updateTextureOnTargetContext];
	
	// invalidate CPU memory pixel buffer
	// [super invalidateCPUMemPixelBuffer];
	
	return success;
}*/

-(bool) feedVideoInputWithCVPixelBuffer: (CVImageBufferRef) cvPixelBufferRef	{
	if (!cvPixelBufferRef) return false;

	bool success;

		success= [_renderer setValue: cvPixelBufferRef forInputKey: @"VideoInput"];

	return success;
}

@end
