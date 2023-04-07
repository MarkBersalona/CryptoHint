//
//  MainViewController.m
//  CryptoHint
//
//  Created by Mark Bersalona on 2010.08.06.
//  Copyright 2010 Bersalona Technologies LLC. All rights reserved.
//

#import "CryptoHintAppDelegate.h"
#import "MainViewController.h"
#import "AboutViewController.h"
#import "HowtoViewController.h"
#import "SubstitutionListViewController.h"
#import "SubstitutionPickersViewController.h"
#import "MatchViewController.h"
#import "Reachability.h"

NSInteger iCryptoLetterRow;
NSInteger iPlainLetterRow;
NSMutableString *strCryptoLetter;
NSMutableString *strPlainLetter;


@implementation MainViewController

@synthesize controllers;
@synthesize actvSearching;
@synthesize txtfldCryptoWord;
@synthesize lblStatus;
@synthesize lblSubstitutePlainLetters;
@synthesize tblRecentCryptoWords;

#pragma mark -
#pragma mark Methods

/* *****************************************************************
 txtfldCryoptoWordDoneEditing:
 
 Method called when user is finished editing in the
 txtfldCryptoWordDoneEditing text field. This occurs
 when user hits the RETURN key in the pop-up keyboard.
 (Would also like to call this when/if user touches the area
 outside the text field?)
 
 PDL
	Have text field (sender) resign first responder so keyboard disappears
	Capture crypto word
	Strip crypto word of non-letters
	Capitalize crypto word text
	If crypto word length > 0
		Save crypto word in recent history
		Start activity indicator and display "Searching..." status
		Search database for matches to crypto word letter pattern
 	Else (crypto word length = 0)
		Display status:  no crypto word entered!
	Endif
	Release locally generated objects
 End PDL
 ***************************************************************** */
- (IBAction)txtfldCryptoWordDoneEditing:(id)sender
{
	NSLog(@"Enter txtfldCryptoWordDoneEditing:");
	//Have text field (sender) resign first responder so keyboard disappears
	[sender resignFirstResponder];
	
	// Capture crypto word
	NSString *strRawCryptoword = [[NSString alloc] initWithString:[sender text]];
	//NSLog(@"strRawCryptoword=%@",strRawCryptoword);
	
	// Strip crypto word of non-letters
	NSMutableString *strCryptoLetters = [[NSMutableString alloc] initWithString:[strRawCryptoword uppercaseString]];
	NSCharacterSet *desiredCharacters = [NSCharacterSet letterCharacterSet];
	for (NSUInteger i = 0; i < [strCryptoLetters length ]; i++)
	{
		//NSLog(@"i=%d strCryptoLetters length = %d", i, [strCryptoLetters length]);
		unichar currentCharacter = [strCryptoLetters characterAtIndex:i];
		//NSLog(@"Character at i=%d is %d",i,currentCharacter);
		if ((currentCharacter >= 'A') && (currentCharacter <= 'Z'))
		{
			//NSLog(@"Character %c is a good letter!", currentCharacter);
		}
		if (! [desiredCharacters characterIsMember:currentCharacter])
		{
			[strCryptoLetters deleteCharactersInRange:NSMakeRange( i, 1 )];
			i--;
		}
	}
	[strRawCryptoword release];

	// Capitalize crypto word text
	NSMutableString *strCapitalized = [[NSMutableString alloc] initWithString:[strCryptoLetters uppercaseString]];
	lblStatus.text = strCapitalized;
	//NSLog(@"strCapitalized=%@",strCapitalized);
	[sender setText:strCapitalized];
	//NSLog(@"strCapitalized = %@", strCapitalized);
	[strCryptoLetters release];
	[gstrCryptogramWord setString:strCapitalized];
	//[strCapitalized release];
	NSLog(@"gstrCryptogramWord = %@", gstrCryptogramWord);

	// If crypto word length > 0
	if ([gstrCryptogramWord length] > 0)
	{
		//NSLog(@"User entered a word which parsed to a cryptogram word OK");
		// Save crypto word in recent history
		if ([garrayRecentCryptoWords count] >= kMaxRecentCryptoWords)
		{
			// Delete oldest item from recent history
			[garrayRecentCryptoWords removeObjectAtIndex:[garrayRecentCryptoWords count]-1];
		}
		if ([garrayRecentCryptoWords count] == 0)
		{
			[garrayRecentCryptoWords addObject:strCapitalized];
		}
		else
		{
			[garrayRecentCryptoWords insertObject:strCapitalized atIndex:0];
		}
		[tblRecentCryptoWords reloadData];
		
		// Start activity indicator and display "Searching..." status
		lblStatus.text = @"Searching...";
		[actvSearching startAnimating];
		
		// Search database for matches to crypto word letter pattern
		[self performSelector:@selector(searchDatabaseMatches:) withObject:nil afterDelay:0];
		
	}
	// Else (crypto word length = 0)
	else
	{
		// Display status:  no crypto word entered!
		NSLog(@"User entered a word which did not parse to a cryptogram word");
		lblStatus.text = @"No cryptogram word entered";
	}
	// Endif (crypto word length > 0)
		
	// Release locally created objects
	NSLog(@"Exiting txtfldCryptoWordDoneEditing:");
	[strCapitalized release];
}

