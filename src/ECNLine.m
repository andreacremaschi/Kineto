//
//  ECNLine.m
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 31/10/10.
//  Copyright 2010 AndreaCremaschi. All rights reserved.
//

#import "ECNLine.h"
#import <OpenGL/CGLMacro.h>  // Set up using macros


@implementation ECNLine

// +  + Default values  +  +  +  +  +
NSString *LineClassValue = @"Line";
NSString *LineNameDefaultValue = @"New line";
// +  +  +  +  +  +  +  +  +  +  +  +

#pragma mark *** Accessors

- (NSMutableDictionary *) attributesDictionary	{
	
	NSMutableDictionary* dict = [super attributesDictionary];

	// set default attributes values
	[dict setValue: LineClassValue forKey: ECNObjectClassKey];
	
	NSDictionary *propertiesDict = [NSDictionary dictionaryWithObjectsAndKeys:
									nil];
	
	//[_attributes addEntriesFromDictionary: attributesDict];
	[[dict objectForKey: ECNPropertiesKey] addEntriesFromDictionary: propertiesDict ];
	
	return dict;
	
	
}

#pragma mark *** Constructors ***


+ (ECNLine *)lineWithDocument: (ECNProjectDocument *)document {
	ECNLine *newLine = [[[ECNLine alloc] initWithProjectDocument: document] autorelease];
	
	if (newLine != nil)	{
		
		[newLine setValue: LineClassValue forPropertyKey: ECNObjectClassKey];
		[newLine setIncrementalNameWithRootName: LineNameDefaultValue];

	}
	return newLine;
	
}

+ (ECNElement *)elementWithDocument: (ECNProjectDocument *)document	{
	return [ECNLine lineWithDocument: document];
}

#pragma mark *** Other

- (id)copyWithZone:(NSZone *)zone {
    id newObj = [super copyWithZone:zone];
	
    [newObj setStartsAtLowerLeft:[self startsAtLowerLeft]];
	
    return newObj;
}

- (void)setStartsAtLowerLeft:(BOOL)flag {
    if (_startsAtLowerLeft != flag) {
        [[[self undoManager] prepareWithInvocationTarget:self] setStartsAtLowerLeft:_startsAtLowerLeft];
        _startsAtLowerLeft = flag;
        [self didChange];
    }
}

- (BOOL)startsAtLowerLeft {
    return _startsAtLowerLeft;
}

- (void)flipHorizontally {
    [self setStartsAtLowerLeft:![self startsAtLowerLeft]];
    return;
}

- (void)flipVertically {
    [self setStartsAtLowerLeft:![self startsAtLowerLeft]];
    return;
}

/*- (BOOL)drawsFill {
    // ECNLines never draw fill
    return NO;
}

- (BOOL)canDrawFill {
    // ECNLines never draw fill
    return NO;
}
*/
- (BOOL)hasNaturalSize {
    // ECNLines have no "natural" size
    return NO;
}


#pragma mark *** Drawing


- (NSBezierPath *)bezierPathInRect: (NSRect )rect {
    NSBezierPath *path = [NSBezierPath bezierPath];
	NSRect drawingBounds = [self calcPixelBoundsInRect: rect]; 
    
    if ([self startsAtLowerLeft]) {
        [path moveToPoint:NSMakePoint(NSMinX(drawingBounds), NSMaxY(drawingBounds))];
        [path lineToPoint:NSMakePoint(NSMaxX(drawingBounds), NSMinY(drawingBounds))];
    } else {
        [path moveToPoint:NSMakePoint(NSMinX(drawingBounds), NSMinY(drawingBounds))];
        [path lineToPoint:NSMakePoint(NSMaxX(drawingBounds), NSMaxY(drawingBounds))];
    }
	
    [path setLineWidth: 1.0];
	
    return path;
}


- (CGMutablePathRef)quartzPathInRect: (CGRect) rect {
	
	NSRect drawingBounds = [self calcPixelBoundsInRect: NSRectToCGRect( rect )]; 
//	CGRect cgDrawingBounds = NSRectToCGRect(drawingBounds);
	
	// CG contexts are upside down in respect of NS graphics contexts!
	drawingBounds.origin.y = rect.size.height - drawingBounds.origin.y - drawingBounds.size.height;
	
	
    CGMutablePathRef path = CGPathCreateMutable();
	
	if ([self startsAtLowerLeft]) {
		CGPathMoveToPoint(path, 
						  nil,
						  NSMinX(drawingBounds),
						  NSMinY(drawingBounds));
		CGPathAddLineToPoint (path,
							  nil,
							  NSMaxX(drawingBounds),
							  NSMaxY(drawingBounds));
		
    } else {
		CGPathMoveToPoint(path, 
						  nil,
						  NSMinX(drawingBounds),
						  NSMaxY(drawingBounds));
		CGPathAddLineToPoint (path,
							  nil,
							  NSMaxX(drawingBounds),
							  NSMinY(drawingBounds));
		
		/*        [path moveToPoint:NSMakePoint(NSMinX(drawingBounds), NSMinY(drawingBounds))];
        [path lineToPoint:NSMakePoint(NSMaxX(drawingBounds), NSMaxY(drawingBounds))];*/
    }
	
	CGPathCloseSubpath ( path);
	return path;
}


