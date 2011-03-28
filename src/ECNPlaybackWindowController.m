//
//  ECNPlaybackWindowController.m
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 05/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SynthesizeSingleton.h"
#import <OpenGL/CGLMacro.h>  

#import "ECNShape.h"

#import "ECNScene.h"
#import "ECNAction.h" // solo per notifica ECNActiveElementsSetIsChangedNotification
#import "ECNPlaybackWindowController.h"
#import "ECNElementActivityInspectorWindowController.h"
#import "ECNSceneWindowController.h"
#import "ECNProjectWindowController.h"
#import "ECNProjectDocument.h"
#import "ECNLiveViewerController.h"
#import "ECNOSCTarget.h"
#import "ECNOSCTargetAsset.h"
#import "ECNTrigger.h"
#import "DataViewerWindowController.h"

#import <VVOSC/OSCManager.h>


NSString *PlaybackNewFrameHasBeenProcessedNotification = @"PlaybackNewFrameHasBeenProcessed";

@interface ECNPlaybackWindowController (PrivateMethods)
- (void) startPlayback;
- (void) stop;
@end

@implementation ECNPlaybackWindowController

SYNTHESIZE_SINGLETON_FOR_CLASS(ECNPlaybackWindowController);


#pragma mark *** LiveViewer initialization ***

- (id)init {
	
	if (![self initWithWindowNibName: @"ECNPlaybackController"])
	{
		NSLog(@"Could not init ECNPlaybackController!");
		_mBMasksDidChange = true;
		[[self window] makeKeyAndOrderFront:nil];
		
		_mPlaybackState = kECNStop;
		_activeElementsSetShouldUpdate = false;
		_activeElementsSet = [[[NSMutableSet alloc] initWithCapacity: 0] retain];
	}
	
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

	//Stop and release the timer 
	[_playbackTimer invalidate];
	[_playbackTimer release];
	[_activeElementsSet release];
	[_onePixelBitmap release];
	[_onePixelContext release];
	[_areaAverageFilter release];
	[_startTime release];
    [super dealloc];
}

- (void)windowDidLoad {
	
	[super windowDidLoad];
	
	//We need to know when the rendering view frame changes so that we can update the OpenGL context
    [self setMainWindow:[NSApp mainWindow]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowChanged:) name:NSWindowDidBecomeMainNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowResigned:) name:NSWindowDidResignMainNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(masksDidChange:) name:MasksHasBeenUpdatedNotification object:[ECNLiveViewerController sharedECNLiveViewerController]];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeElementsSetDidChange:) name:ECNActiveElementsSetIsChangedNotification object:nil];
	
	//we need to know also what's up about playback
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackIsOver:) name:ECNPlaybackIsOverNotification object:nil];
	
	//setup the timer
	_playbackTimer = [[NSTimer timerWithTimeInterval:(1.0 / (NSTimeInterval)kPlaybackFPS) target:self selector:@selector(_playbackTick:) userInfo:nil repeats:YES] retain];
	[[NSRunLoop currentRunLoop] addTimer:_playbackTimer forMode:NSDefaultRunLoopMode];
	[[NSRunLoop currentRunLoop] addTimer:_playbackTimer forMode:NSModalPanelRunLoopMode];
	[[NSRunLoop currentRunLoop] addTimer:_playbackTimer forMode:NSEventTrackingRunLoopMode];
	
	// create an OSCManager- set myself up as its delegate
/*	_OSCManager = [[[OSCManager alloc] init] retain];
	[_OSCManager setDelegate:self];*/
	
	_mPlaybackState = kECNStop;
	[mPlaybackSelectorMatrix selectCellAtRow: 0 column: kECNStop];

	
	//one pixel bitmap used to calculate collisions in checkActivity...
	
	_onePixelBitmap = [[[NSBitmapImageRep alloc]
										  initWithBitmapDataPlanes: nil
										  pixelsWide: 1
										  pixelsHigh: 1 
										  bitsPerSample:8
										  samplesPerPixel:4
										  hasAlpha:YES 
										  isPlanar:NO 
										  colorSpaceName:NSCalibratedRGBColorSpace
										  bytesPerRow: 0
										  bitsPerPixel:32] retain];
	_onePixelContext = [[NSGraphicsContext
										   graphicsContextWithBitmapImageRep:_onePixelBitmap] retain];
	// setup the "CIAreaAverage" filter
	_areaAverageFilter   = [[CIFilter filterWithName: @"CIAreaAverage"] retain];
	
}