/* *****************************************************************
 searchDatabaseMatches
 PDL
	Generate crypto word letter pattern
	Search database for words matching letter pattern
	If count of words found > 0 AND substitutions exist
		For each match
			For each letter in match word
				If letter in crypto word = letter in match word
					Mark match word for deletion (replace word with '-')
				Else
					For each substitution pair
						Check if crypto letter was in crypto word
						Check if plain letter is in match word at same position
						If crypto letter in crypto word
						AND plain letter NOT in match word at position
							Mark match word for deletion (replace word with '-')
						Endif
						If crypto letter NOT in crypto word
						AND plain letter in match word at position
							Mark match word for deletion (replace word with '-')
						Endif
					Endfor (each substitution pair)
				Endif (letter in crypto word = letter in match word)
			Endfor (each letter in match word)
			If match word marked for deletion
				Delete match word from list
			Endif
		Endfor (each match)
 	Endif (count of words found > 0) AND (substitutions exist)
	If count of matches still > 0
		GOTO matched words view
	Else (count of words found = 0)
		Display status:  no matches found for letter pattern
	Endif
	Stop activity indicator
 End PDL
 ***************************************************************** */
- (void)searchDatabaseMatches:(id)sender
{
	// Clear array of matched words
	[arrayMatchWords removeAllObjects];
	[arrayMatchWordsSorted removeAllObjects];
	
	// Generate crypto word letter pattern
	int luiArrayUsedLetterPattern[26];
	for (NSUInteger i = 0; i<26; i++)
	{
		luiArrayUsedLetterPattern[i] = 0;
	}
	int luiUsedLetters = 0;
	NSMutableString *strLetterPattern = [[NSMutableString alloc] initWithString:@""];
	BOOL lfLetterAlreadyUsed;
	for (NSUInteger i = 0; i < [gstrCryptogramWord length]; i++)
	{
		lfLetterAlreadyUsed = NO;
		unichar currentCharacter = [gstrCryptogramWord characterAtIndex:i];
		//NSLog(@"Character at i=%d is %c", i, currentCharacter);
		for (NSUInteger j = 0; j < luiUsedLetters; j++)
		{
			//NSLog(@"j=%d currentCharacter=%c", j, currentCharacter);
			//NSLog(@"luiArrayUsedLetterPattern[%d]=%c", j, luiArrayUsedLetterPattern[j]);
			if (currentCharacter == luiArrayUsedLetterPattern[j])
			{
				lfLetterAlreadyUsed = YES;
				//NSLog(@"%c found in luiArrayUsedLetterPattern[%d]",currentCharacter,j);
				//NSLog(@"Letter pattern character = %c",'A'+j);
				[strLetterPattern appendFormat:@"%c",'A'+j];
			}
		}
		if (!lfLetterAlreadyUsed)
		{
			//NSLog(@"Character %c assigned to %c", currentCharacter, 'A'+luiUsedLetters);
			luiArrayUsedLetterPattern[luiUsedLetters] = currentCharacter;
			//NSLog(@"Letter pattern character = %c",'A'+luiUsedLetters);
			[strLetterPattern appendFormat:@"%c",'A'+luiUsedLetters];
			luiUsedLetters++;
		}
	}
	NSLog(@"strLetterPattern = %@",strLetterPattern);
	
	// Search database for words matching letter pattern
	// ? is a placeholder for parameters
	char *cQuery;
	cQuery = "SELECT PatternWord, PlainWord, Score FROM CryptoSearch WHERE PatternWord LIKE ? ORDER BY Score DESC";

	//NSLog(@"cQuery = %s",cQuery);
	// Prepare the query
	if (sqlite3_prepare_v2(database, cQuery, -1, &statement, NULL) != SQLITE_OK)
	{
		//NSLog(@"*** query error: %s",statement);
	}
	//NSLog(@"statement = %s",statement);
	// Add % to the end of the search text
	//[gstrLetterPattern appendString:@"%"];
	//NSLog(@"Searching for %@", strLetterPattern);
	// This C string will get cleaned up automatically
	const char *cSearchText = [strLetterPattern cStringUsingEncoding:NSUTF8StringEncoding];
	//NSLog(@"cSearchText = %s",cSearchText);
	// Replace the first (and only) parameter with the search text
	sqlite3_bind_text(statement, 1, cSearchText, -1, SQLITE_TRANSIENT);
	//NSLog(@"statement = %s",statement);
	// Loop to get all the rows
	while (sqlite3_step(statement) == SQLITE_ROW)
	{
		// Get the string in the first column
		//const char *cCryptoWord = (const char *)sqlite3_column_text(statement, 0);
		// Convert C string into an NSString
		//NSString *strCryptoWord = [[[NSString alloc] initWithUTF8String:cCryptoWord] 
		//						   autorelease];
		
		// Get the string in the second column
		const char *cPlainWord = (const char *)sqlite3_column_text(statement, 1);
		// Convert C string into an NSString
		NSString *strPlainWord  = [[[NSString alloc] initWithUTF8String:cPlainWord]  
								   autorelease];
		//NSLog(@"Letter pattern %@ for %@", strCryptoWord,strPlainWord);
		//lblStatus.text = strPlainWord;
		
		// Add plain word to matched words array
		[arrayMatchWords addObject:strPlainWord];
	}
	// Clear the query results
	sqlite3_reset(statement);
	//NSLog(@"Number of elements in arrayMatchWords = %d",[arrayMatchWords count]);
	
	// If count of words found > 0 AND substitutions exist
	if ([arrayMatchWords count] > 0 && [garraySubstitutions count] > 0)
	{
		//NSLog(@"Word found > 0 AND substitutions exist:  filter match words");
		// For each match
		for (NSUInteger luiMatchWordIndex = 0; 
			 luiMatchWordIndex < [arrayMatchWords count]; 
			 luiMatchWordIndex++)
		{
			NSString *lstrMatchWord = [[[NSString alloc] 
										 initWithString:[arrayMatchWords objectAtIndex:luiMatchWordIndex]] 
										autorelease];
			//NSLog(@"arrayMatchWords[%d] = %@", luiMatchWordIndex, lstrMatchWord);
			// For each letter in match word
			for (NSUInteger luiMatchLetterIndex = 0; 
				 luiMatchLetterIndex < [[arrayMatchWords objectAtIndex:luiMatchWordIndex] length]; 
				 luiMatchLetterIndex++)
			{
				unichar lcMatchCharacter = [lstrMatchWord characterAtIndex:luiMatchLetterIndex];
				unichar lcCryptoCharacter  = [gstrCryptogramWord characterAtIndex:luiMatchLetterIndex];
				// If letter in crypto word = letter in match word
				if (lcMatchCharacter == lcCryptoCharacter)
				{
					// Mark match word for deletion (replace word with '-')
					//NSLog(@"arrayMatchWords[%d] = %@: deleted because %c=%c", 
					//	  luiMatchWordIndex, [arrayMatchWords objectAtIndex:luiMatchWordIndex],
					//	  lcMatchCharacter, lcCryptoCharacter);
					[arrayMatchWords replaceObjectAtIndex:luiMatchWordIndex withObject:@"-"];
				}
				// Else (check all substitution pairs)
				else
				{
					// For each substitution pair
					for (NSUInteger luiSubstitutionIndex = 0; 
						 luiSubstitutionIndex < [garraySubstitutions count]; 
						 luiSubstitutionIndex++)
					{
						unichar lcCipherCharacter = [[garraySubstitutions objectAtIndex:luiSubstitutionIndex] 
													 characterAtIndex:0];
						unichar lcPlainCharacter  = [[garraySubstitutions objectAtIndex:luiSubstitutionIndex] 
													 characterAtIndex:2];
						
						// Check if crypto letter was in crypto word
						// Check if plain letter is in match word at same position
						// If crypto letter in crypto word
						// AND plain letter NOT in match word at position
						if ((lcCipherCharacter == lcCryptoCharacter) &&
							(lcPlainCharacter  != lcMatchCharacter))
						{
							//NSLog(@"Crypto letter = %c, Plain letter = %c",lcCipherCharacter,lcPlainCharacter);
							//NSLog(@"Crypto letter in crypto word BUT plain letter not a match in same position");
							// Mark match word for deletion (replace word with '-')
							//NSLog(@"arrayMatchWords[%d] = %@: deleted because %c=%c but %c!= %c", 
							//	  luiMatchWordIndex, [arrayMatchWords objectAtIndex:luiMatchWordIndex],
							//	  lcCipherCharacter, lcCryptoCharacter,
							//	  lcPlainCharacter, lcMatchCharacter);
							[arrayMatchWords replaceObjectAtIndex:luiMatchWordIndex withObject:@"-"];
						}
						// Endif
						
						// If crypto letter NOT in crypto word
						// AND plain letter in match word at position
						if ((lcCipherCharacter != lcCryptoCharacter) &&
							(lcPlainCharacter  == lcMatchCharacter))
						{
							//NSLog(@"Crypto letter = %c, Plain letter = %c",lcCipherCharacter,lcPlainCharacter);
							//NSLog(@"Crypto letter not in crypto word BUT plain letter IS a match in same position");
							// Mark match word for deletion (replace word with '-')
							//NSLog(@"arrayMatchWords[%d] = %@: deleted because %c!=%c but %c=%c", 
							//	  luiMatchWordIndex, [arrayMatchWords objectAtIndex:luiMatchWordIndex],
							//	  lcCipherCharacter, lcCryptoCharacter,
							//	  lcPlainCharacter, lcMatchCharacter);
							[arrayMatchWords replaceObjectAtIndex:luiMatchWordIndex withObject:@"-"];
						}
						// Endif
					}
					// Endfor (each substitution pair)
				}
				// Endif (letter in crypto word = letter in match word)
			}
			// Endfor (each letter in match word)
			
			// If match word marked for deletion
			if ([[arrayMatchWords objectAtIndex:luiMatchWordIndex] isEqualToString:@"-"])
			{
				//NSLog(@"Deleting arrayMatchWords[%d]",luiMatchWordIndex);
				[arrayMatchWords removeObjectAtIndex:luiMatchWordIndex];
				--luiMatchWordIndex;
			}
				// Delete match word from list
			// Endif
		}
		// Endfor (each match)
	}
	// Endif (count of words found > 0) AND (substitutions exist)
						
	// Copy match words and sort the list
	[arrayMatchWordsSorted addObjectsFromArray:arrayMatchWords];
	NSSortDescriptor *wordSorter = [[NSSortDescriptor alloc]
									initWithKey:0 ascending:YES];
	[arrayMatchWordsSorted sortUsingDescriptors:[NSArray arrayWithObject:wordSorter]];
	[wordSorter release];
	
	NSMutableString *strSearchResult = [[NSMutableString alloc] initWithString:@""];
	// If count of matches still > 0
	if ([arrayMatchWords count] > 0)
	{
		// GOTO matched words view
		[strSearchResult appendFormat:
		 @"%@ has %d match", gstrCryptogramWord, [arrayMatchWords count] ];
		if ([arrayMatchWords count] > 1)
		{
			[strSearchResult appendString:@"es"];
		}
		MatchViewController *matchViewController = [self.controllers objectAtIndex:3];
		matchViewController.title = gstrCryptogramWord;
		[self.navigationController pushViewController:matchViewController 
											 animated:YES];
	}
	// Else (count of words found = 0)
	else
	{
		// Display status:  no matches found for letter pattern
		[strSearchResult appendFormat:@"%@ had no matches", gstrCryptogramWord];
	}
	// Endif (count of matches still > 0)
	
	// Stop activity indicator
	[actvSearching stopAnimating];
	
	lblStatus.text = strSearchResult;
	[strLetterPattern release];
	[strSearchResult release];	
}




