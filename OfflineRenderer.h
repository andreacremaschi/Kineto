
#import <AppKit/AppKit.h>
#import <Quartz/Quartz.h>
#import <OpenGL/CGLMacro.h>




@interface OfflineRenderer : NSObject
{

	NSOpenGLContext*			_openGLContext;
	NSOpenGLPixelFormat *		_pixelFormat;

	// GPU memory buffer
	NSOpenGLPixelBuffer*		_pixelBuffer;
	
	// CPU memory buffer
	void*						_scratchBufferPtr;
	unsigned					_scratchBufferRowBytes;
	unsigned					_bytesPerPixel;
}

// Accessors
- (NSSize)				size;
- (NSOpenGLContext *)	openGLContext;
- (NSOpenGLPixelFormat *)		pixelFormat;
- (NSOpenGLPixelBuffer *)		pixelBuffer;

- (id) initWithPixelsWide:	(unsigned)width 
			   pixelsHigh:	(unsigned)height;

/*- (id) initWithOpenGLContext:	(NSOpenGLContext*)context
				  pixelsWide:	(unsigned)width 
				  pixelsHigh:	(unsigned)height
				   depthSize:	(GLint) depthSize;*/

/*- (id) initWithOpenGLContext:	(NSOpenGLContext*)sharedContext
				  pixelsWide:	(unsigned)width 
				  pixelsHigh:	(unsigned)height
				   depthSize:	(GLint) depthSize
				 pixelFormat: (NSOpenGLPixelFormat *)pixelFormat;*/

- (id) initPixelsWide:	(unsigned)width 
		   pixelsHigh:	(unsigned)height
			depthSize:	(GLint) depthSize
		  pixelFormat: (NSOpenGLPixelFormat *)pixelFormat
		openGLContext: (NSOpenGLContext*)openGLContext	;

- (id) initPixelsWide:	(unsigned)width 
		   pixelsHigh:	(unsigned)height
			depthSize:	(GLint) depthSize
		  pixelFormat: (NSOpenGLPixelFormat *)pixelFormat
		sharedContext: (NSOpenGLContext*)sharedContext;

- (NSBitmapImageRep*) bitmapImageForTime:(NSTimeInterval)time;

@end

