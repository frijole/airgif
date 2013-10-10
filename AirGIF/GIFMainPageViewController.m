//
//  GIFMainPageViewController.m
//  AirGIF
//
//  Created by Ian on 10/7/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import "GIFMainPageViewController.h"

#import "GIFSinglePageViewController.h"
#import "GIFOpenedFileViewController.h"

#import "GIFLibrary.h"
#import "GIFActivityProvider.h"

#import "UIImage+animatedGIF.h"
#import "MMActionSheet.h"
#import "MMAlertView.h"

#define kGIFPageViewControllerAnimationDuration 0.5f

#define kGIFPageViewControllerKBaseAirDropAddress @"http://support.apple.com/kb/HT5887"
#define kGIFPageViewControllerKBaseSharingAddress @"http://support.apple.com/kb/HT5887"

typedef NS_ENUM(NSInteger, GIFLibrarySegmentedControlSelectedIndex) {
    GIFLibrarySegmentedControlSelectedIndexFavorites = 0,
    GIFLibrarySegmentedControlSelectedIndexRandom
};

typedef NS_ENUM(NSInteger, GIFLibraryScrollingDirection) {
	GIFLibraryScrollingDirectionLeft = -1,
	GIFLibraryScrollingDirectionNone = 0,
	GIFLibraryScrollingDirectionRight = 1,
};

// comment out for normal behavior
// #define TEST_OPEN_URL YES


@interface GIFMainPageViewController ()

@property (nonatomic) BOOL statusbarHidden;
@property (nonatomic, strong) NSURL *openedURL;
@property (nonatomic) BOOL scaleImages; // default YES, UIViewContentModeScaleAspectFill. NO results in UIViewContentModeScaleAspectFit.

@property (nonatomic, weak) NSArray *library;

@property (nonatomic) GIFLibraryScrollingDirection scrollDirection;

@end

@implementation GIFMainPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setDataSource:self];
    [self setDelegate:self];
    
    // set default to scale images to fill
    [self setScaleImages:YES];
    
    // set initial view controller
    [self setupCurrentPageFromPrefsAnimated:NO];
    
    [self.tapRecognizer requireGestureRecognizerToFail:self.doubleTapRecognizer];
    
    [self.view setGestureRecognizers:@[self.tapRecognizer, self.doubleTapRecognizer, self.longPressRecognizer]];
    
    // monitor scrolling direction to verify correct images displayed
    // UIPageViewController's _UIPageViewControllerContentView responds to "scrollView"
    // via https://github.com/nst/iOS-Runtime-Headers/blob/master/Frameworks/UIKit.framework/_UIPageViewControllerContentView.h
    // UIWebView does too, so casting that type to suppress warning
    if ( [self.view respondsToSelector:@selector(scrollView)] )
        [[(UIWebView *)self.view scrollView] addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

#ifdef TEST_OPEN_URL
- (void)viewDidAppear:(BOOL)animated
{
    [self performSelector:@selector(openURL:)
               withObject:[NSURL URLWithString:@"http://31.media.tumblr.com/17304b5d47e174685c62f61c9d2ffce3/tumblr_mriia3bgMp1r2vcn2o1_500.gif"]
               afterDelay:1.0f];
}
#endif

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBars) object:nil];
}


