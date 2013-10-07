//
//  GIFSinglePageViewController.m
//  AirGIF
//
//  Created by Ian on 10/7/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import "GIFSinglePageViewController.h"

#import "UIImage+animatedGIF.h"

@interface GIFSinglePageViewController ()

@end

@implementation GIFSinglePageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setOpenedURL:(NSURL *)openedURL
{
    _openedURL = openedURL;
    
    if ( [openedURL isFileURL] )
    {   // file url, open directly
        [self.imageView setImage:[UIImage animatedImageWithAnimatedGIFURL:openedURL]];
    }
    else
    {
        [self.imageView setImage:[UIImage animatedImageWithAnimatedGIFURL:openedURL]]; // TODO: load remote images async
    }
    
}

@end
