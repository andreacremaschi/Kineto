//
//  QCMaskRenderer.h
//  kineto
//
//  Created by Andrea Cremaschi on 18/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OfflineRenderer.h"

@class PBufferRenderer;
@interface QCMaskRenderer : OfflineRenderer {
	QCRenderer*					_renderer;
}

// Accessors
- (QCRenderer *)renderer;

// QCRenderer methods
- (id) valueForOutputKey:(NSString*)key;
- (id) valueForOutputKey:(NSString*)key ofType:(NSString*)type;
- (BOOL) setValue:(id)value forInputKey:(NSString *)inputKey;
- (BOOL) renderAtTime:(NSTimeInterval)time arguments:(NSDictionary*)arguments;
- (BOOL) updateTextureForTime:(NSTimeInterval)time;

- (BOOL) feedVideoInputWithOutputOfRenderer: (OfflineRenderer *)srcRenderer ;
- (bool) feedVideoInputWithCVPixelBuffer: (CVImageBufferRef) cvPixelBufferRef;
- (id) createSnapshotImageOfType:(NSString*)type;


// constructor methods
+ (QCMaskRenderer *) createMaskWithCompositionPath: (NSString*)path	
									 usingRenderer: (OfflineRenderer *) renderer;
+ (QCMaskRenderer *) createFilterWithCompositionPath: (NSString*)path	
									   usingRenderer: (OfflineRenderer *) renderer;



@end