#pragma mark - Page View Controller
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    UIViewController *rtnVC =nil;
    
    NSURL *tmpCurrentURL = [self.viewControllers.firstObject openedURL];
    
    NSInteger tmpIndex = [self.library indexOfObject:tmpCurrentURL];
    
    if ( tmpIndex > 0 ) // if there is another image before the current one...
    {
        NSURL *tmpPrevURL = [self.library objectAtIndex:tmpIndex-1];
        
        UIStoryboard *tmpStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
        rtnVC = [tmpStoryboard instantiateViewControllerWithIdentifier:@"GIFSinglePageViewController"];
        [rtnVC loadView];
        
        if ( [rtnVC respondsToSelector:@selector(imageView)] ) {
            GIFSinglePageViewController *tmpPrevPage = (GIFSinglePageViewController *)rtnVC;
            [tmpPrevPage.imageView setContentMode:(self.scaleImages?UIViewContentModeScaleAspectFill:UIViewContentModeScaleAspectFit)];
            [tmpPrevPage.imageView setClipsToBounds:YES]; // TODO: move to a more robust place
            [tmpPrevPage setOpenedURL:tmpPrevURL];
        }
        
    }
    
    return rtnVC;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    UIViewController *rtnVC =nil;
    
    NSURL *tmpCurrentURL = [self.viewControllers.firstObject openedURL];
    
    NSInteger tmpIndex = [self.library indexOfObject:tmpCurrentURL];
    
    if ( tmpIndex < self.library.count-1 ) // if there is another image after the current one...
    {
        NSURL *tmpNextURL = [self.library objectAtIndex:tmpIndex+1];
        
        UIStoryboard *tmpStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
        rtnVC = [tmpStoryboard instantiateViewControllerWithIdentifier:@"GIFSinglePageViewController"];
        [rtnVC loadView];
        
        if ( [rtnVC respondsToSelector:@selector(imageView)] ) {
            GIFSinglePageViewController *tmpNextPage = (GIFSinglePageViewController *)rtnVC;
            [tmpNextPage.imageView setContentMode:(self.scaleImages?UIViewContentModeScaleAspectFill:UIViewContentModeScaleAspectFit)];
            [tmpNextPage.imageView setClipsToBounds:YES]; // TODO: move to a more robust place
            [tmpNextPage setOpenedURL:tmpNextURL];
        }
        
    }
    
    return rtnVC;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    // make sure pendingViewController.firstObject (should only be one) is properly configured.
    // it may have been cached with an image from a different source (favorites vs randoms).
    // not sure how to tell which direction we're scrolling to verify the pendingViewController's openedURL though. :| 
    NSLog(@"willTransition called. scrolling direction: %ld",self.scrollDirection);
    // this is close, but sometimes is zero, so not quite what we need.
    
    for ( GIFSinglePageViewController *tmpPageVC in pendingViewControllers )
    {
        // NSLog(@"pending view controller: %@",tmpPageVC);
        [tmpPageVC.imageView setContentMode:(self.scaleImages?UIViewContentModeScaleAspectFill:UIViewContentModeScaleAspectFit)];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if ( completed ) {
        // get current view
        GIFSinglePageViewController *tmpCurrentPage = self.viewControllers.firstObject;
        
        // get its url
        NSURL *tmpCurrentURL = tmpCurrentPage.openedURL;
        
        // get its index
        NSInteger tmpCurrentIndex = [self.library indexOfObject:tmpCurrentURL];
        
        // update the prefs
        NSString *tmpLibraryIndexKey = kGIFLibraryUserDefaultsKeyFavoriteIndex;
        if ( self.segmentedControl.selectedSegmentIndex == GIFLibrarySegmentedControlSelectedIndexRandom )
            tmpLibraryIndexKey = kGIFLibraryUserDefaultsKeyRandomIndex;
        [[NSUserDefaults standardUserDefaults] setInteger:tmpCurrentIndex forKey:tmpLibraryIndexKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // and display it.
        
        // indicies are zero-indexed, add one for display
        tmpCurrentIndex++;
        
        // and display it
        NSInteger tmpTotal = self.library.count;
        [self.currentPageItem setTitle:[NSString stringWithFormat:@"%ld of %lu", (long)tmpCurrentIndex, (long)tmpTotal]];

        // and if we're close to the end and displaying randoms, get some more.
        if ( self.segmentedControl.selectedSegmentIndex == GIFLibrarySegmentedControlSelectedIndexRandom &&
             tmpCurrentIndex > tmpTotal - 5 )
        {
            [GIFLibrary fetchRandoms:10];
        }
        
    }
    else
    {
        NSLog(@"didFinishAnimating but completed = NO");
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	// via http://stackoverflow.com/a/16953031
    CGFloat newContentOffset = [[change objectForKey:@"new"] CGPointValue].x;
    CGFloat oldContentOffset = [[change objectForKey:@"old"] CGPointValue].x;
    CGFloat diff = newContentOffset - oldContentOffset;
    
    if ( diff < 0 ) {
		//scrolling down
        self.scrollDirection = GIFLibraryScrollingDirectionLeft;
    }
	else if ( diff > 0 ) {
		// scrolling up
		self.scrollDirection = GIFLibraryScrollingDirectionRight;
	}
	else {
		// not scrolling
		self.scrollDirection = GIFLibraryScrollingDirectionNone;
	}
    
}


#pragma mark - Gestures & Buttons
- (IBAction)screenTapped:(id)sender
{
    if ( self.statusbarHidden )
        [self showBars];
    else
        [self hideBars];;
}

- (IBAction)screenDoubleTapped:(id)sender
{
    [self setScaleImages:!self.scaleImages];
    
    // reload display
    [UIView animateWithDuration:kGIFPageViewControllerAnimationDuration/2
                     animations:^{
                         // hide the image
                         if ( [self.viewControllers.firstObject respondsToSelector:@selector(imageView)] )
                             [[self.viewControllers.firstObject imageView] setAlpha:0.0f];
                     }
                     completion:^(BOOL finished) {
                         if ( finished ) {
                             
                             // update the contentMode
                             if ( [self.viewControllers.firstObject respondsToSelector:@selector(imageView)] )
                                 [[self.viewControllers.firstObject imageView] setContentMode:(self.scaleImages?UIViewContentModeScaleAspectFill:UIViewContentModeScaleAspectFit)];
                             
                             // and bring it back
                             [UIView animateWithDuration:kGIFPageViewControllerAnimationDuration/2
                                              animations:^{
                                                  if ( [self.viewControllers.firstObject respondsToSelector:@selector(imageView)] )
                                                      [[self.viewControllers.firstObject imageView] setAlpha:1.0f];
                                              }];
                         }
                     }];
}

- (void)longPressTriggered:(id)sender
{
    // fire up the share sheet, this makes it easy to share things when you're flipping through full screen.
    [self shareButtonTapped:nil];
}

- (void)addButtonTapped:(id)sender
{
    MMActionSheet *tmpActionSheet = [[MMActionSheet alloc] init];
    
    if ( self.segmentedControl.selectedSegmentIndex == GIFLibrarySegmentedControlSelectedIndexRandom )
    {
        
        [tmpActionSheet addButtonWithTitle:@"Add to Favorites"
                               buttonBlock:^{
                                   // TODO: add to favorites
                                   
                                   if ( [self.viewControllers.firstObject respondsToSelector:@selector(openedURL)] )
                                   {
                                       
                                       NSURL *tmpURL = [self.viewControllers.firstObject openedURL];

                                       // remove it
                                       [GIFLibrary deleteGif:tmpURL];
                                       
                                       // and see if we can add it to the favorites
                                       BOOL success = [GIFLibrary addToFavorites:tmpURL];
                                       
                                       if ( success )
                                       {
                                           // switch to favorites
                                           [self.segmentedControl setSelectedSegmentIndex:0];
                                           
                                           // set the index to the newly-selected, last image
                                           [[NSUserDefaults standardUserDefaults] setInteger:[GIFLibrary favorites].count forKey:kGIFLibraryUserDefaultsKeyFavoriteIndex];
                                           [[NSUserDefaults standardUserDefaults] synchronize];
                                           
                                           // and reload
                                           [self setupCurrentPageFromPrefsAnimated:NO];
                                       }
                                       else
                                       {
                                           NSLog(@"lolwut");
                                       }
                                   }
                               }];
        
        [tmpActionSheet addButtonWithTitle:@"Load more GIFs"
                               buttonBlock:^{
                                   // TODO: figure out why this isn't working
                                   [GIFLibrary fetchRandoms:10];
                               }];
        
    }
    else
    {
        [tmpActionSheet addButtonWithTitle:@"Add GIF from URL"
                               buttonBlock:^{
                                   // TODO: throw up a text field to catch a url
                                   
                               }];
        
        [tmpActionSheet addButtonWithTitle:@"Add GIF from Clipboard"
                               buttonBlock:^{
                                   // TODO: take an incoming paste
                                   // of an image or url or mix from other apps (?)
                               }];
        
    /* alerts don't show. wat do?
        [tmpActionSheet addButtonWithTitle:@"Add GIF from Safari"
                               buttonBlock:^{
                                   
                                   MMAlertView *tmpAlert = [[MMAlertView alloc] initWithTitle:nil
                                                                                      message:@"To add a GIF from Safari, just change the beginning of the address to \"gif://\" and reload." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                   [tmpAlert show];
                               }];
        
        [tmpActionSheet addButtonWithTitle:@"from another phone"
                               buttonBlock:^{
                                   
                                   [MMAlertView showAlertViewWithTitle:nil message:@"You can allow other AirGIF users to send you GIFs by turning on AirDrop in Control Center."
                                                     cancelButtonTitle:@"LOL WUT" acceptButtonTitle:@"OK" cancelBlock:^{
                                                         // more info in safari?
                                                         [MMAlertView showAlertViewWithTitle:nil message:@"Show more info about AirDrop in Safari?" cancelButtonTitle:@"No Thanks" acceptButtonTitle:@"OK" cancelBlock:nil acceptBlock:^{
                                                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kGIFPageViewControllerKBaseAirDropAddress]];
                                                         }];
                                                     }
                                                           acceptBlock:nil];
                               }];
        
        [tmpActionSheet addButtonWithTitle:@"from another app"
                               buttonBlock:^{
                                   
                                   [MMAlertView showAlertViewWithTitle:nil message:@"Applications that use the standard \"sharing\" methods will show AirGIF under \"Open With...\"." cancelButtonTitle:@"LOL WUT" acceptButtonTitle:@"OK" cancelBlock:^{
                                       // more info in safari?
                                       [MMAlertView showAlertViewWithTitle:nil message:@"Show more info about sharing in Safari?" cancelButtonTitle:@"No Thanks" acceptButtonTitle:@"OK" cancelBlock:nil acceptBlock:^{
                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kGIFPageViewControllerKBaseSharingAddress]];
                                       }];
                                   }
                                                           acceptBlock:nil];
                               }];
         */
    
    }
    
    [tmpActionSheet addCancelButtonWithTitle:@"Cancel"
                           cancelButtonBlock:nil];
    
    [tmpActionSheet showFromToolbar:self.navigationController.toolbar];
    
}

- (void)shareButtonTapped:(id)sender
{
    if ( [self.viewControllers.firstObject respondsToSelector:@selector(openedURL)] )
    {
        
        NSURL *tmpURL = [self.viewControllers.firstObject openedURL];
        NSData *tmpData = [self.viewControllers.firstObject gifData];
        
        // bail out if we didn't get a url
        if ( !tmpURL ) {
            UIAlertView *tmpAlert = [[UIAlertView alloc] initWithTitle:@"AirGIF" message:@"Oops, the GIF got lost between there and here." delegate:nil cancelButtonTitle:@"Bummer, Dude." otherButtonTitles:nil];
            [tmpAlert show];
            return;
        }
        
        GIFActivityProvider *activityProvider = [[GIFActivityProvider alloc] initWithURL:tmpURL andData:tmpData];
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[activityProvider] applicationActivities:nil];
        
        [activityController setExcludedActivityTypes:[NSArray arrayWithObjects:UIActivityTypePrint, // print a gif? lulz.
                                                      UIActivityTypeAssignToContact, // no animation
                                                      // UIActivityTypeCopyToPasteboard, // default doesn't copy animation, but we're doing our own, so allow it
                                                      UIActivityTypeSaveToCameraRoll, // photos app is sadmake for gifs
                                                      // UIActivityTypeMail, // attachments animate!
                                                      nil]];
        
        while ( !activityProvider.image ) {
            NSLog(@"no image to share yet");
        }
        
        [self presentViewController:activityController animated:YES completion:nil];
        
    }
    else
    {
        UIAlertView *tmpAlert = [[UIAlertView alloc] initWithTitle:@"Uh oh..." message:@"\nI can't tell how\nto get the current GIF.\n\nI think my mind is going.\n\nWould you like me\nto sing you a song?" delegate:nil cancelButtonTitle:@"Daisy, daisy..." otherButtonTitles:nil];
        [tmpAlert show];
    }
}

- (void)deleteButtonTapped:(id)sender
{
    NSURL *tmpCurrentURL = [self.viewControllers.firstObject openedURL];
    
    MMActionSheet *tmpActionSheet = [[MMActionSheet alloc] initWithTitle:nil
                                                       cancelButtonTitle:nil
                                                             cancelBlock:nil
                                                  destructiveButtonTitle:@"Delete GIF"
                                                        destructiveBlock:^{
                                                            // delete it
                                                            [GIFLibrary deleteGif:tmpCurrentURL];
                                                            
                                                            // update the display
                                                            // by keeping the index and refreshing
                                                            [self setupCurrentPageFromPrefsAnimated:NO];
                                                            
                                                            // TODO: check if the deleted was the last.
                                                            // currently, will reset to first if the
                                                            // index is out of range
                                                        }];
    
    [tmpActionSheet addButtonWithTitle:@"Report Problem"
                           buttonBlock:^{
                               // report it
                               [GIFLibrary reportProblem:tmpCurrentURL];
                               
                               // update the display
                               // by keeping the index and refreshing
                               [self setupCurrentPageFromPrefsAnimated:NO];
                               
                               // TODO: check if the deleted was the last.
                               // currently, will reset to first if the
                               // index is out of range
                           }];
    
    [tmpActionSheet addCancelButtonWithTitle:@"Cancel"
                           cancelButtonBlock:nil];
    
    /*
     UIActionSheet *tmpActionSheet = [[UIActionSheet alloc] initWithTitle:nil
     delegate:nil
     cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete GIF"
     otherButtonTitles:@"Report Problem", nil];
     */
    
    [tmpActionSheet showFromToolbar:self.navigationController.toolbar];
}

- (void)segmentedControlChanged:(id)sender
{
    // save new library selection
    NSInteger tmpLibraryIndex = [(UISegmentedControl *)sender selectedSegmentIndex];
    [[NSUserDefaults standardUserDefaults] setInteger:tmpLibraryIndex forKey:kGIFLibraryUserDefaultsKeyCurrentLibraryIndex];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // and update the display
    [self resetCurrentPageFromPrefsAnimated:YES];
}

- (void)setupCurrentPageFromPrefsAnimated:(BOOL)shouldAnimate
{
    UIStoryboard *tmpStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    GIFSinglePageViewController *tmpFirstSinglePageVC = [tmpStoryboard instantiateViewControllerWithIdentifier:@"GIFSinglePageViewController"];
    [tmpFirstSinglePageVC loadView]; // so we can configure it
                                     // TODO: set real image, and use -setOpenedURL
    [tmpFirstSinglePageVC.imageView setContentMode:(self.scaleImages?UIViewContentModeScaleAspectFill:UIViewContentModeScaleAspectFit)];
    [tmpFirstSinglePageVC.imageView setClipsToBounds:YES]; // TODO: move to a more robust location
    
    // setup library and first page
    NSInteger tmpLibraryIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kGIFLibraryUserDefaultsKeyCurrentLibraryIndex];
    [self.segmentedControl setSelectedSegmentIndex:tmpLibraryIndex];
    if ( tmpLibraryIndex == GIFLibrarySegmentedControlSelectedIndexRandom )
        [self setLibrary:[GIFLibrary randoms]];
    else
        [self setLibrary:[GIFLibrary favorites]];
    
    NSInteger tmpPageIndex = [[NSUserDefaults standardUserDefaults] integerForKey:(tmpLibraryIndex?kGIFLibraryUserDefaultsKeyRandomIndex:kGIFLibraryUserDefaultsKeyFavoriteIndex)];
    NSURL *tmpURL = nil;
    if ( tmpPageIndex < self.library.count ) // aviod out of range exception
        tmpURL = [self.library objectAtIndex:tmpPageIndex];
    else
        tmpURL = self.library.firstObject; // default to first if something weird is going on
    
    [tmpFirstSinglePageVC setOpenedURL:tmpURL];
    
    // update interface
    tmpPageIndex = [self.library indexOfObject:tmpURL]; // reset in case we were over and went to the first
    tmpPageIndex++; // array is zero-indexed, UI starts with one.
    [self.currentPageItem setTitle:[NSString stringWithFormat:@"%ld of %lu", (long)tmpPageIndex, (unsigned long)self.library.count]];
    
    [self setViewControllers:@[tmpFirstSinglePageVC]
                   direction:(tmpLibraryIndex?UIPageViewControllerNavigationDirectionForward:UIPageViewControllerNavigationDirectionReverse)
                    animated:shouldAnimate
                  completion:nil];
}

