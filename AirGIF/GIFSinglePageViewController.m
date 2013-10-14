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
        [self setGifData:[NSData dataWithContentsOfURL:openedURL]];
        [self.imageView setImage:[UIImage animatedImageWithAnimatedGIFData:self.gifData]];
        [self.imageView setClipsToBounds:YES];

        // and stop the spinner
        [self.spinner stopAnimating];
    }
    else
    {
        // if we have an existing one, cancel it and let it go
        if ( self.operation ) {
            [self.operation cancel];
            [self setOperation:nil];
        }
        
        // clear image and set default background (in case it was changed due to error, via code below)
        self.imageView.image = nil;
        self.imageView.backgroundColor = [UIColor clearColor];

        // and start the spinner
        [self.spinner startAnimating];
        
        // create an AFHTTPRequestOperation to download the gif data
        AFHTTPRequestOperation *tmpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:openedURL]];
        [tmpOperation.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"image/gif", nil]];
        [tmpOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            // got it!
            // NSLog(@"got remote image object: %@",responseObject);
            
            [self setGifData:responseObject];
        }
                                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                NSLog(@"failed to load remote image, error: %@",error);
                                                self.imageView.backgroundColor = [UIColor orangeColor];
                                                // TODO: real error handling
                                            }];
        // and download it
        [tmpOperation start];
    }
    
}

- (void)setGifData:(NSData *)gifData
{
    _gifData = gifData;
    
    UIImage *tmpImage = [UIImage animatedImageWithAnimatedGIFData:gifData];
    if ( tmpImage )
    {
        [self.imageView setImage:tmpImage];
        [self.imageView setClipsToBounds:YES];

        [self.spinner stopAnimating];
    }
    else
        self.imageView.backgroundColor = [UIColor redColor];
    
    // TODO: real error handling
}

@end