/* *****************************************************************
 aboutButtonPressed:
 Presents the About screen, showing version number and other info
 This screen is also the gateway to the CryptoHint website and
 in-app Email.
 ***************************************************************** */
- (IBAction)aboutButtonPressed:(id)sender
{
	NSLog(@"Enter MainViewController - aboutButtonPressed");
	
	// Let's load the About view
	AboutViewController *aboutViewController = [self.controllers objectAtIndex:0];
	[self.navigationController pushViewController:aboutViewController 
										 animated:YES];
	//[self presentModalViewController:aboutViewController 
	//									 animated:YES];
	
	NSLog(@"Exit  MainViewController - aboutButtonPressed");
}

/* *****************************************************************
 howtoButtonPressed:
 Presents the Help screens
 ***************************************************************** */
- (IBAction)howtoButtonPressed:(id)sender
{
	NSLog(@"Enter MainViewController - howtoButtonPressed");

	// Let's load the HOWTO view
	HowtoViewController *howtoViewController = [self.controllers objectAtIndex:1];
	//[self.navigationController pushViewController:howtoViewController animated:YES];
	[self presentViewController:howtoViewController animated:YES completion:nil];
	NSLog(@"Exit  MainViewController - howtoButtonPressed");	
}


/* *****************************************************************
 substitutionsButtonPressed
 User taps the letter substitution map to add or edit individual
 letter substitutions. Control goes to the substitution pickers screen
 unless the map is full, in which case control goes directly to
 the substitution list screen.
 
 PDL
	If letters are available to add to the substitution map
		Goto substitution pickers screen
	Else
		Goto substitution edit screen
	Endif
 End PDL
 ***************************************************************** */
