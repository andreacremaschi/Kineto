//
//  ECNOSCTargetAssetInstance.h
//  kineto
//
//  Created by Andrea Cremaschi on 28/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import "ECNAssetInstance.h"

extern NSString *OSCTxAssetInstanceAddressPatternKey;
extern NSString *OSCTxAssetInstanceBundleKey;
extern NSString *OSCTxAssetInstanceObservedPortsArrayKey;
extern NSString *OSCTxAssetInstancePacketComposerScriptKey;

@class ECNOSCTargetAsset;
@interface ECNOSCTxAssetInstance : ECNAssetInstance {
	NSDictionary *lastPacketSent;
}
@property (readonly) NSDictionary *lastPacketSent;

- (void) addPortToObserve: (ECNPort *)outputport;

- (ECNOSCTargetAsset *)oscAsset;
+ (ECNOSCTxAssetInstance *)oscTxAssetInstanceWithAsset: (ECNAsset *) asset;



@end
