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

- (void) addDelegate: (id) delegate;
- (void) removeDelegate: (id) delegate;

- (NSString *)position;

- (id) initAssetWithProjectDocument: (ECNProjectDocument *)document
					   withFilePath: (NSString *)filePath;
	
- (id) loadAsset;
- (bool) loadAssetWithError: (NSError*)error;
+ (Class) instanceClass;

@end
