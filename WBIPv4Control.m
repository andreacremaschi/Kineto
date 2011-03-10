/*
    Redistribution and use in source and binary forms, with or without modification,
    are permitted provided that the following conditions are met:

    Redistributions of source code must retain this list of conditions and the following disclaimer.

    The names of its contributors may not be used to endorse or promote products derived from this
    software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE CONTRIBUTORS "AS IS" AND ANY 
    EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT 
    SHALL THE CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT 
    OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
    HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "WBIPv4Control.h"

#define WBIPV4CONTROL_LEFT_OFFSET		3.5
#define WBIPV4CONTROL_INTERCELL_SPACE	2
#define WBIPV4CONTROL_RIGHT_OFFSET		3
#define WBIPV4CONTROL_TOP_OFFSET		3
#define WBIPV4CONTROL_BOTTOM_OFFSET		3

int _WBTimeControlMax[WBIPV4CONTROL_CELL_COUNT]={255,255,255,255};

@implementation WBIPv4Control

- (BOOL) acceptsFirstResponder
{
    return [self isEnabled];
}

- (BOOL) needsPanelToBecomeKey
{
    return YES;
}

- (BOOL) becomeFirstResponder
{
    BOOL tResult=[super becomeFirstResponder];
        
    if (tResult==YES)
    {
        NSSelectionDirection tSelectionDirection= [_window keyViewSelectionDirection];
        
        if (tSelectionDirection==NSSelectingNext)
        {
            [self editCell:0];
        }
        else if (tSelectionDirection==NSSelectingPrevious)
        {
            [self editCell:WBIPV4CONTROL_CELL_COUNT-1];
        }
        
        
    }
    
    return tResult;
}

+ (Class)cellClass
{
    return [NSTextFieldCell class];
}

- (id)cell
{
    return [self selectedCell];
}


- (void)setEnabled:(BOOL)flag
{
    int i;
    
    [super setEnabled:flag];
    
    for(i=0;i<WBIPV4CONTROL_CELL_COUNT;i++)
    {
        [cells[i] setEnabled:flag];
    }
}

- (id)selectedCell
{
    if (selected!=-1)
    {
        return cells[selected];
    }
    
    return nil;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        int i;
        NSRect tCellFrame;
        
        // No cell selected
        
        selected=-1;
        
        isUsingFieldEditor=NO;
        
        // Set the default date
        
        currentAddress_=0;
        
        // Create the 4 cells
        
        for(i=0;i<WBIPV4CONTROL_CELL_COUNT;i++)
        {
            cells[i]=[[NSTextFieldCell alloc] initTextCell:@"0"];
            [(NSTextFieldCell *) cells[i] setDrawsBackground:YES];
            [(NSTextFieldCell *) cells[i] setAlignment:NSCenterTextAlignment];
            [(NSTextFieldCell *) cells[i] setEditable:YES];
            [(NSTextFieldCell *) cells[i] setBordered:NO];
            [(NSTextFieldCell *) cells[i] setFont:[NSFont labelFontOfSize:13]];
        }
        
        // Create the 3 point cells
        
        for(i=0;i<(WBIPV4CONTROL_CELL_COUNT-1);i++)
        {
            pointCells[i]=[[NSTextFieldCell alloc] initTextCell:@"."];
            [(NSTextFieldCell *) pointCells[i] setDrawsBackground:NO];
            [(NSTextFieldCell *) pointCells[i] setEditable:NO];
            [(NSTextFieldCell *) pointCells[i] setBordered:NO];
            [(NSTextFieldCell *) pointCells[i] setFont:[NSFont labelFontOfSize:13]];
        }
        
        // Compute the Cells' frame
        
        tCellFrame.origin.x=WBIPV4CONTROL_LEFT_OFFSET;
        tCellFrame.origin.y=WBIPV4CONTROL_BOTTOM_OFFSET;
        
        tCellFrame.size.width=(NSWidth(frame)-3*WBIPV4CONTROL_INTERCELL_SPACE-WBIPV4CONTROL_RIGHT_OFFSET-WBIPV4CONTROL_LEFT_OFFSET)/4;
        tCellFrame.size.height=NSHeight(frame)-WBIPV4CONTROL_TOP_OFFSET-WBIPV4CONTROL_BOTTOM_OFFSET;
        
        for(i=0;i<WBIPV4CONTROL_CELL_COUNT;i++)
        {
            rects[i]=tCellFrame;
            
            tCellFrame.origin.x=NSMaxX(tCellFrame)+WBIPV4CONTROL_INTERCELL_SPACE;
        }
        
        // Compute the Colons' frame
        
        for(i=0;i<(WBIPV4CONTROL_CELL_COUNT-1);i++)
        {
            pointRects[i]=tCellFrame;
            
            pointRects[i].origin.x=NSMaxX(rects[i])-3;
            pointRects[i].size.width=NSMinX(rects[i+1])-NSMinX(pointRects[i])-1;
        }
    }
    
    return self;
}

- (int) intValue
{
    return currentAddress_;
}

- (void) setIntValue:(int) aValue
{
    if (aValue!=currentAddress_)
    {
        currentAddress_=aValue;
        
        [self editOff];
        
        [cells[WBIPV4CONTROL_A_ID] setStringValue:[NSString stringWithFormat:@"%d",(currentAddress_ & 0xFF000000)>>24]];
        [cells[WBIPV4CONTROL_B_ID] setStringValue:[NSString stringWithFormat:@"%d",(currentAddress_ & 0xFF0000)>>16]];
        [cells[WBIPV4CONTROL_C_ID] setStringValue:[NSString stringWithFormat:@"%d",(currentAddress_ & 0xFF00)>>8]];
        [cells[WBIPV4CONTROL_D_ID] setStringValue:[NSString stringWithFormat:@"%d",currentAddress_ & 0xFF]];
        
    }
}

- (NSString *) stringValue
{
    return [NSString stringWithFormat:@"%d.%d.%d.%d",(currentAddress_ & 0xFF000000)>>24,
                                                     (currentAddress_ & 0xFF0000)>>16,
                                                     (currentAddress_ & 0xFF00)>>8,
                                                     currentAddress_ & 0xFF];
}

- (void) setStringValue:(NSString *) aValue
{
    if (aValue!=nil)
    {
        NSArray * tArray;
        int i,tCount;
        
        tArray=[aValue componentsSeparatedByString:@"."];
        
        tCount=[tArray count];
        
        if (tCount==4)
        {
            currentAddress_=0;
            
            for(i=0;i<tCount;i++)
            {
                currentAddress_=(currentAddress_<<8)+[[tArray objectAtIndex:i] unsignedIntValue];
            }
        
            [self setIntValue:currentAddress_];
        }
    }
}

- (void) setDelegate:(id) aDelegate
{
    if (delegate!=nil)
    {
        [[NSNotificationCenter defaultCenter]  removeObserver:delegate
                                                         name:nil
                                                       object:self];
    }
  
    delegate = aDelegate;

    if ([delegate respondsToSelector: @selector(controlTextDidEndEditing:)])
    {
        [[NSNotificationCenter defaultCenter] addObserver: delegate
                                                 selector: @selector(controlTextDidEndEditing:)
                                                     name: NSControlTextDidEndEditingNotification
                                                   object: self];
    
    }
}

- (void)setA:(int)inA
{
    if (inA>=0 && inA<=_WBTimeControlMax[WBIPV4CONTROL_A_ID])
    {
        currentAddress_=(currentAddress_ & 0x00FFFFFF) + (inA<<24);
        
        if (isUsingFieldEditor==YES && selected==WBIPV4CONTROL_A_ID)
        {
            [[self currentEditor] setString:[NSString stringWithFormat:@"%d",inA]];
                
            [self editOff];
        }
        else
        {
            [cells[WBIPV4CONTROL_A_ID] setStringValue:[NSString stringWithFormat:@"%d",inA]];
        }
    }
}

- (unsigned char) A
{
    return ((currentAddress_ & 0xFF000000)>>24);
}

- (void)setB:(int)inB
{
    if (inB>=0 && inB<=_WBTimeControlMax[WBIPV4CONTROL_B_ID])
    {
        currentAddress_=(currentAddress_ & 0xFF00FFFF) + (inB<<16);
        
        if (isUsingFieldEditor==YES && selected==WBIPV4CONTROL_B_ID)
        {
            [[self currentEditor] setString:[NSString stringWithFormat:@"%d",inB]];
                
            [self editOff];
        }
        else
        {
            [cells[WBIPV4CONTROL_B_ID] setStringValue:[NSString stringWithFormat:@"%d",inB]];
        }
    }
}

- (unsigned char) B
{
    return ((currentAddress_ & 0xFF0000)>>16);
}

- (void)setC:(int)inC
{
    if (inC>=0 && inC<=_WBTimeControlMax[WBIPV4CONTROL_C_ID])
    {
        currentAddress_=(currentAddress_ & 0xFFFF00FF) + (inC<<8);
        
        if (isUsingFieldEditor==YES && selected==WBIPV4CONTROL_C_ID)
        {
            [[self currentEditor] setString:[NSString stringWithFormat:@"%d",inC]];
                
            [self editOff];
        }
        else
        {
            [cells[WBIPV4CONTROL_C_ID] setStringValue:[NSString stringWithFormat:@"%d",inC]];
        }
    }
}

- (unsigned char) C
{
    return ((currentAddress_ & 0xFF00)>>8);
}

- (void)setD:(int)inD
{
    if (inD>=0 && inD<=_WBTimeControlMax[WBIPV4CONTROL_D_ID])
    {
        currentAddress_=(currentAddress_ & 0xFFFFFF00) + inD;
        
        if (isUsingFieldEditor==YES && selected==WBIPV4CONTROL_D_ID)
        {
            [[self currentEditor] setString:[NSString stringWithFormat:@"%d",inD]];
                
            [self editOff];
        }
        else
        {
            [cells[WBIPV4CONTROL_D_ID] setStringValue:[NSString stringWithFormat:@"%d",inD]];
        }
    }
}

- (unsigned char) D
{
    return (currentAddress_ & 0xFF);
}

- (int)selected
{
    return selected;
}

- (void)setSelected:(int)aSelected
{
    selected=aSelected;
    
    [self setNeedsDisplay];
}

- (BOOL) isOpaque
{
    return NO;
}

- (void) drawRect:(NSRect) aFrame
{
    int i;
    NSRect tBounds=[self bounds];
    NSRect tRect;
    
    [[NSColor whiteColor] set];

    // Draw the background
    
    tRect=tBounds;
    tRect.origin.y=WBIPV4CONTROL_BOTTOM_OFFSET-3;
    
    tRect.size.height-=tRect.origin.y;
    
    NSRectFill(tRect);
    
    // Draw the Frame
    
    [(NSTextFieldCell *) cells[0] _drawThemeBezelWithFrame:tRect inView:self];
    
    if ([_window isKeyWindow])
    {
        if (isUsingFieldEditor==YES)
        {
            NSRect tRect = [self bounds];
            NSBezierPath * tBezierPath;
            
            tBezierPath=[NSBezierPath bezierPathWithRect:tRect];
            
            [NSGraphicsContext saveGraphicsState]; 
            
            NSSetFocusRingStyle(NSFocusRingOnly); 
            
            [tBezierPath fill];
            
            [NSGraphicsContext restoreGraphicsState];
        }
    }
    
    // Draw the Time Separator
    
    for(i=0;i<(WBIPV4CONTROL_CELL_COUNT-1);i++)
    {
        [pointCells[i] drawWithFrame:pointRects[i] inView:self];
    }
    
    // Draw the cells
    
    for(i=0;i<WBIPV4CONTROL_CELL_COUNT;i++)
    {
        [cells[i] drawWithFrame:rects[i] inView:self];
    }
}

- (void) mouseDown:(NSEvent *) theEvent
{
    int i;
    NSPoint tMouseLoc=[self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSRect tBounds;
    float tWidth;
    
    // Find where the event occurred
    
    tBounds=[self bounds];
    
    tWidth=NSWidth(tBounds)/4;
    
    // Or in a cell
    
    for(i=0;i<WBIPV4CONTROL_CELL_COUNT;i++)
    {
        if (NSMouseInRect(tMouseLoc,rects[i],[self isFlipped])==YES)
        {
            if (i!=selected || isUsingFieldEditor==NO)
            {
                if (isUsingFieldEditor==YES)
                {
                    [self editOff];
                }
                else
                {
                    [_window endEditingFor:nil];
                
                    [_window makeFirstResponder: self];
                }
        
                [self editCell:i];
            }
            else
            {
                [cells[selected] editWithFrame:rects[selected]
                                        inView:self
                                        editor:[self currentEditor]
                                      delegate:self
                                         event:theEvent];
            }
            
            break;
        }
    }
}

- (BOOL)acceptNewValueInSelectedCell:(id) sender
{
    NSString *string;
    int tValue;
	
    string = [[[[self currentEditor] string] copy] autorelease];

    tValue=[string intValue];
    
    if (tValue<=_WBTimeControlMax[selected])
    {
        [cells[selected] setStringValue: [NSString stringWithFormat:@"%d",tValue]];
                
        // Set the new date
        
        switch(selected)
        {
            case WBIPV4CONTROL_A_ID:
                [self setA:tValue];
                break;
            case WBIPV4CONTROL_B_ID:
                [self setB:tValue];
                break;
            case WBIPV4CONTROL_C_ID:
                [self setC:tValue];
                break;
            case WBIPV4CONTROL_D_ID:
                [self setD:tValue];
                break;
        }
        
        return YES;
    }

    
    return NO;
}

- (void)editCell:(int) aSelected
{
    NSText *tObject;
    NSText* t;
    int length;
    id tCell=cells[aSelected];
    
    [self setSelected:aSelected];
    
    t = [_window fieldEditor: YES forObject: self];
    
    length = [[tCell stringValue] length];
    
    tObject = [tCell setUpFieldEditorAttributes: t];
            
    isUsingFieldEditor=YES;
    
    [tCell selectWithFrame: rects[aSelected]
                    inView: self
                    editor: t
                  delegate: self
                     start: 0
                    length: length];

    selected=aSelected;
}

- (void)editOff
{
    if (isUsingFieldEditor==YES)
    {
        [cells[selected] endEditing: [self currentEditor]];
    
        isUsingFieldEditor=NO;
    }
}

- (void) textDidEndEditing:(NSNotification *) aNotification
{
    NSMutableDictionary * tDictionary;
    id textMovement;
    BOOL wasAccepted;
    
    wasAccepted=[self acceptNewValueInSelectedCell:self];
    
    [cells[selected] endEditing: [aNotification object]];

    if (wasAccepted==YES)
    {
        tDictionary = [[[NSMutableDictionary alloc] initWithDictionary:[aNotification userInfo]] autorelease];
    
        [tDictionary setObject: [aNotification object] forKey: @"NSFieldEditor"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: NSControlTextDidEndEditingNotification
                                                            object: self
                                                          userInfo: tDictionary];
    }
    
    isUsingFieldEditor=NO;
    
    textMovement = [[aNotification userInfo] objectForKey: @"NSTextMovement"];
    
    if (textMovement)
    {
        switch ([(NSNumber *)textMovement intValue])
        {
            case NSReturnTextMovement:
                if ([self sendAction:[self action] to:[self target]] == NO)
                {
                    NSEvent *event = [_window currentEvent];
        
                    if ([self performKeyEquivalent: event] == NO
                        && [_window performKeyEquivalent: event] == NO)
                    {
                        
                    }
                }
                break;
            case NSTabTextMovement:
                if (selected<WBIPV4CONTROL_D_ID)
                {
                    [self editCell:selected+1];
                    break;
                }
                
                [_window selectKeyViewFollowingView: self];
                
                if ([_window firstResponder] == _window)
                {
                    [self editCell:WBIPV4CONTROL_A_ID];
                }
                break;
            case NSBacktabTextMovement:
                if (selected>WBIPV4CONTROL_A_ID)
                {
                    [self editCell:selected-1];
                    break;
                }
                
                [_window selectKeyViewPrecedingView: self];
                
                if ([_window firstResponder] == _window)
                {
                    [self editCell:WBIPV4CONTROL_D_ID];
                }
                break;
        }
    }
}

- (void)setKeyboardFocusRingNeedsDisplayInRect:(NSRect) aFrame
{
    
    [super setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
}

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
    int i,tLength;
    unichar tUniChar;
    
    tLength=[replacementString length];
    
    if (affectedCharRange.location>=3 || affectedCharRange.length>3)
    {
        return NO;
    }
    
    for(i=0;i<tLength;i++)
    {
        tUniChar=[replacementString characterAtIndex:i];
        
        if (tUniChar<'0' || tUniChar>'9')
        {
            return NO;
        }
    }
    
    return YES;
}

@end
