//
//  GIFMainPageViewController.h
//  AirGIF
//
//  Created by Ian on 10/7/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIFMainPageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *customEditButton; // strong property to keep it around when not being displayed

@property (nonatomic, weak) IBOutlet UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, weak) IBOutlet UITapGestureRecognizer *doubleTapRecognizer;

- (void)openURL:(NSURL *)url;

- (IBAction)screenTapped:(id)sender;
- (IBAction)screenDoubleTapped:(id)sender;
- (IBAction)shareButtonTapped:(id)sender;
- (IBAction)deleteButtonTapped:(id)sender;

@end
