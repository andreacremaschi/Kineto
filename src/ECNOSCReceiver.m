//
//  ECNLine.m
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 31/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ECNOSCReceiver.h"
#import "ECNProjectDocument.h"
#import <OpenGL/CGLMacro.h>  // Set up using macros


	
@implementation ECNOSCReceiver

// +  + Elements specific properties  +
// +  +  +  +  +  +  +  +  +  +  +  +


// +  + Default values  +  +  +  +  +
NSString *ECNOSCReceiverClassValue = @"OSCReceiver";
NSString *OSCReceiverNameDefaultValue = @"localhost receiver";
// +  +  +  +  +  +  +  +  +  +  +  +

#pragma mark *** Accessors

- (void) setInPort: (int) inPort {
	_inPort = inPort;
}

- (int) inPort	{
	return _inPort;
}

- (void) initOSCIcon
{
	NSString *strOSCIconPath = [[[NSString alloc] initWithString: [[NSBundle mainBundle] pathForResource:@"osc_receiver" ofType:@"tif"]] autorelease];
	NSImage *OSCIcon = [[NSImage allocWithZone:[[[super scene] document] zone]] initWithContentsOfFile:strOSCIconPath];
	if (OSCIcon) {
		[self setBounds:NSMakeRect(0, 0, [OSCIcon size].width, [OSCIcon size].height)];
		[self setImage: OSCIcon];
	}
}


- (id) init
{
    self = [super init];
    if (self) {
		
		[super setName: @"New OSC receiver"];
		_inPort = kOSCDefaultPort; //arc4random() % 65535; // default to a random port
		[self initOSCIcon];
		
	}
	return self;
}



- (NSMutableDictionary *) attributesDictionary	{
	
	NSMutableDictionary* dict = [super attributesDictionary];
	
	// set default attributes values
	[dict setValue: ECNOSCReceiverClassValue forKey: ECNObjectClassKey];
	
	// define class specific attributes	
	NSDictionary *propertiesDict = [NSDictionary dictionaryWithObjectsAndKeys:
									nil];
	
	[[dict objectForKey: ECNPropertiesKey] addEntriesFromDictionary: propertiesDict ];
	
	return dict;
	
	
}

#pragma mark Constructors
+ (ECNOSCReceiver *)oscReceiverWithDocument: (ECNProjectDocument *)document {
	ECNOSCReceiver *newOscReceiver = [[[ECNOSCReceiver alloc] initWithProjectDocument: document] autorelease];
	
	if (newOscReceiver != nil)	{
		[newOscReceiver setValue: OSCReceiverNameDefaultValue forPropertyKey: ECNObjectNameKey];
	}
	return newOscReceiver;
	
}

+ (ECNOSCReceiver *)elementWithDocument: (ECNProjectDocument *)document	{
	return [ECNOSCReceiver oscReceiverWithDocument: document];
}


#pragma mark *** Other

- (id)copyWithZone:(NSZone *)zone {
    id newObj = [super copyWithZone:zone];
	
    [newObj setImage:[self image]];

    return newObj;
}

- (void)ECN_clearCachedImage {
    if (_cachedImage != _image) {
        [_cachedImage release];
    }
    _cachedImage = nil;
}

- (void)setImage:(NSImage *)image {
    if (image != _image) {
        [[[self undoManager] prepareWithInvocationTarget:self] setImage:_image];
        [_image release];
        _image = [image retain];
        [self ECN_clearCachedImage];
        [self didChange];
    }
}

- (NSImage *)image {
    return _image;
}

- (NSImage *)transformedImage {
    if (!_cachedImage) {
//        NSRect bounds = [self bounds];
 //       NSImage *image = [self image];
 //       NSSize imageSize = [image size];
        
      //  if (NSEqualSizes(bounds.size, imageSize)) {
            _cachedImage = _image;
       /* } else if (!NSIsEmptyRect(bounds)) {
                       
            _cachedImage = [[NSImage allocWithZone:[self zone]] initWithSize:bounds.size];
            if (!NSIsEmptyRect(bounds)) {
                // Only draw in the image if it has any content.
                [_cachedImage lockFocus];
                [[image bestRepresentationForDevice:nil] drawInRect:NSMakeRect(0.0, 0.0, bounds.size.width, bounds.size.height)];
                [_cachedImage unlockFocus];
            }
        }*/
    }
    return _cachedImage;
}


