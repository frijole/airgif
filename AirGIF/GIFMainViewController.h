//
//  GIFMainViewController.h
//  AirGIF
//
//  Created by Ian Meyer on 9/20/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import "GIFFlipsideViewController.h"

@interface GIFMainViewController : UIViewController <GIFFlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

- (void)openURL:(NSURL *)url;

- (IBAction)screenTapped:(id)sender;
- (IBAction)shareButtonTapped:(id)sender;
- (IBAction)deleteButtonTapped:(id)sender;

@end
