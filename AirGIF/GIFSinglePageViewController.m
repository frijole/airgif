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

        // take care of any progress bar or x
        self.progressBar.hidden = YES;
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
        [self.progressBar setProgress:0.0f animated:NO];
        [self.progressBar setHidden:NO];
        [self.xImageView setHidden:YES];
        
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
                                                
                                                self.progressBar.hidden = YES;
                                                self.xImageView.hidden = NO;
                                                
                                                if ( self.delegate && [self.delegate respondsToSelector:@selector(singlePageViewController:encounteredErrorLoadingURL:)] ) {
                                                    // notify delegate of failure
                                                    [self.delegate singlePageViewController:self
                                                                 encounteredErrorLoadingURL:openedURL];
                                                }

                                                self.imageView.backgroundColor = [UIColor colorWithRed:0.2f green:0.0f blue:0.0f alpha:1.0f];
                                                
                                                // NSLog(@"download failed");
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
        [self.progressBar setHidden:YES];
        [self.xImageView setHidden:YES];

        [self.imageView setImage:tmpImage];
        [self.imageView setBackgroundColor:[UIColor clearColor]];
        [self.imageView setClipsToBounds:YES];
    }
    else
    {
        [self.progressBar setHidden:YES];
        [self.xImageView setHidden:NO];
        
        // NSLog(@"failed to load animation, or gif had only one frame");

        if ( self.delegate && [self.delegate respondsToSelector:@selector(singlePageViewController:encounteredErrorLoadingURL:)] ) {
            // notify delegate of failure
            [self.delegate singlePageViewController:self
                         encounteredErrorLoadingURL:self.openedURL];
        }

        self.imageView.backgroundColor = [UIColor colorWithRed:0.2f green:0.0f blue:0.0f alpha:1.0f];
    }
}

@end