- (void)showOrHideWindow {
	
    NSWindow *window = [self window];
    if ([window isVisible]) {
		[window orderOut:self];
    } else {
		[self showWindow:self];
    }
}
#pragma mark *** Conveniences ***
- (NSSet *)activeElementsSet		{

	if (!_activeElementsSetShouldUpdate) 
		return _activeElementsSet;
	
	// TODO: cache this mutable set elements
	NSMutableSet *elementsSet;
	elementsSet = [NSMutableSet set];

	if (_mPlaybackState == kECNTestMode) 
	{	
		if (_curScene == nil)	{
			return nil;
		}
		[elementsSet  setSet: [_curScene visibleElements]];
	}
	else if ((_mPlaybackState == kECNPlayEntireDocument) || (_mPlaybackState == kECNPause))
	{	
		if (_curProjectDocument == nil) {
			return nil;
		}
		NSSet *activeScenes = [_curProjectDocument activeScenes];
		ECNScene *scene;
		
		for(scene in activeScenes)
			[elementsSet unionSet: [scene activeElements]];

	}		
	[_activeElementsSet release];
	_activeElementsSet= [elementsSet retain];
	return elementsSet;
	
}


#pragma mark *** Observing ***

- (void) toggleActivityInspectorScrollview: (id)sender	{

	if (!(sender && [sender isKindOfClass:[NSButton class]])) return;
	NSRect frame = [[self window] frame];
	int origHeight=frame.size.height;
	
	/*if ([(NSButton*)sender state] == NSOnState)	{
		frame.size.height= [_controlsBox frame].size.height+ [oScrollViewActivityInspector frame].size.height;	
	}
	else	{*/
		frame.size.height= [_controlsBox frame].size.height+20; //+ [oScrollViewActivityInspector frame].size.height
//		[[self window] setContentSize: NSMakeSize(frame.size.width, frame.size.height)];
	//}
	frame.origin.y += origHeight - frame.size.height;
	
	[[self window] setFrame: frame display: YES animate: YES];
}

- (void)activeElementsSetDidChange: (NSNotification *)notification	{
	
//	_elementsActivityInspectorShouldUpdate = true;
	_activeElementsSetShouldUpdate = true;

}

- (void)setMainWindow:(NSWindow *)mainWindow {
    NSWindowController *controller = [mainWindow windowController];
	
    if (controller && [controller isKindOfClass:[ECNProjectWindowController class]]) {
		_curProjectDocument = (ECNProjectDocument *)[controller document];		
		if ( _mPlaybackState == kECNTestMode ) 
			_activeElementsSetShouldUpdate = true;

	} else if (controller && [controller isKindOfClass:[ECNSceneWindowController class]]) {
        _curScene = [(ECNSceneWindowController *)controller scene];
		_curProjectDocument = (ECNProjectDocument *)[controller document];
		if ( _mPlaybackState == kECNTestMode ) 
			_activeElementsSetShouldUpdate = true;
    } else {
		// do nothing
		//     _curScene = nil; 
    }
}


- (void)mainWindowChanged:(NSNotification *)notification {
    [self setMainWindow:[notification object]];
}

- (void)mainWindowResigned:(NSNotification *)notification {
    [self setMainWindow:nil];
}

- (void) masksDidChange: (NSNotification *)notification {
	_mBMasksDidChange = true;
}

#pragma mark *** Document interface ***

- (void) openOSCPorts	{
	
	_OSCManager = [[[OSCManager	alloc] init] retain];
	[_OSCManager setDelegate:self];


	for (ECNOSCTargetAsset *OSCTarget in [_curProjectDocument objectsOfKind: [ECNOSCTargetAsset class]])
		 {
			 [OSCTarget openOutportOnManager: _OSCManager];

		 }
/*	ECNOSCTarget *oscTarget;
	for (oscTarget in [_curProjectDocument OSCtargets])	{
		if (![oscTarget openOutportOnManager: _OSCManager]) 
			NSLog(@"OSC Error: couldn't open OSC port %i on host %@", [oscTarget port], [oscTarget host]);
	}*/
		
}
- (void) closeOSCPorts	{
	
	
	for (ECNOSCTargetAsset *OSCTarget in [_curProjectDocument objectsOfKind: [ECNOSCTargetAsset class]])
	{
		[OSCTarget closeOutportOnManager: _OSCManager];
		
	}
	
	// just to be sure...
	[_OSCManager deleteAllOutputs];
	[_OSCManager release];
	_OSCManager = nil;
}

