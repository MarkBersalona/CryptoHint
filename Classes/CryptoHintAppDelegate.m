//
//  CryptoHintAppDelegate.m
//  CryptoHint
//
//  Created by Mark Bersalona on 2010.08.04.
//  Copyright Bersalona Technologies LLC 2010. All rights reserved.
//

#import "CryptoHintAppDelegate.h"
#import "MainViewController.h"

@implementation CryptoHintAppDelegate

@synthesize window;
@synthesize navigationController;


- (NSString *)saveDataFilePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:kSaveFilename];
}


#pragma mark -
#pragma mark Application lifecycle

/* *****************************************************************
 application:didFinishLaunchingWithOptions:
 
 Called once, on application launch - a good place to put
 application initialization code
 

 ***************************************************************** */
- (BOOL)application:(UIApplication *)application 
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
	NSLog(@"Enter CryptoHintAppDelegate - application:didFinishLaunchingWithOptions");
	//application.statusBarStyle = UIStatusBarStyleBlackOpaque;
    // Override point for customization after application launch.
	
	// Place navigation controller's view in the window hierarchy
	[window addSubview:navigationController.view];
	
    [window makeKeyAndVisible];
	

	
	// Initialize globals
	
	return YES;
	NSLog(@"Exit  CryptoHintAppDelegate - application:didFinishLaunchingWithOptions");
}


- (void)applicationWillResignActive:(UIApplication *)application 
{
	NSLog(@"CryptoHintAppDelegate - applicationWillResignActive");
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

/* *****************************************************************
 applicationDidEnterBackground:
 
 Called when application goes to the background - save data
 Copied from applicationWillTerminate: make any changes there first,
 then copy it here.
 
 PDL
	Save the array of substitutions
	Save the array of recent cryptogram words
	Save to file
 End PDL
 ***************************************************************** */

- (void)applicationDidEnterBackground:(UIApplication *)application {
	NSLog(@"CryptoHintAppDelegate - applicationDidEnterBackground");
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	
	NSMutableArray *larraySaveData = [[NSMutableArray alloc] init];
	
	// Save the array of substitutions
	[larraySaveData addObject:garraySubstitutions];
	
	// Save the array of recent cryptogram words
	[larraySaveData addObject:garrayRecentCryptoWords];
	
	// Save to file
	[larraySaveData writeToFile:[self saveDataFilePath] atomically:YES];
	[larraySaveData release];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	NSLog(@"CryptoHintAppDelegate - applicationWillEnterForeground");
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	NSLog(@"CryptoHintAppDelegate - applicationDidBecomeActive");
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/* *****************************************************************
 applicationWillTerminate:
 
 Called once, on application termination - save data
 
 PDL
	Save the array of substitutions
	Save the array of recent cryptogram words
	Save to file
 End PDL
 ***************************************************************** */
- (void)applicationWillTerminate:(UIApplication *)application {
	NSLog(@"CryptoHintAppDelegate - applicationWillTerminate");
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	
	NSMutableArray *larraySaveData = [[NSMutableArray alloc] init];
	
	// Save the array of substitutions
	/*
	for (int luiX = 0; luiX < [garraySubstitutions count]; luiX++)
	{
		NSLog(@"garraySubstitutions[%d] = %@",luiX,[garraySubstitutions objectAtIndex:luiX]);
	}
	 */
	[larraySaveData addObject:garraySubstitutions];
	
	// Save the array of recent cryptogram words
	/*
	for (int luiY = 0; luiY < [garrayRecentCryptoWords count]; luiY++)
	{
		NSLog(@"garrayRecentCryptoWords[%d] = %@",luiY,[garrayRecentCryptoWords objectAtIndex:luiY]);
	}
	 */
	[larraySaveData addObject:garrayRecentCryptoWords];
	
	// Save to file
	[larraySaveData writeToFile:[self saveDataFilePath] atomically:YES];
	[larraySaveData release];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	NSLog(@"CryptoHintAppDelegate - applicationDidReceiveMemoryWarning");
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


/* *****************************************************************
 dealloc
 
 Release objects for good when application terminates
 ***************************************************************** */
- (void)dealloc 
{
	NSLog(@"Enter CryptoHintAppDelegate - dealloc");
    [window release];
	[navigationController release];
	
	// Release globals
	
    [super dealloc];
	NSLog(@"Exit  CryptoHintAppDelegate - dealloc");
}


@end
