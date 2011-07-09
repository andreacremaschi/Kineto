//
//  ECNProjectDocument.m
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 21/10/10.
//  Copyright 2010 AndreaCremaschi. All rights reserved.
//
#import "ECNObject.h"

#import "ECNProjectDocument.h"
#import "KProjectWindowController.h"
#import "KCueEditorViewController.h"
#import "KCue.h"
#import "ECNOSCTarget.h"
#import "ElementsView.h"

#import "ECNAssets.h"
//#import "ECNActions.h"
#import "ECNVideoInputAsset.h"

#import <VVOSC/VVOSC.h>


NSString *strNewSceneDefaultName = @"New cue";
//NSString *ECNPlaybackIsOverNotification = @"ECNPlaybackIsOver";


// Sketch establishes an NSError domain and some error codes. In a bigger app this stuff would of course be declared in a header. Also, in a bigger app the lookup of error description and failure reasons would probably be centralized somewhere instead of scattered all over the source code like in this file.
NSString *const ECNErrorDomain = @"KinetoErrorDomain";
enum {
    ECNReadUnknownError = 1
};

NSString *ECNDocumentType = @"Kineto Format";


@implementation ECNProjectDocument
@synthesize _objects;

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
    KProjectWindowController *myController = [[KProjectWindowController allocWithZone:[self zone]] init];    
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

- (NSArray *)cues {
   return [self objectsOfKind: [KCue class]];
}
- (NSArray *)assets	{
	return [self objectsOfKind: [ECNAsset class]];	
}
- (NSArray *)videoAssets	{
	return [self objectsOfKind: [ECNVideoInputAsset class]];	
}

- (NSArray *)oscTargetAssets {
	return [self objectsOfKind: [ECNOSCTargetAsset class]];		
}


- (ECNAsset *)defaultAssetOfKind: (Class) objectKind {
	NSAssert ([objectKind isSubclassOfClass: [ECNAsset class]], @"Assertion error in ECNProjectDocument:defaultAssetOfKind");
	NSArray *assets = [self objectsOfKind: objectKind];
	if ([assets count] > 0) 
		return [assets objectAtIndex: 0]; //for now return the first object in the array
	return nil;
	
}


-(KCue *)createNewCue {

	//check if a cue that active at first is already in the list of cues
	bool firstCueExists = false;
	for (KCue *cue in [self cues])
		if ([[cue valueForPropertyKey: ECNSceneActiveAtFirstKey] boolValue])	{
			firstCueExists = true;
			break;
		}
	
	[self willChangeValueForKey:@"cues"];
	
	// create a new cue
	KCue *_creatingScene = [KCue cueWithDocument: self];

	if (_creatingScene)	{
		[_creatingScene setValue: [NSNumber numberWithBool: !firstCueExists] forPropertyKey: ECNSceneActiveAtFirstKey];
		//[self insertScene: _creatingScene atIndex:0];
	}
	else {
		[_creatingScene release];
		return nil;
	}
		[self didChangeValueForKey:@"cues"];
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


- (void)invalidateElement:(ECNElement *)element {
    NSArray *windowControllers = [self windowControllers];
	
    [windowControllers makeObjectsPerformSelector:@selector(invalidateElement:) withObject:element];
}


#pragma mark *** Objects management ***
- (void)addObject:(ECNObject *)object	{
	if ([object isKindOfClass: [KCue class]])
		[self willChangeValueForKey: @"scenes"];
	else if ([object isKindOfClass: [ECNOSCTargetAsset class]])
		[self willChangeValueForKey: @"oscTargetAssets"];
	else if ([object isKindOfClass: [ECNVideoInputAsset class]])
		[self willChangeValueForKey: @"videoAssets"];
	else if ([object isKindOfClass: [ECNAsset class]])
		[self willChangeValueForKey: @"assets"];

	//[_objects insertObject: object atIndex: 0];
	[_objects addObject: object];

	if ([object isKindOfClass: [KCue class]])
		[self didChangeValueForKey: @"scenes"];
	else if ([object isKindOfClass: [ECNOSCTargetAsset class]])
		[self didChangeValueForKey: @"oscTargetAssets"];
	else if ([object isKindOfClass: [ECNVideoInputAsset class]])
		[self didChangeValueForKey: @"videoAssets"];
	else if ([object isKindOfClass: [ECNAsset class]])
		[self didChangeValueForKey: @"assets"];

}

- (void)removeObject:(ECNObject *)object	{
	if ([object isKindOfClass: [KCue class]])
		[self willChangeValueForKey: @"scenes"];
	else if ([object isKindOfClass: [ECNAsset class]])
		[self willChangeValueForKey: @"assets"];
	
		[_objects removeObject:object];
	
	if ([object isKindOfClass: [KCue class]])
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
	
	NSArray *scenes = [self cues];
	for (KCue *curScene in scenes)
		if ([[curScene valueForPropertyKey: ECNSceneActiveAtFirstKey] boolValue]) 	{	
			NSLog (@"adding scene: '%@' to active scenes array", [curScene valueForPropertyKey: ECNObjectNameKey]) ;
			[curScene resetToInitialState];
			[_curActiveScenes addObject: curScene];
		}
	
} // resetToInitialState
	
- (void) setSceneActivationState: (KCue *)scene active: (bool) active	{

	// check if target scene is owned by this document, else return
	if (![[self cues] containsObject: scene]) return;
	
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


- (bool) isSceneActive: (KCue *)scene	{
	return [_curActiveScenes containsObject: scene];
}


#pragma mark  *** Asset management
- (void) importAsset: (NSString *)filePath	{

	Class theClass = nil;
	if (!filePath) return;
	
	NSString *extension = [filePath pathExtension];
	if ([extension isEqual: @"qtz"])
		theClass = [ECNQCAsset class];
	
	if (nil == theClass) return;
	
	ECNAsset *qcAsset = [theClass assetWithDocument: self
									 withQCFilePath: filePath];
	
	[self addObject: qcAsset];
	
	
}


@end
