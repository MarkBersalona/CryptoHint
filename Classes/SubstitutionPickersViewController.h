//
//  SubstitutionPickersViewController.h
//  CryptoHint
//
//  Created by Mark Bersalona on 2010.08.06.
//  Copyright 2010 Bersalona Technologies LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCryptoComponent 0
#define kPlainComponent 1


@interface SubstitutionPickersViewController : UIViewController 
<UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate>
{
	UIPickerView *pckrSubstitutions;
}

@property (nonatomic, retain) IBOutlet UIPickerView *pckrSubstitutions;

- (IBAction)selectButtonPressed:(id)sender;
- (IBAction)resetMapButtonPressed:(id)sender;
- (IBAction)editButtonPressed:(id)sender;


@end
