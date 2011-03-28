//
//  ECNOSCTarget.h
//  kineto
//
//  Created by Andrea Cremaschi on 05/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ECNObject.h"

@class OSCOutPort;
@class OSCManager;

@interface ECNOSCTarget : ECNObject {

	// target identifiers
	NSString *_host;
	int _port;
	NSString *_OSCLabel;
	
	// OSC manager objects
	OSCOutPort		*_OSCOutPort;
	OSCManager		*_OSCmanager;

	// runtime properties
	float _lastValueSent;
	bool _bBundle;

}


// Init method
- (id) initWithProjectDocument: (ECNProjectDocument *)document withOSCManager: (OSCManager *)OSCmanager host: (NSString *)host port: (int) OSCport label: (NSString*)OSClabel;


// Constructors
+ (ECNOSCTarget *)oscTargetWithDocument: (ECNProjectDocument *)document;

// Accessors
- (NSString*) OSCLabel;
- (float) lastValueSent;
- (NSString*) host;
- (int) port;
- (bool) bundle;

- (NSString *) stringValue;

- (void) setOSCLabel: (NSString *)OSCLabel;
- (void) setHost: (NSString *)host;
- (void) setPort: (int) port;
- (void) setBundle: (bool) bundle;

// Methods
- (void) sendValue: (float) value;
- (bool) openOutportOnManager: (OSCManager *)oscManager;
- (bool) closeOutport;

// =================================== Persistence ===================================
- (NSMutableDictionary *)propertyListRepresentation;
+ (id)oscTargetWithPropertyListRepresentation:(NSDictionary *)dict;
- (void)loadPropertyListRepresentation:(NSDictionary *)dict;

@end
