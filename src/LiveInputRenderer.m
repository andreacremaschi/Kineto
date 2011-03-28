
#import <OpenGL/CGLMacro.h>

#import "LiveInputRenderer.h"
#import "CameraController.h"
#import "QTVisualContextKit.h"
#import "OpenGLTexture.h"
#import "OpenGLQuad.h"

@implementation LiveInputRenderer


#pragma mark *** Init ***


/*
// Create or update the hardware accelerated offscreen area
// Framebuffer object aka. FBO
- (void)setFBO
{	
	
	// If not previously setup
	// generate IDs for FBO and its associated texture
	if (!FBOid)
	{
		// Make sure the framebuffer extenstion is supported
		const GLubyte* strExt;
		GLboolean isFBO;
		// Get the extenstion name string.
		// It is a space-delimited list of the OpenGL extenstions 
		// that are supported by the current renderer
		strExt = glGetString(GL_EXTENSIONS);
		isFBO = gluCheckExtension((const GLubyte*)"GL_EXT_framebuffer_object", strExt);
		if (!isFBO)
		{
			NSLog(@"Your system does not support framebuffer extension");
		}
		
		// create FBO object
		glGenFramebuffersEXT(1, &FBOid);
		// the texture
		glGenTextures(1, &FBOTextureId);
	}
	
	// Bind to FBO
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, FBOid);
	
	
	NSSize cameraSize = [_cameraController cameraSize];
	
	// Initialize FBO Texture
	glBindTexture(GL_TEXTURE_RECTANGLE_ARB, FBOTextureId);
	// Using GL_LINEAR because we want a linear sampling for this particular case
	// if your intention is to simply get the bitmap data out of Core Image
	// you might want to use a 1:1 rendering and GL_NEAREST
	glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	// the GPUs like the GL_BGRA / GL_UNSIGNED_INT_8_8_8_8_REV combination
	// others are also valid, but might incur a costly software translation.
	glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA, cameraSize.width, cameraSize.height, 0, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, NULL);
	
	// and attach texture to the FBO as its color destination
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_RECTANGLE_ARB, FBOTextureId, 0);
	
	// NOTE: for this particular case we don't need a depth buffer when drawing to the FBO, 
	// if you do need it, make sure you add the depth size in the pixel format, and
	// you might want to do something along the lines of:
#if 0
	// Initialize Depth Render Buffer
	GLuint depth_rb;
	glGenRenderbuffersEXT(1, &depth_rb);
	glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, depth_rb);
	glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, GL_DEPTH_COMPONENT, cameraSize.width, cameraSize.height);
	// and attach it to the FBO
	glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, depth_rb);
#endif	
	
	// Make sure the FBO was created succesfully.
	if (GL_FRAMEBUFFER_COMPLETE_EXT != glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT))
	{
		NSLog(@"Framebuffer Object creation or update failed!");
	}
	
	// unbind FBO 
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
}
*/


- (bool) initWithCameraController:(CameraController*) cameraController
				//CompositionPath:(NSString*)path 
				// textureTarget:(GLenum)target 
				//  textureWidth:(unsigned)width 
				// textureHeight:(unsigned)height 
				
