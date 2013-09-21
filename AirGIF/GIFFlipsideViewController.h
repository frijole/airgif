//
//  GIFFlipsideViewController.h
//  AirGIF
//
//  Created by Ian Meyer on 9/20/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GIFFlipsideViewController;

@protocol GIFFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(GIFFlipsideViewController *)controller;
@end

@interface GIFFlipsideViewController : UIViewController

@property (weak, nonatomic) id <GIFFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
