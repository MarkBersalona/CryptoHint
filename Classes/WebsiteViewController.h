//
//  WebsiteViewController.h
//  CryptoHint
//
//  Created by Mark Bersalona on 2010.08.06.
//  Copyright 2010 Bersalona Technologies LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebsiteViewController : UIViewController 
{
	UIWebView *webviewHome;
}

@property (nonatomic, retain) IBOutlet UIWebView *webviewHome;

- (IBAction)homeButtonPressed:(id)sender;

@end
