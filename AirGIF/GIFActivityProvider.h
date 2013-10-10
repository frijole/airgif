//
//  GIFActivityProvider.h
//  AirGIF
//
//  Created by Ian Meyer on 9/22/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIFActivityProvider : UIActivityItemProvider <UIActivityItemSource>

// use this
@property (nonatomic, strong) NSURL *url; // setting will load data if not present

// not these
@property (nonatomic, strong) NSData *data; // cached gif data
@property (nonatomic, strong) UIImage *image; // cached static image for thumbnails/previews

// new!
- (instancetype)initWithURL:(NSURL *)url andData:(NSData *)data;

@end