- (void)resetCurrentPageFromPrefsAnimated:(BOOL)shouldAnimate
{
    // setup library and first page
    NSInteger tmpLibraryIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kGIFLibraryUserDefaultsKeyCurrentLibraryIndex];
    [self.segmentedControl setSelectedSegmentIndex:tmpLibraryIndex];
    if ( tmpLibraryIndex == GIFLibrarySegmentedControlSelectedIndexRandom )
        [self setLibrary:[GIFLibrary randoms]];
    else
        [self setLibrary:[GIFLibrary favorites]];
    
    NSInteger tmpPageIndex = [[NSUserDefaults standardUserDefaults] integerForKey:(tmpLibraryIndex?kGIFLibraryUserDefaultsKeyRandomIndex:kGIFLibraryUserDefaultsKeyFavoriteIndex)];
    NSURL *tmpURL = nil;
    if ( tmpPageIndex < self.library.count ) // aviod out of range exception
        tmpURL = [self.library objectAtIndex:tmpPageIndex];
    else
        tmpURL = self.library.firstObject; // default to first if something weird is going on
    
    GIFSinglePageViewController *tmpCurrentPage = self.viewControllers.firstObject;
    [tmpCurrentPage setOpenedURL:tmpURL];
    
    // update interface
    tmpPageIndex = [self.library indexOfObject:tmpURL]; // reset in case we were over and went to the first
    tmpPageIndex++; // array is zero-indexed, UI starts with one.
    [self.currentPageItem setTitle:[NSString stringWithFormat:@"%ld of %lu", (long)tmpPageIndex, (unsigned long)self.library.count]];
}

#pragma mark - Storyboard
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"openURL"]) {
        
        if ( [[segue destinationViewController] respondsToSelector:@selector(openURL:)] && [sender respondsToSelector:@selector(absoluteString)] )
        {
            NSURL *tmpURL = sender;
            [(GIFSoloRootViewController *)[segue destinationViewController] openURL:tmpURL];
        }
    }
}


#pragma mark - Utilities
- (void)openURL:(NSURL *)url
{
    [self performSegueWithIdentifier:@"openURL" sender:url];
}

- (void)showBars
{
    [self setStatusbarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)hideBars
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self setStatusbarHidden:YES];
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{[self setNeedsStatusBarAppearanceUpdate];}];
}

- (void)setStatusbarHidden:(BOOL)statusbarHidden
{
    _statusbarHidden = statusbarHidden;
    
    // [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)prefersStatusBarHidden
{
    return _statusbarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}


@end
