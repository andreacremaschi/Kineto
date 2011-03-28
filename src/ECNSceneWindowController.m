//
//  ECNSceneWindowController.m
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 21/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ECNSceneWindowController.h"
#import "ElementsView.h"

// singleton palettes
#import "ECNDrawingToolbar.h"
#import "ECNLiveViewerController.h"
#import "ECNPlaybackWindowController.h"
#import "ShapeSettingsPanel.h"
#import "OSCTxAssetInstanceSettingsPanel.h"

#import "DataViewerWindowController.h"
#import "ECNProjectWindowController.h"

// model classes
#import "ECNScene.h"
#import "ECNElements.h"
#import "ECNProjectDocument.h"

#import "ECNAsset.h"
#import "ECNQCAssetInstance.h"
#import "ECNOSCTxAssetInstance.h"
#import "ECNOSCTargetAsset.h"

@interface ECNSceneWindowController (PrivateMethods)
- (void) setScene: (ECNScene *)scene;
- (void)selectedToolDidChange:(NSNotification *)notification;
@end

@implementation ECNSceneWindowController


- (id)init {
	_aspectRatio = 1.33; // rapporto di default;
	_scene = nil;
	
    self = [super initWithWindowNibName:@"ECNSceneWindow"];
    return self;
}

- (void)dealloc {
	
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[_scene release];
	
    [super dealloc];
}


/*
 // Questo è un altro modo di ricevere una notifica quando cambia la selezione sulla tabella
 
 
-(void) awakeFromNib	{
	[oElementsListArrayController addObserver: self
					 forKeyPath: @"selectionIndexes"
						options: NSKeyValueObservingOptionNew
						context: NULL];
}

#pragma mark *** Data binding ***

- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context
{
	NSLog(@"Table section changed: keyPath = %@, %@", keyPath, [object selectionIndexes]);
}*/



#pragma mark Constructor 

- (void) setScene: (ECNScene *)scene	{
	
	_scene	= [scene retain];	
	[oElementsListArrayController setContent: [_scene elements]];	
	// tell elementsview to refresh
	[elementsView setNeedsDisplay: true];
	
	// observe scene for modification
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sceneDidChange:) name:ECNSceneDidChangeNotification object:scene];
	[[NSNotificationCenter defaultCenter] postNotificationName: ECNSceneDidChangeNotification object:self];
	
}

+ (ECNSceneWindowController *)windowWithScene: (ECNScene *)scene {
		
	ECNSceneWindowController *windowController = [[[ECNSceneWindowController alloc] init] autorelease];
	[windowController window];
	
	// retain scene reference and bind elementslist arraycontroller
	[windowController setScene: scene];	
	[[scene document] addWindowController: windowController];
	
	[windowController showWindow: nil];
	
	return windowController;
	
}

#pragma mark Accessors


- (ECNScene *)scene {
	return _scene;
}

- (NSArray *)sceneObjects	{
	return [_scene elements];
}

- (NSArray *)selectedElements	{
	return [oElementsListArrayController selectedObjects];
}

- (ECNProjectDocument *)projectDocument {
	return (ECNProjectDocument*)[self document];
}

#pragma mark *** Initialization ***

- (void)setUpElementsView {
    [elementsView setNeedsDisplay:YES];
	//[_scene setViewBounds: [elementsView bounds]];
	[elementsView useBackground: (bool)(oBGCheckbox.state == NSOnState)];
	[elementsView setBackground: [[ECNLiveViewerController sharedECNLiveViewerController] getBackground]];
	
}

#pragma mark *** Other methods ***

- (void)setAspectRatio: (float) aspectRatio {
	
	
	//	int theWidth = [[self window] frame].size.width;
	//int theHeight  = [[self window] frame].size.height;
	
	_aspectRatio = aspectRatio > 0 ? aspectRatio : 1.66;
	
	//[self windowWillResize: [self window] toSize: [[self window] frame]];
	
	/*	[[self window] setFrame: [[self window] frame] display: YES];
	 [[self window] setContentSize: NSMakeSize(theWidth , theWidth / aspectRatio + 15)];*/
}


