//
//  AboutViewController.h
//  CryptoHint
//
//  Created by Mark Bersalona on 2010.08.06.
//  Copyright 2010 Bersalona Technologies LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface AboutViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
	UIWebView *webviewAbout;
}

@property (nonatomic, retain) IBOutlet UIWebView *webviewAbout;

- (IBAction)websiteButtonPressed:(id)sender;
- (IBAction)emailButtonPressed:(id)sender;
- (void)showMailComposer;

@end
