//
//  ECNRectangle.m
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 01/11/10.
//  Copyright 2010 AndreaCremaschi. All rights reserved.
//

#import "ECNRectangle.h"
#import	<OpenGL/CGLMacro.h>

// +  + Default values  +  +  +  +  +
NSString *RectangleClassValue = @"Rectangle";
NSString *RectangleNameDefaultValue = @"New rectangle";
// +  +  +  +  +  +  +  +  +  +  +  +


@implementation ECNRectangle




- (NSMutableDictionary *) attributesDictionary	{
	
	NSMutableDictionary* dict = [super attributesDictionary];
	
	// set default attributes values
	[dict setValue: RectangleClassValue forKey: ECNObjectClassKey];

	NSDictionary *propertiesDict = [NSDictionary dictionaryWithObjectsAndKeys:
									nil];
	
	//[_attributes addEntriesFromDictionary: attributesDict];
	[[dict objectForKey: ECNPropertiesKey] addEntriesFromDictionary: propertiesDict ];
		
	return dict;
	
	
}


#pragma mark *** Constructors ***


+ (ECNRectangle *)rectangleWithDocument: (ECNProjectDocument *)document {
	ECNRectangle *newRectangle = [[[ECNRectangle alloc] initWithProjectDocument: document] autorelease];
	if (newRectangle != nil)	{
		[newRectangle setValue: RectangleClassValue forPropertyKey: ECNObjectClassKey];
		[newRectangle setIncrementalNameWithRootName: RectangleNameDefaultValue];


	}
	return newRectangle;
	
}

+ (ECNElement *)elementWithDocument: (ECNProjectDocument *)document	{
	return [ECNRectangle rectangleWithDocument: document];
}

#pragma mark *** ECNElement overrides

- (NSBezierPath *)bezierPathInRect: (NSRect )rect {
	NSRect drawingBounds = [self calcPixelBoundsInRect: rect]; 

    NSBezierPath *path = [NSBezierPath bezierPathWithRect: drawingBounds];
	
    [path setLineWidth:1.0];
	
    return path;
}

- (CGMutablePathRef)quartzPathInRect: (CGRect) rect {
	
	NSRect drawingBounds = [self calcPixelBoundsInRect: NSRectFromCGRect( rect )]; 
	CGRect cgDrawingBounds = NSRectToCGRect(drawingBounds);
	
	// CG contexts are upside down in respect of NS graphics contexts!
	cgDrawingBounds.origin.y = rect.size.height - cgDrawingBounds.origin.y - cgDrawingBounds.size.height;
	
    CGMutablePathRef path = CGPathCreateMutable();

	CGPathAddRect (path,
				   nil,
				   cgDrawingBounds );

	CGPathCloseSubpath ( path );
	return path;
}
   




