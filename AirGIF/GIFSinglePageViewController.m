//
//  GIFSinglePageViewController.m
//  AirGIF
//
//  Created by Ian on 10/7/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import "GIFSinglePageViewController.h"

#import "UIImage+animatedGIF.h"
#import "UIImageView+AFNetworking.h"


@interface GIFSinglePageViewController ()

@property (nonatomic, weak) AFHTTPRequestOperation *operation;

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
        // if we have an existing one, cancel it and let it go
        if ( self.operation ) {
            [self.operation cancel];
            [self setOperation:nil];
        }
        
        // default black background (in case it was changed due to error, via code below)
        self.imageView.backgroundColor = [UIColor blackColor];
        
        // create an AFHTTPRequestOperation to download the gif data
        AFHTTPRequestOperation *tmpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:openedURL]];
        [tmpOperation.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"image/gif", nil]];
        [tmpOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            // got it!
            // NSLog(@"got remote image object: %@",responseObject);

            UIImage *tmpImage = [UIImage animatedImageWithAnimatedGIFData:responseObject];
            if ( tmpImage )
                self.imageView.image = tmpImage;
            else
                self.imageView.backgroundColor = [UIColor redColor]; // TODO: real error handling
        }
                                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                NSLog(@"failed to load remote image, error: %@",error);
                                                self.imageView.backgroundColor = [UIColor redColor]; // TODO: real error handling
                                            }];
        // and download it
        [tmpOperation start];
    }
    
}

@end
