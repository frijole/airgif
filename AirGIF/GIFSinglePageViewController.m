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

        // take care of any spinner or progress bar or x
        self.progressBar.hidden = YES;
        self.spinner.hidden = YES;
        self.xImageView.hidden = YES;
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

        // prep the progress bar
        [self.progressBar setHidden:NO];
        [self.progressBar setProgress:0.0f animated:NO];
        [self.spinner stopAnimating];
        [self.spinner setHidden:YES];
        [self.xImageView setHidden:YES];
        
        // create an AFHTTPRequestOperation to download the gif data
        AFHTTPRequestOperation *tmpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:openedURL]];
        [tmpOperation.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"image/gif", nil]];
        [tmpOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            // got it!
            // NSLog(@"got remote image object: %@",responseObject);
            
            self.progressBar.hidden = YES;
            self.spinner.hidden = NO;
            [self.spinner startAnimating];
            
            [self setGifData:responseObject];
        }
                                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                NSLog(@"failed to load remote image, error: %@",error);
                                                
                                                self.progressBar.hidden = YES;
                                                self.spinner.hidden = YES;
                                                self.xImageView.hidden = NO;

                                                // TODO: real error handling
                                                // self.imageView.backgroundColor = [UIColor orangeColor];
                                            }];
        
        [tmpOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            CGFloat tmpProgress = totalBytesRead/totalBytesExpectedToRead;
            [self.progressBar setProgress:tmpProgress animated:YES];
        }];

        // and download it
        [tmpOperation start];
    }
    
}

- (void)setGifData:(NSData *)gifData
{
    _gifData = gifData;
    
    UIImage *tmpImage = [UIImage animatedImageWithAnimatedGIFData:gifData];
    if ( tmpImage && tmpImage.images.count > 1 )
    {
        [self.spinner stopAnimating];
        [self.spinner setHidden:YES];
        
        [self.imageView setImage:tmpImage];
        [self.imageView setClipsToBounds:YES];

        [self.spinner stopAnimating];
    }
    else
    {
        [self.spinner stopAnimating];
        [self.spinner setHidden:YES];

        // TODO: real error handling
        [self.xImageView setHidden:NO];
        self.imageView.backgroundColor = [UIColor colorWithRed:0.2f green:0.0f blue:0.0f alpha:1.0f];
    }
}

@end