- (void)invalidateScene:(ECNScene *)scene {
	[self willChangeValueForKey:@"sceneObjects"];

	[elementsView setNeedsDisplay: YES];
	[self didChangeValueForKey:@"sceneObjects"];

	//    [elementsView invalidateElement:element];
}

- (void)invalidateElement:(ECNElement *)element {
	[elementsView invalidateElement:element];
}



- (IBAction) bgCheckbox: (id)sender	{
	[elementsView useBackground: (bool)(oBGCheckbox.state == NSOnState)];
	[elementsView setNeedsDisplay: true];
}



/*- (IBAction)switchAspectRatio: (id) sender {
 float aspectRatio = [mAspectRatio intValue] == 1.0 ? 1.77 : 1.33;
 
 
 [self setAspectRatio: aspectRatio];
 }*/

#pragma mark -
#pragma mark *** delegate of NSWindow ***
/*
-(NSSize)windowWillResize:(NSWindow *)sender
				   toSize:(NSSize)framesize;
{
	framesize.height = (framesize.width - [elementsListView bounds].size.width) / _aspectRatio + [[self window] frame].size.height - [elementsView bounds].size.height;
	
	//NSLog(@"framesize is %f wide and %f tall", framesize.width, framesize.height);
	return framesize;
}


- (void)windowDidResize:(NSNotification *)notification;
{	
	// ridisegna la scena con le nuove dimensioni
	//[_scene setViewBounds: NSMakeRect(0.0, 0.0, [elementsView bounds].size.width, [elementsView bounds].size.height)];
	[elementsView setNeedsDisplay:YES];
}*/

- (void) windowDidLoad {
	// NSScrollView *enclosingScrollView;
	
	
	// Do the regular Cocoa thing.
    [super windowDidLoad];
	
	[self setAspectRatio: [[ECNLiveViewerController sharedECNLiveViewerController] getRenderAspectRatio] ];
	
	[self setUpElementsView];
	
	//[self showWindow: self];
	
	[[self window] makeFirstResponder: elementsView];
	
	// Be the data source... 
  //  [elementsListView setDataSource:self];
	
	// On double click open the element inspector
	[elementsListView setDoubleAction: @selector(doubleClickOnElementsList:)];

	// Start observing the tool palette.
	[self selectedToolDidChange:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedToolDidChange:) name:ECNSelectedToolDidChangeNotification object:[ECNDrawingToolbarController sharedECNDrawingToolbarController]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundDidChange:) name:ECNBackgroundDidChangeNotification object:[ECNLiveViewerController sharedECNLiveViewerController]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionChangedInElementsView:) name:ElementsViewSelectionDidChangeNotification object:elementsView];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(elementChanged:) name:ECNElementDidChangeNotification object:elementsView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doubleClickOnElementsList:) name:ElementsViewDoubleClicOnElementNotification object:elementsView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionChangedInTableView:) name:NSTableViewSelectionDidChangeNotification object:elementsListView];
	
	
}

#pragma mark KVC/KVO
- (void) refreshTableView	{
	[oElementsListArrayController setContent: [_scene elements]];	
	
	// tell elementsview to refresh
	[elementsView setNeedsDisplay: true];
}

#pragma mark *** Observing ***


- (void)doubleClickOnElementsList:(NSNotification *)notification {
/*	[[NSNotificationCenter defaultCenter] postNotificationName: ElementsViewNewElementToEditNotification object:self];
	[oSelectedElementPropertyKeys setContent: [self selectedObjectPropertyKeys]];
*/
//	[oSelectedElementPropertyKeys setContent: [self selectedObjectPropertyKeys]];
	[[DataViewerWindowController sharedDataViewerWindowController] setElementToObserve: [self selectedObject]];
	[[DataViewerWindowController sharedDataViewerWindowController] showWindow: self];
}



