
#import "OfflineRenderer.h"
#import <QTKit/QTKit.h>
#import <QuickTime/QuickTime.h>

@class CameraController;
@class QTVisualContextKit;
@class OpenGLQuad;
@class OpenGLTexture;
@interface LiveInputRenderer : OfflineRenderer
{
	
	//keystone buffer context
	NSOpenGLContext* _keystoneOpenGLContext;
	
	// video device members
	CameraController *_cameraController;
	QTVisualContextKit       *_visualContext;
	
	bool _bNeedsToUpdateKeystone;

	CVBufferRef _currentFrame;
	
	OpenGLQuad * _quad;
	
}

+ (LiveInputRenderer *) createWithCameraController: (CameraController*)cameraController	
								 withOpenGLContext: (NSOpenGLContext *) openGLContext
								   withPixelFormat: (NSOpenGLPixelFormat *) pixelFormat;

- (CameraController *) cameraController;
- (void )releaseCameraController;

- (CVImageBufferRef ) getCurrentFrame;

- (void) task;


@end
