//
//  GIFMainViewController.h
//  AirGIF
//
//  Created by Ian Meyer on 9/20/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import "GIFFlipsideViewController.h"

@interface GIFMainViewController : UICollectionViewController <GIFFlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, weak) IBOutlet UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, weak) IBOutlet UITapGestureRecognizer *doubleTapRecognizer;

- (void)openURL:(NSURL *)url;

- (IBAction)screenTapped:(id)sender;
- (IBAction)screenDoubleTapped:(id)sender;
- (IBAction)shareButtonTapped:(id)sender;
- (IBAction)deleteButtonTapped:(id)sender;

@end