- (void)selectedToolDidChange:(NSNotification *)notification {
    // Just set the correct cursor
    Class theClass = [[ECNDrawingToolbarController sharedECNDrawingToolbarController] currentElementClass];
    NSCursor *theCursor = nil;
    if (theClass) {
        theCursor = [theClass creationCursor];
    }
    if (!theCursor) {
        theCursor = [NSCursor arrowCursor];
    }
   [[elementsView enclosingScrollView] setDocumentCursor:theCursor];
}

- (void)backgroundDidChange:(NSNotification *)notification {
	[elementsView setBackground: [[ECNLiveViewerController sharedECNLiveViewerController] getBackground]];
	[elementsView setNeedsDisplay: true];

}

- (void)elementChanged:(NSNotification *)notification {
	//if ([[elementsView	selectedElements] containsObject:[notification object]]){
//		needsUpdate = YES;
	[elementsListView reloadData];
	
	
	//}

}

- (void)sceneDidChange:(NSNotification *)notification {
	[[self window] setTitle: [_scene name]];
	[elementsView setNeedsDisplay: true];
}

- (void)selectionChangedInElementsView:(NSNotification *)notification {
	//if ([[elementsView	selectedElements] containsObject:[notification object]]){
//		needsUpdate = YES;
	//int i;
	
	if (_bTableviewSelectionIsUpdating) return;
	_bTableviewSelectionIsUpdating = true;
	
	
	// in case elements list has changed.. this is not the best way to do this, but it works..
	[oElementsListArrayController setContent: [self sceneObjects]];
	[oElementsListArrayController removeSelectedObjects: [self sceneObjects]];
	[oElementsListArrayController addSelectedObjects: [elementsView selectedElements]];

	_bTableviewSelectionIsUpdating = false;
	
    //}
}

- (void)selectionChangedInTableView:(NSNotification *)notification {
	
	if (_bTableviewSelectionIsUpdating) return;
	_bTableviewSelectionIsUpdating = true;
	
	//NSUInteger index=[[elementsListView selectedRowIndexes] firstIndex];
	
	[elementsView clearSelection];
	for (ECNObject * element in [oElementsListArrayController selectedObjects])
		[elementsView selectElement: (ECNElement *)element];
	
/*	while(index != NSNotFound)
	{
		[elementsView selectElement: [[_scene elements] objectAtIndex: index ]];
		index = [[elementsListView selectedRowIndexes] indexGreaterThanIndex: index];
	}*/
	[(ECNProjectDocument *)[self document] invalidateScene: _scene];
	_bTableviewSelectionIsUpdating = false;
	return;
}

#pragma mark *** Drag and drop
/*
- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info
			  row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
    NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:MyPrivateTableViewDataType];
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    NSInteger dragRow = [rowIndexes firstIndex];
	
    // Move the specified row to its new location...
}

*/
#pragma mark *** Menu messages

- (IBAction) editElementSettings: (id)sender	{
	if ([self selectedObject] == nil) return;
	
	
	//shapes panel
	if ([[self selectedObject] isKindOfClass: [ECNShape class]])	{
	
		ShapeSettingsPanel * panel = [ShapeSettingsPanel settingsPanelWithElement: [self selectedObject]] ;
		if ([panel runModal] == NSOKButton)	{
			
			
		}

	//osc tx instance panel
	} else if ([[self selectedObject] isKindOfClass: [ECNOSCTxAssetInstance class]])	{
		OSCTxAssetInstanceSettingsPanel * panel = [OSCTxAssetInstanceSettingsPanel settingsPanelWithElement: (ECNOSCTxAssetInstance *)[self selectedObject]] ;
		if ([panel runModal] == NSOKButton)	{
		}		
	}
	
	
	
	
	
	
}