- (void) drawInOpenGLContext: (NSOpenGLContext *)openGLContext {
	
	NSRect drawingBounds = [self bounds];
	GLint saveMode;
	NSPoint startPoint, endPoint;
	
	
	drawingBounds.origin.x=drawingBounds.origin.x*2.0-1.0;
	drawingBounds.origin.y=1.0-drawingBounds.origin.y*2.0;
	drawingBounds.size.width*=2.0;
	drawingBounds.size.height*=2.0;
	
	
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
/*	if ([self isTriggered]) {
		glLineWidth((GLfloat)sizes[0] + step*3);
		glColor3f(1.0f, 0.0f, 0.0f);
	}
	else {*/
		glLineWidth(sizes[0]);
		glColor3f(1.0f, 1.0f, 1.0f);
//	}
	
	glVertex2f(startPoint.x, startPoint.y);
	glVertex2f(endPoint.x, endPoint.y);	
	
	glEnd();
	
	//After drawing, restore original OpenGL states.
    glPopMatrix();
    glMatrixMode(saveMode);
	
    // Check for errors.
    glGetError();
}


- (unsigned)knobMask {
    if ([self startsAtLowerLeft]) {
        return (LowerLeftKnobMask | UpperRightKnobMask);
    } else {
        return (UpperLeftKnobMask | LowerRightKnobMask);
    }
}

