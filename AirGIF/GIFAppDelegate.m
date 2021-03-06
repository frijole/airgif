//
//  GIFAppDelegate.m
//  AirGIF
//
//  Created by Ian Meyer on 9/20/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import "GIFAppDelegate.h"

#import "GIFLibrary.h"

#import "GIFMainPageViewController.h"

@implementation GIFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // check contents of collections, this will also trigger migration/upgrade if needed
    NSLog(@"Launching with %d favorites, %d randoms, and %d bans",[GIFLibrary favorites].count, [GIFLibrary randoms].count, [GIFLibrary blacklist].count);
    
    // Override point for customization after application launch.
    NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    
    if ( [url isFileURL] ) {
        NSLog(@"application launched with an opened file");
        
        UINavigationController *rootViewController = (UINavigationController *)self.window.rootViewController;
        
        if ( [rootViewController respondsToSelector:@selector(viewControllers)] &&
            [[[rootViewController viewControllers] firstObject] respondsToSelector:@selector(openURL:)] )
        {
            [(GIFMainPageViewController *)[[rootViewController viewControllers] firstObject] openURL:url];
        }
    }
    
    
    // appearance
    BOOL darkUI = NO; // set via NSUserDefaults?
    if ( darkUI )
    {
        [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
        [[UIToolbar appearance] setBarTintColor:[UIColor blackColor]];
        [[UISegmentedControl appearance] setTintColor:[UIColor lightGrayColor]];
        
        [self.window setTintColor:[UIColor whiteColor]];
    }
    
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"application openURL:%@ \n    sourceApplication:%@ \n    annotation:%@",url.absoluteString,sourceApplication,annotation);
    
    UINavigationController *rootViewController = (UINavigationController *)self.window.rootViewController;
    
    if ( [rootViewController respondsToSelector:@selector(viewControllers)] &&
        [[[rootViewController viewControllers] firstObject] respondsToSelector:@selector(openURL:)] )
    {
        [(GIFMainPageViewController *)[[rootViewController viewControllers] firstObject] openURL:url];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
