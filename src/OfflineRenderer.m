
#import "OfflineRenderer.h"





@implementation OfflineRenderer

- (id) init
{
	return [self initWithPixelsWide: 256 pixelsHigh:256];
}

/*
- (id) initWithPixelsWide:	(unsigned)width 
			   pixelsHigh:	(unsigned)height	{
	
	return [self initWithOpenGLContext:	nil
							pixelsWide:	width 
							pixelsHigh:	height
							 depthSize:	24	];
	
}
*/


- (id) initPixelsWide:	(unsigned)width 
		   pixelsHigh:	(unsigned)height
			depthSize:	(GLint) depthSize
		  pixelFormat: (NSOpenGLPixelFormat *)pixelFormat
		openGLContext: (NSOpenGLContext*)openGLContext
		sharedContext: (NSOpenGLContext*)sharedContext
{
	CGLContextObj					cgl_ctx = [sharedContext CGLContextObj];
	
	NSOpenGLPixelFormatAttribute	attributes[] = {
		NSOpenGLPFAPixelBuffer,
		NSOpenGLPFANoRecovery,
		NSOpenGLPFAAccelerated,
		NSOpenGLPFADepthSize, depthSize,
		(NSOpenGLPixelFormatAttribute) 0
	};
		
	//Check parameters - Rendering at sizes smaller than 16x16 will likely produce garbage
	if((width < 16) || (height < 16)) {
		[self release];
		return nil;
	}
	
	if(self = [super init]) {
		if (pixelFormat == nil)
			_pixelFormat = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] retain];
		else 
			_pixelFormat = [pixelFormat retain];

		// choose the correct pixel format
		GLenum intFormat;
		switch (depthSize)	{
			case 8: intFormat = GL_DEPTH_COMPONENT; _bytesPerPixel = 1; break;
			case 24: intFormat = GL_RGB; _bytesPerPixel = 3; break;
			default: intFormat = GL_RGBA; _bytesPerPixel = 4; break;
		}
			
		//Create the OpenGL pixel buffer to render into
		_pixelBuffer = [[NSOpenGLPixelBuffer alloc] initWithTextureTarget:GL_TEXTURE_RECTANGLE_EXT 
													textureInternalFormat:intFormat 
													textureMaxMipMapLevel:0 
															   pixelsWide:width 
															   pixelsHigh:height];
		if(_pixelBuffer == nil) {
			NSLog(@"Cannot create OpenGL pixel buffer");
			[self release];
			return nil;
		}
		
		//if not passed from outside,
		//create the OpenGL context to render with (with color and depth buffers)
		if (openGLContext == nil)	{
			_openGLContext = [[NSOpenGLContext alloc] initWithFormat: _pixelFormat 
														shareContext: sharedContext];
		} else {
			_openGLContext = [openGLContext retain];
		}

		
		if(_openGLContext == nil) {
			NSLog(@"Cannot create OpenGL context");
			[self release];
			return nil;
		}
		NSLog (@"OfflineRenderer to share '_sharedGLContext' CGLContext is: %i", [sharedContext CGLContextObj]);
		NSLog (@" ->  OfflineRenderer openGLContext to share '_openGLContext' created with CGLContext: %i", [_openGLContext CGLContextObj]);
		NSLog (@" ->  Pixelbuffer is: %i wide and %i tall", width, height);

		
		[_openGLContext setPixelBuffer: _pixelBuffer 
						   cubeMapFace: 0 
						   mipMapLevel: 0 
				  currentVirtualScreen: [sharedContext currentVirtualScreen] ];
		// TODO : controllare 'sta storia dei virtualscreen
	
		//Create a scratch buffer used to download the pixels from the OpenGL pixel buffer - For optimal performances the buffer is paged-aligned and the rowbytes is a multiple of 64 bytes
		_scratchBufferRowBytes = (width * _bytesPerPixel + 63) & ~63;
		_scratchBufferPtr = valloc(height * _scratchBufferRowBytes);
		if(_scratchBufferPtr == NULL) {
			[self release];
			return nil;
		}
				
	}

	return self;
		
}

