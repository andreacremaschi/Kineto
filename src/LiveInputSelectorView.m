//
//  LiveInputSelectorView.m
//  kineto
//
//  Created by Andrea Cremaschi on 28/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LiveInputSelectorView.h"
#import "LiveInputRenderer.h"
#import "CameraController.h"


@implementation LiveInputSelectorView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}


#pragma mark *** Accessors
- (void) setKeystoneEnabled: (bool) keystoneEnabled	{
	_keystoneEnabled = keystoneEnabled;
}


- (void) setFlipEnabled: (bool) flipEnabled	{
	_flipEnabled = flipEnabled;
}


#pragma mark *** Overrides of CameraControllerInQCMaskRendererView

- (NSString *) qcPatchName {
	
	return @"keystone";
	
}

- (void) prepareRenderingWithFrame: (id) currentFrame	{
	
	[[super renderer] setValue: [NSNumber numberWithBool: _keystoneEnabled] forInputKey: @"enable_keystone"];
	[[super renderer] setValue: [NSNumber numberWithBool: _flipEnabled] forInputKey: @"horizontal_flop"];
	
	[[super renderer] setValue: [NSNumber numberWithBool: [super isLeftButtonDown]] forInputKey: @"LeftButtonDown"];

	if ([super isLeftButtonDown])	{
		NSPoint curMousePos = [super curMousePos];
		[[super renderer] setValue: [NSNumber numberWithFloat: curMousePos.x] forInputKey: @"XPosition"];
		[[super renderer] setValue: [NSNumber numberWithFloat: curMousePos.y] forInputKey: @"YPosition"];
	}
	

	[super prepareRenderingWithFrame: currentFrame];
}

- (CameraController *) releaseCameraController	{
	
	double topLeftX, topLeftY;
	double topRightX, topRightY;
	double bottomLeftX, bottomLeftY;
	double bottomRightX, bottomRightY;
	
	// TODO modificare i valori direttamente nella maschera QC
	topLeftX = [[[super renderer] valueForOutputKey: @"tl_x"] floatValue];
	topLeftY = [[[super renderer] valueForOutputKey: @"tl_y"] floatValue];
	topRightX = [[[super renderer] valueForOutputKey: @"tr_x"] floatValue];
	topRightY = [[[super renderer] valueForOutputKey: @"tr_y"] floatValue];
	bottomLeftX = [[[super renderer] valueForOutputKey: @"bl_x"] floatValue];
	bottomLeftY = [[[super renderer] valueForOutputKey: @"bl_y"] floatValue];
	bottomRightX = [[[super renderer] valueForOutputKey: @"br_x"] floatValue];
	bottomRightY = [[[super renderer] valueForOutputKey: @"br_y"] floatValue];
	
	NSSize theSize = [[[super liveInput] cameraController] cameraSize];
	
	//setup keystone
	if (_keystoneEnabled)	{
		
		NSLog (@"Width: %.2f, Height: %.2f", theSize.width, theSize.height);
		NSLog (@"Top left: (%.2f, %.2f), (%.2f, %.2f)", topLeftX, topLeftY);
		NSLog (@"Top right: (%.2f, %.2f), (%.2f, %.2f)", topRightX, topRightY);
		NSLog (@"Bottom left: (%.2f, %.2f), (%.2f, %.2f)", bottomLeftX, bottomLeftY);
		NSLog (@"Bottom right: (%.2f, %.2f), (%.2f, %.2f)", bottomRightX, bottomRightY);
		
		[[[super liveInput] cameraController] setKeystone: _keystoneEnabled];
		[[[super liveInput] cameraController] setKeystoneCoordsTopLeftX:	topLeftX
											topLeftY: topLeftY
										   topRightX: topRightX
										   topRightY: topRightY
										 bottomLeftX: bottomLeftX
										 bottomLeftY: bottomLeftY
										bottomRightX: bottomRightX 
										bottomRightY: bottomRightY];
	}
	
	//flip image
	[[[super liveInput] cameraController] setFlipImage: _flipEnabled];
	
	return [super releaseCameraController];
}


- (void) hookToCameraController: (CameraController*)cameraController	{
	
	// store the keystone value and disable it: we don't want to see live input keystoned here!
	_keystoneEnabled = [ cameraController keystone];
	
	//...and we want to flip the image autonomosly so we don't have to reload liveinputcontroller 
	_flipEnabled= [ cameraController flipImage];
	
	[cameraController setKeystone: false];
	[cameraController setFlipImage: false];
	
	[super hookToCameraController: cameraController];

	
}
@end