- (IBAction)substitutionsButtonPressed:(id)sender
{
	NSLog(@"Enter MainViewController - substitutionsButtonPressed");
	
	// If letters are available to add to the substitution map
	if ([garrayPlainLetters count] > 0)
	{
		// Goto substitution pickers screen
		SubstitutionPickersViewController *substitutionPickersViewController = [self.controllers objectAtIndex:2];
		[self.navigationController pushViewController:substitutionPickersViewController 
											 animated:YES];
	}
	// Else
	else
	{
		// Goto substitution edit screen
		SubstitutionListViewController *substitutionListViewController = [[SubstitutionListViewController alloc] init];
		substitutionListViewController.title = @"Substitutions";
		[self.navigationController pushViewController:substitutionListViewController 
											 animated:YES];
	}
	// Endif (letters available)

	NSLog(@"Exit  MainViewController - substitutionsButtonPressed");
}

/* *****************************************************************
 resetAllButtonPressed
 Removes all substitutions from the substitution map, which implies
 the arrays for the substitution pickers are restored to full
 alphabets, and substituion map on main screen is cleared.
 
 If substitution map was already cleared, clear the list of
 recent cryptogram words.
 
 Clear substitution map
 If substitution map had some entries
	Restore substitution pickers to full alphabets
	Clear substitution map on main screen
	Clear substitution list
	Clear text field
 Else
	Clear list of recent cryptogram words
 Endif
 Clear status

 
 ***************************************************************** */