- (id) initPixelsWide:	(unsigned)width 
		   pixelsHigh:	(unsigned)height
			depthSize:	(GLint) depthSize
		  pixelFormat: (NSOpenGLPixelFormat *)pixelFormat
		sharedContext: (NSOpenGLContext*)sharedContext	{
		
	return [self initPixelsWide:	width 
					 pixelsHigh:	height
					  depthSize:	depthSize
					pixelFormat: pixelFormat
				  openGLContext: nil
				  sharedContext: sharedContext];
}

- (id) initPixelsWide:	(unsigned)width 
		   pixelsHigh:	(unsigned)height
			depthSize:	(GLint) depthSize
		  pixelFormat: (NSOpenGLPixelFormat *)pixelFormat
		openGLContext: (NSOpenGLContext*)openGLContext	{
	
	return [self initPixelsWide:	width 
					 pixelsHigh:	height
					  depthSize:	depthSize
					pixelFormat: pixelFormat
				  openGLContext: openGLContext
				  sharedContext: nil];
}


- (void) dealloc 
{
	//Destroy the scratch buffer
	if(_scratchBufferPtr)
		free(_scratchBufferPtr);
	
	//Destroy the OpenGL context
	[_openGLContext clearDrawable];
	[_openGLContext release];
	
	//Destroy the OpenGL pixel buffer
	[_pixelBuffer release];
	
	//Destroy the OpenGL pixel buffer
	[_pixelFormat release];
	
	[super dealloc];
}

/*
- (id) initWithOpenGLContext:	(NSOpenGLContext*)sharedContext
				  pixelsWide:	(unsigned)width 
				  pixelsHigh:	(unsigned)height
				   depthSize:	(GLint) depthSize
				 pixelFormat: (NSOpenGLPixelFormat *)pixelFormat
{
	CGLContextObj					cgl_ctx = [sharedContext CGLContextObj];
	
	NSOpenGLPixelFormatAttribute	attributes[] = {
		NSOpenGLPFAPixelBuffer,
		NSOpenGLPFANoRecovery,
		NSOpenGLPFAAccelerated,
		NSOpenGLPFADepthSize, depthSize,
		(NSOpenGLPixelFormatAttribute) 0
	};
	
	//Check parameters - Rendering at sizes smaller than 16x16 will likely produce garbage
	if((width < 16) || (height < 16)) {
		[self release];
		return nil;
	}
	
	if(self = [super init]) {
		if (pixelFormat == nil)
			_pixelFormat = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] retain];
		else 
			_pixelFormat = [pixelFormat retain];
		
		// choose the correct pixel format
		GLenum intFormat;
		switch (depthSize)	{
			case 8: intFormat = GL_DEPTH_COMPONENT; _bytesPerPixel = 1; break;
			case 24: intFormat = GL_RGB; _bytesPerPixel = 3; break;
			default: intFormat = GL_RGBA; _bytesPerPixel = 4; break;
		}
		
		//Create the OpenGL pixel buffer to render into
		_pixelBuffer = [[NSOpenGLPixelBuffer alloc] initWithTextureTarget:GL_TEXTURE_RECTANGLE_EXT 
													textureInternalFormat:intFormat 
													textureMaxMipMapLevel:0 
															   pixelsWide:width 
															   pixelsHigh:height];
		if(_pixelBuffer == nil) {
			NSLog(@"Cannot create OpenGL pixel buffer");
			[self release];
			return nil;
		}
		
		
		//Create the OpenGL context to render with (with color and depth buffers)
		_openGLContext = [[NSOpenGLContext alloc] initWithFormat: _pixelFormat 
													shareContext: sharedContext];
		if(_openGLContext == nil) {
			NSLog(@"Cannot create OpenGL context");
			[self release];
			return nil;
		}
		NSLog (@"OfflineRenderer openGLContext to share '_openGLContext' created with CGLContext: %i", [_openGLContext CGLContextObj]);
		NSLog (@"OfflineRenderer to share '_sharedGLContext' CGLContext is: %i", [sharedContext CGLContextObj]);
		
		
		[_openGLContext setPixelBuffer: _pixelBuffer 
						   cubeMapFace: 0 
						   mipMapLevel: 0 
				  currentVirtualScreen: [sharedContext currentVirtualScreen] ];
		// TODO : controllare 'sta storia dei virtualscreen
		
		//Create a scratch buffer used to download the pixels from the OpenGL pixel buffer - For optimal performances the buffer is paged-aligned and the rowbytes is a multiple of 64 bytes
		_scratchBufferRowBytes = (width * _bytesPerPixel + 63) & ~63;
		_scratchBufferPtr = valloc(height * _scratchBufferRowBytes);
		if(_scratchBufferPtr == NULL) {
			[self release];
			return nil;
		}
		
	}
	
	return self;
	
}
*/