- (void) drawInOpenGLContext: (NSOpenGLContext *)openGLContext
{
	NSRect drawingBounds = [self bounds];
	GLint saveMode;
	NSPoint startPoint, endPoint;
	
//	if (![self startsAtLowerLeft]) {
	//convert to opengl coordinates
	drawingBounds.origin.x=drawingBounds.origin.x*2.0-1.0;
	drawingBounds.origin.y=1.0-drawingBounds.origin.y*2.0;
	drawingBounds.size.width*=2.0;
	drawingBounds.size.height*=2.0;
	
	startPoint = NSMakePoint(drawingBounds.origin.x, drawingBounds.origin.y);
	endPoint = NSMakePoint(drawingBounds.origin.x + drawingBounds.size.width, drawingBounds.origin.y - drawingBounds.size.height);
	

	/*	} else {
		startPoint = NSMakePoint(drawingBounds.origin.x, drawingBounds.origin.y - drawingBounds.size.height);
		endPoint = NSMakePoint(drawingBounds.origin.x + drawingBounds.size.width, drawingBounds.origin.y);		
	}	*/
	// NSLog(@"curElement bound coord is %fx:%fy, %fw:%fh ", drawingBounds.origin.x, drawingBounds.origin.y, drawingBounds.size.width, drawingBounds.size.height);
	
	CGLContextObj cgl_ctx = [openGLContext CGLContextObj];
	glGetIntegerv(GL_MATRIX_MODE, &saveMode);
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
	
	glBegin(GL_LINES);
//	glEnable(GL_LINE_SMOOTH);
	
	GLfloat sizes[2];  // Store supported line width range
	GLfloat step;     // Store supported line width increments
	
	glGetFloatv(GL_LINE_WIDTH_RANGE, sizes);
	glGetFloatv(GL_LINE_WIDTH_GRANULARITY, &step);
	
	bool isTriggered = false;
	for (ECNTrigger * trigger in [self triggers])
		if ([trigger isActive]) isTriggered = true;
	
	//imposta la dimensione della linea a seconda se l'elemento è stato azionato oppure no
	if (isTriggered) {
		glLineWidth((GLfloat)sizes[0] + step*3);
		glColor3f(1.0f, 0.0f, 0.0f);
	}
	else {
		glLineWidth(sizes[0]);
		glColor3f(1.0f, 1.0f, 1.0f);
	}
	
	glVertex2f(startPoint.x, startPoint.y);
	glVertex2f(endPoint.x, startPoint.y);
	
	glVertex2f(endPoint.x, startPoint.y);
	glVertex2f(endPoint.x, endPoint.y);
	
	glVertex2f(endPoint.x, endPoint.y);
	glVertex2f(startPoint.x, endPoint.y);
	
	glVertex2f(startPoint.x, endPoint.y);
	glVertex2f(startPoint.x, startPoint.y);
//	glVertex2f(startPoint.x, startPoint.y);

	
	glEnd();
	
	//After drawing, restore original OpenGL states.
    glPopMatrix();
    glMatrixMode(saveMode);
	
    // Check for errors.
    glGetError();
	
	
	[super drawInOpenGLContext: openGLContext];
}



- (void)makeNaturalSize {
    NSRect bounds = [self bounds];
    if (bounds.size.width < bounds.size.height) {
        bounds.size.height = bounds.size.width;
        [self setBounds:bounds];
    } else if (bounds.size.width > bounds.size.height) {
        bounds.size.width = bounds.size.height;
        [self setBounds:bounds];
    }
}



#pragma mark *** ECNShape overrides

// optimization override:
// Rectangles don't need to perform mask operations!
// just crop and return
- (CIImage*) calculateMaskImageWithMask: (CIImage *)cimask	{
	
	NSRect srcRect = NSRectFromCGRect( [cimask extent] );
	
	NSRect cropRect = [self calcPixelBoundsInRect: srcRect];
	cropRect.origin.y = [cimask extent].size.height - cropRect.origin.y - cropRect.size.height;
	
//	CIImage * shapeImage = [self valueForOutputKey: ShapeOutputShapeImage];
	CIImage * cropSrcImage = [super CIcropImage: cimask withRect: cropRect ];
	
//	CIImage * result = [self CIMultiplyWithInputImage: cropSrcImage
//								  withBackgroundImage: shapeImage];
	return cropSrcImage;
}

#pragma mark *** Playback

- (NSColor *) readPixelFromBuffer: (void *) buffer x: (int) x y: (int) y width: (int) width height: (int)height{
	
	void *pixel = buffer + ((x + (height- y) * width)*4);
	
	float red = (float)*(GLubyte*)pixel / 255;
	float green = (float)*(GLubyte*)(pixel+1) / 255;
	float blue = (float)*(GLubyte*)(pixel+2) / 255;
	float alpha = (float)*(GLubyte*)(pixel+3) / 255;
	
	//NSColor * color = [NSColor colorWithDeviceRed: (CGFloat) *((GLubyte*)pixel[0])/255 green:(CGFloat) (*(GLubyte*)pixel[1])/255 blue:(CGFloat) (*(GLubyte*)pixel[2])/255 alpha:(CGFloat) (*(GLubyte*)pixel[3])/255];
	//	NSColor * color = [NSColor colorWithDeviceRed: 0.0 green:0.0 blue:0.0 alpha:0.0];;
	//if (!alpha == 0) NSLog(@"pixel at %ix, %iy coord is: %hu/%hu/%hu/%hu  ", x, y, *(GLubyte*)pixel, *(GLubyte*)(pixel+1), *(GLubyte*)(pixel+2), *(GLubyte*)(pixel+3) );
	
	return [NSColor colorWithDeviceRed: red green:green blue:blue alpha:alpha];
}


