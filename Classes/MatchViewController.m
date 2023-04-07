//
//  MatchViewController.m
//  CryptoHint
//
//  Created by Mark Bersalona on 2010.08.10.
//  Copyright 2010 Bersalona Technologies LLC. All rights reserved.
//

#import "MatchViewController.h"
#import "MainViewController.h"		// need access to array of matched words

NSInteger iCryptoLetterRow;
NSInteger iPlainLetterRow;
NSMutableString *strCryptoLetter;
NSMutableString *strPlainLetter;

@implementation MatchViewController

@synthesize lblStatus;
@synthesize list;
@synthesize table;
@synthesize sgmtSortSelector;

#pragma mark -
#pragma mark Methods

/* *****************************************************************
 toggleMatchSort
 Change display of match words to either an alphabetical sort or a
 sort by word popularity and letter frequency. Changes value of
 global Boolean flag.
 
 PDL
	If user pressed Alphabetical toggle button
		Set FrequencySort flag to FALSE
		Set list to alphabetically sorted array
	Else (user pressed Frequency toggle button)
		Set FrequencySort flag to TRUE
		Set list to frequency sorted array
	Endif
	Redraw table
 End PDL
 ***************************************************************** */
- (IBAction)toggleMatchSort:(id)sender
{
	// If user pressed Alphabetical toggle button
	if ([sender selectedSegmentIndex] == kAlphabeticalSort)
	{
		// Set FrequencySort flag to FALSE
		isSortByFrequency = NO;
		
		// Set list to alphabetically sorted array
		list = arrayMatchWordsSorted;
	}
	// Else (user pressed Frequency toggle button)
	else
	{
		// Set FrequencySort flag to TRUE
		isSortByFrequency = YES;
		
		// Set list to frequency sorted array
		list = arrayMatchWords;
	}
	// Endif
	
	// Redraw table
	[table reloadData];
}


#pragma mark -
#pragma mark Table Data Source methods

/* *****************************************************************
 tableView:numberOfRowsInSection
 Returns number of rows in the table view for match words - simply
 the count of the array containing the match words.
 ***************************************************************** */
- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section
{
	return [list count];
}

/* *****************************************************************
 tableView:cellForRowAtIndexPath
 Display a match word in the match word table cell. If the user
 taps the word, the intention is to add the letters of that word
 to the substitution map.
 ***************************************************************** */
- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *MatchViewCellIdentifier = @"MatchViewCellIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MatchViewCellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
									   reuseIdentifier:MatchViewCellIdentifier] 
				autorelease];
		UIImage *buttonUpImage = [UIImage imageNamed:@"ADD_up.png"];
		UIImage *buttonDownImage = [UIImage imageNamed:@"ADD_dn.png"];
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.frame = CGRectMake(0.0, 0.0, buttonUpImage.size.width, buttonUpImage.size.height);
		[button setBackgroundImage:buttonUpImage forState:UIControlStateNormal];
		[button setBackgroundImage:buttonDownImage forState:UIControlStateHighlighted];
		[button setTitle:@"Add" forState:UIControlStateNormal];
		//[button addTarget:self 
		//		   action:@selector(addMatchLettersPressed:) 
		// forControlEvents:UIControlEventTouchUpInside];
		cell.accessoryView = button;
	}
	NSUInteger row = [indexPath row];
	NSString *rowString = [list objectAtIndex:row];
	cell.textLabel.text = rowString;
	cell.textLabel.font = [UIFont fontWithName:@"Marker Felt" size:25.0];
	cell.textLabel.textAlignment = NSTextAlignmentCenter;
	//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	//[rowString release];
	return cell;
}

#pragma mark -
#pragma mark Table Delegate Methods

/* *****************************************************************
 tableView:didSelectRowAtIndexPath
 User has tapped a word's cell in the match word table, with the
 intention of adding the word's letters to the substitution map.
 
 If the user confirms, add the word's letters to the substitution
 map - will also need to delete letters from the ciphertext and
 plaintext picker arrays if they haven't already been deleted.
 Once done, clear the match list except perhaps for the
 selected word.
 
 HOWEVER, if any ciphertext and plaintext letters match,
 e.g. A=A, reject the selection and alert the user.
 
 PDL
	For each letter in match word
		If crypto letter matches plain letter
			Reject match word
		Endif
	Endfor
	If match word was rejected
		Alert user of rejection
	Else
		Get user confirmation for match word
	Endif
 End PDL
 ***************************************************************** */
- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger luiRow = [indexPath row];
	NSString *lstrMatchWord = [list objectAtIndex:luiRow];
	[gstrSubstitutionWord setString:lstrMatchWord];
	
	BOOL isMatchWordRejected = NO;
	// For each letter in match word
	for (NSUInteger luiMatchWordLetterIndex = 0; 
		 luiMatchWordLetterIndex < [gstrSubstitutionWord length]; 
		 luiMatchWordLetterIndex++)
	{
		unichar lcMatchCharacter = [gstrSubstitutionWord 
									characterAtIndex:luiMatchWordLetterIndex];
		unichar lcCryptoCharacter = [gstrCryptogramWord 
									 characterAtIndex:luiMatchWordLetterIndex];
		// If crypto letter matches plain letter
		if (lcCryptoCharacter == lcMatchCharacter)
		{
			// Reject match word
			isMatchWordRejected = YES;
		}
		// Endif
	}
	// Endfor
	
	// If match word was rejected
	if (isMatchWordRejected)
	{
		// Alert user of rejection
		NSString *lstrMessage = [[NSString alloc] initWithFormat:@"%@ has letters in common with %@",
								 gstrSubstitutionWord, gstrCryptogramWord];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Selection invalid" 
														message:lstrMessage
													   delegate:nil 
											  cancelButtonTitle:@"Oops" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		[lstrMessage release];
	}
	// Else
	else
	{
		// Get user confirmation for match word
		NSString *lstrMessage = [[NSString alloc] initWithFormat:@"Add letters from %@ to substitution list?",
								 gstrSubstitutionWord];
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:lstrMessage 
																 delegate:self 
														cancelButtonTitle:@"Cancel" 
												   destructiveButtonTitle:@"Do it" 
														otherButtonTitles:nil];
		[actionSheet showInView:self.view];
		[actionSheet release];
		[lstrMessage release];
	}
	// Endif

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/* *****************************************************************
 actionSheet:didDismissWithButtonIndex
 User has confirmed the selected match word's letters to be added to
 the substitution map. Proceed with checking the letters of the match
 word against the substitution map, adding new substitution pairs
 as they are found.  For each new substitution pair, also need to
 update the substitution map display(s), the picker wheel arrays
 and the substitution list. Finally, clear the match lists.
 
 Since this match word has already been filtered through the
 substitution list, a given crypto letter is either already assigned
 a plaintext letter or is unassigned - don't need to check for
 mismatched crypto-to-plain mappings.
 
 PDL
	For each letter in match word
		If crypto letter still unassigned
			Delete ciphertext letter from available ciphertext letters
			Delete plaintext letter from available plaintext letters
			Map plaintext letter to ciphertext letter in substitution map
			Add substitution pair to substitution list
		Endif
	Endfor
	Redraw substitution map display
	Clear main screen status
	Clear text entry field
	Return to main screen
 End PDL
 ***************************************************************** */
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != [actionSheet cancelButtonIndex])
	{
		// For each letter in match word
		for (NSUInteger luiMatchWordLetterIndex = 0; 
			 luiMatchWordLetterIndex < [gstrSubstitutionWord length]; 
			 luiMatchWordLetterIndex++)
		{
			unichar lcMatchCharacter = [gstrSubstitutionWord 
										characterAtIndex:luiMatchWordLetterIndex];
			unichar lcCryptoCharacter = [gstrCryptogramWord 
										 characterAtIndex:luiMatchWordLetterIndex];
			//NSLog(@"%@ letter %d is %d", gstrSubstitutionWord, luiMatchWordLetterIndex, lcMatchCharacter);
			//NSLog(@"%@ letter %d is %d", gstrCryptogramWord, luiMatchWordLetterIndex, lcCryptoCharacter);
			
			// If crypto letter still unassigned
			if (guiCryptoToPlain[lcCryptoCharacter-65] == 0)
			{
				//NSLog(@"guiCryptoToPlain[%d] = 0",lcCryptoCharacter-65);

				// Delete ciphertext letter from available ciphertext letters
				NSString *lstrCryptoLetter = [[NSString alloc] initWithFormat:@"%c",lcCryptoCharacter];
				strCryptoLetter = [NSString stringWithString:lstrCryptoLetter];
				//[strCryptoLetter setString:lstrCryptoLetter];
				[lstrCryptoLetter release];
				//NSLog(@"strCryptoLetter = %@",strCryptoLetter);
				iCryptoLetterRow = [garrayCryptoLetters indexOfObject:strCryptoLetter];
				//NSLog(@"iCryptoLetterRow = %d",iCryptoLetterRow);
				[garrayCryptoLetters removeObjectAtIndex:iCryptoLetterRow];
				
				// Delete plaintext letter from available plaintext letters
				NSString *lstrPlainLetter = [[NSString alloc] initWithFormat:@"%c",lcMatchCharacter];
				strPlainLetter = [NSString stringWithString:lstrPlainLetter];
				//[strPlainLetter setString:lstrPlainLetter];
				[lstrPlainLetter release];
				//NSLog(@"strPlainLetter = %@",strPlainLetter);
				iPlainLetterRow = [garrayPlainLetters indexOfObject:strPlainLetter];
				//NSLog(@"iPlainLetterRow = %d",iPlainLetterRow);
				[garrayPlainLetters removeObjectAtIndex:iPlainLetterRow];
				
				// Map plaintext letter to ciphertext letter in substitution map
				guiCryptoToPlain[lcCryptoCharacter-65] = lcMatchCharacter;
				
				// Add substitution pair to substitution list
				NSString *lstrSubstitutionPair = [[NSString alloc] initWithFormat:@"%@=%@",
												  strCryptoLetter, strPlainLetter];
				[garraySubstitutions addObject:lstrSubstitutionPair];
				//NSLog(@"New substitution pair:  %@",lstrSubstitutionPair);
				NSSortDescriptor *pairSorter = [[NSSortDescriptor alloc]
												initWithKey:0 ascending:YES];
				[garraySubstitutions sortUsingDescriptors:[NSArray arrayWithObject:pairSorter]];
				[lstrSubstitutionPair release];
				[pairSorter release];
			}
			// Endif (crypto letter still unassigned

		}
		// Endfor (each letter in match word)
		
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
		
		// Clear main screen status
		glblStatus.text = @"";
		
		/*
		NSString *msg = nil;
		msg = [[NSString alloc] 
			   initWithFormat:@"%@ letters to be added to substitution list",gstrSubstitutionWord];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CONFIRMATION" 
														message:msg 
													   delegate:self 
											  cancelButtonTitle:@"Great!" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		[msg release];
		 */
		
		// Clear text entry field
		gtxtfldCryptoWord.text = @"";
		
		// Return to main screen
		[self.navigationController popViewControllerAnimated:YES];
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
- (void)viewDidLoad 
{
	NSLog(@"Enter MatchViewController - viewDidLoad");
	strCryptoLetter = [[NSMutableString alloc] initWithCapacity:1];
	strPlainLetter  = [[NSMutableString alloc] initWithCapacity:1];
	sgmtSortSelector.tintColor = [UIColor darkGrayColor];
    [super viewDidLoad];
}

/* *****************************************************************
 viewWillAppear
 When this view reappears, present the array of match words sorted
 either by letter/word frequency or alphabetially, depending on
 the state of Boolean variable isSortByFrequency
 ***************************************************************** */
- (void)viewWillAppear:(BOOL)animated
{
	NSLog(@"Enter MatchViewController - viewWillAppear");
	if (isSortByFrequency)
	{
		list = arrayMatchWords;
	}
	else
	{
		list = arrayMatchWordsSorted;
	}

	[table reloadData];
	
	NSMutableString *lstrTemp = [[NSMutableString alloc] initWithFormat:@"Found %d match",[list count]];
	if ([list count] > 1)
	{
		[lstrTemp appendString:@"es"];
	}
	lblStatus.text = lstrTemp;
	[lstrTemp release];
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
	list = nil;
}


- (void)dealloc 
{
	NSLog(@"MatchViewController - dealloc");
	[strCryptoLetter release];
	[strPlainLetter release];
	[list release];
	[table release];
	[sgmtSortSelector release];
    [super dealloc];
}


@end
