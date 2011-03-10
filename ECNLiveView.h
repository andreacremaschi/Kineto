//
//  ECNLiveView.h
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 21/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CameraControllerInQCMaskRendererView.h"

#define kMaskLiveInput 0
#define kMaskBackground 1
#define kMaskDiffMask 2
#define kMaskMotionMask 3

#define kMasksCount 4



typedef struct MaskLayerAttributes *MaskLayerAttributesRef;
extern NSString *BackgroundDidChangeNotification ;
extern NSString *MasksHasBeenUpdatedNotification ;


@interface ECNLiveView : CameraControllerInQCMaskRendererView {
	
	BOOL bCatturaProssimoSfondo;
	int _currentlyModifyingLayer;
	
	MaskLayerAttributesRef _kinetoLayersAttributes[5];
	NSImage * _imgBackground;

	//NSBitmapImageRep * _diffMask;
	//NSBitmapImageRep * _motionMask;
	
/*	CIImage *_CIdiffMask;
	CIImage *_CImotionMask;*/
	CIImage *_cimask;
	CIImage* _videoframe;
	
	float _dropFrameFactor, _dropFrameCounter, _minFPSDropThreshold;
	
	CIContext *_ciContext;
	
	unsigned char *data;
}

// Accessors
/*- (CIImage*)motionMask;
- (CIImage*)diffMask;*/
- (CIImage*)cimask;
- (	CIImage*)videoframe;

- (CIContext *)CIContext;

- (void) setFlipImage: (bool)flipImage;

- (void)setColor: (NSColor*)color forLayer: (int)nLayer;
- (NSColor*)layerColor: (int) nLayer;
- (void)setVisible: (bool)visible forLayer: (int)nLayer;
- (bool)layerVisible: (int)nLayer;
- (NSString *)layerName: (int)nLayer;

- (void) captureNextBackground;
- (NSImage *)backgroundImage;

- (void)prepareOpenGL;
- (void)bindTexture: (CVOpenGLTextureRef) texture;



@end
