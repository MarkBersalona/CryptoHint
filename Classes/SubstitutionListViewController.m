//
//  SubstitutionListViewController.m
//  CryptoHint
//
//  Created by Mark Bersalona on 2010.08.06.
//  Copyright 2010 Bersalona Technologies LLC. All rights reserved.
//

#import "SubstitutionListViewController.h"
#import "SubstitutionPickersViewController.h"
#import "MainViewController.h"

@implementation SubstitutionListViewController

@synthesize lblStatus;
@synthesize tblSubstitutionList;

#pragma mark -
#pragma mark Methods

/* *****************************************************************
 resetMapButtonPressed
 Removes all substitutions from the substitution map, which implies
 the arrays for the substitution pickers are restored to full
 alphabets, and substituion map on main screen is cleared.
 
 Clear substitution map
 Restore substitution pickers to full alphabets
 Clear substitution map on main screen
 Clear substitution list
 Return to main screen
 
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
	[tblSubstitutionList reloadData];
	
	// Return to main screen
	//[self.navigationController popToRootViewControllerAnimated:YES];
	[self.navigationController popViewControllerAnimated:YES];
}

/* *****************************************************************
 editButtonPressed
 
 This was the routine called by a toolbar Edit button, but now not
 in use since the navigation bar Edit button is used instead to
 change the Edit mode.  In case there's a future need, the old
 PDL and commented-out code is kept here for reference.
 
 Allow user to delete selected substitution pairs. For each
 pair deleted, the respective letters in the substitution crypto
 and plaintext pickers are restored
 
 PDL
	If currently in editing mode
		Change text of edit button to "Edit"
		Turn off editing mode
	Else (currently not in editing mode)
		Change text of edit button to "Done"
		Turn on editing mode
	Endif
 End PDL
 ***************************************************************** */
- (IBAction)editButtonPressed:(id)sender
{
	/*
	lblStatus.text = @"Edit button pressed";
	// If currently in editing mode
	if ([self isEditing])
	{
		// Change text of edit button to "Edit"
		//[sender setTitle:@"EDIT" forState:UIControlStateNormal];
		
		// Turn off editing mode
		[self setEditing:NO animated:YES];
	}
	// Else (currently not in editing mode)
	else
	{
		// Change text of edit button to "Done"
		//[sender setTitle:@"DONE" forState:UIControlStateNormal];
		
		// Turn on editing mode
		[self setEditing:YES animated:YES];
	}
	// Endif
	 */
}

#pragma mark -
#pragma mark Table Data Source methods

/* *****************************************************************
 tableView:titleForHeaderInSection
 tableView:titleForFooterInSection
 
 Returns section header and footer titles
 ***************************************************************** */
- (NSString *)tableView:(UITableView *)tableView 
titleForHeaderInSection:(NSInteger)section
{
	return @"Select pair(s) to be deleted";
}

/*
- (NSString *)tableView:(UITableView *)tableView 
titleForFooterInSection:(NSInteger)section
{
	return @"Edit button or swipe";
}
*/


/* *****************************************************************
 tableView:numberOfRowsInSection
 Returns number of rows in the table view for match words - simply
 the count of the array containing the substitution list.
 ***************************************************************** */
- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section
{
	return [garraySubstitutions count];
}

/* *****************************************************************
 tableView:cellForRowAtIndexPath
 ***************************************************************** */
- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *SubstitutionListViewCellIdentifier = @"SubstitutonListViewCellIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SubstitutionListViewCellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
									   reuseIdentifier:SubstitutionListViewCellIdentifier] 
				autorelease];
	}
	NSUInteger row = [indexPath row];
	NSString *rowString = [garraySubstitutions objectAtIndex:row];
	cell.textLabel.text = rowString;
	//cell.textLabel.font = [UIFont fontWithName:@"Marker Felt" size:25.0];
	cell.textLabel.textAlignment = NSTextAlignmentCenter;
	//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	//[rowString release];
	return cell;
}

#pragma mark -
#pragma mark Table Delegate Methods

