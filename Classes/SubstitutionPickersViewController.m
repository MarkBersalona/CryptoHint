//
//  SubstitutionPickersViewController.m
//  CryptoHint
//
//  Created by Mark Bersalona on 2010.08.06.
//  Copyright 2010 Bersalona Technologies LLC. All rights reserved.
//

#import "SubstitutionPickersViewController.h"
#import "SubstitutionListViewController.h"
#import "MainViewController.h"

NSInteger iCryptoLetterRow;
NSInteger iPlainLetterRow;
NSMutableString *strCryptoLetter;
NSMutableString *strPlainLetter;

@implementation SubstitutionPickersViewController

@synthesize pckrSubstitutions;

#pragma mark -
#pragma mark Methods

/* *****************************************************************
 selectButtonPressed
 Attempt to add the pickers' substitution pair to the substitution
 map.  Assumes letters already in the substitution map have been 
 previously deleted, so don't need to worry if a letter has already
 been added to the map. Checks must be on the actual letter value
 and not on the letters index in the picker, since the array sizes
 will vary when letters are added/deleted. Self-matching letters,
 e.g. G=G, are not allowed.
 
 PDL
	If letters for substitution pairs are available
		Get selected substitution letter candidates from ciphertext and plaintext pickers
		If ciphertext and plaintext letters are identical
			Reject the selection
		Else (letters do not match, proceed with substitution)
			Get user confirmation to proceed with substitution
		Endif (letters are identical)
	Endif (letters for substitution pairs are )
 End PDL
 ***************************************************************** */
-(IBAction)selectButtonPressed:(id)sender
{
	// If letters for substitution pairs are available
	if ([garrayPlainLetters count] > 0)
	{
		// Get selected substitution letter candidates from ciphertext and plaintext pickers
		iCryptoLetterRow = [pckrSubstitutions selectedRowInComponent:kCryptoComponent];
		iPlainLetterRow  = [pckrSubstitutions selectedRowInComponent:kPlainComponent];
		NSString *lstrCryptoLetter = [garrayCryptoLetters objectAtIndex:iCryptoLetterRow];
		NSString *lstrPlainLetter  = [garrayPlainLetters  objectAtIndex:iPlainLetterRow];
		
		// Bug found when implementing Issue 3:
		// If substitution letters run out, control returns to main screen and next tap
		// of substitution map goes to substitution list where pairs might be deleted.
		// Next tap of map button, control goes to substitution pickers and user may
		// select new pairs. There was a problem, apparently strCryptoLetter and
		// strPlainLetter are deallocated, so when trying to access them in
		// actionSheet code, app crashes. Additional code to retain and release
		// both of these variables solves the problem.
		
		strCryptoLetter = [NSString stringWithString:lstrCryptoLetter];
		[strCryptoLetter retain];
		strPlainLetter = [NSString stringWithString:lstrPlainLetter];
		[strPlainLetter retain];
		
		// If ciphertext and plaintext letters are identical
		if ([strCryptoLetter isEqualToString:strPlainLetter])
		{
			// Reject the selection
			NSLog(@"Letters match");
			NSString *msg = nil;
			msg = [[NSString alloc] initWithFormat:@"%@=%@ LETTERS MATCH",
				   strCryptoLetter,strPlainLetter];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid letter selection" 
															message:msg 
														   delegate:self 
												  cancelButtonTitle:@"Oops" 
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
			[msg release];
		}
		// Else (letters do not match, proceed with substitution)
		else
		{
			//NSLog(@"Letters don't match, proceed with substitution");
			NSString *message = [[NSString alloc] initWithFormat:@" Add %@=%@ to substitution list",
								 lstrCryptoLetter,lstrPlainLetter];
			
			// Get user confirmation to proceed with substitution
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:message 
																	 delegate:self 
															cancelButtonTitle:@"Cancel" 
													   destructiveButtonTitle:@"Do it" 
															otherButtonTitles:nil];
			[actionSheet showInView:self.view];
			[actionSheet release];
			[message release];
		}
		// Endif (letters are identical)
	}
	// Endif (letters for substitution pairs are available)
}

