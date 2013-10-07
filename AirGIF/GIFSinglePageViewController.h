//
//  GIFSinglePageViewController.h
//  AirGIF
//
//  Created by Ian on 10/7/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIFSinglePageViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) NSURL *openedURL; // TODO: move image setup to this setter

@end
