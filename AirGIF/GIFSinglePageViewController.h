//
//  GIFSinglePageViewController.h
//  AirGIF
//
//  Created by Ian on 10/7/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import <UIKit/UIKit.h>

// declare the class for use in the protocol method(s)
@class GIFSinglePageViewController;

// set up the delegate protocol
@protocol GIFSinglePageViewControllerDelegate <NSObject>

@optional
- (void)singlePageViewController:(GIFSinglePageViewController *)singlePageViewController encounteredErrorLoadingURL:(NSURL *)url;

@end

// and now on to the show...
@interface GIFSinglePageViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIProgressView *progressBar;
@property (nonatomic, weak) IBOutlet UIImageView *xImageView;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, weak) NSObject<GIFSinglePageViewControllerDelegate> *delegate;

@property (nonatomic, strong) NSURL *openedURL; // setting will load locally instantly, or remote async
@property (nonatomic, strong) NSData *gifData; // setting sets the image

@end
