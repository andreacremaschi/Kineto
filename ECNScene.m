//
//  ECNElement.m
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 28/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ECNSceneWindowController.h"
#import "ECNProjectDocument.h"

#import "ECNScene.h"
#import "ECNElement.h"
#import "ECNOSCTarget.h"
#import "ECNAction.h"


NSString *ECNSceneDidChangeNotification = @"ECNSceneDidChange";
NSString *kStrNewSceneDefaultName = @"New scene";
NSString *kStrNewSceneDefaultDescription = @"";



// +  + Object specific properties  +

NSString *ECNSceneDescriptionKey = @"Description";
NSString *ECNSceneActiveAtFirstKey = @"activeAtFirst";
NSString *ECNSceneAspectRatioKey = @"AspectRatio";

NSString *ECNSceneElementsListKey = @"ElementsList";
// +  +  +  +  +  +  +  +  +  +  +  +

// +  + Default values  +  +  +  +  +
NSString *SceneClassValue = @"Scene";
NSString *SceneNameDefaultValue = @"New scene";
// +  +  +  +  +  +  +  +  +  +  +  +


@implementation ECNScene


#pragma mark *** Initialization

- (id) init	{
	self = [super init];
	if (self) {
		// the set used in playback to store active scenes
		_curActiveElements = [[NSMutableSet allocWithZone:[self zone]] init];
		_visibleElements = [[NSMutableSet allocWithZone:[self zone]] init];
	}
	return self;
}

- (id) initWithProjectDocument: (ECNProjectDocument *)document{
	
	self = [super initWithProjectDocument: document];	
	if (self) {
		
		// set default values for existing attributes
		[self setValue: SceneClassValue forPropertyKey: ECNObjectClassKey];
		[self setValue: SceneNameDefaultValue forPropertyKey: ECNObjectNameKey];
				
        
    }
	
	return self;
}



- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    	
	[_curActiveElements release];
	[_visibleElements release];
		
/*    [_fillColor release];
    [_strokeColor release];*/
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    id newObj = [[[self class] allocWithZone:zone] init];
	
    // Document is not "copied".  The new graphic will need to be inserted into a document.
   /* [newObj setBounds:[self bounds]];
    [newObj setFillColor:[self fillColor]];
    [newObj setDrawsFill:[self drawsFill]];
    [newObj setStrokeColor:[self strokeColor]];
    [newObj setDrawsStroke:[self drawsStroke]];
    [newObj setStrokeLineWidth:[self strokeLineWidth]];*/
	
    return newObj;
}


- (NSMutableDictionary *) attributesDictionary	{
	
	NSMutableDictionary* dict = [super attributesDictionary];
	
	// set default attributes values
	[dict setValue: SceneClassValue forKey: ECNObjectClassKey];

	// define class specific attributes	
	NSDictionary *propertiesDict = [NSDictionary dictionaryWithObjectsAndKeys:
									@"", ECNSceneDescriptionKey, 
									[NSNumber numberWithBool: true], ECNSceneActiveAtFirstKey,
									[NSNumber numberWithFloat: 0.66f], ECNSceneAspectRatioKey,
									[NSMutableArray array], ECNSceneElementsListKey,
									nil];
	
	[[dict objectForKey: ECNPropertiesKey] addEntriesFromDictionary: propertiesDict ];
	
	return dict;
	
	
}

#pragma mark *** Constructors ***


+ (ECNScene *)sceneWithDocument: (ECNProjectDocument *)document {
	ECNScene *newScene = [[[ECNScene alloc] initWithProjectDocument: document] autorelease];
	
	if (newScene != nil)	{
		[newScene setValue: SceneNameDefaultValue forPropertyKey: ECNObjectNameKey];
	}
	return newScene;
	
}


#pragma mark *** Document accessors and conveniences

- (NSString *)description	{
	return [self valueForPropertyKey: ECNSceneDescriptionKey]; 	
}

- (void)setDescription: (NSString *) description	{
	[self setValue: description forPropertyKey: ECNSceneDescriptionKey];
}

			
- (NSUndoManager *)undoManager {
    return [[self document] undoManager];
}

- (NSString *)graphicType {
    return NSStringFromClass([self class]);
}

- (NSArray *)elements {
//	myLog1(@"ME ECNElement elements");
    return [self valueForPropertyKey: ECNSceneElementsListKey];
}

#pragma mark *** Playback management ***

- (NSSet *) activeElements	{	return _curActiveElements;	}
- (NSSet *) visibleElements	{	return _visibleElements;	}