{

	_bNeedsToUpdateKeystone =true;
	
	
	if (self) {
		
		//1. Create the OpenGL context shared with the one created in superclass,
		//	so that: [super openGLContext] is the one that will be used to create the QTVisualContext and retrieve new camera controller frames,
		// and _keystoneOpenGLContext will be used to draw the keystone corrected frame
		_keystoneOpenGLContext = [[[NSOpenGLContext alloc] initWithFormat: [super pixelFormat] 
																  shareContext: [super openGLContext]] retain]; 
		
		if(_keystoneOpenGLContext == nil) {
			NSLog(@"Cannot create OpenGL context"); 
			[NSApp terminate:nil]; 
		}
		
		// 2. attacco lo stream del cameracontroller a [super openGLContext]
		// NB è un tentativo a braccio costruito sulla base del post di vade: http://lists.apple.com/archives/quartz-dev/2009/Aug/msg00030.html
		// e dell'esempio QTCoreVideo101
		
		_visualContext = [[[QTVisualContextKit alloc] initQTVisualContextWithSize:		[cameraController cameraSize]
																			 type:		kQTOpenGLTextureContext
																		  context:		[super openGLContext]
																	  pixelFormat:		[super pixelFormat]
						   ] retain];
	
		
		if (_visualContext == nil)	{
			NSLog(@"ERRORE GRAVE! NON SON RIUSCITO A CREARE VISUAL CONTEXT!");
			[self release];
			return false;
			// TODO manage this!
		} else		
			NSLog (@"QT Visual Context created on CGLContext: %i with size: %.f x %.f", [[super openGLContext] CGLContextObj], [cameraController cameraSize].width, [cameraController cameraSize].height);

		
		// Set the created visual context &for each connection of the camera controller
		[cameraController setVisualContext: [_visualContext context]];
	
		
		// 3. create a quad used to draw the keystone corrected frame
		NSSize theSize = [cameraController cameraSize];
		if (_quad != nil) [_quad release];

		//_quad = [[OpenGLQuad quadWithSize:&theSize range:1] retain];


		//identity quad
		NSPoint topLeft		= NSMakePoint( 0,0);
		NSPoint topRight	= NSMakePoint( theSize.width,0.0f);
		NSPoint bottomRight	= NSMakePoint( theSize.width,theSize.height);
		NSPoint bottomLeft	= NSMakePoint( 0.0f,theSize.height);

		NSLog(@"Identity quad - topleft: %.f, %.f - topRight: %.f, %.f - bottomRight: %.f, %.f - bottomLeft: %.f, %.f", topLeft.x, topLeft.y,  topRight.x, topRight.y,  bottomRight.x, bottomRight.y,  bottomLeft.x, bottomLeft.y);
		//keystone
		if ([cameraController keystone]) {
			topLeft = [cameraController topLeft];
			topRight = [cameraController topRight];
			bottomRight =[cameraController bottomRight] ;
			bottomLeft = [cameraController bottomLeft];
			NSLog(@"Keystone applied - topleft: %.f, %.f - topRight: %.f, %.f - bottomRight: %.f, %.f - bottomLeft: %.f, %.f", topLeft.x, topLeft.y,  topRight.x, topRight.y,  bottomRight.x, bottomRight.y,  bottomLeft.x, bottomLeft.y);
		}
		
		//flipimage
		if ([cameraController flipImage]) {
			int width = theSize.width;
			topLeft.x = width - topLeft.x;
			topRight.x = width - topRight.x;
			bottomLeft.x = width - bottomLeft.x;
			bottomRight.x = width - bottomRight.x;
			NSLog(@"FlipImage applied - topleft: %.f, %.f - topRight: %.f, %.f - bottomRight: %.f, %.f - bottomLeft: %.f, %.f", topLeft.x, topLeft.y,  topRight.x, topRight.y,  bottomRight.x, bottomRight.y,  bottomLeft.x, bottomLeft.y);
			
		}
		
		_quad = [[OpenGLQuad keyStoneQuadWithSize: &theSize
										  TopLeft: topLeft
										 TopRight: topRight
									  BottomRight: bottomRight 
									   BottomLeft: bottomLeft
											range: 1] retain];
		
		
		// 4. start observing the camera controller for new frames
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_newFrameReceived:) name:CCReceivedNewFrameNotification object:cameraController];
		[cameraController delegateForVideoOutput: self];
		
		_cameraController = [cameraController retain];

	}
	

	return true;		
}


+ (LiveInputRenderer *) createWithCameraController: (CameraController*)cameraController	
							 withOpenGLContext: (NSOpenGLContext *) openGLContext 
								withPixelFormat: (NSOpenGLPixelFormat *) pixelFormat{
	

	// assume that cameraController is already initialized!
	if (!cameraController) return nil;
	
	// 1. create generic renderer 
	LiveInputRenderer *newLiveInputRenderer = [[[LiveInputRenderer alloc] initPixelsWide:	[cameraController cameraSize].width 
																			  pixelsHigh:	[cameraController cameraSize].height
																			   depthSize:	24
																			 pixelFormat: pixelFormat
																		   sharedContext: openGLContext] autorelease];
	// 2. create actual Live input renderer
	if (newLiveInputRenderer) {
		NSAssert ([newLiveInputRenderer initWithCameraController:	cameraController], @"LiveinputRenderer.m: troubles while initializing LiveInputRenderer!");
	}
	
	
	return newLiveInputRenderer;
}


#pragma mark *** Keystone management


#pragma mark *** Camera controller management ***


- (CVImageBufferRef ) getCurrentFrame	{
		
		return _currentFrame;
}


- (void) task	{
	[_visualContext task];
	
}


#pragma mark *** Accessors ***

- (CameraController *) cameraController	{
	return _cameraController;
}


- (void)releaseCameraController {
	
	if (_visualContext != nil) 
	{
		NSLog(@"LiveInputRenderer with CGLContextObj: %i releasing cameracontroller.", [[self openGLContext] CGLContextObj]);
		@synchronized (self)	{
		[_cameraController setVisualContext: nil];
		[_visualContext release];
		_visualContext = nil;
		[_cameraController delegateForVideoOutput: _cameraController];
		}
	}
	
	return;
	
}


#pragma mark *** Observing ***


// Dalla TN 2143:
// OpenGL rendering: create a CVOpenGLBufferRef with CVOpenGLBufferCreate(), 
// attach it to an OpenGL context with CVOpenGLBufferAttach(), 
// perform some OpenGL rendering in that context, 
// then call glFlush() to terminate rendering, 
// and eventually pass the CVOpenGLBufferRef to the appropriate composition's Image input and release it
// (see Core Video Reference for more information on the CVOpenGLBufferRef API).

// IMPORTANT: Do not wrap CGImageRefs, CVImageBuffers, raw pixels data or OpenGL textures 
// into CIImages to pass them to Quartz Composer as this will lead to a performance hit.

