//
//  GIFMainPageViewController.m
//  AirGIF
//
//  Created by Ian on 10/7/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import "GIFMainPageViewController.h"

#import "GIFSinglePageViewController.h"

@interface GIFMainPageViewController ()

@end

@implementation GIFMainPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self setDataSource:self];
    [self setDelegate:self];
    
    // set initial view controller
    UIStoryboard *tmpStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    GIFSinglePageViewController *tmpFirstSinglePageVC = [tmpStoryboard instantiateViewControllerWithIdentifier:@"GIFSinglePageViewController"];
    [tmpFirstSinglePageVC.view setBackgroundColor:[UIColor blueColor]];
    
    [self setViewControllers:@[tmpFirstSinglePageVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    UIViewController *rtnVC =nil;
    
    UIStoryboard *tmpStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    rtnVC = [tmpStoryboard instantiateViewControllerWithIdentifier:@"GIFSinglePageViewController"];
    
    [rtnVC.view setBackgroundColor:[UIColor redColor]];
    
    return rtnVC;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    UIViewController *rtnVC =nil;
    
    UIStoryboard *tmpStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    rtnVC = [tmpStoryboard instantiateViewControllerWithIdentifier:@"GIFSinglePageViewController"];
    
    [rtnVC.view setBackgroundColor:[UIColor orangeColor]];
    
    return rtnVC;
}

@end
