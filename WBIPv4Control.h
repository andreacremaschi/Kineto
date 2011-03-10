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

#import <AppKit/AppKit.h>

#define WBIPV4CONTROL_CELL_COUNT	4

#define WBIPV4CONTROL_A_ID			0
#define WBIPV4CONTROL_B_ID			1
#define WBIPV4CONTROL_C_ID			2
#define WBIPV4CONTROL_D_ID			3

@interface WBIPv4Control : NSControl
{
    unsigned long	currentAddress_;
    
    NSCell *		cells[WBIPV4CONTROL_CELL_COUNT];
    NSRect 		rects[WBIPV4CONTROL_CELL_COUNT];
    
    NSCell *		pointCells[WBIPV4CONTROL_CELL_COUNT-1];
    NSRect 		pointRects[WBIPV4CONTROL_CELL_COUNT-1];
    
    int 		selected;
    
    IBOutlet id 	delegate;
    
    BOOL 		isUsingFieldEditor;
}

- (int) intValue;
- (void) setIntValue:(int) aValue;

- (NSString *) stringValue;
- (void) setStringValue:(NSString *) aValue;

- (void) setDelegate:(id) aDelegate;

- (void) editCell:(int) aSelected;
- (void )editOff;

- (int) selected;
- (void) setSelected:(int)aSelected;

- (void) setA:(int) inA;
- (unsigned char) A;

- (void) setB:(int) inB;
- (unsigned char) B;

- (void) setC:(int) inC;
- (unsigned char) C;

- (void) setD:(int) inD;
- (unsigned char) D;

- (BOOL) acceptNewValueInSelectedCell:(id) sender;

@end