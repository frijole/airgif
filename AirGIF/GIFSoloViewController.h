//
//  GIFSoloViewController.h
//  AirGIF
//
//  Created by Ian Meyer on 10/6/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIFSoloViewController : UINavigationController

- (void)openURL:(NSURL *)url; // pass through to root view controller to open (?)

@end


@interface GIFSoloRootViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, weak) IBOutlet UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, weak) IBOutlet UITapGestureRecognizer *doubleTapRecognizer;

- (void)openURL:(NSURL *)url;

- (IBAction)discardButtonTapped:(id)sender;
- (IBAction)addToFavoritesButtonTapped:(id)sender;
- (IBAction)shareButtonTapped:(id)sender;

@end