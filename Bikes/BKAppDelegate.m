//
//  BKAppDelegate.m
//  Bikes
//
//  Created by Evan Coleman on 7/13/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import "BKAppDelegate.h"
#import "BKTabBarController.h"
#import "BKTabBarViewModel.h"

#import <CocoaLumberjack/DDASLLogger.h>
#import <CocoaLumberjack/DDTTYLogger.h>
#import <HockeySDK/HockeySDK.h>

@implementation BKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupLogger];
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"8ae5d4f1d795d7954070bba999915c06"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSFontAttributeName: [UIFont bikes_boldWithSize:16] }];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont bikes_boldWithSize:13]];
    
    BKTabBarViewModel *viewModel = [[BKTabBarViewModel alloc] init];
    BKTabBarController *pageViewController = [[BKTabBarController alloc] initWithViewModel:viewModel];
    self.window.rootViewController = pageViewController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setupLogger {
    #if DEBUG
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // Xcode console
    #else
    [DDLog addLogger:[DDASLLogger sharedInstance]]; // Console.app
    #endif
}

@end