/*- (id) initPixelsWide:	(unsigned)width 
		   pixelsHigh:	(unsigned)height
			depthSize:	(GLint) depthSize	
		sharedContext:	(NSOpenGLContext*)sharedContext
{
return [self initPixelsWide: width
						pixelsHigh:  height
						 depthSize:depthSize
					   pixelFormat: nil
				sharedContext: sharedContext];
	
}*/

/*
- (id) initWithCompositionPath:(NSString*)path pixelsWide:(unsigned)width pixelsHigh:(unsigned)height
{
	NSOpenGLPixelFormatAttribute	attributes[] = {
														NSOpenGLPFAPixelBuffer,
														//NSOpenGLPFADoubleBuffer,
														NSOpenGLPFANoRecovery,
														NSOpenGLPFAAccelerated,
														NSOpenGLPFADepthSize, 24,
														(NSOpenGLPixelFormatAttribute) 0
													};
	
	//Check parameters - Rendering at sizes smaller than 16x16 will likely produce garbage
	if(![path length] || (width < 16) || (height < 16)) {
		[self release];
		return nil;
	}
		
	if(self = [super init]) {
		
		
		_pixelFormat = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] retain];

		//Create the OpenGL pixel buffer to render into
		_pixelBuffer = [[[NSOpenGLPixelBuffer alloc] initWithTextureTarget: GL_TEXTURE_RECTANGLE_EXT 
													textureInternalFormat: GL_RGBA 
													textureMaxMipMapLevel:0 
															   pixelsWide:width 
															   pixelsHigh:height] retain];
		if(_pixelBuffer == nil) {
			NSLog(@"Cannot create OpenGL pixel buffer");
			[self release];
			return nil;
		}
		
		//Create the OpenGL context to render with (with color and depth buffers)
		_openGLContext = [[NSOpenGLContext alloc] initWithFormat:_pixelFormat shareContext:nil];
		if(_openGLContext == nil) {
			NSLog(@"Cannot create OpenGL context");
			[self release];
			return nil;
		}
		
		[_openGLContext setPixelBuffer:_pixelBuffer 
						   cubeMapFace:0 
						   mipMapLevel:0 
				  currentVirtualScreen:[_openGLContext currentVirtualScreen]];
		
		//Create a scratch buffer used to downloads the pixels from the OpenGL pixel buffer - For optimal performances the buffer is paged-aligned and the rowbytes is a multiple of 64 bytes
		_scratchBufferRowBytes = (width * 4 + 63) & ~63;
		_scratchBufferPtr = valloc(height * _scratchBufferRowBytes);
		if(_scratchBufferPtr == NULL) {
			[self release];
			return nil;
		}
	}
	
	return self;
}
*/

#pragma mark  Accessors

- (NSSize)						size			{ return NSMakeSize([_pixelBuffer pixelsWide], [_pixelBuffer pixelsHigh]);	}
- (NSOpenGLContext *)			openGLContext	{ return _openGLContext; }
- (NSOpenGLPixelFormat *)		pixelFormat		{ return _pixelFormat;	}
- (NSOpenGLPixelBuffer *)		pixelBuffer		{ return _pixelBuffer;	}


#pragma mark Other methods


// TODO: generalizzare questo metodo per ogni profondità 