#pragma mark *** Playback logic ***


#pragma mark *** NIB interface ***

- (IBAction) changePlaybackState: (id)sender	{

	int selColumn = [mPlaybackSelectorMatrix selectedColumn];			
	if (selColumn == _mPlaybackState) return;
	
	switch (selColumn) {
			
			case  kECNPlayEntireDocument: 
				if ((_curProjectDocument != nil) && !(_mPlaybackState == kECNPause))
					[[DataViewerWindowController sharedDataViewerWindowController] startRendering];
					[self startPlayback];
				break;

			case  kECNPause:
				break;

			case  kECNStop:
				[[DataViewerWindowController sharedDataViewerWindowController] stopRendering];
				[self stop];
				break;

			case  kECNTestMode:
				[[DataViewerWindowController sharedDataViewerWindowController] startRendering];
				break;
	}
	_mPlaybackState = selColumn;				

	// update inspector list
	_activeElementsSetShouldUpdate = true;
//	[oScrollViewActivityInspector setElementsList: [self activeElementsSet]];	
	
}


#pragma mark *** Playback methods ***

- (void) startPlayback {
	if (_startTime) [_startTime release];
	_startTime = [[NSDate date] retain];
	
	[_curProjectDocument resetToInitialState];
	_activeElementsSetShouldUpdate = true;
	[self openOSCPorts];

	[mPlaybackSelectorMatrix selectCellAtRow: 0 column: kECNPlayEntireDocument];

}

- (void) stop	{
	[self closeOSCPorts];
	
	[mPlaybackSelectorMatrix selectCellAtRow: 0 column: kECNStop];
	
}

- (void) playbackIsOver {
	_mBMasksDidChange = true;
	[mPlaybackSelectorMatrix selectCellAtRow: 0 column: kECNStop];
	[self changePlaybackState: nil];
	//_mPlaybackState = kECNStop;
}

- (void)updateValuePortsOnElementsSet: (NSSet*)elementSet  
					   withVideoFrame: (CIImage *)videoframe
							 withMask: (CIImage *) cimask
							inContext:	(NSOpenGLContext *) openGLContext
{		
    ECNElement *curElement;
//	bool result;
	
	if (cimask == nil) return;
	
	// no need anymore to copy the masks in the cpu memory...
	//bitmapMask = [self bitmapForMask: cimask];	
	
/*	NSUInteger curPixel[4];


	[_areaAverageFilter setDefaults];
	[_areaAverageFilter setValue: cimask forKey:@"inputImage"];*/
	
//	ECNTrigger *curTrigger;
	NSTimeInterval time = [[NSDate date] timeIntervalSinceDate: _startTime];
	
	for (curElement in elementSet)
	{	
		[curElement setValue: cimask
				 forInputKey: ShapeInputMaskImage];

		[curElement setValue: videoframe
				 forInputKey: ShapeInputVideoFrameImage];

		[curElement executeAtTime: time];
		
		
	}
	
	
}


- (void)drawElementsSet: (NSSet *)elementSet
				 inContext:	(NSOpenGLContext *) openGLContext
{
    ECNElement *curElement;

	for (curElement in elementSet)
		[curElement drawInOpenGLContext: openGLContext];
	
	
}

- (void) commitActionsForTriggeredElementsInElementsSet: (NSSet *)elements	{

	NSMutableArray *actionsToCommit = [NSMutableArray arrayWithCapacity: 0];

	if (elements == nil) return;
	
	
	//gets a list of actions to commit
	for (ECNElement *curElement in elements)	
		for (ECNTrigger *curTrigger in [curElement triggers])
			if ([curTrigger shouldCommitActions])
				[actionsToCommit addObjectsFromArray: [curTrigger actionsToCommit]];

	//performs actions
	for (ECNAction *curAction in actionsToCommit)	{
		[curAction performAction];
		NSLog (@"%@", curAction);
	}
	
	
}

