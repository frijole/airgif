//
//  GIFLibrary.m
//  AirGIF
//
//  Created by Ian on 9/30/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import "GIFLibrary.h"

#define kGIFLibraryRandomFileName   @"randoms"
#define kGIFLibraryFavoriteFileName @"favorites"
#define kGIFLibraryBanFileName      @"bans"

// for keepsies
static NSMutableArray *_favorites = nil;

// from picbot
static NSMutableArray *_randoms = nil;
static NSMutableArray *_blacklist = nil;

// prevent multiple requests
static BOOL _fetching = NO;


@implementation GIFLibrary

+ (NSMutableArray *)favorites
{
    
    if ( !_favorites ) {
        // load from disk
        
        NSArray *cacheDirectories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *tmpAddressFilePath = [NSString stringWithFormat:@"%@/%@",[cacheDirectories objectAtIndex:0],kGIFLibraryFavoriteFileName];
        NSArray *tmpFavoritesFromDisk = [NSKeyedUnarchiver unarchiveObjectWithFile:tmpAddressFilePath];
        if ( tmpFavoritesFromDisk && tmpFavoritesFromDisk.count > 0 )
            _favorites = [NSMutableArray arrayWithArray:tmpFavoritesFromDisk];
    }
    
    if ( !_favorites || _favorites.count == 0 ) {
        // loading failed
        _favorites = [NSMutableArray array];
        
        NSArray *tmpDefaults = [NSArray arrayWithObjects:
                                [[NSBundle mainBundle] URLForResource:@"senna prost" withExtension:@"gif"],
                                [[NSBundle mainBundle] URLForResource:@"rally" withExtension:@"gif"],
                                [[NSBundle mainBundle] URLForResource:@"gilles" withExtension:@"gif"],
                                nil];
        
        _favorites = [NSMutableArray arrayWithArray:tmpDefaults];
    }
    
    return _favorites;
}

+ (NSMutableArray *)randoms
{
    
    if ( !_randoms ) {
        
        if ( [[NSUserDefaults standardUserDefaults] boolForKey:kGIFLibraryUserDefaultsKeyResetURLs] ) {
            
            // reset the reset preference
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGIFLibraryUserDefaultsKeyResetURLs];
            [[NSUserDefaults standardUserDefaults] synchronize];

            // and skip loading from disk
        
            // in fact, nuke the disk.
            // TODO: move `resetLibrary` to standalone method
            NSArray *cacheDirectories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *tmpAddressFilePath = [NSString stringWithFormat:@"%@/%@",[cacheDirectories objectAtIndex:0],kGIFLibraryRandomFileName];
            NSError *tmpError;
            [[NSFileManager defaultManager] removeItemAtPath:tmpAddressFilePath error:&tmpError];
            if ( tmpError )
                NSLog(@"failed to remove random url cache: %@",tmpError);
            else
                NSLog(@"removed random url cache");
            
        }
        else
        {
            // load from disk
            NSArray *cacheDirectories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *tmpAddressFilePath = [NSString stringWithFormat:@"%@/%@",[cacheDirectories objectAtIndex:0],kGIFLibraryRandomFileName];
            NSArray *tmpRandomsFromDisk = [NSKeyedUnarchiver unarchiveObjectWithFile:tmpAddressFilePath];
            if ( tmpRandomsFromDisk && tmpRandomsFromDisk.count > 0 )
                _randoms = [NSMutableArray arrayWithArray:tmpRandomsFromDisk];

        }
    
    }
    
    // if we failed to load, or loaded none...
    if ( !_randoms || _randoms.count == 0 ) {
        // loading failed
        _randoms = [NSMutableArray array];

        NSArray *tmpDefaults = [NSArray arrayWithObjects:
                                [NSURL URLWithString:@"http://25.media.tumblr.com/0a9f27187f486be9d24a4760b89ac03a/tumblr_mgn52pl4hI1qg39ewo1_500.gif"],
                                [NSURL URLWithString:@"http://25.media.tumblr.com/4d6bfe7484da35cf9dd235d60109fe47/tumblr_mg6ld5tbaG1qehntzo1_500.gif"],
                                [NSURL URLWithString:@"http://24.media.tumblr.com/tumblr_m7dbzmGd4n1qzqdulo1_500.gif"],
                                [NSURL URLWithString:@"http://24.media.tumblr.com/1e56a4ab8fda12c8e396fe02a850939a/tumblr_mg9x5pQUlH1qd4q8ao1_500.gif"],
                                [NSURL URLWithString:@"http://thismight.be/offensive/uploads/2011/05/27/image/315413_%5Btmbar%5D%20volvo%2C%20literally.gif"],
                                [NSURL URLWithString:@"http://i.imgur.com/xajwt.gif"],
                                nil];
        
        _randoms = [NSMutableArray arrayWithArray:tmpDefaults];
        
        // and get some more
        [[self class] fetchRandoms:10];
    }
    
    return _randoms;
}

+ (NSMutableArray *)blacklist
{
    
    if ( !_blacklist ) {
        // load from disk
        NSArray *cacheDirectories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *tmpAddressFilePath = [NSString stringWithFormat:@"%@/%@",[cacheDirectories objectAtIndex:0],kGIFLibraryRandomFileName];
        NSArray *tmpRandomsFromDisk = [NSKeyedUnarchiver unarchiveObjectWithFile:tmpAddressFilePath];
        if ( tmpRandomsFromDisk && tmpRandomsFromDisk.count > 0 )
            _blacklist = [NSMutableArray arrayWithArray:tmpRandomsFromDisk];
    }
    
    if ( !_blacklist ) {
        _blacklist = [NSMutableArray array];
    }

    return _blacklist;
}


