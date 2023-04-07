//
//  AboutViewController.m
//  CryptoHint
//
//  Created by Mark Bersalona on 2010.08.06.
//  Copyright 2010 Bersalona Technologies LLC. All rights reserved.
//

#import "AboutViewController.h"
#import "WebsiteViewController.h"
#import "MainViewController.h"


@implementation AboutViewController

@synthesize webviewAbout;

#pragma mark -
#pragma mark Methods



/* *****************************************************************
 websiteButtonPressed:
 
 Go to the website detail view (consisting of a web view) with
 the CryptoHint website - but only if Internet connection is OK
 
 PDL
	If Internet connection OK AND website is reachable
		Load the website view
	Else
		Alert user - unable to reach website
	Endif
 End PDL
 ***************************************************************** */
- (IBAction)websiteButtonPressed:(id)sender
{
	NSLog(@"Enter AboutViewController - websiteButtonPressed");

	// If Internet connection OK AND website is reachable
	if (isInternetConnected && isHostConnected)
	{
		// Load the website view
		WebsiteViewController *websiteViewController = [[WebsiteViewController alloc] init];
		websiteViewController.title = @"Website";
		
		[self.navigationController pushViewController:websiteViewController 
											 animated:YES];
	}
	// Else
	else
	{
		// Alert user - unable to reach website
		NSString *msg = nil;
		if (!isInternetConnected)
		{
			msg = [[NSString alloc] initWithString:@"Bad network connection"];
		}
		else
		{
			msg = [[NSString alloc] initWithString:@"Unable to reach CryptoHint's website"];
		}

		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection failed" 
														message:msg 
													   delegate:self 
											  cancelButtonTitle:@"OK, I'll try again later" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		[msg release];
	}

	NSLog(@"Exit AboutViewController - websiteButtonPressed");
}

/* *****************************************************************
 emailButtonPressed:
 
 Go to what will hopefully be an internal Email view allowing the
 user to email comments and suggestions to
 CryptoHint@BersalonaTechnologies.com while remaining within
 the CryptoHint application.  If this isn't possible, put up a
 modal alert warning the user continuing with the email will
 exit the CryptoHint application and allowing the user to
 cancel.
 ***************************************************************** */
- (IBAction)emailButtonPressed:(id)sender
{
	NSLog(@"Enter AboutViewController - emailButtonPressed");
	[self showMailComposer];
	NSLog(@"Exit AboutViewController - emailButtonPressed");
}

/* *****************************************************************
 showMailComposer
 Show in-app Email so user may Email comments
 From "The Business of iPhone App Development" page 98
 ***************************************************************** */
- (void)showMailComposer
{
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		if ([mailClass canSendMail])
		{
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
			picker.mailComposeDelegate = self;
			[picker setSubject:@"User comment on CryptoHint"];
			[picker setToRecipients:[NSArray arrayWithObject:@"CryptoHint@bersalonatechnologies.com"]];
			NSString *emailBody = @"My comments on CryptoHint are as follows:";
			[picker setMessageBody:emailBody isHTML:NO];
			picker.navigationBar.barStyle = UIBarStyleBlack;
			[self presentViewController:picker animated:YES completion:nil];
			[picker release];
		}
		else
		{
			// Can't do in-app Email
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unable to Email" 
																message:@"This device is not yet configured for sending emails." 
															   delegate:self 
													  cancelButtonTitle:@"OK, I'll Try Later" 
													  otherButtonTitles:nil];
			[alertView show];
			[alertView release];
		}

	}
	else
	{
		// Device is not configured for sending emails, so notify user
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unable to Email" 
															message:@"This device is not yet configured for sending emails." 
														   delegate:self 
												  cancelButtonTitle:@"OK, I'll Try Later" 
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}

}

/* *****************************************************************
 mailComposeController:didFinishWithResult:error
 Dismisses the Mail composer when user taps Cancel or Send
 From "The Business of iPhone App Development" page 100
 ***************************************************************** */
- (void)mailComposeController:(MFMailComposeViewController*)controller 
		  didFinishWithResult:(MFMailComposeResult)result 
						error:(NSError*)error
{
	NSString *resultTitle = nil;
	NSString *resultMsg = nil;
	
	switch (result)
	{
		case MFMailComposeResultCancelled:
			resultTitle = @"Email Cancelled";
			resultMsg = @"You elected to cancel the email";
			break;
		case MFMailComposeResultSaved:
			resultTitle = @"Email Saved";
			resultMsg = @"You saved the email as a draft";
			break;
		case MFMailComposeResultSent:
			resultTitle = @"Email Sent";
			resultMsg = @"Your email was successfully delivered";
			break;
		case MFMailComposeResultFailed:
			resultTitle = @"Email Failed";
			resultMsg = @"Sorry, the Mail Composer failed. If you had tried to save a draft, the settings for your Drafts folder may be incorrect. Please try again.";
			break;
		default:
			resultTitle = @"Email Not Sent";
			resultMsg = @"Sorry, an error occurred. Your email could not be sent.";
			break;
	}
	
	// Notifies user of any Mail Composer errors received with an Alert View dialog
	UIAlertView *mailAlertView = [[UIAlertView alloc] initWithTitle:resultTitle 
															message:resultMsg 
														   delegate:self 
												  cancelButtonTitle:@"OK" 
												  otherButtonTitles:nil];
	[mailAlertView show];
	[mailAlertView release];
	[resultTitle release];
	[resultMsg release];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark -
#pragma mark Application lifecycle

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
	// Load the About file into the web view
	NSString *lstrPath = [[NSBundle mainBundle] pathForResource:@"CryptoHintAbout" ofType:@"html"];
	NSURL *url = [NSURL fileURLWithPath:lstrPath];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[self.webviewAbout loadRequest:request];
	
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
	NSLog(@"Enter AboutViewController - didReceiveMemoryWarning");
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	NSLog(@"Enter AboutViewController - viewDidUnload");
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	NSLog(@"Exit AboutViewController - viewDidUnload");
}


- (void)dealloc 
{
	NSLog(@"Enter AboutViewController - dealloc");
	[webviewAbout release];
    [super dealloc];
	NSLog(@"Exit AboutViewController - dealloc");
}


@end