- (CVOpenGLBufferRef) drawKeystonedFrame: (CVOpenGLBufferRef)  frame {
	
    CGLContextObj cgl_ctx = [_keystoneOpenGLContext CGLContextObj];
	GLint			saveTextureName;
	CVOpenGLBufferRef CVframeBuffer;
	
	
	//CVOpenGLBufferRelease(CVframeBuffer);

	NSOpenGLContext *current = [NSOpenGLContext currentContext];
	[_keystoneOpenGLContext makeCurrentContext];
	
	
	CVReturn returnVal = CVOpenGLBufferCreate( 0,
											  [super size].width, [super size].height,	// Whatever dimensions you require 
											  0, &CVframeBuffer
											  ); 
	if(returnVal != kCVReturnSuccess) { 
		NSLog(@"Cannot create CV context"); 
		return nil ;
	}	
		
	
	NSAssert ( CVOpenGLBufferAttach(CVframeBuffer, 
									[_keystoneOpenGLContext CGLContextObj], 
									0, 
									0,
									0) == kCVReturnSuccess, @"Error attaching CoreVideo OpenGLBuffer"); 

	// In case the buffers have changed in size, reset the viewport.
	CGRect cleanRect = CVImageBufferGetCleanRect(frame);
	glViewport(CGRectGetMinX(cleanRect), CGRectGetMinY(cleanRect), CGRectGetWidth(cleanRect), CGRectGetHeight(cleanRect));
        
	// clear
	glClearColor(1.0, 0.0, 0.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT);
	
	GLenum target = CVOpenGLTextureGetTarget( frame );
	
	// get the texture target name
	GLint name = CVOpenGLTextureGetName( frame );
	
	//Save the currently bound texture
	glGetIntegerv((target == GL_TEXTURE_RECTANGLE_EXT ? GL_TEXTURE_BINDING_RECTANGLE_EXT : GL_TEXTURE_BINDING_2D), &saveTextureName);
	
	glEnable(target);
	
	// bind to the CoreVideo texture
	glBindTexture( target, name );
	
	glMatrixMode(GL_TEXTURE);
    glLoadIdentity();
    glColor4f(1.0, 1.0, 1.0, 1.0);
    
	
	//Draw textured quad
	[_quad draw];		// NB le coordinate della quad sono in pixel, 
	// come anche le coordinate delle maschere  perché
	// inizializzate come GL_TEXTURE_RECTANGLE_EXT. 
	// Se fossero state inizializzate come GL_TEXTURE_2D le coord sarebbero espresse in 0-1
	
	//[self disable];
	glDisable(target);
	
	
	glBindTexture( target, saveTextureName );

		/*
		glBegin(GL_LINES);
		 glVertex2f(-1.0f, -1.0f); // origin of the line
		 glVertex2f(1.0f, 1.0f); // ending point of the line
		 glEnd( );
		
		glBegin(GL_LINES);
		glVertex2f(-1.0f, 1.0f); // origin of the line
		glVertex2f(1.0f, -1.0f); // ending point of the line
		glEnd( );
		*/
		
	glFlush();


	//	CGLError error = CGLClearDrawable(cgl_ctx);
	// NSAssert(error == kCGLNoError, @"whoops");

		[current makeCurrentContext];
	
	return CVframeBuffer;
		
	
}


//- (void) _newFrameReceived:(NSNotification*)notification	{
	- (void)captureOutput:(QTCaptureOutput *)captureOutput
didOutputVideoFrame:(CVImageBufferRef)videoFrame
withSampleBuffer:(QTSampleBuffer *)sampleBuffer
fromConnection:(QTCaptureConnection *)connection
	{	
	_bNeedsToUpdateKeystone = true;
		
	// There is no autorelease pool when this method is called because it will
	// be called from another thread it's important to create one or you will 
	// leak objects
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	CVImageBufferRef oldFrame = nil;
	CVImageBufferRef newFrame = nil;	
	
	// Check for new frame
	@synchronized (self) {	
		
		oldFrame = _currentFrame;
		
		if ((_visualContext!= nil) && ( [_visualContext isValidVisualContext] )) {
			if ([_visualContext isNewImageAvailable: NULL])		{
				newFrame = [_visualContext copyImageForTime:NULL];
				if ([_cameraController keystone] || [_cameraController flipImage] ) {
				
					_currentFrame = [self drawKeystonedFrame: newFrame ];
					CVBufferRelease(newFrame);
					
				} else {
					_currentFrame = newFrame;
				}
			}
			else { 
				[pool release]; 
				return;
			}
		}

		if (oldFrame!=nil)	{
			CVBufferRelease(oldFrame);
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName:CCReceivedNewFrameNotification object:self];
		[pool release];
		//	NSLog(@"new frame! CVBufferRef: %i", _currentFrame);
	}
	return;
}


#pragma mark *** dealloc ***

- (void) dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];	

	if (_cameraController) [self releaseCameraController];
	
	//Destroy the CV buffer 
	CVOpenGLBufferRelease(_currentFrame);

	//Destroy the secondary OpenGL context 
	[_keystoneOpenGLContext clearDrawable]; 
	[_keystoneOpenGLContext release];

	// destroy the quad
	if (_quad != nil) [_quad release];
	
	[super dealloc];
}

@end
