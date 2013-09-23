//
//  GIFActivityProvider.m
//  AirGIF
//
//  Created by Ian Meyer on 9/22/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import "GIFActivityProvider.h"

#import <MobileCoreServices/MobileCoreServices.h>

@implementation GIFActivityProvider

- (id)initWithData:(NSData *)data
{
    if ( self = [super init] ) {
        [self setData:data];
    }

    return self;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    if ( [activityType isEqualToString:UIActivityTypePostToTwitter] )
        return @"$URL from @gifbookapp";
    
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
    if ( [activityType isEqualToString:UIActivityTypePostToTwitter] )
        return nil;

    if ( [activityType isEqualToString:UIActivityTypeAirDrop] )
        return @"info.frijole.airgif";
    
    // return @"info.frijole.airgif";
    return @"com.compuserve.gif";
}

- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return @"";
}

@end