/* *****************************************************************
 tableView:didSelectRowAtIndexPath
 Simply deselect the row.  No need to do anything else since this
 screen is for deleting individual pairs, handled separately.
 ***************************************************************** */
- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	/*
	NSUInteger luiRow = [indexPath row];
	NSString *lstrMatchWord = [list objectAtIndex:luiRow];
	NSString *lstrMessage = [[NSString alloc] initWithFormat:@"You selected %@",lstrMatchWord];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SELECTION" 
													message:lstrMessage
												   delegate:nil 
										  cancelButtonTitle:@"Nah, pick something else" 
										  otherButtonTitles:nil];
	[lstrMessage release];
	[alert show];
	[alert release];
	 */
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/* *****************************************************************
 tableView:commitEditingStyle:forRowAtIndexPath
 Delete the selected substitution pair from the array of substitution
 pairs with contents like 'X=A'. Also need to restore the crypto
 letter and the plaintext letter to their respective picker arrays.
 
 PDL
	Add ciphertext letter to ciphertext letters
	Add plaintext  letter to plaintext letters
	Remove plaintext letter from ciphertext letter in substitution map
	Redraw substitution map display
	Delete substitution pair from substitution list
	If no substitution pairs remain
		Return to previous screen
	Endif
 End PDL
 ***************************************************************** */
- (void)tableView:(UITableView *)tableView 
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
		NSString *lstrSubstitutionPair = [garraySubstitutions objectAtIndex:indexPath.row];
		//NSLog(@"Selected substitution pair is %@",lstrSubstitutionPair);
		unichar lcCryptoCharacter = [lstrSubstitutionPair characterAtIndex:0];
		unichar lcPlainCharacter  = [lstrSubstitutionPair characterAtIndex:2];
		//NSLog(@"Crypto char = %d",lcCryptoCharacter);
		//NSLog(@"Plain  char = %d",lcPlainCharacter);
		
		// Add ciphertext letter to ciphertext letters
		NSString *lstrCryptoLetter = [[NSString alloc] initWithFormat:@"%c",lcCryptoCharacter];
		//NSLog(@"Crypto letter is %@",lstrCryptoLetter);
		[garrayCryptoLetters addObject:lstrCryptoLetter];
		NSSortDescriptor *letterSorter = [[NSSortDescriptor alloc]
										initWithKey:0 ascending:YES];
		[garrayCryptoLetters sortUsingDescriptors:[NSArray arrayWithObject:letterSorter]];
		
		// Add plaintext  letter to plaintext letters
		NSString *lstrPlainLetter = [[NSString alloc] initWithFormat:@"%c",lcPlainCharacter];
		//NSLog(@"Plain  letter is %@",lstrPlainLetter);
		[garrayPlainLetters addObject:lstrPlainLetter];
		[garrayPlainLetters sortUsingDescriptors:[NSArray arrayWithObject:letterSorter]];
		
		// Remove plaintext letter from ciphertext letter in substitution map
		guiCryptoToPlain[lcCryptoCharacter-65] = 0;
		
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
		glblSubstitutePlainLetters.text = lstrSubstitutionMapDisplay;
		[lstrSubstitutionMapDisplay release];

		// Delete substitution pair from substitution list
		[garraySubstitutions removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];

		// If no substitution pairs remain
		if ([garraySubstitutions count] == 0)
		{
			// Return to previous screen
			[self.navigationController popViewControllerAnimated:YES];
		}
		// Endif
		
		[lstrCryptoLetter release];
		[lstrPlainLetter release];
		[letterSorter release];
	}   
	else if (editingStyle == UITableViewCellEditingStyleInsert) 
	{
		// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
	}   
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
- (void)viewDidLoad {
    // In iOS 8 the Edit button no longer seems to enable the editing icons in a listview.
    // Disable the Edit button in the Navigation bar - it's useless now.
	//self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)viewWillAppear:(BOOL)animated
{
	[tblSubstitutionList reloadData];
}

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
