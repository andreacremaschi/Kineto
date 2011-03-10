//
//  ECNLine.h
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 31/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ECNShape.h"



@interface ECNLine : ECNShape {
@private
    BOOL _startsAtLowerLeft;
	
}

- (void)setStartsAtLowerLeft:(BOOL)flag;
- (BOOL)startsAtLowerLeft;

@end