- (NSBitmapImageRep*) bitmapImageForTime:(NSTimeInterval)time
{
	//IMPORTANT: We use the macros provided by <OpenGL/CGLMacro.h> which provide better performances and allows us not to bother with making sure the current context is valid
	CGLContextObj					cgl_ctx = [_openGLContext CGLContextObj];
	int								width = [_pixelBuffer pixelsWide],
									height = [_pixelBuffer pixelsHigh],
									bitmapRowBytes = _bytesPerPixel * width;
	NSBitmapImageRep*				bitmap;
	GLint							save;
	int								i;
	
	//Read pixels back from the OpenGL pixel buffer in ARGB 32 bits format - For extra safety, we save / restore the OpenGL states we change 
	glGetIntegerv(GL_PACK_ROW_LENGTH, &save);
	glPixelStorei(GL_PACK_ROW_LENGTH, _scratchBufferRowBytes / _bytesPerPixel);
	glReadPixels(0, 0, width, height, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, _scratchBufferPtr);
	glPixelStorei(GL_PACK_ROW_LENGTH, save);
	if(glGetError())
	return nil;
	
	//User NSBitmapImageRep to allocate a memory buffer of ARGB 32 bits pixels - We use the "NSCalibratedRGBColorSpace" so that no color profile is embedded in the bitmap
	bitmap = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes: NULL 
													 pixelsWide: width 
													 pixelsHigh: height 
												  bitsPerSample: 8 
												samplesPerPixel: 4 
													   hasAlpha: YES 
													   isPlanar: NO 
												 colorSpaceName: NSCalibratedRGBColorSpace 
												   bitmapFormat: NSAlphaFirstBitmapFormat 
													bytesPerRow: bitmapRowBytes 
												   bitsPerPixel: 32];
	if(bitmap == nil)
	return nil;
	
	//Copy the pixels line by line from the scratch buffer to the bitmap and flip vertically - OpenGL downloaded images are upside-down
	for(i = 0; i < height; ++i)
		bcopy(_scratchBufferPtr + i * _scratchBufferRowBytes, (char*)[bitmap bitmapData] + (height - i - 1) * bitmapRowBytes, bitmapRowBytes);
	
	return [bitmap autorelease];
}



@end


/*
int main(int argc, const char* argv[])
{
	NSAutoreleasePool*			pool = [NSAutoreleasePool new];
	NSString*					compositionPath;
	NSString*					folderPath;
	OfflineRenderer*			renderer;
	NSBitmapImageRep*			bitmapImage;
	NSTimeInterval				time;
	NSData*						tiffData;
	NSString*					fileName;
	
	//Make sure we have the correct number of arguments
	if(argc == 3) {
		//Process the arguments
		compositionPath = [[NSString stringWithUTF8String:argv[1]] stringByExpandingTildeInPath];
		folderPath = [[NSString stringWithUTF8String:argv[2]] stringByExpandingTildeInPath];
		
		//Create an offline renderer
		renderer = [[OfflineRenderer alloc] initWithCompositionPath:compositionPath pixelsWide:640 pixelsHigh:480];
		if(renderer) {
			//Render a frame every second for 10 seconds and save the resulting images as LZW compressed TIFF files
			printf("Rendering composition \"%s\"...\n", [[compositionPath lastPathComponent] UTF8String]);
			for(time = 0.0; time <= 10.0; time += 1.0) {
				bitmapImage = [renderer bitmapImageForTime:time];
				if(bitmapImage) {
					tiffData = [bitmapImage TIFFRepresentationUsingCompression:NSTIFFCompressionLZW factor:1.0];
					fileName = [NSString stringWithFormat:@"%@-%g.tiff", [[compositionPath lastPathComponent] stringByDeletingPathExtension], time];
					if([tiffData writeToFile:[folderPath stringByAppendingPathComponent:fileName] atomically:YES])
					printf("\tRendered image \"%s\" at time %.3f\n", [fileName UTF8String], time);
					else
					NSLog(@"Image writing to disk failed (%s)", fileName);
				}
				else
				NSLog(@"Image rendering at time %f failed", time);
			}
			printf("...done!\n");
			[renderer release];
		}
		else
		NSLog(@"Offline renderer creation for composition failed (%@)", compositionPath);
	}
	else
	printf("Usage: %s sourceComposition destinationFolder\n", basename(argv[0]));
	
	[pool release];
	
	return 0;
}*/
