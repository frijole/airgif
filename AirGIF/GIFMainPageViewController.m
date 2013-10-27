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
#import "MBProgressHUD.h"

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
    [self.doubleLongPressRecognizer requireGestureRecognizerToFail:self.longPressRecognizer];
    
    [self.view setGestureRecognizers:@[self.tapRecognizer, self.doubleTapRecognizer, self.longPressRecognizer, self.doubleLongPressRecognizer]];
    
    // monitor scrolling direction to verify correct images displayed
    // UIPageViewController's _UIPageViewControllerContentView responds to "scrollView"
    // via https://github.com/nst/iOS-Runtime-Headers/blob/master/Frameworks/UIKit.framework/_UIPageViewControllerContentView.h
    // UIWebView does too, so casting that type to suppress warning
    if ( [self.view respondsToSelector:@selector(scrollView)] )
        [[(UIWebView *)self.view scrollView] addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    // in case we're coming back from editing and deleted the current image
    [self setupCurrentPageFromPrefsAnimated:NO];
}

#ifdef TEST_OPEN_URL
- (void)viewDidAppear:(BOOL)animated
{
    [self performSelector:@selector(openURL:)
               withObject:[NSURL URLWithString:@"http://31.media.tumblr.com/17304b5d47e174685c62f61c9d2ffce3/tumblr_mriia3bgMp1r2vcn2o1_500.gif"]
               afterDelay:1.0f];
}
#endif

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(hideBars) withObject:nil afterDelay:1.0f];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self cancelHideBars];
}

- (void)cancelHideBars
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBars) object:nil];
}

