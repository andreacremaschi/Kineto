//
//  ECNOSCTargetAssetInstance.h
//  kineto
//
//  Created by Andrea Cremaschi on 28/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import "ECNAssetInstance.h"
/*
extern NSString *OSCTxAssetInstanceBundleKey;
extern NSString *OSCTxAssetInstanceObservedPortsArrayKey;
*/
extern NSString *OSCTxAssetInstanceAddressPatternKey;
extern NSString *OSCTxAssetInstancePacketComposerScriptKey;
extern NSString *OSCTxAssetInstanceMessagesArrayKey;

@class ECNOSCTargetAsset;
@class KBNFMessageObject;

@interface ECNOSCTxAssetInstance : ECNAssetInstance {
	NSDictionary *lastPacketSent;
	NSMutableArray *oscArgumentsCache;
}
@property (readonly) NSDictionary *lastPacketSent;
@property (retain) NSString *addressPattern;
@property (retain) NSMutableArray *argumentsArray;

//- (void) addPortToObserve: (ECNPort *)outputport;

- (ECNOSCTargetAsset *)oscAsset;
+ (ECNOSCTxAssetInstance *)oscTxAssetInstanceWithAsset: (ECNAsset *) asset;



@end