- (void) populateVisibleElementsSet
{
	[_visibleElements removeAllObjects];
	ECNElement *element;
	for (element in [self elements])
		if ([element isVisible]) [_visibleElements addObject: element];
	
}

- (void) resetToInitialState
{
	// reset "_curActiveElements" to initial states
	
	int i;
	ECNElement *curElement;
	
	[_curActiveElements removeAllObjects];
	
	NSArray *elements = [self elements];
	for (i=0; i< [elements count]; i++)
	{	curElement = [elements objectAtIndex: i];
		if ([curElement activeWhenSceneOpens]) 	{	
			[curElement prepareForPlayback];
			[curElement setActivationState: true];
			[_curActiveElements addObject: curElement];
		}
	}
			
			
} // resetToInitialState
			
- (void) setElementActivationState: (ECNElement *)element active: (bool) active{
	
	// check if target element is owned by this scene, else return
	if (![[self elements] containsObject: element]) return;

	if (active)
	{
		// add element to list of active elements
		if ([_curActiveElements containsObject: element]) return;
		[_curActiveElements addObject: element];		
	}
	else{
		// remove element from list of active elements
		if (![_curActiveElements containsObject: element]) return;
		[_curActiveElements removeObject: element];		
	}

	
} //setElementActivationState

- (bool) isElementActive: (ECNElement *)element	{
	return [_curActiveElements containsObject: element];
}

- (void) setActivationState: (bool) active { 
	return;
}

- (bool) activationState { 
	return false;
}

#pragma mark *** Primitives 

- (void)didChange {
    [_document invalidateScene:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:ECNSceneDidChangeNotification object:self];
}


- (void)invalidateElement:(ECNElement *)element {
  /*  NSArray *windowControllers = [_document windowControllers];
	
    [windowControllers makeObjectsPerformSelector:@selector(invalidateElement:) withObject:element];*/
	
}


- (void)insertElement:(ECNElement *)element atIndex:(unsigned)index {

    [[[self undoManager] prepareWithInvocationTarget:self] removeElementAtIndex:index];
    [[self valueForPropertyKey: ECNSceneElementsListKey] insertObject: element atIndex:index];
    
	[element setScene:self];

	[self populateVisibleElementsSet];
    [self invalidateElement:element];
	
}



- (void)removeElementAtIndex:(unsigned)index {
	
	NSArray *elements = [self elements];
	id element = [[elements objectAtIndex:index] retain];
    [[self valueForPropertyKey: ECNSceneElementsListKey] removeObjectAtIndex:index];

	[self populateVisibleElementsSet];

    [self invalidateElement:element];
    [[[self undoManager] prepareWithInvocationTarget:self] insertElement:element atIndex:index];
    [element release];
}

- (void)removeElement:(ECNElement *)element {
	NSArray *elements = [self elements];
    long index = [elements indexOfObjectIdenticalTo:element];
    if (index != NSNotFound) {
        [self removeElementAtIndex:index];
			[self populateVisibleElementsSet];
	}
}

- (void)moveElement:(ECNElement *)element toIndex:(unsigned)newIndex {
	NSArray *elements = [self elements];
    unsigned curIndex = [elements indexOfObjectIdenticalTo:element];
    if (curIndex != newIndex) {
        [[[self undoManager] prepareWithInvocationTarget:self] moveElement:element toIndex:((curIndex > newIndex) ? curIndex+1 : curIndex)];
        if (curIndex < newIndex) {
            newIndex--;
        }
        [element retain];
        [[self valueForPropertyKey: ECNSceneElementsListKey] removeObjectAtIndex:curIndex];
        [[self valueForPropertyKey: ECNSceneElementsListKey] insertObject:element atIndex:newIndex];
        [element release];
        [self invalidateElement:element];
    }
}

- (NSRect)boundsForElements:(NSArray *)elements {
    NSRect rect = NSZeroRect;
    unsigned i, c = [elements count];
    for (i=0; i<c; i++) 
        if (i==0) 
            rect = [[elements objectAtIndex:i] bounds];
         else 
            rect = NSUnionRect(rect, [[elements objectAtIndex:i] bounds]);
        
    return rect;
}

#pragma mark *** Window Controller Management 


- (void)makeWindowControllers {
    ECNSceneWindowController *myController = [[ECNSceneWindowController allocWithZone:[self zone]] init];
    [[self document] addWindowController:myController];
    [myController release];
}




@end