- (IBAction)resetAllButtonPressed:(id)sender
{
	BOOL wasSubstitutionMapAlreadyClear = NO;
	// Clear substitution map
	for (int i = 0; i < 26; i++)
	{
		if (guiCryptoToPlain[i]!=0)
		{
			wasSubstitutionMapAlreadyClear = YES;
		}
		guiCryptoToPlain[i] = 0;
	}
	
	// If substitution map had some entries
	if (wasSubstitutionMapAlreadyClear)
	{
		// Restore substitution pickers to full alphabets
		[garrayCryptoLetters removeAllObjects];
		[garrayPlainLetters  removeAllObjects];
		[garrayCryptoLetters addObjectsFromArray:garrayBaseCryptoLetters];
		[garrayPlainLetters  addObjectsFromArray:garrayBasePlainLetters];
		
		// Clear substitution map on main screen
		glblSubstitutePlainLetters.text = @"..........................";
		
		// Clear substitution list
		[garraySubstitutions removeAllObjects];
		
		// Clear text field
		//gtxtfldCryptoWord.text = @"";
		txtfldCryptoWord.text = @"";
	}
	// Else
	else
	{
		// Clear list of recent cryptogram words
		[garrayRecentCryptoWords removeAllObjects];
		[tblRecentCryptoWords reloadData];
	}
	
	// Clear status
	lblStatus.text = @"";
}