// loads some random gif urls from picbot
+ (void)fetchRandoms:(NSInteger)quantity
{
    // do it!
    if ( !_fetching )
    {
        _fetching = YES;
        
        NSString *tmpURLString = [NSString stringWithFormat:@"http://iank.org/picbot/pic?n=%ld&type=gif",(long)quantity];

        NSURL *URL = [NSURL URLWithString:tmpURLString];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                             initWithRequest:request];
        
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             // NSLog(@"%@", responseObject);
             // parse 'em
             for ( NSString *tmpGIFAddress in [responseObject valueForKey:@"pics"] ) {
                 if ( [self randoms] ) // sets up if necessary
                 {
                     // do we want to add the new url?
                     BOOL shouldAdd = YES;
                     
                     // check for collisions
                     for ( NSURL *tmpRandom in [self randoms] ) {
                         if ( [tmpRandom.absoluteString isEqualToString:tmpGIFAddress] ) {
                             NSLog(@"fetched URL is already in library, skipping: %@", tmpGIFAddress);
                             shouldAdd = NO;
                         }
                     }
                     
                     if ( shouldAdd ) {
                         [_randoms addObject:[NSURL URLWithString:tmpGIFAddress]];
                     }
                 }
             }
             
             // save changes
             [self saveData];
             
             NSLog(@"added gifs, new total: %lu",(unsigned long)_randoms.count);
             
             _fetching = NO;
         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"failed to download new url");

             _fetching = NO;
         }];
        
        [operation start];

    }

}



// adds image at address to favorites.
// if a remote url, download to Documents and add local url to favorites
+ (BOOL)addToFavorites:(NSURL *)url
{
    [[self class] addToFavorites:url withCompletionBlock:nil];
    
    NSLog(@"addToFavorites called, returning YES immediately. running withCompletionBlock in background.");
    
    return YES;
}

+ (void)addToFavorites:(NSURL *)url withCompletionBlock:(void (^)(BOOL success, NSURL *newFavoriteURL))inCompletionBlock
{
    // do it!
    
    // make sure we have a place to put the new favorite...
    if ( !_favorites ) {
        // loading failed, set it up
        _favorites = [NSMutableArray array];
    }

    // TODO: add downloading/copying/etc
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:url.lastPathComponent];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded file to %@", path);

        NSURL *tmpNewFavoriteURL = [[NSURL alloc] initFileURLWithPath:path];
        
        // add the new favorite
        [_favorites addObject:tmpNewFavoriteURL];
        
        // save changes
        [self saveData];
        
        if ( inCompletionBlock )
            inCompletionBlock(YES,tmpNewFavoriteURL);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);

        if ( inCompletionBlock )
            inCompletionBlock(NO,nil);
    }];
    
    [operation start];
}



// removes from favorites and random and adds to blacklist
+ (BOOL)deleteGif:(NSURL *)url
{
    BOOL rtnStatus = NO;
    
    NSURL *tmpURLtoDelete = nil;
    
    // check favorites and randoms for the url
    for ( NSMutableArray *tmpArray in @[[[self class] favorites], [[self class] randoms]] ) {
        // check for the url
        for ( NSURL *tmpURL in tmpArray ) {
            if ( [tmpURL isEqual:url] )
                tmpURLtoDelete = tmpURL;
        }
        
        // if we found it, remove it
        if ( tmpURLtoDelete )
            [tmpArray removeObject:tmpURLtoDelete];
    }


    // add it to the blacklist
    [(NSMutableArray *)[[self class] blacklist] addObject:url];
    
    // save changes
    [self saveData];
    
    
    return rtnStatus;
}



// report problem to picbot (send 404 command)
+ (BOOL)reportProblem:(NSURL *)url
{
    BOOL rtnStatus = NO;
    
    // delete it
    [self deleteGif:url];
    
    // TODO: hit picbot's 404
    
    // save changes
    [self saveData];
    
    return rtnStatus;
}


// write to disk
+ (void)saveData
{
    // save updated list
    // save the update
    NSArray *cacheDirectories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *tmpAddressFilePath = [NSString stringWithFormat:@"%@/%@",[cacheDirectories objectAtIndex:0],kGIFLibraryFavoriteFileName];
    if ( [NSKeyedArchiver archiveRootObject:[[self class] favorites] toFile:tmpAddressFilePath] ) {
        // NSLog(@"saved updated list");
    } else {
        NSLog(@"error saving favorites");
    }
    
    NSString *tmpRandomsFilePath = [NSString stringWithFormat:@"%@/%@",[cacheDirectories objectAtIndex:0],kGIFLibraryRandomFileName];
    if ( [NSKeyedArchiver archiveRootObject:[[self class] randoms] toFile:tmpRandomsFilePath] ) {
        // NSLog(@"saved updated list");
    } else {
        NSLog(@"error saving randoms");
    }
    
    NSString *tmpBlacklistFilePath = [NSString stringWithFormat:@"%@/%@",[cacheDirectories objectAtIndex:0],kGIFLibraryBanFileName];
    if ( [NSKeyedArchiver archiveRootObject:[[self class] blacklist] toFile:tmpBlacklistFilePath] ) {
        // NSLog(@"saved updated ban list");
    } else {
        NSLog(@"error saving blacklist");
    }
    
}


@end
