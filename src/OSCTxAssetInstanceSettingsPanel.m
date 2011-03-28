//
//  ElementSettingsPanel.m
//  kineto
//
//  Created by Andrea Cremaschi on 14/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OSCTxAssetInstanceSettingsPanel.h"
#import "ECNAction.h"
#import "ECNElement.h"
#import "ECNOSCTxAssetInstance.h"
#import "ECNOSCTargetAsset.h"

#import "ECNProjectDocument.h"
#import "ECNScene.h"
#import "ECNTrigger.h"

#import <VVOSC/VVOSC.h>

@interface OSCTxAssetInstanceSettingsPanel (ECNConvenience) 
- (void) resetContent;
@end
	
@implementation OSCTxAssetInstanceSettingsPanel

- (id)init {
	
	if (![self initWithWindowNibName: @"OSCTxSettingsPanel"])
	{
		NSLog(@"Could not init OSC client settings panel!");
		return nil;
	}
    
	[self setWindowFrameAutosaveName:@"OSC sender settings panel"];
	
	_oscManager = [[[OSCManager alloc] init] retain];
	return self;
}


- (id) initWithElement: (ECNElement*)element {
	self = [self init];
	if (self)	{
		_element = [element retain];
		
	}							  
	return self;
}

- (void) awakeFromNib	{
/*	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(oscServerListChanged:) 
												 name:VVOSCOutPortsChangedNotification 
											   object:nil];*/
	[_oscManager setDelegate: self];


	return;	
}

- (void) dealloc {
	
	[_element release];
	[_oscManager release];
	
	[super dealloc];
	
}

- (void) resetContent	{	
	[oElementToInspect setContent: _element];	
}

#pragma mark *** Constructors
+ (OSCTxAssetInstanceSettingsPanel *) settingsPanelWithElement: (ECNOSCTxAssetInstance *)elementToModify	{
	OSCTxAssetInstanceSettingsPanel *panel = [[[OSCTxAssetInstanceSettingsPanel alloc] initWithElement: elementToModify] autorelease];
	
	[panel window];
	[panel resetContent];
	
	return panel;
}

#pragma mark *** 
- (NSInteger)runModal	{
	
	_state = NSRunContinuesResponse;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSModalSession modalSession = [NSApp beginModalSessionForWindow: [self window]];
	NSUInteger result;
	for (;;) {
		NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
		
		result = [NSApp runModalSession:modalSession];
		if (result != NSRunContinuesResponse)
			break;
		
		[loopPool drain];
	}
	
	[NSApp endModalSession:modalSession];
	
	[_oscManager setDelegate: nil];
	
	[[self window] close];
	
	// Do whatever cleanup is needed.
	[pool drain];
	
	return _state;
}




#pragma mark *** UI events

- (IBAction) popupSelectionDidChange: (id)sender	{
	NSString *osc_host = @"";
	NSString *osc_port = @"";
	
	if (sender == oPopupBonjourServers)	{
		int				selectedIndex = [oPopupBonjourServers indexOfSelectedItem];
		OSCOutPort		*selectedPort = nil;
		
		//	figure out the index of the selected item
		if (selectedIndex == -1)	{
			[oTxtFieldHost setStringValue: @""];
			[oTxtFieldPort setStringValue: @""];
			return;
		}
		
		//	find the output port corresponding to the index of the selected item
		selectedPort = [_oscManager findOutputForIndex: selectedIndex];
		if (selectedPort == nil)	{
			[oTxtFieldHost setStringValue: @""];
			[oTxtFieldPort setStringValue: @""];
			return;
		}
		osc_host = [selectedPort addressString];
		osc_port = [NSString stringWithFormat:@"%d",[selectedPort port]];
		
	} else 	if (sender == oPopupExistingServers)		{
		// sets host and port text field using values of selected osc target
		ECNOSCTargetAsset *osc_asset = [_element oscAsset];
		osc_host = [osc_asset valueForPropertyKey: OSCAssetHostKey];
		osc_port = [osc_asset valueForPropertyKey: OSCAssetPortKey ];
		
	}

	//	push the data of the selected output to the fields
	[oTxtFieldHost setStringValue: osc_host];
	[oTxtFieldPort setIntValue: [osc_port intValue]];
	
}

