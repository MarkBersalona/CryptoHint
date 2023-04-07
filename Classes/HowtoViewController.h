//
//  HowtoViewController.h
//  CryptoHint
//
//  Created by Mark Bersalona on 2010.08.06.
//  Copyright 2010 Bersalona Technologies LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HowtoViewController : UIViewController 
{
	UIWebView *webviewHelp;
}

@property (nonatomic, retain) IBOutlet UIWebView *webviewHelp;

- (IBAction)returnHomeButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;

@end
