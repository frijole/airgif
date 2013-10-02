//
//  GIFLibrary.m
//  AirGIF
//
//  Created by Ian on 9/30/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import "GIFLibrary.h"

@implementation GIFLibrary

+ (NSArray *)favorites {
    NSArray *rtnArray;
    
    // wat?
    
    return rtnArray;
}

+ (NSArray *)random {
    NSArray *rtnArray;
    
    // wat?
    
    return rtnArray;
}



// loads some random gif urls from picbot
+ (BOOL)fetchRandom:(NSInteger)quantity {
    BOOL rtnStatus = NO;
    
    // do it!
    
    return rtnStatus;
}



// adds image at address to favorites.
// if a remote url, downloads and adds local url to favorites
+ (BOOL)addToFavorites:(NSURL *)url {
    BOOL rtnStatus = NO;
    
    // do it!
    
    return rtnStatus;
}



// removes from favorites and random and adds to blacklist
+ (BOOL)deleteGif:(NSURL *)url {
    BOOL rtnStatus = NO;
    
    // do it!
    
    return rtnStatus;
}



// report problem to picbot (send 404 command)
+ (BOOL)reportProblem:(NSURL *)url {
    BOOL rtnStatus = NO;
    
    // do it!
    
    return rtnStatus;
}



@end
