//
//  ECNProjectDocument.m
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 21/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "ECNObject.h"

#import "ECNProjectDocument.h"
#import "ECNProjectWindowController.h"
#import "ECNSceneWindowController.h"
#import "ECNScene.h"
#import "ECNOSCTarget.h"
#import "ElementsView.h"
#import "ECNLiveViewerController.h"
#import "ECNQCAsset.h"
//#import "ECNActions.h"

#import <VVOSC/VVOSC.h>


NSString *strNewSceneDefaultName = @"New scene ";
//NSString *ECNPlaybackIsOverNotification = @"ECNPlaybackIsOver";


// Sketch establishes an NSError domain and some error codes. In a bigger app this stuff would of course be declared in a header. Also, in a bigger app the lookup of error description and failure reasons would probably be centralized somewhere instead of scattered all over the source code like in this file.
NSString *const ECNErrorDomain = @"KinetoErrorDomain";
enum {
    ECNReadUnknownError = 1
};

NSString *ECNDocumentType = @"Kineto Format";


@implementation ECNProjectDocument


- (id)init
{
    self = [super init];
    if (self) {
		
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
        _objects = [[NSMutableArray allocWithZone:[self zone]] init];

		//this is used to identify objects when saving and loading projects
		_objectIDCounter = 0;
		
		// aggiungi temporaneamete un unico target per i messaggi OSC: 
		//  127.0.0.1 p 5000

		//ECNOSCTarget *oscTarget =  [self createNewOSCTarget];

		
/*
		// test qc asset!
		NSString *compositionPath;
		compositionPath = [[NSBundle mainBundle] pathForResource: @"kineto_masks" ofType:@"qtz"];
		ECNQCAsset *qcTestAsset = [ECNQCAsset assetWithDocument: self
												 withQCFilePath: compositionPath];*/

		
		// the set used in playback to store active scenes
		_curActiveScenes = [[NSMutableSet allocWithZone:[self zone]] init];
    }
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_objects release];
    [_curActiveScenes release];
	
    [super dealloc];
}





/*
- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"ECNProjectDocument";
}
*/

- (void)makeWindowControllers {
    ECNProjectWindowController *myController = [[ECNProjectWindowController allocWithZone:[self zone]] init];    
	[self addWindowController:myController];
    [myController release];
	
}


- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];

    // Add any code here that needs to be executed once the windowController has loaded the document's window.
	[aController setShouldCloseDocument: YES];
	
}


#pragma mark *** Accessors

- (NSSet *)activeScenes	{
	return _curActiveScenes;
}

- (NSArray *)scenes {
   return [self objectsOfKind: [ECNScene class]];
}
- (NSArray *)assets	{
	return [self objectsOfKind: [ECNAsset class]];	
}


-(ECNScene *)createNewScene {

	//cicla tra le scene e controlla
	//- se esiste già una scena con quel nome
	//- se esiste già una "first scene"
	
	int i=0; int n=0;
	NSString *newSceneName;
	bool nameIsNew =false;
	bool nameExists = false;
	bool firstSceneExists = false;
	
	newSceneName = [[[NSString alloc] initWithString: strNewSceneDefaultName] autorelease];

	NSArray *scenes = [self scenes]; 
	if ([scenes count] > 0)
	while (!nameIsNew)
	{
		if (i>0) newSceneName = [strNewSceneDefaultName stringByAppendingString: [NSString stringWithFormat:@"%i", i]];
		
		nameExists = false;
		nameIsNew = true;

		for (n=0;n<[scenes count]; n++)
		{
			if ([[scenes objectAtIndex:n] valueForPropertyKey: ECNObjectNameKey] == newSceneName) nameExists = true;
			if ([[scenes objectAtIndex:n] valueForPropertyKey: ECNSceneActiveAtFirstKey]) firstSceneExists = true;
		}
		if (nameExists) nameIsNew =false;
		i++;
	}
	// se esiste modifica il contatore
	
	ECNScene *_creatingScene = [ECNScene sceneWithDocument: self]; //[[ECNScene allocWithZone:[self zone]] initWithProjectDocument: self];
	if (_creatingScene)	{
		[_creatingScene setValue: newSceneName forPropertyKey: ECNObjectNameKey];	
		[_creatingScene setValue: [NSNumber numberWithBool: !firstSceneExists] forPropertyKey: ECNSceneActiveAtFirstKey];
		//[self insertScene: _creatingScene atIndex:0];
	}
	else {
		[_creatingScene release];
		return nil;
	}
	return _creatingScene;
}

