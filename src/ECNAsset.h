//
//  ECNAsset.h
//  kineto
//
//  Created by Andrea Cremaschi on 11/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import "ECNObject.h"

extern NSString *AssetFilePathKey;

@interface ECNAsset : ECNObject {

}

- (NSString *)position;

- (id) initAssetWithProjectDocument: (ECNProjectDocument *)document
					   withFilePath: (NSString *)filePath;
	
- (id) loadAsset;
+ (Class) instanceClass;

@end