/*- (BOOL)drawsFill {
    // ECNOSCReceiver never draw fill
    return NO;
}

- (BOOL)canDrawFill {
    // ECNOSCReceiver never draw fill
    return NO;
}*/

- (BOOL)hasNaturalSize {
    // ECNOSCReceiver have "natural" size
    return YES;
}


#pragma mark *** Drawing
/*
- (NSBezierPath *)bezierPath {
    NSBezierPath *path = [NSBezierPath bezierPath];
    NSRect bounds = [self bounds];
    
    if ([self startsAtLowerLeft]) {
        [path moveToPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds))];
        [path lineToPoint:NSMakePoint(NSMaxX(bounds), NSMinY(bounds))];
    } else {
        [path moveToPoint:NSMakePoint(NSMinX(bounds), NSMinY(bounds))];
        [path lineToPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds))];
    }
	
    [path setLineWidth:[self strokeLineWidth]];
	
    return path;
}
*/

- (void)drawInView:(NSView *)view isSelected:(BOOL)flag {
    NSRect bounds = [self bounds];
    NSImage *image;
    
/*    if ([self drawsFill]) {
        [[self fillColor] set];
        NSRectFill(bounds);
    }*/
    image = [self transformedImage];
    if (image) {
		[image drawAtPoint: NSMakePoint(bounds.origin.x, bounds.origin.y)
					fromRect: NSZeroRect
					operation: NSCompositeSourceOver 
					fraction:1.0f];
//        [image compositeToPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds)) operation:NSCompositeSourceOver];
    }
    [super drawInView:view isSelected:flag];
}



- (void) drawInOpenGLContext: (NSOpenGLContext *)openGLContext {
	
	/*NSRect drawingBounds = [self normBounds];
	GLint saveMode;
	NSPoint startPoint, endPoint;
	
	if (![self startsAtLowerLeft]) {
		startPoint = NSMakePoint(drawingBounds.origin.x, drawingBounds.origin.y);
		endPoint = NSMakePoint(drawingBounds.origin.x + drawingBounds.size.width, drawingBounds.origin.y - drawingBounds.size.height);
	} else {
		startPoint = NSMakePoint(drawingBounds.origin.x, drawingBounds.origin.y - drawingBounds.size.height);
		endPoint = NSMakePoint(drawingBounds.origin.x + drawingBounds.size.width, drawingBounds.origin.y);		
	}	
	// NSLog(@"curElement bound coord is %fx:%fy, %fw:%fh ", drawingBounds.origin.x, drawingBounds.origin.y, drawingBounds.size.width, drawingBounds.size.height);
	CGLContextObj cgl_ctx = [openGLContext CGLContextObj];
	glGetIntegerv(GL_MATRIX_MODE, &saveMode);
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
	
	glBegin(GL_LINES);
	glEnable(GL_LINE_SMOOTH);
	
	GLfloat sizes[2];  // Store supported line width range
	GLfloat step;     // Store supported line width increments
	
	glGetFloatv(GL_LINE_WIDTH_RANGE, sizes);
	glGetFloatv(GL_LINE_WIDTH_GRANULARITY, &step);
	
	
	//imposta la dimensione della linea a seconda se l'elemento è stato azionato oppure no
	if ([self isTriggered]) {
		glLineWidth((GLfloat)sizes[0] + step*3);
		glColor3f(1.0f, 0.0f, 0.0f);
	}
	else {
		glLineWidth(sizes[0]);
		glColor3f(1.0f, 1.0f, 1.0f);
	}
	
	glVertex2f(startPoint.x, startPoint.y);
	glVertex2f(endPoint.x, endPoint.y);	
	
	glEnd();
	
	//After drawing, restore original OpenGL states.
    glPopMatrix();
    glMatrixMode(saveMode);
	
    // Check for errors.
    glGetError();*/
}


- (unsigned)knobMask {

        return (NoKnob);

}


#pragma mark *** Playback

- (float) checkActivityOnElementInCurrentOpenGLContextWithMotionMask: (NSBitmapImageRep*) motion_mask
														withDiffMask: (NSBitmapImageRep*) diff_mask
{
	if (!_oscReceiverIsActive)	{
		// activate receiver
	}
	
	return 0.0;
	
}




@end
