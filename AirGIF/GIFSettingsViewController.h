//
//  GIFFlipsideViewController.h
//  AirGIF
//
//  Created by Ian Meyer on 9/20/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GIFSettingsViewController;

@protocol GIFSettingsViewControllerDelegate
- (void)settingsViewControllerDidFinish:(GIFSettingsViewController *)controller;
@end

@interface GIFSettingsViewController : UIViewController

@property (weak, nonatomic) id <GIFSettingsViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
