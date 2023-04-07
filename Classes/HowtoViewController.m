//
//  HowtoViewController.m
//  CryptoHint
//
//  Created by Mark Bersalona on 2010.08.06.
//  Copyright 2010 Bersalona Technologies LLC. All rights reserved.
//

#import "HowtoViewController.h"


@implementation HowtoViewController

@synthesize webviewHelp;


/* *****************************************************************
 returnHomeButtonPressed
 Reload the Help home page, in case user gets lost
 ***************************************************************** */
- (IBAction)returnHomeButtonPressed:(id)sender
{
	// Load the home Help file into the web view
	NSString *lstrPath = [[NSBundle mainBundle] pathForResource:@"CryptoHintHelpHome" ofType:@"html"];
	NSURL *url = [NSURL fileURLWithPath:lstrPath];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[self.webviewHelp loadRequest:request];
}

/* *****************************************************************
 doneButtonPressed
 Return control to the previous screen (should be the Main screen)
 by popping this modal view off the navigation stack.
 ***************************************************************** */
- (IBAction)doneButtonPressed:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
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
	// Load the home Help file into the web view
	/*
	NSString *lstrPath = [[NSBundle mainBundle] pathForResource:@"CryptoHintHelpHome" ofType:@"html"];
	NSURL *url = [NSURL fileURLWithPath:lstrPath];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[self.webviewHelp loadRequest:request];
	 */
	
    [super viewDidLoad];
}

/* *****************************************************************
 Moved the code to load the home Help file from viewDidLoad to
 here so the home Help file will always be called whenever the Help
 button is tapped.
 ***************************************************************** */
-(void)viewWillAppear:(BOOL)animated
{
	// Load the home Help file into the web view
	NSString *lstrPath = [[NSBundle mainBundle] pathForResource:@"CryptoHintHelpHome" ofType:@"html"];
	NSURL *url = [NSURL fileURLWithPath:lstrPath];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[self.webviewHelp loadRequest:request];
	
	[super viewWillAppear:YES];
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


- (void)dealloc 
{
	[webviewHelp release];
    [super dealloc];
}


@end
