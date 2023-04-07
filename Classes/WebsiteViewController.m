//
//  WebsiteViewController.m
//  CryptoHint
//
//  Created by Mark Bersalona on 2010.08.06.
//  Copyright 2010 Bersalona Technologies LLC. All rights reserved.
//

#import "WebsiteViewController.h"


@implementation WebsiteViewController

@synthesize webviewHome;

/* *****************************************************************
 homeButtonPressed
 Reload CryptoHint home web page in case the user gets lost
 ***************************************************************** */
- (IBAction)homeButtonPressed:(id)sender
{
	// Load the home page into the web view
	NSURL *url = [NSURL URLWithString:@"http://BersalonaTechnologies.com/iPhone/CryptoHint/CryptoHintHome.html"];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[self.webviewHome loadRequest:request];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	// Load the home page into the web view
	NSURL *url = [NSURL URLWithString:@"http://BersalonaTechnologies.com/iPhone/CryptoHint/CryptoHintHome.html"];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[self.webviewHome loadRequest:request];
	
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