- (IBAction) createNewElement: (id)sender	{
	
	id theClass=nil;
	
	if (![sender isKindOfClass: [NSMenuItem class]]) return;
	if ([[sender title] isEqual:  @"Plane"]) {
		theClass = [ECNLine class];
		[elementsView createElementOfClass: theClass withEvent:nil];
	}
	else if ([[sender title] isEqual: @"Field"]) {
		theClass = [ECNRectangle class];
		[elementsView createElementOfClass: theClass withEvent:nil];
	}
	else if ([[sender title] isEqual:  @"OSC sender"]) {

		// get default OSC target
		NSArray *OSCTargets = [[self projectDocument] objectsOfKind: [ECNOSCTargetAsset class]];
		ECNOSCTargetAsset *defaultOSCTarget = [OSCTargets count] > 0 ? [OSCTargets objectAtIndex: 0] : nil;
		
		if (!defaultOSCTarget)	{
				// create a default OSC target
				defaultOSCTarget = [ECNOSCTargetAsset assetWithDocument: [self projectDocument]
														withOSCTargetIP: @"127.0.0.1"
													  withOSCTargetPort: [NSNumber numberWithInt: 5000]
									];
		}
			
		//create new OSC target
		ECNOSCTxAssetInstance *newOSCTxAssetInstance = (ECNOSCTxAssetInstance *)[ECNOSCTxAssetInstance assetInstanceWithAsset: defaultOSCTarget];
		[newOSCTxAssetInstance setScene:  _scene];
			  
		// open OSC target modification panel
		OSCTxAssetInstanceSettingsPanel * panel = [OSCTxAssetInstanceSettingsPanel settingsPanelWithElement: newOSCTxAssetInstance] ;
		if ([panel runModal] == NSOKButton)	{
			[_scene insertElement: newOSCTxAssetInstance atIndex:0];
			[elementsView selectElement: newOSCTxAssetInstance];
			[elementsView invalidateElement: newOSCTxAssetInstance];
		};
	}
	/*else if ([[sender title] isEqual:  @"Timer"]) 
		theClass = [ECNTimer class];*/
/*	else if ([[sender title] isEqual:  @"OSC Sender"]) 
		theClass = [ECNOSCTxAssetInstance class];
	else if ([[sender title] isEqual:  @"OSC Receiver"]) 
		theClass = [ECNOSCReceiver class];*/
	if (theClass == nil) return;
	
}

- (IBAction) addAssetToScene: (id)sender	{

	//get the active document
	ECNProjectDocument *document = [_scene document];
	
	id controller;
	
	//search for the main window controller
	for (controller in [document windowControllers])
		if ([controller isKindOfClass: [ECNProjectWindowController class]])
			 break;
	if (controller == nil) return;
			 

	//ask the main window controller for selected asset
	NSArray *selectedAssets = [(ECNProjectWindowController *)controller selectedAssets];
	if (selectedAssets == nil) return;
	
	// add instances of selected assets in scene
	for (ECNAsset *asset in selectedAssets)	{
		Class assetClass = [[asset class] instanceClass];
		id assetInstance = [assetClass assetInstanceWithAsset: asset];
		if (assetInstance != nil)
			[_scene insertElement: assetInstance atIndex: 0];
	}
	
	//refresh view and table
	[elementsView setNeedsDisplay: YES];
	[self refreshTableView];
}

#pragma mark *** UI bindings accessors ***
-(ECNElement *)selectedObject {
	if ([[oElementsListArrayController selectedObjects] count] != 1) return nil;
	
	return [[oElementsListArrayController selectedObjects] objectAtIndex: 0];
}

- (NSArray *)selectedObjectPropertyKeys	{

	if ([self selectedObject]==nil) return nil;
	
	ECNElement * selectedObject = [[oElementsListArrayController selectedObjects] objectAtIndex: 0];
	return [selectedObject propertyKeys];
	
}


@end
