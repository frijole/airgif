//
//  GIFActivityProvider.h
//  AirGIF
//
//  Created by Ian Meyer on 9/22/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIFActivityProvider : UIActivityItemProvider <UIActivityItemSource>

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) UIImage *image;

- (id)initWithData:(NSData *)data;

@end