/* *****************************************************************
 restoreDataFilePath
 Returns the file path of the saved data file - should be pointing
 to the application's Documents directory
 ***************************************************************** */
- (NSString *)restoreDataFilePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:kRestoreFilename];
}


#pragma mark -
#pragma mark Table Data Source methods
/* *****************************************************************
 tableView:numberOfRowsInSection
 Returns number of rows in the table view for recent cryptogram words
 - simply the count of the array containing the recent words.
 ***************************************************************** */
- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section
{
	return [garrayRecentCryptoWords count];
}

/* *****************************************************************
 tableView:cellForRowAtIndexPath
 Returns a cell for the table view of recent cryptogram words
 ***************************************************************** */
- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *RecentCryptogramWordsCellIdentifier = @"RecentCryptogramWordsCellIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RecentCryptogramWordsCellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
									   reuseIdentifier:RecentCryptogramWordsCellIdentifier] 
				autorelease];
		UIImage *buttonUpImage = [UIImage imageNamed:@"ADD_up.png"];
		UIImage *buttonDownImage = [UIImage imageNamed:@"ADD_dn.png"];
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.frame = CGRectMake(0.0, 0.0, buttonUpImage.size.width, buttonUpImage.size.height);
		[button setBackgroundImage:buttonUpImage forState:UIControlStateNormal];
		[button setBackgroundImage:buttonDownImage forState:UIControlStateHighlighted];
		[button setTitle:@"Add" forState:UIControlStateNormal];
		cell.accessoryView = button;
}
	NSUInteger row = [indexPath row];
	NSString *rowString = [garrayRecentCryptoWords objectAtIndex:row];
	cell.textLabel.text = rowString;
	cell.textLabel.font = [UIFont fontWithName:@"Courier" size:25.0];
	cell.textLabel.textAlignment = NSTextAlignmentCenter;
	//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	//[rowString release];
	return cell;
}


#pragma mark -
#pragma mark Table Delegate Methods

/* *****************************************************************
 tableView:didSelectRowAtIndexPath
 ***************************************************************** */
- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger luiRow = [indexPath row];
	NSString *lstrRecentCryptoWord = [garrayRecentCryptoWords objectAtIndex:luiRow];
	//gtxtfldCryptoWord.text = lstrRecentCryptoWord;
	txtfldCryptoWord.text = lstrRecentCryptoWord;
	[gstrCryptogramWord setString:lstrRecentCryptoWord];
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	// Start activity indicator and display "Searching..." status
	lblStatus.text = @"Searching...";
	[actvSearching startAnimating];
	
	// Search database for matches to crypto word letter pattern
	[self performSelector:@selector(searchDatabaseMatches:) withObject:nil afterDelay:0];
}


#pragma mark -
#pragma mark Application lifecycle

