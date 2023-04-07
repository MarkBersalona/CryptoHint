//
//  CryptoHintAppDelegate.h
//  CryptoHint
//
//  Created by Mark Bersalona on 2010.08.04.
//  Copyright Bersalona Technologies LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

// Save file for data persistence
#define kSaveFilename @"CryptoHint_SavedData.plist"

@interface CryptoHintAppDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow *window;
    UINavigationController *navigationController;	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

- (NSString *)saveDataFilePath;

@end

