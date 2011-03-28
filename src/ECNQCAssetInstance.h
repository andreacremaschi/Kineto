//
//  ECNQCAssetInstance.h
//  kineto
//
//  Created by Andrea Cremaschi on 22/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import "ECNAssetInstance.h"


@interface ECNQCAssetInstance : ECNAssetInstance {
	QCRenderer *_renderer;
}

+ (ECNQCAssetInstance *)qcAssetInstanceWithAsset: (ECNAsset *) asset;


@end