- (BOOL)hitTest:(NSPoint)point isSelected:(BOOL)isSelected inView:(NSView *)view {
    if (isSelected && ([super knobUnderPoint:point inView: view] != NoKnob)) {
        return YES;
    } else {
        NSRect bounds = [self bounds];
        float halfWidth =1.0 / 2.0;
        halfWidth += 2.0;  // Fudge
        if (bounds.size.width == 0.0) {
            if (fabs(point.x - bounds.origin.x) <= halfWidth) {
                return YES;
            }
        } else {
            BOOL startsAtLowerLeft = [self startsAtLowerLeft];
            float slope = bounds.size.height / bounds.size.width;
			
            if (startsAtLowerLeft) {
                slope = -slope;
            }
			
            
            if (fabs(((point.x - bounds.origin.x) * slope) - (point.y - (startsAtLowerLeft ? NSMaxY(bounds) : bounds.origin.y))) <= halfWidth) {
                return YES;
            }
        }
        return NO;
    }
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

// implementa l'algoritmo di Bresenham!
/*- (float) checkActivityOnElementInCurrentOpenGLContextWithMask:	(NSBitmapImageRep*)mask

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
		
	
	

	//NSLog (@"Bits per pixel: %i", [mask bitsPerPixel]); //32
	//NSLog (@"Samples per pixel: %i", [mask samplesPerPixel]); //4
	
	// ottieni le giuste coordinate della linea
	// nel sistema di riferimento in pixel della texture opengl (0, 0, width, height)
	
	
		//NSLog(@"New line");
	
	NSRect drawingBounds = [self bounds];

	if (![self startsAtLowerLeft]) {
		startPoint = NSMakePoint(drawingBounds.origin.x, drawingBounds.origin.y);
		endPoint = NSMakePoint(drawingBounds.origin.x + drawingBounds.size.width, drawingBounds.origin.y - drawingBounds.size.height);
	} else {
		startPoint = NSMakePoint(drawingBounds.origin.x, drawingBounds.origin.y - drawingBounds.size.height);
		endPoint = NSMakePoint(drawingBounds.origin.x + drawingBounds.size.width, drawingBounds.origin.y);		
	}		
	
	NSAssert (startPoint.x < endPoint.x, @"startpointx non può essere > endpoint.x!");
	
//	NSSize mask_size = diff_mask.size; 
	NSSize mask_size;
	mask_size.width=[mask size].width; 
	mask_size.height=[mask size].height; 
	
	// adatta le coordinate a uno spazio 0:1 - 0:1
	startPoint.x = (startPoint.x + 1.0) / 2.0;
	startPoint.y = (1.0 - startPoint.y) / 2.0;
	endPoint.x = (endPoint.x + 1.0) / 2.0;
	endPoint.y = (1.0 - endPoint.y) / 2.0;
	
	int x1 = startPoint.x * mask_size.width; 
	int y1 = (startPoint.y) * mask_size.height; 
	int x2 = endPoint.x	* mask_size.width;
	int y2 = (endPoint.y)	* mask_size.height;

	
	
//	id rect_buffer = malloc( * 3);
	NSRect rect;
	rect.origin.x = x1;
	rect.origin.y = y2<y1 ? (mask_size.height - y2) : (mask_size.height - y1); // l'immagine è a testa in giù!!!!
	rect.size.width = x2 - x1;
	rect.size.height = abs(y2 - y1);
	
	
	//NSLog(@"Allocationg buffer with values: x %f y %f width %f height %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
	
	void * membuffer = [mask bitmapData];
	if (membuffer == nil) return 0.0;

	// ALGORITMO DI BRESENHAM per il tracciamento delle linee
	
	int deltax = abs(x2-x1);
	int deltay = abs(y2-y1);

	int xinc1 = 1;
	int xinc2 = 1;
	int yinc1, yinc2;
	int den, num, numadd, numpixels, curpixel;
	
	if (y2 >= y1)                 // The y-values are increasing
	{
		yinc1 = 1;
		yinc2 = 1;
	}
	else                          // The y-values are decreasing
	{
		yinc1 = -1;
		yinc2 = -1;
	}
	
	if (deltax >= deltay)         // There is at least one x-value for every y-value
	{
		xinc1 = 0;                  // Don't change the x when numerator >= denominator
		yinc2 = 0;                  // Don't change the y for every iteration
		den = deltax;
		num = deltax / 2;
		numadd = deltay;
		numpixels = deltax;         // There are more x-values than y-values
	}
	else                          // There is at least one y-value for every x-value
	{
		xinc2 = 0;                  // Don't change the x for every iteration
		yinc1 = 0;                  // Don't change the y when numerator >= denominator
		den = deltay;
		num = deltay / 2;
		numadd = deltax;
		numpixels = deltay;         // There are more y-values than x-values
	}

	
	// inizializza i valori di controllo
	numActivePixels = 0;
	lowestActivePixelPos = 0;
	highestActivePixelPos = 0;
	numPixels = 1;
	
	//assegna le coordinate iniziali
	x = x1;
	y = y1;


	// controlla se il punto (x, y) è vuoto o pieno
	//theColor = NSReadPixel(NSMakePoint(x, y));
	// TODO: fai qui gli stessi controlli che fai dentro!
	
	
	for (curpixel = 0; curpixel <= numpixels; curpixel++)
	{
		
		//theColor = [self readPixelFromBuffer: membuffer x: x y: y width: mask_size.width height:mask_size.height]; //NSReadPixel(NSMakePoint(x, mask_size.height - y));
		[mask getPixel: curPixel atX: x y: y];
		//NSLog (@"%i,%i,%i,%i",curPixel[0],curPixel[1],curPixel[2],curPixel[3]);
		
		if (curPixel[_actMonMask] == 255 )
		{
			bActive = true; 
		} else bActive = false;
		if (bActive) { 
			
			// fa la media delle tre componenti colore e confronta con la soglia di sensitività dell'elemento
			//if (([theColor redComponent] + [theColor greenComponent] + [theColor blueComponent]) / 3.0 > (1.0 - [self sensitivity])) {
				if (lowestActivePixelPos == 0) lowestActivePixelPos = numPixels;
				highestActivePixelPos = numPixels;
				numActivePixels ++;
			//}
			//NSLog(@"preso! x: %i, y: %i", x, y);
		}
		numPixels++;

		num += numadd;              // Increase the numerator by the top of the fraction
		if (num >= den)             // Check if numerator >= denominator
		{
			num -= den;               // Calculate the new numerator value
			x += xinc1;               // Change the x as appropriate
			y += yinc1;               // Change the y as appropriate
		}
		x += xinc2;                 // Change the x as appropriate
		y += yinc2;                 // Change the y as appropriate
	}
	
	
	middleActivePixelPos = lowestActivePixelPos > 0.0 ? (highestActivePixelPos + lowestActivePixelPos) / 2.0 : 0.0;

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
				default: returnValue = 0.0;	
			}
			break;
			
		case kActValTriggered:
			returnValue = numActivePixels > 0.0 ? 1.0 : 0.0;
			break;
			
		default:
			returnValue = 0.0; // non dovremmo mai finire qui, Dio ce ne scampi!
			break;
	}
//	NSLog (@"%.2f", returnValue);
	
	if (returnValue > [self triggerThreshold]) [super triggerElement];
	[super setActivity: returnValue];

	return returnValue;
	
}
*/

@end
