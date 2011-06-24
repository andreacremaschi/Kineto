//
//  ECNAssetInstance.m
//  kineto
//
//  Created by Andrea Cremaschi on 23/02/11.
//  Copyright 2011 AndreaCremaschi. All rights reserved.
//

#import "ECNAssetInstance.h"

// +  + Elements specific properties   +
NSString *AssetKey = @"asset";
// +  +  +  +  +  +  +  +  +  +  +  +  +

// +  +  + asset input ports +  +  +
NSString *AssetInstanceAssetInportsKey = @"asset_inports";

// +  +  +  +  +  +  +  +  +  +  +  +

// +  +  + asset output ports +  +  +
NSString *AssetInstanceAssetOutportsKey = @"asset_outports";
// +  +  +  +  +  +  +  +  +  +  +  +


// +  + Default values  +  +  +  +  +
NSString *AssetInstanceClassValue = @"ECNAssetInstance";
NSString *AssetInstanceDefaultNameValue = @"Asset instance";
NSString *AssetInstanceGenericIconDefaultValue = @"osc_receiver";
// +  +  +  +  +  +  +  +  +  +  +  +



@implementation ECNAssetInstance


- (NSMutableDictionary *) attributesDictionary	{
	
	
	NSMutableDictionary* dict = [super attributesDictionary];
	
	// set default attributes values
	[dict setValue: AssetInstanceClassValue forKey: ECNObjectClassKey];
	
	NSDictionary *propertiesDict = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNull null], AssetInstanceAssetInportsKey,
									[NSNull null], AssetInstanceAssetOutportsKey,
									[NSNull null], AssetKey, 
									nil];
	
	
	//[_attributes addEntriesFromDictionary: attributesDict];
	[[dict objectForKey: ECNPropertiesKey] addEntriesFromDictionary: propertiesDict ];
	
	return dict;
	
	
}


- (id) initWithAsset: (ECNAsset *)asset
{
	self = [super initWithProjectDocument: [asset document]];
	if (self) {
		
//		NSDictionary *dict;
		
		if (asset)
			[self setValue: asset forPropertyKey: AssetKey];
		
		// INPUT PORTS
		
		/*for (dict in [asset valueForPropertyKey: QCAssetOutputPortsKey]
		 [self addInputPortWithType:ECNPortTypeImage 
		 forKey:ShapeInputMaskImage 
		 withAttributes:nil];
		 
		 
		 
		 // OUTPUT PORTS		
		 [self addOutputPortWithType: ECNPortTypeImage
		 forKey: ShapeOutputImage
		 withAttributes: nil];*/
		
	}
	return self;	
}

- (void)dealloc {
	
    [super dealloc];
}

+ (Class) triggerClass		{
	return nil; //[ECNShapeTrigger class];
}

+ (Class )assetType	{
	return nil;			  
}


+ (NSString *)iconName	{
	return AssetInstanceGenericIconDefaultValue;
}


#pragma mark Constructors
+ (ECNAssetInstance *)assetInstanceWithAsset: (ECNAsset *) asset	{
	return nil;
}
			  
			  
// abstract class: no constructors!
/*+ (ECNElement *)assetInstanceWithDocument: (ECNProjectDocument *)document	{
	
	ECNQCAssetInstance *qcInstance = [[[ECNQCAssetInstance alloc] initWithProjectDocument: document] autorelease];
	if (qcInstance != nil)	{
		[qcInstance setValue: QCAssetInstanceClassValue forPropertyKey: ECNObjectClassKey];
		[qcInstance setValue: QCAssetInstanceDefaultNameValue forPropertyKey: ECNObjectNameKey];
		
	}
	return qcInstance;
	
	return nil;
	
}
*/

#pragma mark Accessors

- (ECNAsset *)asset	{
	return [self valueForPropertyKey: AssetKey];
}

- (void) setAsset: (ECNAsset *)asset	{
	
	NSString *errorString = [NSString stringWithFormat: @"Error: tried to set asset of type: %@ in asset instance of type: %@", [asset class], [self class]];
	NSAssert( [asset isKindOfClass: [[self class] assetType]], 
			 errorString);
	[self setValue: asset forPropertyKey: AssetKey];
	
}


- (NSImage *)iconInView: (NSView *)view	{

	NSString *strIconPath = [[NSBundle mainBundle] pathForResource: [[self class] iconName] ofType:@"tif"];
	static NSImage *genIcon;
	if (genIcon != nil) return genIcon; 
	
	genIcon = [[NSImage allocWithZone:[[[super cue] document] zone]] initWithContentsOfFile: strIconPath];

	// genIcon will be loaded with size: 15x15. Why?
	// TODO: resolve this issue
	if (genIcon) {
		NSLog(@"Loading icon image: '%@', size: %.f x %.f", strIconPath, [genIcon size].width, [genIcon size].height);
		[self setBounds:NSMakeRect(0, 
								   0, 
								   [genIcon size].width / [view bounds].size.width, 
								   [genIcon size].height / [view bounds].size.height)];
//		[self setImage: genIcon];
	}
	return genIcon;
}


#pragma mark ECNElement overrides
#pragma mark Drawing methods

- (BOOL)hitTest:(NSPoint)point 
	 isSelected:(BOOL)isSelected 
		 inView:(NSView *)ecnView {
	return false;
}

// an asset instance acts in elementsview as an invisible element
- (bool) isVisible {
	return false;
}

- (unsigned)knobMask {
	return (NoKnob);
}

- (void)drawInView:(NSView *)view 
		isSelected:(BOOL)flag {
	
   /* NSRect bounds = [self calcDrawingBoundsInView: view];
    NSImage *image;
    
    image = [self iconInView: view];
    if (image) {
		[image drawAtPoint: NSMakePoint(bounds.origin.x, bounds.origin.y)
				  fromRect: NSZeroRect
				 operation: NSCompositeSourceOver 
				  fraction: 1.0f];
		//        [image compositeToPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds)) operation:NSCompositeSourceOver];
    }
//    [super drawInView:view isSelected:flag];*/
	
	
}


// asset instances won't draw in liveView (for now...)
- (void) drawInOpenGLContext: (NSOpenGLContext *)openGLContext
{	
	return;
}

@end