#pragma mark - Page View Controller
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    UIViewController *rtnVC =nil;
    
    NSURL *tmpCurrentURL = [self.viewControllers.firstObject openedURL];
    
    NSInteger tmpIndex = [self.library indexOfObject:tmpCurrentURL];
    
    if ( tmpIndex != NSNotFound && tmpIndex > 0 ) // if there is another image before the current one...
    {
        NSURL *tmpPrevURL = [self.library objectAtIndex:tmpIndex-1];
        
        UIStoryboard *tmpStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
        rtnVC = [tmpStoryboard instantiateViewControllerWithIdentifier:@"GIFSinglePageViewController"];
        [rtnVC loadView];
        
        if ( [rtnVC respondsToSelector:@selector(imageView)] ) {
            GIFSinglePageViewController *tmpPrevPage = (GIFSinglePageViewController *)rtnVC;
            [tmpPrevPage.imageView setContentMode:(self.scaleImages?UIViewContentModeScaleAspectFill:UIViewContentModeScaleAspectFit)];
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
    
    if ( tmpIndex != NSNotFound && tmpIndex < self.library.count-1 ) // if there is another image after the current one...
    {
        NSURL *tmpNextURL = [self.library objectAtIndex:tmpIndex+1];
        
        UIStoryboard *tmpStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
        rtnVC = [tmpStoryboard instantiateViewControllerWithIdentifier:@"GIFSinglePageViewController"];
        [rtnVC loadView];
        
        if ( [rtnVC respondsToSelector:@selector(imageView)] ) {
            GIFSinglePageViewController *tmpNextPage = (GIFSinglePageViewController *)rtnVC;
            [tmpNextPage.imageView setContentMode:(self.scaleImages?UIViewContentModeScaleAspectFill:UIViewContentModeScaleAspectFit)];
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
    // NSLog(@"willTransition called. scrolling direction: %d",self.scrollDirection);
    
    // what's the next/prev url for the pendingViewController?
    NSInteger tmpIndexForPendingVC = NSNotFound;

    NSURL *tmpCurrentURL = [self.viewControllers.firstObject openedURL];
    NSInteger tmpCurrentIndex = [self.library indexOfObject:tmpCurrentURL];
    switch ( self.scrollDirection ) {
        case GIFLibraryScrollingDirectionLeft:
            tmpIndexForPendingVC = tmpCurrentIndex-1;
            break;
        case GIFLibraryScrollingDirectionRight:
            tmpIndexForPendingVC = tmpCurrentIndex+1;
            break;
        default:
            // ???
            break;
    }
    
    if ( tmpIndexForPendingVC != NSNotFound && tmpIndexForPendingVC < self.library.count-1 )
    {
        NSURL *tmpURLforPendingVC = self.library[tmpIndexForPendingVC];
        NSURL *tmpURLinPendingVC = [(GIFSinglePageViewController *)[pendingViewControllers firstObject] openedURL];
        if ( ![tmpURLinPendingVC isEqual:tmpURLforPendingVC] ) {
            NSLog(@"pendingVC's openedURL does not match expected value \n pending:  %@ \n expected: %@",
                  [(GIFSinglePageViewController *)[self.viewControllers firstObject] openedURL],
                  tmpURLforPendingVC);
            [pendingViewControllers.firstObject setOpenedURL:tmpURLforPendingVC];
        }
        else
        {
            NSLog(@"pendingVC's openedURL is expected value, proceeding.");
        }
    }
    else
    {
        NSLog(@"couldn't check url on pending view controller");
    }
    
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
        
        if ( tmpCurrentIndex != NSNotFound )
        {
            // indicies are zero-indexed, add one for display
            tmpCurrentIndex++;
            
            // and display it
            NSInteger tmpTotal = self.library.count;
            NSString *tmpTitleString = [NSString stringWithFormat:@"%ld of %lu", (long)tmpCurrentIndex, (unsigned long)self.library.count];
            // add a "+" to the end for random since it'll load more as you go
            if ( self.segmentedControl.selectedSegmentIndex == GIFLibrarySegmentedControlSelectedIndexRandom )
                tmpTitleString = [tmpTitleString stringByAppendingString:@"+"];
            [self.currentPageItem setTitle:tmpTitleString];
            
            // and if we're close to the end and displaying randoms, get some more.
            if ( self.segmentedControl.selectedSegmentIndex == GIFLibrarySegmentedControlSelectedIndexRandom &&
                tmpCurrentIndex > tmpTotal - 5 )
            {
                [GIFLibrary fetchRandoms:10];
            }
        }
        else
        {
            [MMAlertView showAlertViewWithTitle:@"AirGIF" message:@"LOL WUT"];
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

- (void)longPressTriggered:(UIGestureRecognizer *)gestureRecognizer
{
    if ( gestureRecognizer.state == UIGestureRecognizerStateBegan )
    {
        // fire up the share sheet, this makes it easy to share things when you're flipping through full screen.
        [self shareButtonTapped:nil];
    }
}

- (void)doubleLongPressTriggered:(UIGestureRecognizer *)gestureRecognizer
{
    if ( gestureRecognizer.state == UIGestureRecognizerStateBegan )
    {
        MMActionSheet *tmpActionSheet = [[MMActionSheet alloc] initWithTitle:nil
                                                           cancelButtonTitle:nil
                                                                 cancelBlock:nil
                                                      destructiveButtonTitle:@"Delete GIF"
                                                            destructiveBlock:^{
                                                                // delete it
                                                                [self deleteFrontmostGIF];
                                                                
                                                                // update the display
                                                                // by keeping the index and refreshing
                                                                [self setupCurrentPageFromPrefsAnimated:NO];
                                                                
                                                                // TODO: check if the deleted was the last.
                                                                // currently, will reset to first if the
                                                                // index is out of range
                                                            }];
        
        if ( self.segmentedControl.selectedSegmentIndex == GIFLibrarySegmentedControlSelectedIndexRandom )
        {
            [tmpActionSheet addButtonWithTitle:@"Add to Favorites"
                                   buttonBlock:^{
                                       [self addFrontmostGIFtoFavorites];
                                   }];
        }
        else
        {
            [tmpActionSheet addButtonWithTitle:@"Rename GIF"
                                   buttonBlock:^{
                                       [self editButtonTapped:nil];
                                   }];
        }
        
        [tmpActionSheet addCancelButtonWithTitle:@"Cancel"
                               cancelButtonBlock:nil];
        
        [tmpActionSheet showInView:self.view];
        
    }
    
}

- (void)editButtonTapped:(id)sender
{
    [self cancelHideBars];
    
    UIAlertView *tmpAlertView = [[UIAlertView alloc] initWithTitle:@"Rename GIF"
                                                           message:@"Enter a new name for this GIF"
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"Save", nil];

    [tmpAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    NSString *tmpFilename = [[[self.viewControllers.firstObject openedURL] lastPathComponent] stringByRemovingPercentEncoding];
    // tmpFilename = [tmpFilename stringByReplacingOccurrencesOfString:@".gif" withString:@""];
    
    UITextField *tmpTextField = [tmpAlertView textFieldAtIndex:0];
    [tmpTextField setText:tmpFilename];
    [tmpTextField setClearButtonMode:UITextFieldViewModeAlways];
    
    [tmpAlertView show];
    
}

// edit button uialertview delegate

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    BOOL rtnValue = NO;
    
    NSString *tmpString = [alertView textFieldAtIndex:0].text;
    // NSLog(@"entered: %@",tmpString);
    
    // as long as its longer than nothing, but not too long
    if ( tmpString.length > 0 && tmpString.length < 24 )
        rtnValue = YES;
    
    return rtnValue;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == [alertView firstOtherButtonIndex] )
    {
        // NSLog(@"alert dismissed with button index: %d",buttonIndex);
        
        NSString *tmpNewFilename = [alertView textFieldAtIndex:0].text;
        
        // clean off partial file extensions
        if ( tmpNewFilename.length > 1 && [[[tmpNewFilename substringFromIndex:tmpNewFilename.length-1] lowercaseString] isEqualToString:@"."] ) {
            tmpNewFilename = [tmpNewFilename substringToIndex:tmpNewFilename.length-1];
        }
        
        if ( tmpNewFilename.length > 2 && [[[tmpNewFilename substringFromIndex:tmpNewFilename.length-2] lowercaseString] isEqualToString:@".g"] ) {
            tmpNewFilename = [tmpNewFilename substringToIndex:tmpNewFilename.length-2];
        }
        
        if ( tmpNewFilename.length > 3 && [[[tmpNewFilename substringFromIndex:tmpNewFilename.length-3] lowercaseString] isEqualToString:@".gi"] ) {
            tmpNewFilename = [tmpNewFilename substringToIndex:tmpNewFilename.length-3];
        }
        
        // now, if its too short to have an extension, or doesn't have one, add one.
        if ( tmpNewFilename.length < 4 || ![[[tmpNewFilename substringFromIndex:tmpNewFilename.length-4] lowercaseString] isEqualToString:@".gif"] )
            tmpNewFilename = [tmpNewFilename stringByAppendingString:@".gif"];
        
        NSURL *tmpCurrentFavorite = [self.viewControllers.firstObject openedURL];
        
        if ( [[tmpCurrentFavorite lastPathComponent] isEqualToString:tmpNewFilename] ) {
            NSLog(@"new name is same as old name");
        }
        else
        {
            NSLog(@"want to rename %@ to %@",[tmpCurrentFavorite lastPathComponent],tmpNewFilename);
            [GIFLibrary renameFavorite:tmpCurrentFavorite toFilename:tmpNewFilename withCompletionBlock:^(BOOL success, NSURL *newFavoriteURL) {
                
                if ( success ) {
                    [self setupCurrentPageFromPrefsAnimated:NO]; // reload with the URL
                }
                else
                {
                    [MMAlertView showAlertViewWithTitle:@"💩" message:@"An error occurred."];
                }
            }];
        }
    }
//    else
//    {
//        NSLog(@"cancel button pressed");
//    }
    
}

// end edit button uialertview delegate

- (void)deleteFrontmostGIF
{
    if ( [self.viewControllers.firstObject respondsToSelector:@selector(openedURL)] )
    {
        
        NSURL *tmpURL = [self.viewControllers.firstObject openedURL];
        
        // remove it
        [GIFLibrary deleteGif:tmpURL];
    }
    
}

- (void)addFrontmostGIFtoFavorites
{
    if ( [self.viewControllers.firstObject respondsToSelector:@selector(openedURL)] )
    {
        
        NSURL *tmpURL = [self.viewControllers.firstObject openedURL];
        
        // remove it
        [GIFLibrary deleteGif:tmpURL];
        
        // throw up a HUD while we download the new favorite
        MBProgressHUD *tmpProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [tmpProgressHUD setLabelText:@"Saving..."];
        
        // and see if we can add it to the favorites
        [GIFLibrary addToFavorites:tmpURL
               withCompletionBlock:^(BOOL success, NSURL *newFavoriteURL) {
                   
                   NSLog(@"addToFavorites completion block firing...");
                   
                   // dismiss HUD
                   [tmpProgressHUD hide:YES];
                   
                   if ( success )
                   {
                       // switch to favorites
                       [self.segmentedControl setSelectedSegmentIndex:GIFLibrarySegmentedControlSelectedIndexFavorites];
                       
                       // set the index to the newly-selected, last image
                       [[NSUserDefaults standardUserDefaults] setInteger:[GIFLibrary favorites].count forKey:kGIFLibraryUserDefaultsKeyFavoriteIndex];
                       [[NSUserDefaults standardUserDefaults] setInteger:GIFLibrarySegmentedControlSelectedIndexFavorites forKey:kGIFLibraryUserDefaultsKeyCurrentLibraryIndex];
                       [[NSUserDefaults standardUserDefaults] synchronize];
                       
                       
                       // and reload
                       [self setupCurrentPageFromPrefsAnimated:NO];
                   }
                   else
                   {
                       [MMAlertView showAlertViewWithTitle:@"💩" message:@"LOLWUT"];
                   }
               }];
    }
}

- (void)addButtonTapped:(id)sender
{
    [MMAlertView showAlertViewWithTitle:nil
                                message:@"Add to Favorites?"
                      cancelButtonTitle:@"No"
                      acceptButtonTitle:@"Yes"
                            cancelBlock:nil
                            acceptBlock:^{
                                [self addFrontmostGIFtoFavorites];
                            }];
   
}

- (void)shareButtonTapped:(id)sender
{
    if ( [self.viewControllers.firstObject respondsToSelector:@selector(openedURL)] )
    {
        
        NSURL *tmpURL = [self.viewControllers.firstObject openedURL];
        NSData *tmpData = [self.viewControllers.firstObject gifData];
        
        // bail out if we didn't get a url
        if ( !tmpURL ) {
            [MMAlertView showAlertViewWithTitle:nil
                                        message:@"I'm sorry Dave,\nI can't do that."
                               closeButtonTitle:@"OK"];
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
    GIFLibrarySegmentedControlSelectedIndex tmpLibraryIndex = [(UISegmentedControl *)sender selectedSegmentIndex];
    [[NSUserDefaults standardUserDefaults] setInteger:tmpLibraryIndex forKey:kGIFLibraryUserDefaultsKeyCurrentLibraryIndex];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // and update the display
    [self setupCurrentPageFromPrefsAnimated:NO];
}

- (void)setupCurrentPageFromPrefsAnimated:(BOOL)shouldAnimate
{
    UIStoryboard *tmpStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    GIFSinglePageViewController *tmpFirstSinglePageVC = [tmpStoryboard instantiateViewControllerWithIdentifier:@"GIFSinglePageViewController"];
    [tmpFirstSinglePageVC loadView]; // so we can configure it
    [tmpFirstSinglePageVC.imageView setContentMode:(self.scaleImages?UIViewContentModeScaleAspectFill:UIViewContentModeScaleAspectFit)];
    
    // setup library and first page
    GIFLibrarySegmentedControlSelectedIndex tmpLibraryIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kGIFLibraryUserDefaultsKeyCurrentLibraryIndex];
    [self.segmentedControl setSelectedSegmentIndex:tmpLibraryIndex];
    
    switch ( tmpLibraryIndex ) {
        case GIFLibrarySegmentedControlSelectedIndexRandom:
            // set library
            [self setLibrary:[GIFLibrary randoms]];
            
            // and button "Add to Favorites" for random items
            [self.navigationItem setRightBarButtonItem:self.addToFavoritesButton animated:YES];
            break;
            
        case GIFLibrarySegmentedControlSelectedIndexFavorites:
            // set library
            [self setLibrary:[GIFLibrary favorites]];

            // and button is edit for favorites
            [self.navigationItem setRightBarButtonItem:self.customEditButton animated:YES];
            break;
    }
    
    NSInteger tmpPageIndex = [[NSUserDefaults standardUserDefaults] integerForKey:(tmpLibraryIndex?kGIFLibraryUserDefaultsKeyRandomIndex:kGIFLibraryUserDefaultsKeyFavoriteIndex)];
    NSURL *tmpURL = nil;
    if ( tmpPageIndex < self.library.count ) // avoid out of range exception
        tmpURL = [self.library objectAtIndex:tmpPageIndex];
    else
        tmpURL = self.library.lastObject; // out of range, probably deleted one at the end or something.
    
    [tmpFirstSinglePageVC setOpenedURL:tmpURL];
    
    // update interface
    tmpPageIndex = [self.library indexOfObject:tmpURL]; // reset in case we were over and went to the first

    if ( tmpPageIndex != NSNotFound )
    {
        tmpPageIndex++; // array is zero-indexed, UI starts with one.
        NSString *tmpTitleString = [NSString stringWithFormat:@"%ld of %lu", (long)tmpPageIndex, (unsigned long)self.library.count];
        // add a "+" to the end for random since it'll load more as you go
        if ( tmpLibraryIndex == GIFLibrarySegmentedControlSelectedIndexRandom )
            tmpTitleString = [tmpTitleString stringByAppendingString:@"+"];
        [self.currentPageItem setTitle:tmpTitleString];
    }
    else if ( self.library.count > 0 )
    {
        [self.currentPageItem setTitle:@"???"];
    }
    else
    {
        [self.currentPageItem setTitle:@"No Favorites"];
    }

    [self setViewControllers:@[tmpFirstSinglePageVC]
                   direction:(tmpLibraryIndex?UIPageViewControllerNavigationDirectionForward:UIPageViewControllerNavigationDirectionReverse)
                    animated:shouldAnimate
                  completion:nil];
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
