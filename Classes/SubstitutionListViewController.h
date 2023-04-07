//
//  SubstitutionListViewController.h
//  CryptoHint
//
//  Created by Mark Bersalona on 2010.08.06.
//  Copyright 2010 Bersalona Technologies LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


//@interface SubstitutionListViewController : UITableViewController
@interface SubstitutionListViewController : UIViewController
{
	// Label for one-line status
	IBOutlet UILabel *lblStatus;
	
	// Table view for substitution list
	IBOutlet UITableView *tblSubstitutionList;
}
@property (nonatomic, retain) IBOutlet UILabel *lblStatus;
@property (nonatomic, retain) IBOutlet UITableView *tblSubstitutionList;

- (IBAction)resetMapButtonPressed:(id)sender;
- (IBAction)editButtonPressed:(id)sender;

@end
