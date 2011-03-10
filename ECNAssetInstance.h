//
//  ECNAssetInstance.h
//  kineto
//
//  Created by Andrea Cremaschi on 23/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECNElement.h"

extern NSString *AssetKey;

// +  +  + asset input ports +  +  +
extern NSString *AssetInstanceAssetInportsKey ;
// +  +  +  +  +  +  +  +  +  +  +  +

// +  +  + asset output ports +  +  +
extern NSString *AssetInstanceAssetOutportsKey;
// +  +  +  +  +  +  +  +  +  +  +  +


@class ECNAsset;
@interface ECNAssetInstance : ECNElement {

}

- (id) initWithAsset: (ECNAsset *)asset;

- (ECNAsset *)asset;
- (void) setAsset: (ECNAsset *)asset;

+ (NSString *)iconName;

+ (ECNAssetInstance *)assetInstanceWithAsset: (ECNAsset *) asset;
+ (Class)assetType;

@end
