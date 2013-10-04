//
//  GIFLibrary.m
//  AirGIF
//
//  Created by Ian on 9/30/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import "GIFLibrary.h"

static NSMutableArray *_randoms = nil;
static NSMutableArray *_favorites = nil;

@implementation GIFLibrary

+ (NSArray *)favorites {
    
    if ( !_favorites ) {
        // load from disk
        NSArray *cacheDirectories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *tmpAddressFilePath = [NSString stringWithFormat:@"%@/%@",[cacheDirectories objectAtIndex:0],@"favorites"];
        NSArray *tmpFavoritesFromDisk = [NSKeyedUnarchiver unarchiveObjectWithFile:tmpAddressFilePath];
        _favorites = [NSMutableArray arrayWithArray:tmpFavoritesFromDisk];
    }
    
    if ( !_favorites ) {
        // loading failed
        _favorites = [NSMutableArray array];
    }
    
    return _favorites;
}

+ (NSArray *)randoms {
    
    if ( !_randoms ) {
        // load from disk
        NSArray *cacheDirectories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *tmpAddressFilePath = [NSString stringWithFormat:@"%@/%@",[cacheDirectories objectAtIndex:0],@"randoms"];
        NSArray *tmpRandomsFromDisk = [NSKeyedUnarchiver unarchiveObjectWithFile:tmpAddressFilePath];
        _randoms = [NSMutableArray arrayWithArray:tmpRandomsFromDisk];
    }
    
    if ( !_randoms ) {
        // loading failed
        _randoms = [NSMutableArray array];

        NSArray *tmpDefaults = [NSArray arrayWithObjects:@"http://25.media.tumblr.com/0a9f27187f486be9d24a4760b89ac03a/tumblr_mgn52pl4hI1qg39ewo1_500.gif",
                                @"http://25.media.tumblr.com/4d6bfe7484da35cf9dd235d60109fe47/tumblr_mg6ld5tbaG1qehntzo1_500.gif",
                                @"http://24.media.tumblr.com/tumblr_m7dbzmGd4n1qzqdulo1_500.gif",
                                @"http://24.media.tumblr.com/1e56a4ab8fda12c8e396fe02a850939a/tumblr_mg9x5pQUlH1qd4q8ao1_500.gif",
                                @"http://thismight.be/offensive/uploads/2011/05/27/image/315413_%5Btmbar%5D%20volvo%2C%20literally.gif",
                                @"http://i.imgur.com/xajwt.gif",
                                nil];
        
        for ( NSString *tmpGIF in tmpDefaults )
            [_randoms addObject:[NSURL URLWithString:tmpGIF]];

    }
    
    return _randoms;}



// loads some random gif urls from picbot
+ (BOOL)fetchRandoms:(NSInteger)quantity {
    BOOL rtnStatus = NO;
    
    // do it!
    
    return rtnStatus;
}



// adds image at address to favorites.
// if a remote url, download to Documents and add local url to favorites
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
