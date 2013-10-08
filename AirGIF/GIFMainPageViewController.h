//
//  GIFMainPageViewController.h
//  AirGIF
//
//  Created by Ian on 10/7/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIFMainPageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIBarButtonItem *currentPageItem; // x of y

@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl; // favorites vs random

@property (nonatomic, weak) IBOutlet UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, weak) IBOutlet UITapGestureRecognizer *doubleTapRecognizer;
@property (nonatomic, weak) IBOutlet UILongPressGestureRecognizer *longPressRecognizer;

- (void)openURL:(NSURL *)url;

- (IBAction)screenTapped:(id)sender;
- (IBAction)screenDoubleTapped:(id)sender;
- (IBAction)shareButtonTapped:(id)sender;
- (IBAction)deleteButtonTapped:(id)sender;
- (IBAction)longPressTriggered:(id)sender;

@end
