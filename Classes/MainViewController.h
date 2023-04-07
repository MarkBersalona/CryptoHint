//
//  MainViewController.h
//  CryptoHint
//
//  Created by Mark Bersalona on 2010.08.06.
//  Copyright 2010 Bersalona Technologies LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <sqlite3.h>
//#import "Reachability.h"


// ***** Data Model *****

// Arrays of cryptotext and plaintext letters for substitution pairs
NSArray *garrayBaseCryptoLetters;
NSArray *garrayBasePlainLetters;
NSMutableArray *garrayCryptoLetters;
NSMutableArray *garrayPlainLetters;
NSMutableArray *garraySubstitutions;

// Arrays of matching plaintext words
NSMutableArray *arrayMatchWords;
NSMutableArray *arrayMatchWordsSorted;

// Array of recently typed cryptogram words
NSMutableArray *garrayRecentCryptoWords;
#define kMaxRecentCryptoWords	25

// Parsed capitalized cryptogram word entered by user
NSMutableString *gstrCryptogramWord;

// Match word selected by user for addition to substitution map
NSMutableString *gstrSubstitutionWord;

// Flag to determine sort of matched words
// YES - sort by letter frequency statistics (common words score 2x)
// NO  - sort alphabetically
BOOL isSortByFrequency;

// Letter substitution map
// Value is 0              = crypto letter currently unassigned
// Value is an ASCII value = crypto letter has a corresponding plain letter assigned
int guiCryptoToPlain[26];

// Restore file for data persistence
#define kRestoreFilename @"CryptoHint_SavedData.plist"


// ***** Data Model *****


// ***** Global pointers for convenience *****
UILabel *glblSubstitutePlainLetters;
UILabel *glblStatus;
UITextField *gtxtfldCryptoWord;
// ***** Global pointers for convenience *****

// ***** Items to check/test Internet connectivity *****
@class Reachability;
BOOL isInternetConnected;
BOOL isHostConnected;
// ***** Items to check/test Internet connectivity *****

@interface MainViewController : UIViewController
{
	NSArray *controllers;
	
	// ***** Elements in main window *****	
	// Activity indicator while searching database
	IBOutlet UIActivityIndicatorView *actvSearching;
	
	// Text field for cryptogram word
	//IBOutlet UITextField *txtfldCryptoWord;
	UITextField *txtfldCryptoWord;
	
	// Label for one-line status
	IBOutlet UILabel *lblStatus;
	
	// Label for plain letter substitution
	IBOutlet UILabel *lblSubstitutePlainLetters;
	// ***** Elements in main window *****
	
	// Table of recent cryptogram words
	IBOutlet UITableView *tblRecentCryptoWords;

	
	// ***** SQL database stuff *****
	sqlite3 *database;
	sqlite3_stmt *statement;
	// ***** SQL database stuff *****
	
	// ***** Items to check/test Internet connectivity *****
	Reachability *internetReachable;
	Reachability *hostReachable;
	// ***** Items to check/test Internet connectivity *****

}

@property (nonatomic, retain) NSArray *controllers;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *actvSearching;
@property (nonatomic, retain) IBOutlet UITextField *txtfldCryptoWord;
@property (nonatomic, retain) IBOutlet UILabel *lblStatus;
@property (nonatomic, retain) IBOutlet UILabel *lblSubstitutePlainLetters;
@property (nonatomic, retain) IBOutlet UITableView *tblRecentCryptoWords;

- (IBAction)txtfldCryptoWordDoneEditing:(id)sender;
- (void)searchDatabaseMatches:(id)sender;
- (IBAction)aboutButtonPressed:(id)sender;
- (IBAction)howtoButtonPressed:(id)sender;
- (IBAction)substitutionsButtonPressed:(id)sender;
- (IBAction)resetAllButtonPressed:(id)sender;
- (NSString *)restoreDataFilePath;
- (void)checkNetworkStatus:(NSNotification *)notice;

@end
