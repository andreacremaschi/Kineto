//
//  ECNProjectWindowController.m
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 28/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ECNProjectWindowController.h"
#import "ECNLiveViewerController.h"
#import "ECNProjectDocument.h";
#import "ECNSceneWindowController.h"
#import "ECNElement.h"
#import "ECNScene.h"
#import "ECNAsset.h"


@implementation ECNProjectWindowController


- (id)init {
    self = [super initWithWindowNibName:@"ECNProjectDocument"];
    return self;
}



- (void)dealloc {

	[scenesTableView setDataSource:nil];
	
	[super dealloc];
	
}


# pragma mark -
# pragma mark *** delegate of NSWindow


- (void) windowDidLoad {
	[scenesTableView setDoubleAction: @selector(doubleClicOnTableView:)];
	[super windowDidLoad];
}

#pragma mark *** UI events ***


- (void) doubleClicOnTableView: (id)sender	{

	id selectedObjects;
	
	if (sender == scenesTableView)	{
		selectedObjects = [scenesArrayController selectedObjects];
	}
	else if (sender == assetsTableView) {
		selectedObjects = [assetArrayController selectedObjects];
	}
	if (selectedObjects == nil) return;
	ECNProjectDocument* document = [self document];
	
	int index;
	int numItems = [selectedObjects count];
	for (index = 0; index < numItems; index++)
	{
		id object = [selectedObjects objectAtIndex:index];
		if (object != nil)
		{
			NSLog(@"inspect item: '%@' of class: %@", [object name], [object class]);
			if ([object isKindOfClass: [ECNScene class]]) 
				[document openSceneWindowController: object];
		}
	}

	
	
	
	/*ECNProjectDocument* document = [self document];
	if (selection == nil) return;
	
	if ([selection isKindOfClass: [ECNScene class]]) 
		[document openSceneWindowController: selection];*/
/*
	ECNProjectDocument* document = [self document];
	ECNScene *sceneToOpen = [[document scenes] objectAtIndex: [scenesTableView clickedRow]];
	[document openSceneWindowController: sceneToOpen];*/

}


/*
- (void)inspect:(NSArray *)selectedObjects
{
	// handle user double-click
	
	// setup the edit sheet controller if one hasn't been setup already
	if (myEditController == nil)
		myEditController = [[EditController alloc] init];
	
	// remember which selection index we are changing
	unsigned int savedSelectionIndex = [myContentArray selectionIndex];
	
	// get the current selected object and start the edit sheet
	NSDictionary *editItem = [selectedObjects objectAtIndex:0];
	NSMutableDictionary *newValues = [myEditController edit:editItem from:self];
	
	if (![myEditController wasCancelled])
	{
		// remove the current selection and replace it with the newly edited one
		NSArray *selectedObjects = [myContentArray selectedObjects];
		[myContentArray removeObjects:selectedObjects];
		
		// make sure to add the new entry at the same selection location as before
		[myContentArray insertObject:newValues atArrangedObjectIndex:savedSelectionIndex];   
	}
}
*/



- (IBAction) ECNnewScene: (id)sender {
	ECNProjectDocument *document = [self document];	
	
	[self willChangeValueForKey:@"scenesList"];
	ECNScene *newScene = [document createNewScene];
	[self didChangeValueForKey:@"scenesList"];
	
	if (newScene != nil) {
		
		//[self selectScene:newScene];
//		[newScene setAspectRatio: (float)[[ECNLiveViewerController sharedECNLiveViewerController] getRenderAspectRatio]];
		
		//[newScene makeWindowControllers];
		[[document undoManager] setActionName:[NSString stringWithFormat:NSLocalizedStringFromTable(@"Create %@", @"UndoStrings", @"Action name for newly created scenes.  Class name is inserted at the substitution."), [[NSBundle mainBundle] localizedStringForKey:NSStringFromClass([ECNScene class]) value:@"" table:@"SceneClassNames"]]];
		// Append a newly created data object, then reload the table contents.
		[scenesTableView reloadData];
		
		[document openSceneWindowController: newScene];
		
	}
	
	
	return;	
}





- (IBAction) importFile: (id) sender {
	int i; // Loop counter.
	ECNProjectDocument * document = [self document];

	// Create the File Open Dialog class.
	NSOpenPanel* openDlg = [NSOpenPanel openPanel];
	NSArray *fileTypes = [NSArray arrayWithObject:@"qtz"];
	
	[openDlg setCanChooseFiles:YES];
	[openDlg setCanChooseDirectories:NO];
	[openDlg setAllowedFileTypes: fileTypes];
	[openDlg setTitle: @"Import file"]; 
	
	// Display the dialog.  If the OK button was pressed,
	// process the files.
	if ( [openDlg runModal] == NSOKButton )
	{
		// Get an array containing the full filenames of all
		// files and directories selected.
		NSArray* files = [openDlg filenames];

		// Loop through all the files and process them.
		for( i = 0; i < [files count]; i++ )
		{
			NSString* fileName = [files objectAtIndex:i];
			[document importAsset: fileName];
		
		}
	}
}


#pragma mark *** KVC methods ***
- (NSArray *)selectedAssets	{
	id selectedObjects = [assetArrayController selectedObjects];
	
	int numItems = [selectedObjects count];

	if (numItems == 0) selectedObjects = nil;
	return selectedObjects;
	
}

- (NSArray*)assets	{
	return [[self document] assets];
}

- (NSArray*)scenes {	
	return [[self document] scenes];
}

@end
