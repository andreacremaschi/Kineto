//
//  AppController.h
//  eyeconmacosx
//
//  Created by Andrea Cremaschi on 18/10/10.
//  Copyright AndreaCremaschi 2010 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ElementsView.h>

@class LicensingWindowController;
@interface AppController : NSObject
{


	LicensingWindowController		* _licensingWindow;
	
}
- (IBAction) showLicensingWindowController:(id)sender;


@end