- (NSBitmapImageRep *) bitmapForMask: (CIImage *)CIImageMask	{
	
	
	
	// Create a new NSBitmapImageRep.
	NSBitmapImageRep *theBitMapToBeSaved = [[[NSBitmapImageRep alloc]
											 initWithBitmapDataPlanes: nil
											 pixelsWide:[CIImageMask extent].size.width
											 pixelsHigh:[CIImageMask extent].size.height 
											 bitsPerSample:8
											 samplesPerPixel:4
											 hasAlpha:YES 
											 isPlanar:NO 
											 colorSpaceName:NSCalibratedRGBColorSpace
											 bytesPerRow: 0
											 bitsPerPixel:32] autorelease];
	
	// Create an NSGraphicsContext that draws into the NSBitmapImageRep.
	//(This capability is new in Tiger.)
	NSGraphicsContext *nsContext = [NSGraphicsContext
									graphicsContextWithBitmapImageRep:theBitMapToBeSaved];
	
	// Save the previous graphics context and state, and make our bitmap
	// context current.
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext: nsContext];
	
	// Get a CIContext from the NSGraphicsContext, and use it to draw the
	// CIImage into the NSBitmapImageRep.
	CGPoint point = CGPointMake(0,0);
	CGRect rect = CGRectMake(0,0,[CIImageMask extent].size.width, [CIImageMask extent].size.height);
	[[nsContext CIContext] drawImage:CIImageMask
							 atPoint: point 
							fromRect:rect];
	
	// Restore the previous graphics context and state.
	[NSGraphicsContext restoreGraphicsState];
	
	return theBitMapToBeSaved;
}


- (void) _playbackTick: (NSTimer*)timer
{
	NSOpenGLContext *openGLContext;
	
	if (!((_mPlaybackState == kECNTestMode) || (_mPlaybackState == kECNPlayEntireDocument) || (_mPlaybackState == kECNPause))) return;
	if (!_mBMasksDidChange) return;
	
	openGLContext = [[ECNLiveViewerController sharedECNLiveViewerController] openGLContext];
	
	@synchronized (self) {
		
	// retrieve a list of active elements
	NSSet * elementsSet = [self activeElementsSet];
	if (elementsSet == nil) {	

		return;
	}

	// check activity on elements (both for test and playback mode but NOT if in pause)
	if (_mPlaybackState != kECNPause)
		[self updateValuePortsOnElementsSet: elementsSet
							 withVideoFrame: [[ECNLiveViewerController sharedECNLiveViewerController] videoframe]
								   withMask: [[ECNLiveViewerController sharedECNLiveViewerController] cimask]
								  inContext: openGLContext
		 ];
	
	// if in playback mode, commit actions!
	if (_mPlaybackState == kECNPlayEntireDocument)
	{	
		if (_curProjectDocument == nil) {	

			return;
		}
		
		NSSet *activeScenes = [_curProjectDocument activeScenes];
		ECNScene *scene;
		
		// commit actions
		[self commitActionsForTriggeredElementsInElementsSet: elementsSet];
		
		// check if some scene is empty:
		// it means that it should be deactivated
		for(scene in activeScenes)	
			if ([[scene activeElements] count] == 0) 
				[_curProjectDocument setSceneActivationState:scene active:false];
		
		// check if document is empty:
		// it means that playback is over
		if ([[_curProjectDocument activeScenes] count] == 0) 
			[self playbackIsOver];
		
	}
	
/*	if (_activeElementsSetShouldUpdate){ 
		[oScrollViewActivityInspector setElementsList: [self activeElementsSet]];	
		_activeElementsSetShouldUpdate = false;
	}

	[oScrollViewActivityInspector updateActivityInspectors];
*/	
	// post notification for data viewer	
	[[NSNotificationCenter defaultCenter] postNotificationName:PlaybackNewFrameHasBeenProcessedNotification object:self];

	}
	
	
	return;
	
}



- (void) drawPlaybackElements
{
	if (!((_mPlaybackState == kECNTestMode) || (_mPlaybackState == kECNPlayEntireDocument)|| (_mPlaybackState == kECNPause))) return;
	
	NSSet * elementsSet = [self activeElementsSet];
	if (elementsSet == nil) return;
	
	NSOpenGLContext *openGLContext;
	openGLContext = [[ECNLiveViewerController sharedECNLiveViewerController] openGLContext];
	
	[self drawElementsSet: elementsSet
				inContext: openGLContext];	
	
} // drawPlaybackElements

@end
