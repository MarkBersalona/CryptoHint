//
//  MatchViewController.h
//  CryptoHint
//
//  Created by Mark Bersalona on 2010.08.10.
//  Copyright 2010 Bersalona Technologies LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAlphabeticalSort 0
#define kFrequencySort 1


@interface MatchViewController : UIViewController <UIActionSheetDelegate>
{
	IBOutlet UILabel *lblStatus;
	NSMutableArray *list;
	UITableView *table;
	IBOutlet UISegmentedControl *sgmtSortSelector;
}

@property (nonatomic, retain) IBOutlet UILabel *lblStatus;
@property (nonatomic, retain) NSMutableArray *list;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UISegmentedControl *sgmtSortSelector;

- (IBAction)toggleMatchSort:(id)sender;


@end
