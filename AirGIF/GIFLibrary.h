//
//  GIFLibrary.h
//  AirGIF
//
//  Created by Ian on 9/30/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GIFLibrary : NSObject

+ (NSArray *)favorites;
+ (NSArray *)randoms;

// loads some random gif urls from picbot
+ (BOOL)fetchRandoms:(NSInteger)quantity;

// adds image at address to favorites.
// if a remote url, downloads and adds local url to favorites
+ (BOOL)addToFavorites:(NSURL *)url;

// removes from favorites and random and adds to blacklist
+ (BOOL)deleteGif:(NSURL *)url;

// report problem to picbot (send 404 command)
+ (BOOL)reportProblem:(NSURL *)url;

@end
