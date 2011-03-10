//
//  ECNElementActivityInspectorWindowController.m
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 18/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SynthesizeSingleton.h"
#import "ECNElementActivityInspectorWindowController.h"
#import "ElementsView.h"
#import "ECNElement.h"
#import "ECNSceneWindowController.h"
#import "WBIPv4Control.h"

@implementation ECNElementActivityInspectorWindowController

SYNTHESIZE_SINGLETON_FOR_CLASS(ECNElementActivityInspectorWindowController);

- (id)init {
	
	if (![self initWithWindowNibName: @"ActivityInspector"])
	{
		NSLog(@"Could not init Element Activity inspector!");
		return nil;
	}
    
//	[self setWindowFrameAutosaveName:@"Inspector"];
	needsUpdate = NO;
    
	return self;
}



#pragma mark *** update window ***


#pragma mark ***// TODO NNBB: questo controllo sta pescando gli elementi selezionati nella liveView attiva
#pragma mark ***// ma non deve fare così! deve visualizzare gli elementi attualmente controllati dal playbackcontroller

- (void)windowDidUpdate:(NSNotification *)notification {
    if (needsUpdate) {
        NSArray *selectedElements = [_inspectingElementsView selectedElements];
        unsigned c = (selectedElements ? [selectedElements count] : 0);
        ECNElement *element;
		
        needsUpdate = NO;
        
        if (c == 1) {
			
            element = [selectedElements objectAtIndex:0];
//            bounds = [element bounds];
//            tempFlag = [graphic drawsFill];
 /*           [fillCheckbox setState:(tempFlag ? NSOnState : NSOffState)];
            [fillCheckbox setEnabled:[graphic canDrawFill]];
            [fillColorWell setColor:([graphic fillColor] ? [graphic fillColor] : [NSColor clearColor])];
            [fillColorWell setEnabled:tempFlag];
            tempFlag = [graphic drawsStroke];
            [lineCheckbox setState:(tempFlag ? NSOnState : NSOffState)];
            [lineCheckbox setEnabled:[graphic canDrawStroke]];
            [lineColorWell setColor:([graphic strokeColor] ? [graphic strokeColor] : [NSColor clearColor])];
            [lineColorWell setEnabled:tempFlag];
            [lineWidthSlider setFloatValue:[graphic strokeLineWidth]];
            [lineWidthSlider setEnabled:tempFlag];
            [lineWidthTextField setFloatValue:[graphic strokeLineWidth]];
            [lineWidthTextField setEnabled:tempFlag];
            [xTextField setFloatValue:bounds.origin.x];
            [xTextField setEnabled:YES];
            [yTextField setFloatValue:bounds.origin.y];
            [yTextField setEnabled:YES];
            [widthTextField setFloatValue:bounds.size.width];
            [widthTextField setEnabled:YES];
            [heightTextField setFloatValue:bounds.size.height];
            [heightTextField setEnabled:YES];*/
        } else if (c > 1) {
            // MF: Multiple selection should be editable
/*            [fillCheckbox setState:NSMixedState];
            [fillCheckbox setEnabled:NO];
            [fillColorWell setColor:[NSColor whiteColor]];
            [fillColorWell setEnabled:NO];
            [lineCheckbox setState:NSMixedState];
            [lineCheckbox setEnabled:NO];
            [lineColorWell setColor:[NSColor whiteColor]];
            [lineColorWell setEnabled:NO];
            [lineWidthSlider setFloatValue:0.0];
            [lineWidthSlider setEnabled:NO];
            [lineWidthTextField setStringValue:@"--"];
            [lineWidthTextField setEnabled:NO];
            [xTextField setStringValue:@"--"];
            [xTextField setEnabled:NO];
            [yTextField setStringValue:@"--"];
            [yTextField setEnabled:NO];
            [widthTextField setStringValue:@"--"];
            [widthTextField setEnabled:NO];
            [heightTextField setStringValue:@"--"];
            [heightTextField setEnabled:NO];*/
        } else {
/*            [fillCheckbox setState:NSOffState];
            [fillCheckbox setEnabled:NO];
            [fillColorWell setColor:[NSColor whiteColor]];
            [fillColorWell setEnabled:NO];
            [lineCheckbox setState:NSOffState];
            [lineCheckbox setEnabled:NO];
            [lineColorWell setColor:[NSColor whiteColor]];
            [lineColorWell setEnabled:NO];
            [lineWidthSlider setFloatValue:0.0];
            [lineWidthSlider setEnabled:NO];
            [lineWidthTextField setFloatValue:0.0];
            [lineWidthTextField setEnabled:NO];
            [xTextField setStringValue:@""];
            [xTextField setEnabled:NO];
            [yTextField setStringValue:@""];
            [yTextField setEnabled:NO];
            [widthTextField setStringValue:@""];
            [widthTextField setEnabled:NO];
            [heightTextField setStringValue:@""];
            [heightTextField setEnabled:NO];*/
        }
    }
}