/* *****************************************************************
 actionSheet:didDismissWithButtonIndex
 User has confirmed the substitution letter pair. Proceed with
 adding substitution letter pair to substitution map, and delete
 the respective letters from the pickers.
 
 PDL
	Delete ciphertext letter from  ciphertext letters
	Delete plaintext letter from  plaintext letters
	Map plaintext letter to ciphertext letter in substitution map
	Add substitution pair to substitution list
	Redraw substitution map display
	Redraw pickers
	If no more letters available
		Return to previous screen
	Endif
 End PDL
 ***************************************************************** */
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != [actionSheet cancelButtonIndex])
	{
		// Delete ciphertext letter from  ciphertext letters
		[garrayCryptoLetters removeObjectAtIndex:iCryptoLetterRow];
		
		// Delete plaintext letter from  ciphertext letters
		[garrayPlainLetters removeObjectAtIndex:iPlainLetterRow];
		
		//NSLog(@"garrayPlainLetters  count = %d",[garrayPlainLetters count]);
		//NSLog(@"garrayCryptoLetters count = %d",[garrayCryptoLetters count]);
		//NSLog(@"strCryptoLetter is >>%@<<",strCryptoLetter);
		// Map plaintext letter to ciphertext letter in substitution map
		unichar luiCryptoChar = [strCryptoLetter characterAtIndex:0];
		//NSLog(@"luiCryptoChar = %c",luiCryptoChar);
		guiCryptoToPlain[luiCryptoChar-65] = [strPlainLetter characterAtIndex:0];
		//NSLog(@"New guiCryptoToPlain[%d] = %c",
		//	  guiCryptoToPlain[luiCryptoChar-65],[strPlainLetter characterAtIndex:0]);
		
		// Add substitution pair to substitution list
		NSString *lstrSubstitutionPair = [[NSString alloc] initWithFormat:@"%@=%@",
										  strCryptoLetter, strPlainLetter];
		//NSLog(@"lstrSubstitutionPair = %@",lstrSubstitutionPair);
		[garraySubstitutions addObject:lstrSubstitutionPair];
		//NSLog(@"New substitution pair:  %@",lstrSubstitutionPair);
		NSSortDescriptor *pairSorter = [[NSSortDescriptor alloc]
										  initWithKey:0 ascending:YES];
		[garraySubstitutions sortUsingDescriptors:[NSArray arrayWithObject:pairSorter]];
		[lstrSubstitutionPair release];
		[pairSorter release];
		
		// Redraw substitution map display
		NSMutableString *lstrSubstitutionMapDisplay = [[NSMutableString alloc] initWithString:@""];
		for (int luiX = 0; luiX < 26; luiX++)
		{
			if (guiCryptoToPlain[luiX] == 0)
			{
				//NSLog(@"guiCryptoToPlain[%d] is 0",luiX);
				[lstrSubstitutionMapDisplay appendString:@"."];
			}
			else
			{
				//NSLog(@"guiCryptoToPlain[%d] is %d",luiX, guiCryptoToPlain[luiX]);
				[lstrSubstitutionMapDisplay appendFormat:@"%c",guiCryptoToPlain[luiX]];
			}

		}
		//NSLog(@"lstrSubstitutionMapDisplay = %@",lstrSubstitutionMapDisplay);
		glblSubstitutePlainLetters.text = lstrSubstitutionMapDisplay;
		[lstrSubstitutionMapDisplay release];
		
		// Redraw pickers
		[pckrSubstitutions reloadAllComponents];
		
		// If no more letters available
		if ([garrayPlainLetters count] == 0)
		{
			// Return to previous screen
			//NSLog(@"No more letters!");
			[self.navigationController popViewControllerAnimated:YES];
		}
		// Endif
	}
	
	[strCryptoLetter release];
	[strPlainLetter release];
}

/* *****************************************************************
 resetMapButtonPressed
 Removes all substitutions from the substitution map, which implies
 the arrays for the substitution pickers are restored to full
 alphabets, and substituion map on main screen is cleared.
 
 Clear substitution map
 Restore substitution pickers to full alphabets
 Clear substitution map on main screen
 Clear substitution list
 Redraw pickers
 
 ***************************************************************** */
- (IBAction)resetMapButtonPressed:(id)sender
{
	// Clear substitution map
	for (int i = 0; i < 26; i++)
	{
		guiCryptoToPlain[i] = 0;
	}
	
	// Restore substitution pickers to full alphabets
	[garrayCryptoLetters removeAllObjects];
	[garrayPlainLetters  removeAllObjects];
	[garrayCryptoLetters addObjectsFromArray:garrayBaseCryptoLetters];
	[garrayPlainLetters  addObjectsFromArray:garrayBasePlainLetters];
	
	// Clear substitution map on main screen
	glblSubstitutePlainLetters.text = @"..........................";
	
	// Clear substitution list
	[garraySubstitutions removeAllObjects];
	//[tblSubstitutionList reloadData];
	
	// Redraw pickers
	[pckrSubstitutions reloadAllComponents];
}