- (int) incIDCounter	{	return _objectIDCounter++;}

- (ECNObject *)objectWithID: (NSNumber *) ID
{
	ECNObject * object, *correctObject;
	correctObject = nil;
	
	for (object in _objects)
		if ([[object ID] isEqual: ID]) {
			correctObject = object;
			break;
		}
	
	return correctObject;
	
}	
	
#pragma mark *** Persistence

static NSString *ECNDocumentVersionKey = @"KinetoDocumentVersion";
static NSString *ECNProjectDocumentIDCounter = @"IDCounter";
static NSString *ECNObjectsListKey = @"ObjectsList";
static int ECNCurrentDocumentVersion = 1;
//static NSString *ECNPrintInfoKey = @"PrintInfo";


- (NSDictionary *)drawDocumentDictionary {
	
	NSMutableDictionary *doc = [NSMutableDictionary dictionary];
	
	// object id counter
	[doc setObject:[[NSNumber numberWithInt: _objectIDCounter] stringValue] forKey: ECNProjectDocumentIDCounter];

    //	OBJECTS
    NSMutableArray *objectsDicts = [NSMutableArray arrayWithCapacity: [_objects count]];	
	for (ECNObject *object in _objects)
        [objectsDicts addObject: [object propertyListRepresentation]];
    
    [doc setObject:objectsDicts forKey: ECNObjectsListKey ];
	
	
    [doc setObject:[NSString stringWithFormat:@"%d", ECNCurrentDocumentVersion ] forKey:ECNDocumentVersionKey];
//    [doc setObject:[NSArchiver archivedDataWithRootObject: [self printInfo]] forKey: ECNPrintInfoKey];
	//NSLog( @"%@", doc);
    return doc;
}


- (NSData *)drawDocumentData {
    /*NSDictionary *doc = [self drawDocumentDictionary];
    NSString *string = [doc description];
    return [string dataUsingEncoding: NSASCIIStringEncoding];
	
	*/
	NSError *error;
	NSDictionary *doc = [self drawDocumentDictionary];
/*	NSData *xmlData = [NSPropertyListSerialization dataFromPropertyList: doc
																 format: NSPropertyListXMLFormat_v1_0
													   errorDescription: &error];*/
		NSData *xmlData = [NSPropertyListSerialization dataWithPropertyList: doc
																	 format: NSPropertyListXMLFormat_v1_0
																	options: 0
																	  error: &error];
	if(!xmlData) {
		NSLog(@"%@", error);
		NSLog(@"%@", [doc description]);
		
	}
	
	return xmlData;

	
}


