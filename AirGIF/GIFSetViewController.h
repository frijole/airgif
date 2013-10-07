//
//  GIFMainViewController.h
//  AirGIF
//
//  Created by Ian Meyer on 9/20/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

@interface GIFSetViewController : UIViewController <UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *customEditButton; // strong property to keep it around when not being displayed

@property (nonatomic, weak) IBOutlet UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, weak) IBOutlet UITapGestureRecognizer *doubleTapRecognizer;

- (void)openURL:(NSURL *)url;

- (IBAction)screenTapped:(id)sender;
- (IBAction)screenDoubleTapped:(id)sender;
- (IBAction)shareButtonTapped:(id)sender;
- (IBAction)deleteButtonTapped:(id)sender;

@end
