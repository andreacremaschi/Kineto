//
//  ECNOSCTargetAsset.h
//  kineto
//
//  Created by Andrea Cremaschi on 28/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import "ECNAsset.h"

// +  + Object specific properties  +
extern NSString *OSCAssetHostKey;
extern NSString *OSCAssetPortKey;

@interface ECNOSCTargetAsset : ECNAsset {
	
} 

+ (ECNOSCTargetAsset *)assetWithDocument: (ECNProjectDocument *)document 
				  withOSCTargetIP: (NSString *)targetIP
				withOSCTargetPort: (NSNumber *)oscport;

- (bool) closeWithError: (NSError **)error;
- (bool) openWithError: (NSError **)error;

- (bool) sendValues: (NSArray *) values 
		  toAddress: (NSString *)addressPattern
			  error: (NSError **)error;

@end
