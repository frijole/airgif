//
//  GIFLibrary.h
//  AirGIF
//
//  Created by Ian on 9/30/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import <Foundation/Foundation.h>


// Set up some NSUserDefault keys
#define kGIFLibraryUserDefaultsKeyResetURLs             @"resetURLs"

#define kGIFLibraryUserDefaultsKeyCurrentLibraryIndex   @"libraryIndex" // 0 for favorites, 1 for random.

#define kGIFLibraryUserDefaultsKeyFavoriteIndex         @"favoriteIndex"
#define kGIFLibraryUserDefaultsKeyRandomIndex           @"randomIndex"

// use these to display coaching alerts on first run
#define kGIFLibraryUserDefaultsMigratedData             @"migratedData" // upgrade from GIFBOOK
#define kGIFLibraryUserDefaultsInitialSetupDone         @"setupDone"    // new user

@interface GIFLibrary : NSObject

+ (NSArray *)favorites;
+ (NSArray *)randoms;
+ (NSArray *)blacklist; // deleted URLs

// loads some random gif urls from picbot
+ (void)fetchRandoms:(NSInteger)quantity;

// adds image at address to favorites.
// if a remote url, downloads and adds local url to favorites
+ (void)addToFavorites:(NSURL *)url;
+ (void)addToFavorites:(NSURL *)url withCompletionBlock:(void (^)(BOOL success, NSURL *newFavoriteURL))completionBlock;

// rename a favorite
+ (void)renameFavorite:(NSURL *)favoriteURL toFilename:(NSString *)newFileName withCompletionBlock:(void (^)(BOOL success, NSURL *newFavoriteURL))completionBlock;

// removes from favorites and random and adds to blacklist
+ (void)deleteGif:(NSURL *)url;

// report problem to picbot (send 404 command)
+ (void)reportProblem:(NSURL *)url;

// force writing to disk
+ (void)saveData;

@end