#pragma mark *** change bind elements properties ***

#pragma mark *** change observed view and elements ***

- (void)setMainWindow:(NSWindow *)mainWindow {
    NSWindowController *controller = [mainWindow windowController];
	
    if (controller && [controller isKindOfClass:[ECNSceneWindowController class]]) {
        _inspectingElementsView = [(ECNSceneWindowController *)controller elementsView];
    } else {
        _inspectingElementsView = nil;
    }
    needsUpdate = YES;
}

#pragma mark *** delegate of NSWindow ***


- (void)awakeFromNib {
	
	/*[activityIndicator setMinValue: 0.0];
	[activityIndicator setMaxValue: 1.0];	
	[activityIndicator setFloatValue: 0.0];	*/
}

- (void)windowDidLoad {
	[super windowDidLoad];

	//We need to know when the rendering view frame changes so that we can update the OpenGL context
    [self setMainWindow:[NSApp mainWindow]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowChanged:) name:NSWindowDidBecomeMainNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowResigned:) name:NSWindowDidResignMainNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionChanged:) name:ElementsViewSelectionDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(elementChanged:) name:ECNElementDidChangeNotification object:nil];

	
}


#pragma mark *** notifications methods ***

- (void)mainWindowChanged:(NSNotification *)notification {
    [self setMainWindow:[notification object]];
}

- (void)mainWindowResigned:(NSNotification *)notification {
    [self setMainWindow:nil];
}

- (void)elementChanged:(NSNotification *)notification {
    if (_inspectingElementsView) {
        if ([[_inspectingElementsView selectedElements] containsObject:[notification object]]) {
            needsUpdate = YES;
        }
    }
}

- (void)selectionChanged:(NSNotification *)notification {
    if ([notification object] == _inspectingElementsView) {
        needsUpdate = YES;
    }
}


#pragma mark *** other methods ***

- (void) drawLevelIndicatorInView: (NSView *) view withActivityLevel: (float) activity withThreshold: (float) threshold
{
	[activityIndicator setActivity:activity Threshold:threshold];

	
	
}

- (void) updateActivityLevels {
		needsUpdate = YES;

		if (!_inspectingElementsView) return;
        NSArray *selectedElements = [_inspectingElementsView selectedElements];
        unsigned c = (selectedElements ? [selectedElements count] : 0);
        ECNElement *element;
		
        needsUpdate = NO;
        
        if (c == 1) {
			element = [selectedElements objectAtIndex: 0];
			[elementNameLabel setStringValue: [element name]];
			[activityLabel setStringValue: [[NSString alloc ]initWithFormat: @"%.2f",  0 ]];// ([element activity])]];
			[self drawLevelIndicatorInView: activityIndicator withActivityLevel: 0 withThreshold: 0];
//			 [element activity] withThreshold: [element triggerThreshold]];
		}
		
		
}			

#pragma mark *** dealloc ***

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
@end


@implementation ECNActivityIndicator


- (void) setActivity: (float) activity Threshold: (float) triggerThreshold {
	if (!((_activity == activity) && (_triggerThreshold == triggerThreshold))) [self setNeedsDisplay:YES];
	_activity = activity;
	_triggerThreshold = triggerThreshold;
}

- (void)drawRect:(NSRect)rect {


	NSGraphicsContext* theContext = [NSGraphicsContext currentContext]; 

	[theContext saveGraphicsState];

	// Clean up background 
	[[NSColor darkGrayColor] set];
	NSRectFill([self bounds]);

	
	// init rect
	NSRect levelRect;
	levelRect.origin.x=0;
	levelRect.origin.y=0;
	levelRect.size.height=[self bounds].size.height;

	// sensitivity rect
	[[NSColor grayColor] set];
	levelRect.size.width=[self bounds].size.width * _triggerThreshold;
	NSRectFill(levelRect);

	// activity rect
	levelRect.size.width=[self bounds].size.width * _activity;
	if (_activity > _triggerThreshold) [[NSColor greenColor] set]; else [[NSColor yellowColor] set];
	NSRectFill(levelRect);
	
	[theContext restoreGraphicsState];

}

@end