- (NSDictionary *)drawDocumentDictionaryFromData:(NSData *)data error:(NSError **)outError {
	
    // If property list parsing fails we have no choice but to admit that we don't know what went wrong. The error description returned by +[NSPropertyListSerialization propertyListFromData:mutabilityOption:format:errorDescription:] would be pretty technical, and not the sort of thing that we should show to a user.
/*    NSDictionary *properties = [NSPropertyListSerialization 
								propertyListFromData:data 
								mutabilityOption:NSPropertyListImmutable
								format:NULL 
								errorDescription:NULL];*/
	NSError	*error; 
	NSDictionary *properties = [NSPropertyListSerialization propertyListWithData: data 
																		 options: NSPropertyListImmutable 
																		  format: NULL
																		   error: &error];
	NSLog (@"%@", [properties description]);
    if (!properties && outError) {
		
		// An NSError has a bunch of parameters that determine how it's presented to the user. We just specify two of them here.
		NSDictionary *errorUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									   
									   // This localized description won't be presented to the user, except maybe by -[ElementsView paste:]. It's a good idea to always provide a decent description that's a full sentence.
									   NSLocalizedStringFromTable(@"Kineto document data could not be read for an unknown reason.", @"ErrorStrings", @"Description of can't-read-Kineto error."), NSLocalizedDescriptionKey,
									   
									   // This localized failure reason will be presented to the user if we're trying to open a document. NSDocumentController will take it and tack it onto the end of a "The document "so-and-so" could not be opened." message and use the whole thing as an error description. Full sentence!
									   NSLocalizedStringFromTable(@"An unknown error occured.", @"ErrorStrings", @"Reason for can't-read-Kineto error."), NSLocalizedFailureReasonErrorKey,
									   
									   nil];
		
		// In this simple example we know that no one's going to be paying attention to the domain and code that we use here, but don't just fill in junk here. Certainly don't just use NSCocoaErrorDomain and some random error code.
		*outError = [NSError errorWithDomain:ECNErrorDomain code:ECNReadUnknownError userInfo:errorUserInfo];
		
    }
    return properties;
	
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	
	NSParameterAssert([typeName isEqualToString:ECNDocumentType]);
	NSData *data = [self drawDocumentData];
	if (!data && outError) 
		*outError = [NSError errorWithDomain: NSCocoaErrorDomain 
										code: NSFileWriteUnknownError userInfo:nil];
	
	return data;

}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
	
    // This application's Info.plist only declares one document type, ECNDocumentType, for which it can play the "editor" role, and none for which it can play the "viewer" role, so the type better be ECNDocumentType.
    NSParameterAssert([typeName isEqualToString:ECNDocumentType]);
	
    // Read in the property list.
    NSDictionary *documentRootDict = [self drawDocumentDictionaryFromData: data error: outError];
    if (documentRootDict) {
		
		//check version and choose correct method
		id obj = [documentRootDict objectForKey:ECNProjectDocumentIDCounter];
		if (obj) _objectIDCounter = [obj intValue];
		
		// objects list
		if ([[documentRootDict objectForKey: ECNObjectsListKey] isKindOfClass: [NSArray class]])	{
		
			for (obj in [documentRootDict objectForKey: ECNObjectsListKey])	{
				//if ([obj isKindOfClass: [NSDictionary class]])
				[ECNObject objectWithDataDictionary: obj withDocument: self];
			}
			
			//unpack internal references to objects
			// TODO: add type check here!
			for (ECNObject *curObject in _objects)
				[curObject unpackObjectReferences];
			
			
		}
		NSLog (@"File load was a success! "  );
		

		
    } // else it was -drawDocumentDictionaryFromData:error:'s responsibility to set *outError to something good.
    return documentRootDict ? YES : NO;
	
}

#pragma mark *** window controller management

- (ECNSceneWindowController *)openedSceneWindowControllerForScene: (ECNScene *)scene	{
	int i;
	ECNScene *curScene;
	ECNSceneWindowController *sceneWindowController;
	NSWindowController *windowController;
	
	// check if double-clicked scene is already opened
	for (i=0; i<[[self windowControllers] count]; i++)
	{	
		windowController = [[self windowControllers] objectAtIndex: i];
		if ([windowController isKindOfClass: [ECNSceneWindowController class]])
		{
			sceneWindowController = (ECNSceneWindowController *)windowController;
			curScene = (ECNScene*)[sceneWindowController scene];
			if (curScene == scene)
			{	
				// scene window already opened. return it
				return sceneWindowController;
			}
		}
	}
	return nil;
}



- (void) openSceneWindowController:(ECNScene *)sceneToOpen {
	
	ECNSceneWindowController *sceneWindowController = [self openedSceneWindowControllerForScene: sceneToOpen];
	if (sceneWindowController != nil)	{
		[ [sceneWindowController window] makeKeyAndOrderFront: self];
		return;
	}
	
	//apre una nuova finestra per la Scena selezionata
	//ECNSceneWindowController *myController = 
	[ECNSceneWindowController windowWithScene: sceneToOpen];

	
}



