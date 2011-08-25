//
//  ECNProjectDocument.h
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 21/10/10.
//  Copyright 2010 AndreaCremaschi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import "DebugIncludes.h"	

@class KCue;
@class ECNObject;
@class ECNOSCTarget;
@class ECNAsset;
//extern NSString *ECNPlaybackIsOverNotification;

@interface ECNProjectDocument : NSDocument {
@private

    NSMutableArray *_objects;

	// playback management!
	NSMutableSet *_curActiveScenes;
	
	// Object ID generator
	int _objectIDCounter;
}
@property (readonly, getter=objects) NSArray *_objects;

// === ID counter for persistance purposes
- (int) incIDCounter;
- (ECNObject *)objectWithID: (NSNumber *) ID;

// === Accessors
- (NSArray *)cues;
- (NSArray *)assets;
- (NSArray *)videoAssets;
- (NSArray *)oscTargetAssets;

- (NSArray *)objectsOfKind: (Class) objectKind ;
- (ECNAsset *)defaultAssetOfKind: (Class) objectKind ;

// === Data management
- (KCue *)createNewCue;

// === Object collection management
- (void)addObject:(ECNObject *)object;
- (void)removeObject:(ECNObject *)object;
- (NSArray*)objectsOfKind: (Class) objectClass;
							
//- (NSSize)documentSize;
// Returns usable document size based on print info paper size and margins.

//- (void) invalidateWindowControllersForScene: (ECNScene *)scene;

// === Asset management
- (void) importAsset: (NSString *)filePath;

@end

extern NSString *ECNProjectDocumentType;