- (void)viewDidLoad
{
	NSLog(@"Enter MainViewController - viewDidLoad");
	
	self.title = @"CryptoHint";
	NSMutableArray *array = [[NSMutableArray alloc] init];
	glblStatus = lblStatus;
	gtxtfldCryptoWord = txtfldCryptoWord;
	glblSubstitutePlainLetters = lblSubstitutePlainLetters;
	glblSubstitutePlainLetters.text = @"..........................";
	lblStatus.text = @" ";
	for (int i = 0; i < 26; i++)
	{
		guiCryptoToPlain[i] = 0;
	}
	garrayBaseCryptoLetters = [[NSArray alloc] initWithObjects:@"A", @"B", @"C", @"D", @"E", @"F",
							   @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q",
							   @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
	garrayBasePlainLetters  = [[NSArray alloc] initWithObjects:@"A", @"B", @"C", @"D", @"E", @"F",
									@"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q",
									@"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
	garrayCryptoLetters = [[NSMutableArray alloc] init];
	garrayPlainLetters  = [[NSMutableArray alloc] init];
	[garrayCryptoLetters addObjectsFromArray:garrayBaseCryptoLetters];
	[garrayPlainLetters  addObjectsFromArray:garrayBasePlainLetters];
	
	
	// 0 - About controller
	AboutViewController *aboutViewController = [[AboutViewController alloc] init];
	aboutViewController.title = @"About...";
	[array addObject:aboutViewController];
	[aboutViewController release];
	
	// 1 - HOWTO controller
	HowtoViewController *howtoViewController = [[HowtoViewController alloc] init];
	howtoViewController.title = @"HELP";
	[array addObject:howtoViewController];
	[howtoViewController release];
	
	// 2 - Substitution pickers controller
	SubstitutionPickersViewController *substitutionPickersViewController = [[SubstitutionPickersViewController alloc] init];
	substitutionPickersViewController.title = @"Pick letters";
	//substitutionPickersViewController.navigationItem.rightBarButtonItem = substitutionPickersViewController.editButtonItem;
	[array addObject:substitutionPickersViewController];
	[substitutionPickersViewController release];
	
	// 3 - Matches controller
	MatchViewController *matchViewController = [[MatchViewController alloc] init];
	matchViewController.title = @"Matches";
	[array addObject:matchViewController];
	[matchViewController release];
	
	// 4 - Substitution list controller
	SubstitutionListViewController *substitutionListViewController = [[SubstitutionListViewController alloc] init];
	substitutionListViewController.title = @"Substitutions";
	[array addObject:substitutionListViewController];
	[substitutionListViewController release];

	// Open database
	//NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	//NSString *path = [paths objectAtIndex:0];
	// What would be the name of my database file?
	//NSString *fullPath = [path stringByAppendingPathComponent:@"CryptoHint.db"];
	NSString *fullPath = [[NSBundle mainBundle] pathForResource:@"CryptoHint" 
														 ofType:@"db"];
	/*
	// Get a file manager for file operations
	NSFileManager *fm = [NSFileManager defaultManager];
	// Does the file already exist?
	BOOL exists = [fm fileExistsAtPath:fullPath];
	// Does it already exist?
	if (exists)
	{
		NSLog(@"%@ exists already - just opening", fullPath);
	}
	else
	{
		NSLog(@"%@ does not exist - copying and opening",fullPath);
		// Where is the starting database in the application wrapper?
		NSString *pathForStartingDB = [[NSBundle mainBundle] pathForResource:@"CryptoHint" 
																	  ofType:@"db"];
		NSLog(@"Resource directory is %@",pathForStartingDB);
		
		// Copy it to the documents directory
		BOOL success = [fm copyItemAtPath:pathForStartingDB 
								   toPath:fullPath 
									error:NULL];
		if (!success)
		{
			NSLog(@"*** database copy failed");
		}
	}
	 */
	
	const char *cFullPath = [fullPath cStringUsingEncoding:NSUTF8StringEncoding];
	if (sqlite3_open(cFullPath, &database) != SQLITE_OK)
	{
		NSLog(@"*** Unable to open database at %@",fullPath);
	}
	else
	{
		NSLog(@"SUCCESS - able to open database at %@",fullPath);
	}
	
	// Initialize array of matched words
	arrayMatchWords       = [[NSMutableArray alloc] init];
	arrayMatchWordsSorted = [[NSMutableArray alloc] init];
	
	// Initialize array of substitutions
	garraySubstitutions = [[NSMutableArray alloc] init];
	
	// Initialize array of recent cryptogram words
	garrayRecentCryptoWords = [[NSMutableArray alloc] init];
	
	// Initialize string for capitalized crypto word
	gstrCryptogramWord = [[NSMutableString alloc] initWithString:@""];
	
	// Initialize string for selected match word for substitution map
	gstrSubstitutionWord = [[NSMutableString alloc] initWithString:@""];
	
	// If saved data file exists, get saved substitution and recent cryptogram word arrays
	NSString *filePath = [self restoreDataFilePath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		NSArray *larrayRestoreData = [[NSArray alloc] initWithContentsOfFile:filePath];
		// Copy restored substitution array to permanent substitution array
		[garraySubstitutions addObjectsFromArray:[larrayRestoreData objectAtIndex:0]];
		// Copy restored recent cryptogram words array to permanent array
		[garrayRecentCryptoWords addObjectsFromArray:[larrayRestoreData objectAtIndex:1]];
		[larrayRestoreData release];
		
		// For each entry in substitution array: extract letters and add to map
		for (int luiX = 0; luiX < [garraySubstitutions count]; luiX++)
		{
			NSLog(@"Restored garraySubstitutions[%d] = %@",
				  luiX, [garraySubstitutions objectAtIndex:luiX]);
			
			// Map plaintext letter to ciphertext letter in substitution map
			unichar lcCryptoCharacter = [[garraySubstitutions objectAtIndex:luiX] characterAtIndex:0];
			unichar lcPlainCharacter  = [[garraySubstitutions objectAtIndex:luiX] characterAtIndex:2];
			guiCryptoToPlain[lcCryptoCharacter-65] = lcPlainCharacter;
			
			// Delete ciphertext letter from available ciphertext letters
			NSString *lstrCryptoLetter = [[NSString alloc] initWithFormat:@"%c",lcCryptoCharacter];
			strCryptoLetter = [NSString stringWithString:lstrCryptoLetter];
			[lstrCryptoLetter release];
			iCryptoLetterRow = [garrayCryptoLetters indexOfObject:strCryptoLetter];
			[garrayCryptoLetters removeObjectAtIndex:iCryptoLetterRow];
			
			// Delete plaintext letter from available plaintext letters
			NSString *lstrPlainLetter = [[NSString alloc] initWithFormat:@"%c",lcPlainCharacter];
			strPlainLetter = [NSString stringWithString:lstrPlainLetter];
			[lstrPlainLetter release];
			iPlainLetterRow = [garrayPlainLetters indexOfObject:strPlainLetter];
			[garrayPlainLetters removeObjectAtIndex:iPlainLetterRow];
		}
		
		// Get recent cryptogram words
		for (int luiY = 0; luiY < [garrayRecentCryptoWords count]; luiY++)
		{
			NSLog(@"Restored garrayRecentCryptoWords[%d] = %@",
				  luiY, [garrayRecentCryptoWords objectAtIndex:luiY]);			
		}
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
	}
	// Finished restoring from saved data file
	
	// Check for internet connection
	isInternetConnected = NO;
	isHostConnected = NO;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
	internetReachable = [[Reachability reachabilityForInternetConnection] retain];
	[internetReachable startNotifier];
	// Check if a pathway to the website exists
	hostReachable = [[Reachability reachabilityWithHostName:@"www.BersalonaTechnologies.com"] retain];
	[hostReachable startNotifier];
	// Now patiently wait for the notification
	
	self.controllers = array;
	[array release];
	[super viewDidLoad];
	NSLog(@"Exit  MainViewController - viewDidLoad");
}

-(void)checkNetworkStatus:(NSNotification *)notice
{
	// Called after network status changes
	NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
	switch (internetStatus)
	{
		case NotReachable:
		{
			NSLog(@"The Internet is down");
			//lblStatus.text = @"WARNING - cannot connect to Internet";
			isInternetConnected = NO;
			break;
		}
		case ReachableViaWiFi:
		{
			NSLog(@"The Internet is working via WiFi");
			//lblStatus.text = @"Connection to Internet via WiFi is OK";
			isInternetConnected = YES;
			break;
		}
		case ReachableViaWWAN:
		{
			NSLog(@"The Internet is working via WWAN");
			//lblStatus.text = @"Connection to Internet is OK";
			isInternetConnected = YES;
			break;
		}
	}
	
	NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
	switch (hostStatus)
	{
		case NotReachable:
		{
			NSLog(@"A gateway to the host server is down");
			//lblStatus.text = @"WARNING - unable to connect to CryptoHint's website";
			isHostConnected = NO;
			break;
		}
		case ReachableViaWiFi:
		{
			NSLog(@"A gateway to the host server is working via WiFi");
			isHostConnected = YES;
			break;
		}
		case ReachableViaWWAN:
		{
			NSLog(@"A gateway to the host server is working via WWAN");
			isHostConnected = YES;
			break;
		}
	}
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


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	NSLog(@"MainViewController - didReceiveMemoryWarning");
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	NSLog(@"Enter MainViewController - viewDidUnload");
	self.controllers = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	NSLog(@"Exit  MainViewController - viewDidUnload");
}


- (void)dealloc 
{
	NSLog(@"Enter MainViewController - dealloc");
	[garrayBaseCryptoLetters release];
	[garrayBasePlainLetters release];
	[garrayCryptoLetters release];
	[garrayPlainLetters release];
	[gstrCryptogramWord release];
	[gstrSubstitutionWord release];
	[controllers release];
	[actvSearching release];
	[txtfldCryptoWord release];
	//[gtxtfldCryptoWord release];
	[lblStatus release];
	//[arrayMatchWords release];
	[garraySubstitutions release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [super dealloc];
	NSLog(@"Exit  MainViewController - dealloc");
}


@end