/*
- (float) checkActivityOnElementInCurrentOpenGLContextWithMask:	(NSBitmapImageRep*)mask
{
	NSPoint startPoint, endPoint;
	int x, y;
	bool bActive = false;
	int numActivePixels,		// numero di pixel attivi nella linea
	lowestActivePixelPos,	// il più basso dei pixel attivi
	highestActivePixelPos,	// il più alto dei pixel attivi
	middleActivePixelPos,	// il più alto dei pixel attivi
	numPixels;				// numero dei pixel nella linea
	NSUInteger curPixel[4];
	
	float returnValue;
	float alphaComponent;

		
	NSRect drawingBounds = [self bounds];
	
	startPoint = NSMakePoint(drawingBounds.origin.x, drawingBounds.origin.y);
	endPoint = NSMakePoint(drawingBounds.origin.x + drawingBounds.size.width, drawingBounds.origin.y - drawingBounds.size.height);
	
	NSAssert (startPoint.x < endPoint.x, @"startpointx non può essere > endpoint.x!");
	
	//NSLog(@"%i x %i", [mask size].width, [mask size].height);
		  
	// adatta le coordinate a uno spazio 0:1 - 0:1
	startPoint.x = (startPoint.x + 1.0) / 2.0;
	startPoint.y = (1.0 - startPoint.y) / 2.0;
	endPoint.x = (endPoint.x + 1.0) / 2.0;
	endPoint.y = (1.0 - endPoint.y) / 2.0;
	
	int x1 = startPoint.x * [mask size].width; 
	int y1 = (startPoint.y) * [mask size].height; 
	int x2 = endPoint.x	* [mask size].width;
	int y2 = (endPoint.y)	* [mask size].height;
	
	NSRect rect;
	rect.origin.x = x1;
	rect.origin.y = y2<y1 ? ([mask size].height - y2) : ([mask size].height - y1); // l'immagine è a testa in giù!!!!
	rect.size.width = x2 - x1;
	rect.size.height = abs(y2 - y1);
	
	// inizializza i valori di controllo
	numActivePixels = 0;
	lowestActivePixelPos = 0;
	highestActivePixelPos = 0;
	numPixels = 1;
	
	//assegna le coordinate iniziali
	x = x1;
	y = y1;
	
	// controlla se il punto (x, y) è vuoto o pieno	
	for (x = x1; x <x1+rect.size.width; x++)
	{
	  for (y = y1; y < y1+rect.size.height; y++)
	  {
		[mask getPixel: curPixel atX: x y: y];
		
		alphaComponent = (float)curPixel [_actMonMask];

		// la maschera è sul canale alpha!
		bActive = (alphaComponent > 0); 
		
		if (bActive) { 
			
			// fa la media delle tre componenti colore e confronta con la soglia di sensitività dell'elemento
			// if (([theColor redComponent] + [theColor greenComponent] + [theColor blueComponent]) / 3.0 > (1.0 - [self sensitivity])) {
				if (lowestActivePixelPos == 0) lowestActivePixelPos = numPixels;
				highestActivePixelPos = numPixels;
				numActivePixels ++;
			// }
			//NSLog(@"preso! x: %i, y: %i", x, y);
	    }
		numPixels++;
	  }
	}
	
	if (lowestActivePixelPos != 0)
		middleActivePixelPos = (highestActivePixelPos + lowestActivePixelPos) / 2;
	else
		middleActivePixelPos =0;
		
	// TODO sceglie il valore da restituire
	switch (_actVal) {
		case kActValActivityExtension:
			returnValue = (float) numActivePixels / numPixels;
			break;
			
		case kActValPosition:
			
			switch (_actPos)	{
				case kActPosHighest:
					returnValue = (float)highestActivePixelPos / numPixels;
					break;
				case kActPosLowest:
					returnValue = (float)lowestActivePixelPos / numPixels;
					break;
				case kActPosMiddle:
					returnValue = (float) middleActivePixelPos / numPixels;
					break;
					
			}
			break;
		case kActValTriggered:
			returnValue = numActivePixels > 0.0 ? 1.0 : 0.0;
			break;
			
		default:
			returnValue = 0.0; // non dovremmo mai finire qui, Dio ce ne scampi!
			break;
	}
	//NSLog (@"%.2f", returnValue);
	if (returnValue > [self triggerThreshold]) [super triggerElement];
	[super setActivity: returnValue];
	
	return returnValue;
	
}*/
@end
