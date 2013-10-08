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
#import "GIFActivityProvider.h"
#import "GIFLibrary.h"
#import "UIImage+animatedGIF.h"

#define kGIFPageViewControllerAnimationDuration 0.5f


// comment out for normal behavior
// #define TEST_OPEN_URL YES


@interface GIFMainPageViewController ()

@property (nonatomic) BOOL statusbarHidden;
@property (nonatomic, strong) NSURL *openedURL;
@property (nonatomic) BOOL scaleImages; // default YES, UIViewContentModeScaleAspectFill. NO results in UIViewContentModeScaleAspectFit.

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
    UIStoryboard *tmpStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    GIFSinglePageViewController *tmpFirstSinglePageVC = [tmpStoryboard instantiateViewControllerWithIdentifier:@"GIFSinglePageViewController"];
    [tmpFirstSinglePageVC loadView]; // so we can configure it
    // TODO: set real image, and use -setOpenedURL
    [tmpFirstSinglePageVC.imageView setContentMode:(self.scaleImages?UIViewContentModeScaleAspectFill:UIViewContentModeScaleAspectFit)];
    [tmpFirstSinglePageVC.imageView setClipsToBounds:YES]; // TODO: move to a more robust location
    [tmpFirstSinglePageVC setOpenedURL:[GIFLibrary favorites].firstObject];
    
    [self.currentPageItem setTitle:[NSString stringWithFormat:@"%d of %lu", 1, (unsigned long)[GIFLibrary favorites].count]];

    [self setViewControllers:@[tmpFirstSinglePageVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self.tapRecognizer requireGestureRecognizerToFail:self.doubleTapRecognizer];
    
    [self.view setGestureRecognizers:@[self.tapRecognizer, self.doubleTapRecognizer, self.longPressRecognizer]];
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
    
    NSInteger tmpIndex = [[GIFLibrary favorites] indexOfObject:tmpCurrentURL];
    
    if ( tmpIndex > 0 ) // if there is another image before the current one...
    {
        NSURL *tmpPrevURL = [[GIFLibrary favorites] objectAtIndex:tmpIndex-1];
        
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
    
    NSInteger tmpIndex = [[GIFLibrary favorites] indexOfObject:tmpCurrentURL];

    if ( tmpIndex < [GIFLibrary favorites].count-1 ) // if there is another image after the current one...
    {
        NSURL *tmpNextURL = [[GIFLibrary favorites] objectAtIndex:tmpIndex+1];

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
    // make sure pendingViewControllers are properly configured
    
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
        NSInteger tmpCurrentIndex = [[GIFLibrary favorites] indexOfObject:tmpCurrentURL];
        
        // indicies are zero-indexed, add one for display
        tmpCurrentIndex++;
        
        // set it
        [self.currentPageItem setTitle:[NSString stringWithFormat:@"%ld of %lu", (long)tmpCurrentIndex, (unsigned long)[GIFLibrary favorites].count]];
    }
    else
    {
        NSLog(@"didFinishAnimating but completed = NO");
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

- (void)shareButtonTapped:(id)sender
{
    if ( [self.viewControllers.firstObject respondsToSelector:@selector(openedURL)] )
    {
        
        NSURL *tmpURL = [self.viewControllers.firstObject openedURL];
        
        // bail out if we didn't get a url
        if ( !tmpURL ) {
            UIAlertView *tmpAlert = [[UIAlertView alloc] initWithTitle:@"AirGIF" message:@"No openedURL found" delegate:nil cancelButtonTitle:@"Bummer, Dude." otherButtonTitles:nil];
            [tmpAlert show];
            return;
        }
        
        GIFActivityProvider *activityProvider = [[GIFActivityProvider alloc] initWithData:[NSData dataWithContentsOfURL:tmpURL]];
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[activityProvider] applicationActivities:nil];
        
        [activityController setExcludedActivityTypes:[NSArray arrayWithObjects:UIActivityTypePrint, // print a gif? lulz.
                                                      UIActivityTypeAssignToContact, // no animation
                                                      // UIActivityTypeCopyToPasteboard, // default doesn't copy animation, but we're doing our own, so allow it
                                                      // UIActivityTypeSaveToCameraRoll, // saves static version
                                                      // UIActivityTypeMail, // attachments animate?
                                                      nil]];
        
        [self presentViewController:activityController animated:YES completion:nil];
        
    }
    else
    {
        UIAlertView *tmpAlert = [[UIAlertView alloc] initWithTitle:@"AirGIF" message:@"openedURL not found" delegate:nil cancelButtonTitle:@"Bummer, Dude." otherButtonTitles:nil];
        [tmpAlert show];
    }
}

- (void)deleteButtonTapped:(id)sender
{
    UIActionSheet *tmpActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                delegate:nil
                                                       cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete GIF"
                                                       otherButtonTitles:@"Report Problem", nil];
    
    [tmpActionSheet showFromToolbar:self.navigationController.toolbar];
}

- (void)longPressTriggered:(id)sender
{
    // fire up the share sheet, this makes it easy to share things when you're flipping through full screen.
    [self shareButtonTapped:nil];
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
