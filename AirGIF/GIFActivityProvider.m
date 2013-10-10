//
//  GIFActivityProvider.m
//  AirGIF
//
//  Created by Ian Meyer on 9/22/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import "GIFActivityProvider.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "UIImage+animatedGIF.h"


@interface GIFActivityProvider ()

@end


@implementation GIFActivityProvider

- (id)initWithURL:(NSURL *)url andData:(NSData *)data
{
    if ( self = [super init] ) {
        // so dataWithContentsOfURL runs in the background
        [self setData:data];
        [self setUrl:url];
    }
    
    return self;
}

- (void)setUrl:(NSURL *)url
{
    _url = url;

    if ( !_data )
        [self setData:[NSData dataWithContentsOfURL:url]];
}

- (void)setData:(NSData *)data
{
    _data = data;
    
    [self setImage:[UIImage animatedImageWithAnimatedGIFData:_data]];
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
    return @"Check out this GIF";
}

- (UIImage *)activityViewController:(UIActivityViewController *)activityViewController thumbnailImageForActivityType:(NSString *)activityType suggestedSize:(CGSize)size
{
    return self.image;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return self.image;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    if ( [activityType isEqualToString:UIActivityTypePostToTwitter] )
    {
        if ( [self.url isFileURL] )
        {   // local image.
            // TODO: upload to share?
            return [NSString stringWithFormat:@"%@ /via @AirGIF",self.url];
        }
        else
        {   // remote url, share it! (shorten it?)
            return [NSString stringWithFormat:@"%@ /via @AirGIF",self.url];
        }
    }
    
    // if ( [activityType isEqualToString:UIActivityTypeAirDrop] )
    //     return self.data;
    
    // if ( [activityType isEqualToString:UIActivityTypePostToFacebook] )
    //     return self.data;
    
    // if ( [activityType isEqualToString:UIActivityTypeMessage] )
    //     return self.data;
    
    // if ( [activityType isEqualToString:UIActivityTypeMail] )
    //     return self.data;

    return self.data;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController dataTypeIdentifierForActivityType:(NSString *)activityType
{
    id rtnValue = nil;
    
    /* if ( [activityType isEqualToString:UIActivityTypePostToTwitter] )
        rtnValue = nil;
    else */ if ( [activityType isEqualToString:UIActivityTypeAirDrop] )
        rtnValue = @"info.frijole.airgif";
    else
        rtnValue = @"com.compuserve.gif";
    
    NSLog(@"activityType: %@  dataTypeIdentifier: %@",activityType,rtnValue);
    
    return rtnValue;
}

@end