/* *****************************************************************
 editButtonPressed
 Allow user to delete selected substitution pairs. For each
 pair deleted, the respective letters in the substitution crypto
 and plaintext pickers are restored
 ***************************************************************** */
- (IBAction)editButtonPressed:(id)sender
{
	NSLog(@"SubstitutionPickersViewController - Edit button pressed");
	// Let's load the Substitution List view
	SubstitutionListViewController *substitutionListViewController = [[SubstitutionListViewController alloc] init];
	substitutionListViewController.title = @"Substitutions";
	
	[self.navigationController pushViewController:substitutionListViewController 
										 animated:YES];
}

#pragma mark -
#pragma mark Picker methods

/* *****************************************************************
 numberOfComponentsInPickerView
 Returns number of pickers for substitution letter pair.
 - First picker is ciphertext letters
 - Second picker is plaintext letters
 Therefore return value is 2
 ***************************************************************** */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *) pickerView
{
	return 2;
}

/* *****************************************************************
 pickerView:numberOfRowsInComponent
 Return number of letters for each substitution letter picker.
 In practice since the substitution letter pairs are removed or
 restored in pairs, the array size of the ciphertext and plaintext
 arrays should be the same.
 ***************************************************************** */
- (NSInteger)pickerView:(UIPickerView *)pickerView 
numberOfRowsInComponent:(NSInteger)component
{
	// Replace this with array count of either ciphertext or plaintext
	// mutable arrays
	return [garrayCryptoLetters count];
}

/* *****************************************************************
 pickerView:titleForRow:forComponent
 Delegate method for substitution pickers. Return a letter from the
 ciphertext or plaintext mutable array depending on which
 component (kCryptoComponent or kPlainComponent) is being loaded.
 ***************************************************************** */
- (NSString *)pickerView:(UIPickerView *)pickerView 
			 titleForRow:(NSInteger)row 
			forComponent:(NSInteger)component
{
	switch (component)
	{
		case kCryptoComponent:
			// Replace with mutable array for ciphertext
			return [garrayCryptoLetters objectAtIndex:row];
			break;
		case kPlainComponent:
			// Replace with mutable array for plaintext
			return [garrayPlainLetters objectAtIndex:row];
			break;
		default:
			return nil;
			break;
	}
}

/* *****************************************************************
 pickerView:widthForComponent
 Return width of substitution picker component. Value is simply
 determined by trial and error.
 ***************************************************************** */
/*
- (CGFloat)pickerView:(UIPickerView *)pickerView 
	widthForComponent:(NSInteger)component
{
	return 80;
}
 */

/* *****************************************************************
 pickerView:viewForRow:forComponent:reusingView
 Method added so letters in substitution letter picker will be
 center-aligned in each component. Also allows for setting
 font and size.
 ***************************************************************** */
- (UIView *)pickerView:(UIPickerView *)pickerView 
			viewForRow:(NSInteger)row 
		  forComponent:(NSInteger)component 
		   reusingView:(UIView *)view
{
	UILabel *retval = (UILabel *)view;
	if (!retval)
	{
		retval = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 138, 44.0)] 
				  autorelease];
	}
	if (component == kCryptoComponent)
	{
		retval.text = [NSString stringWithFormat:@"%@",[garrayCryptoLetters objectAtIndex:row]];
		retval.textAlignment = NSTextAlignmentRight;
		retval.font = [UIFont fontWithName:@"Courier" size:32.0];
	}
	else
	{
		retval.text = [NSString stringWithFormat:@"%@",[garrayPlainLetters objectAtIndex:row]];
		retval.textAlignment = NSTextAlignmentLeft;
		retval.font = [UIFont fontWithName:@"Marker Felt" size:30.0];
	}
	
	return retval;
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


// Implement viewDidLoad to do additional setup after loading the view, 
// typically from a nib.
/* *****************************************************************
 ***************************************************************** */
- (void)viewDidLoad 
{
	strCryptoLetter = [[NSMutableString alloc] init];
	strPlainLetter  = [[NSMutableString alloc] init];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	// Redraw pickers
	[pckrSubstitutions reloadAllComponents];
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

- (void)viewDidUnload 
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.pckrSubstitutions = nil;
	strCryptoLetter = nil;
	strPlainLetter = nil;
}


- (void)dealloc 
{
	[pckrSubstitutions release];
	[strCryptoLetter release];
	[strPlainLetter release];
	
    [super dealloc];
}


@end