- (void)invalidateScene:(ECNScene *)scene {
/*    NSArray *windowControllers = [self windowControllers];
	
    [windowControllers makeObjectsPerformSelector:@selector(invalidateScene:) withObject:scene];
*/
}

- (void)invalidateElement:(ECNElement *)element {
    NSArray *windowControllers = [self windowControllers];
	
    [windowControllers makeObjectsPerformSelector:@selector(invalidateElement:) withObject:element];
}


#pragma mark *** Objects management ***
- (void)addObject:(ECNObject *)object	{
	if ([object isKindOfClass: [ECNScene class]])
		[self willChangeValueForKey: @"scenes"];
	else if ([object isKindOfClass: [ECNAsset class]])
		[self willChangeValueForKey: @"assets"];

	[_objects insertObject: object atIndex: 0];

	if ([object isKindOfClass: [ECNScene class]])
		[self didChangeValueForKey: @"scenes"];
	else if ([object isKindOfClass: [ECNAsset class]])
		[self didChangeValueForKey: @"assets"];
}

- (void)removeObject:(ECNObject *)object	{
	if ([object isKindOfClass: [ECNScene class]])
		[self willChangeValueForKey: @"scenes"];
	else if ([object isKindOfClass: [ECNAsset class]])
		[self willChangeValueForKey: @"assets"];
	
		[_objects removeObject:object];
	
	if ([object isKindOfClass: [ECNScene class]])
		[self didChangeValueForKey: @"scenes"];
	else if ([object isKindOfClass: [ECNAsset class]])
		[self didChangeValueForKey: @"assets"];
}

- (NSArray*)objectsOfKind: (Class) objectClass	{
	
	if (![objectClass isSubclassOfClass: [ECNObject class]]) return nil;
	
	NSMutableArray *objectsArray = [NSMutableArray arrayWithCapacity: 0];
	for (ECNObject *object in _objects)
		if ([object isKindOfClass: objectClass]) 
			[objectsArray addObject: object];
	return objectsArray;
}


#pragma mark *** Playback management ***

- (void) resetToInitialState
{
//	NSAssert( _curActiveScenes != nil);
	
	// reset "_curActiveScenes" to initial states
	[_curActiveScenes removeAllObjects];
	
	NSArray *scenes = [self scenes];
	for (ECNScene *curScene in scenes)
		if ([[curScene valueForPropertyKey: ECNSceneActiveAtFirstKey] boolValue]) 	{	
			NSLog (@"adding scene: '%@' to active scenes array", [curScene valueForPropertyKey: ECNObjectNameKey]) ;
			[curScene resetToInitialState];
			[_curActiveScenes addObject: curScene];
		}
	
} // resetToInitialState
	
- (void) setSceneActivationState: (ECNScene *)scene active: (bool) active	{

	// check if target scene is owned by this document, else return
	if (![[self scenes] containsObject: scene]) return;
	
	if (active)
	{
		// add element to list of active elements
		if ([_curActiveScenes containsObject: scene]) return;
		[scene resetToInitialState];
		[_curActiveScenes addObject: scene];		
	}
	else {
		// remove scene from list of active elements
		if (![_curActiveScenes containsObject: scene]) return;
		[_curActiveScenes removeObject: scene];	
		
	}
	
} // setSceneActivationState


- (bool) isSceneActive: (ECNScene *)scene	{
	return [_curActiveScenes containsObject: scene];
}


#pragma mark  *** Asset management
- (void) importAsset: (NSString *)filePath	{

	Class theClass;
	if (!filePath) return;
	
	NSString *extension = [filePath pathExtension];
	if ([extension isEqual: @"qtz"])
		theClass = [ECNQCAsset class];
	
	if (!theClass) return;
	
	ECNAsset *qcAsset = [theClass assetWithDocument: self
									 withQCFilePath: filePath];
	
	[self addObject: qcAsset];
	
	
}


@end