- (IBAction) ok: (id)sender	{
	_state = NSOKButton;
	
	
	// if a manual or bonjour OSC host has been selected, check if osc asset exists, then
	// create a new OSC asset with selected host:port coords
	if ([oMtxOSCTargetKind selectedRow] > 0)	{
	
		// TODO: validate new OSC target coords

		NSNumber* portValue = [NSNumber numberWithInt: [oTxtFieldPort.stringValue intValue]];
		NSString *host =oTxtFieldHost.stringValue;

		// check if OSC target with given coordinates already exists...
		NSArray* oscTargets = [[_element document] objectsOfKind: [ECNOSCTargetAsset class]];
		ECNOSCTargetAsset *oscAssetToAdd = nil;
		for (ECNOSCTargetAsset *curAsset in oscTargets)	{
			if (([[curAsset valueForPropertyKey: OSCAssetHostKey] isEqual: host]) && 
				([[curAsset valueForPropertyKey: OSCAssetPortKey] isEqual: portValue]) )	{
				oscAssetToAdd = curAsset;
			}
		}
		if (!oscAssetToAdd)	{
			// ... if not, create a new OSC target asset
			oscAssetToAdd = [ECNOSCTargetAsset assetWithDocument: [_element document]
																		 withOSCTargetIP: host
																	   withOSCTargetPort: portValue
													 ];
		} 			
		[_element setAsset: oscAssetToAdd];
		
	}
	[NSApp stopModal];
}
- (IBAction) cancel: (id)sender		{
	_state = NSCancelButton;
	[NSApp abortModal];
}

- (IBAction)add:(id)sender;
{
	ECNPort * selectedPort = [[oOutputPortsList selectedObjects] objectAtIndex:0  ];
	ECNObject *portOwner = [selectedPort object];
	for (ECNPort *curPort in [portOwner outputPorts])
		if ([[curPort name] isEqual: [selectedPort name]])
			 { selectedPort = curPort; break; }
	if (!selectedPort) return;
	
	[_element willChangeValueForKey: OSCTxAssetInstanceObservedPortsArrayKey]; 
	[_element addPortToObserve: selectedPort];
	[_element didChangeValueForKey: OSCTxAssetInstanceObservedPortsArrayKey]; 
	
}

- (IBAction)changeRadioSelection:(id)sender
{

	if (![sender isKindOfClass: [NSMatrix class]]) return;

	int i = [sender selectedRow];
	id oscTargetPopupButton = nil;
	
	[oPopupExistingServers setEnabled: false];
	[oPopupBonjourServers setEnabled: false];
	[oTxtFieldHost setEnabled: false];
	[oTxtFieldPort setEnabled: false];

	
	if (i == 0) oscTargetPopupButton = oPopupExistingServers;
	if (i == 1) oscTargetPopupButton = oPopupBonjourServers;
	if (i == 2) {
		[oTxtFieldHost setEnabled: true];
		[oTxtFieldPort setEnabled: true];
	}
	
	if (oscTargetPopupButton)	{
		[oscTargetPopupButton setEnabled: true];
		[self popupSelectionDidChange: oscTargetPopupButton];	
	}
	
}

#pragma mark *** OSCManager delegate
- (void) setupChanged	{
	[_oscManager willChangeValueForKey: @"outPortLabelArray"];
	[_oscManager didChangeValueForKey: @"outPortLabelArray"];

	
	if ([oMtxOSCTargetKind selectedRow] ==1)	// if bonjour option selected, update text fields
		[self popupSelectionDidChange: oPopupBonjourServers];
}


#pragma mark  -
#pragma mark *** KVC/KVO methods			
- (NSArray *)OSCTargetsList	{
	return [[_element document] objectsOfKind: [ECNOSCTargetAsset class]];
}

- (OSCManager *)oscManager	{
	return _oscManager;
}

@end
