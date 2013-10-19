//
//  GIFSoloViewController.m
//  AirGIF
//
//  Created by Ian Meyer on 10/6/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import "GIFOpenedFileViewController.h"

#import "UIImage+animatedGIF.h"

#import "GIFSinglePageViewController.h"

#import "GIFMainPageViewController.h"

#import "GIFActivityProvider.h"
#import "GIFLibrary.h"

#define cellIdentifier @"soloCellIdentifier"

#define kGIFSoloViewControllerAnimationDuration 0.5f

@implementation GIFOpenedFileViewController

- (void)openURL:(NSURL *)url
{
    if ( [self.viewControllers.firstObject respondsToSelector:@selector(openURL:)] )
        [(GIFSoloRootViewController *)self.viewControllers.firstObject openURL:url];
}

@end


@interface GIFSoloRootViewController ()

@property (nonatomic) BOOL statusbarHidden;
@property (nonatomic, strong) NSURL *openedURL;
@property (nonatomic) BOOL scaleImages; // default YES, UIViewContentModeScaleAspectFill. NO results in UIViewContentModeScaleAspectFit.

@property (nonatomic, strong) NSArray *cachedToolbarItems;

@end

@implementation GIFSoloRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // load default image
    // NSURL *url = [[NSBundle mainBundle] URLForResource:@"gilles" withExtension:@"gif"];
    
    // or not (for now)
    // NSURL *url = [[GIFLibrary favorites] firstObject];
    // self.imageView.image = [UIImage animatedImageWithAnimatedGIFURL:url];
    // self.openedURL = url;
    
    if ( self.openedURL ) // may be set preparing for the segue before loaded the nib
        [self.imageView setImage:[UIImage animatedImageWithAnimatedGIFURL:self.openedURL]];
    
    // image view is ScaleAspectFill in storyboard, set default value here.
    self.scaleImages = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // tweak the tap handling
    [self.tapRecognizer requireGestureRecognizerToFail:self.doubleTapRecognizer];
    // moved here from viewDidLoad becuase self.tapRecognizer was nil there. 
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBars) object:nil];
}

- (void)dealloc
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openURL:(NSURL *)url
{
    [self setOpenedURL:url];
    
    [self.imageView setImage:[UIImage animatedImageWithAnimatedGIFURL:url]];
    
    [self.navigationItem setTitle:url.lastPathComponent];
}

#pragma mark - Segue Actions
- (IBAction)discardButtonTappedSegueCallback:(UIStoryboardSegue *)segue
{
    [self discardButtonTapped:nil];
}

- (IBAction)favoritesButtonTappedSegueCallback:(UIStoryboardSegue *)segue
{
    [self addToFavoritesButtonTapped:nil];
}



#pragma mark - Button Actions
- (void)discardButtonTapped:(id)sender
{
    // TODO: delete file

    // go away
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (void)addToFavoritesButtonTapped:(id)sender
{
    NSAssert(self.openedURL, @"addToFavorites tapped, but no openedURL set");
    
    // check url, if a file, copy to Documents folder, and add url there to favorites
    NSURL *savedDocumentURL = self.openedURL; // TODO: disable default pass-through after implementing below
    
    if ( self.openedURL.isFileURL )
    {   // is file
        
        // TODO: check for location, move to Documents if necessary and save final path
        // savedDocumentURL = [NSURL URLWithString:@"file://"];
    }
    else
    {   // is remote,

        // TODO: download into Documents and save path
        // savedDocumentURL = [NSURL URLWithString:@"file://"];
    }
    
    [GIFLibrary addToFavorites:self.openedURL withCompletionBlock:^(BOOL success, NSURL *newFavoriteURL) {
        // TODO: tell main vc to display new favorite (uh, doesn't this work?)
        if ( success && [self.presentingViewController respondsToSelector:@selector(viewControllers)] )
        {
            GIFMainPageViewController *tmpParentVC = [(UINavigationController *)[self presentingViewController] viewControllers].firstObject;
            
            if ( [tmpParentVC respondsToSelector:@selector(setViewControllers:direction:animated:completion:)] )
            {
                UIStoryboard *tmpStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
                GIFSinglePageViewController *tmpNewFavoriteVC = [tmpStoryboard instantiateViewControllerWithIdentifier:@"GIFSinglePageViewController"];
                [tmpNewFavoriteVC loadView]; // so we can configure it
                                             // TODO: set real image, and use -setOpenedURL
                [tmpNewFavoriteVC.imageView setContentMode:(self.scaleImages?UIViewContentModeScaleAspectFill:UIViewContentModeScaleAspectFit)];
                [tmpNewFavoriteVC.imageView setClipsToBounds:YES]; // TODO: move to a more robust location
                [tmpNewFavoriteVC setOpenedURL:self.openedURL];
                
                [tmpParentVC setViewControllers:@[tmpNewFavoriteVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
                NSInteger tmpCount = [GIFLibrary favorites].count;
                [tmpParentVC.currentPageItem setTitle:[NSString stringWithFormat:@"%ld of %ld",(long)tmpCount,(long)tmpCount]];
            }
        }
        // and go away
        [self.presentingViewController dismissViewControllerAnimated:YES
                                                          completion:nil];
    }];
}

- (void)shareButtonTapped:(id)sender
{
    GIFActivityProvider *activityProvider = [[GIFActivityProvider alloc] initWithURL:self.openedURL andData:[NSData dataWithContentsOfURL:self.openedURL]];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[activityProvider] applicationActivities:nil];
    

    [activityController setExcludedActivityTypes:[NSArray arrayWithObjects:UIActivityTypePrint, // print a gif? lulz.
                                                  UIActivityTypeAssignToContact, // no animation
                                                  // UIActivityTypeCopyToPasteboard, // default doesn't copy animation, but we're doing our own, so allow it
                                                  // UIActivityTypeSaveToCameraRoll, // saves static version
                                                  // UIActivityTypeMail, // attachments animate?
                                                  nil]];
    
    [self presentViewController:activityController animated:YES completion:nil];
    
}


#pragma mark - Gesture Recognizers, etc.
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
    [UIView animateWithDuration:kGIFSoloViewControllerAnimationDuration/2
                     animations:^{
                         // hide the image
                         [self.imageView setAlpha:0.0f];
                     }
                     completion:^(BOOL finished) {
                         if ( finished ) {
                             
                             // update the contentMode
                             [self.imageView setContentMode:(self.scaleImages?UIViewContentModeScaleAspectFill:UIViewContentModeScaleAspectFit)];
                             
                             // and bring it back
                             [UIView animateWithDuration:kGIFSoloViewControllerAnimationDuration/2
                                              animations:^{
                                                  [self.imageView setAlpha:1.0f];
                                              }];
                         }
                     }];
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
