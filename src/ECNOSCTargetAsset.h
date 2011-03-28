//
//  ECNOSCTargetAsset.h
//  kineto
//
//  Created by Andrea Cremaschi on 28/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECNAsset.h"
#import <VVOSC/VVOSC.h>

// +  + Object specific properties  +
extern NSString *OSCAssetHostKey;
extern NSString *OSCAssetPortKey;

@interface ECNOSCTargetAsset : ECNAsset {
	OSCManager *_oscManager;
	OSCOutPort *_OSCOutputPort;
}

+ (ECNOSCTargetAsset *)assetWithDocument: (ECNProjectDocument *)document 
				  withOSCTargetIP: (NSString *)targetIP
				withOSCTargetPort: (NSNumber *)oscport;

- (bool) sendValues: (NSArray *) values toAddress: (NSString *)addressPattern;
- (bool) openOutportOnManager: (OSCManager *)oscManager;
- (bool) closeOutportOnManager: (OSCManager *)oscManager;

@end
