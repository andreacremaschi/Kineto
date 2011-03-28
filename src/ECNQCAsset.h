//
//  ECNQCAsset.h
//  kineto
//
//  Created by Andrea Cremaschi on 11/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import "ECNAsset.h"

extern NSString *QCAssetRenderSizeKey;
extern NSString *QCAssetInputPortsKey ;
extern NSString *QCAssetOutputPortsKey ;
extern NSString *QCAssetPortKey;

@interface ECNQCAsset : ECNAsset {
//	QCRenderer *_qcRenderer;
}


+ (ECNQCAsset *)assetWithDocument: (ECNProjectDocument *)document 
				   withQCFilePath: (NSString *)filePath;

@end
