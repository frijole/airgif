//
//  GIFMainCollectionViewController.h
//  AirGIF
//
//  Created by Ian Meyer on 10/4/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIFMainCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@interface GIFMainCollectionViewController : UICollectionViewController <UIPopoverControllerDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *customEditButton; // strong property to keep it around when not being displayed

// Don't want to throw a imageView into the views of a UICollectionViewController
// Should present the opened GIF in a modal anyway. Do that next.
// @property (nonatomic, weak) IBOutlet UIImageView *imageView; // for opened images only

@property (nonatomic, weak) IBOutlet UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, weak) IBOutlet UITapGestureRecognizer *doubleTapRecognizer;

- (void)openURL:(NSURL *)url;

- (IBAction)screenTapped:(id)sender;
- (IBAction)screenDoubleTapped:(id)sender;
- (IBAction)shareButtonTapped:(id)sender;
- (IBAction)deleteButtonTapped:(id)sender;

@end
