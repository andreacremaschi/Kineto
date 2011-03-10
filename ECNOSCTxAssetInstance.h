//
//  ECNOSCTargetAssetInstance.h
//  kineto
//
//  Created by Andrea Cremaschi on 28/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECNAssetInstance.h"

extern NSString *OSCTxAssetInstanceAddressPatternKey;
extern NSString *OSCTxAssetInstanceBundleKey;
extern NSString *OSCTxAssetInstanceObservedPortsArrayKey;

@class ECNOSCTargetAsset;
@interface ECNOSCTxAssetInstance : ECNAssetInstance {
}

- (void) addPortToObserve: (ECNPort *)outputport;

- (ECNOSCTargetAsset *)oscAsset;
+ (ECNOSCTxAssetInstance *)oscTxAssetInstanceWithAsset: (ECNAsset *) asset;



@end
