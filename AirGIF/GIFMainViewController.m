//
//  GIFMainViewController.m
//  AirGIF
//
//  Created by Ian Meyer on 9/20/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import "GIFMainViewController.h"

#import "UIImage+animatedGIF.h"
#import "GIFActivityProvider.h"

#import "GIFLibrary.h"

#define cellIdentifier @"cellIdentifier"

#define kGIFMainViewControllerAnimationDuration 0.5f

@interface GIFMainViewController ()

@property (nonatomic) BOOL statusbarHidden;
@property (nonatomic, strong) NSURL *openedURL;
@property (nonatomic) BOOL scaleImages; // default YES, UIViewContentModeScaleAspectFill. NO results in UIViewContentModeScaleAspectFit.

@property (nonatomic, strong) NSArray *cachedToolbarItems;

@end

@implementation GIFMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // load default image
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"gilles" withExtension:@"gif"];
    self.imageView.image = [UIImage animatedImageWithAnimatedGIFURL:url];
    self.openedURL = url;
    
    // image view is ScaleAspectFill in storyboard, set default value here.
    self.scaleImages = YES;
    
    // tweak the tap handling
    [self.tapRecognizer requireGestureRecognizerToFail:self.doubleTapRecognizer];
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
    [UIView animateWithDuration:kGIFMainViewControllerAnimationDuration/2
                     animations:^{
                         // hide the image
                         [self.imageView setAlpha:0.0f];
                     }
                     completion:^(BOOL finished) {
                         if ( finished ) {
                             
                             // update the contentMode
                             [self.imageView setContentMode:(self.scaleImages?UIViewContentModeScaleAspectFill:UIViewContentModeScaleAspectFit)];

                             // and bring it back
                             [UIView animateWithDuration:kGIFMainViewControllerAnimationDuration/2
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

- (void)openURL:(NSURL *)url
{
    [self setOpenedURL:url];
    
    [self.imageView setImage:[UIImage animatedImageWithAnimatedGIFURL:url]];
    
    [self.navigationItem setTitle:url.lastPathComponent];
    
    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    
    UIBarButtonItem *tmpFavoritesBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add to Favorites" style:UIBarButtonItemStylePlain target:self action:@selector(addToFavoritesTapped)];
    UIBarButtonItem *tmpDiscardBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Discard" style:UIBarButtonItemStylePlain target:self action:@selector(discardButtonTapped)];
    [tmpDiscardBarButtonItem setTintColor:[UIColor redColor]];
    
    UIBarButtonItem *tmpSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self setCachedToolbarItems:self.toolbarItems];
    [self setToolbarItems:@[tmpSpace, tmpDiscardBarButtonItem, tmpSpace, tmpFavoritesBarButtonItem, tmpSpace] animated:NO];
    
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

- (void)discardButtonTapped
{
    if ( self.cachedToolbarItems ) {
        [self setToolbarItems:self.cachedToolbarItems animated:YES];
        [self setCachedToolbarItems:nil];
    }
    
    // restore our edit button
    [self.navigationItem setLeftBarButtonItem:self.customEditButton animated:YES];
    
    // and reset the UI
    UIImage *tmpNextImage = nil; // TODO: get the last-displayed one from the favorites or randoms
    
    [UIView animateWithDuration:kGIFMainViewControllerAnimationDuration
                     animations:^{
                         self.imageView.image = tmpNextImage;
    
                         self.navigationItem.title = @"x of y";
                     }];
}

- (void)addToFavoritesTapped
{
    NSAssert(self.openedURL, @"addToFavorites tapped, but no openedURL set");
    
    // check url, if a file, copy to Documents folder, and add url there to favorites
    NSURL *savedDocumentURL;
    
    if ( self.openedURL.isFileURL ) {
        // is file, check for location, move to Documents if necessary and save final path
        
        savedDocumentURL = [NSURL URLWithString:@"file://"];
    }
    else {
        // is remote, download into Documents and save path

        savedDocumentURL = [NSURL URLWithString:@"file://"];
    }

    BOOL success = [GIFLibrary addToFavorites:savedDocumentURL];

    // did it work?
    NSLog(@"added to favorites: %d",success);

#warning temporary override
    if ( success || YES ) {

        [UIView animateWithDuration:kGIFMainViewControllerAnimationDuration
                         animations:^{
                             NSInteger tmpTotalFavorites = 5;
                             [self setTitle:[NSString stringWithFormat:@"%ld of %ld",(long)tmpTotalFavorites,tmpTotalFavorites]];

                             // reset the toolbar
                             if ( self.cachedToolbarItems ) {
                                 self.toolbarItems = self.cachedToolbarItems;
                                 self.cachedToolbarItems = nil;
                             }

                         }];


        // restore our edit button
        [self.navigationItem setLeftBarButtonItem:self.customEditButton animated:YES];
    }
    else {
        // alert?
    }
}

- (void)shareButtonTapped:(id)sender
{
    GIFActivityProvider *activityProvider = [[GIFActivityProvider alloc] initWithData:[NSData dataWithContentsOfURL:self.openedURL]];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[activityProvider] applicationActivities:nil];

    /*
    [activityController setCompletionHandler:^(NSString *activityType, BOOL completed){
        if ( completed ) {
            if ( [activityType isEqualToString:UIActivityTypeCopyToPasteboard] ) {
                // custom copy to pasteboard?
                NSData *gifData = [NSData dataWithContentsOfURL:url];
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                [pasteboard setData:gifData forPasteboardType:@"com.compuserve.gif"];
            }
            else if ( [activityType isEqualToString:UIActivityTypeMail] ) {
                NSLog(@"mailed");
            }
        }
    }];
     */
    
    [activityController setExcludedActivityTypes:[NSArray arrayWithObjects:UIActivityTypePrint, // print a gif? lulz.
                                                  UIActivityTypeAssignToContact, // no animation
                                                  // UIActivityTypeCopyToPasteboard, // default doesn't copy animation, but we're doing our own, so allow it
                                                  // UIActivityTypeSaveToCameraRoll, // saves static version
                                                  // UIActivityTypeMail, // attachments animate?
                                                  nil]];
    
    [self presentViewController:activityController animated:YES completion:nil];

}

- (void)deleteButtonTapped:(id)sender
{
    UIActionSheet *tmpActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                delegate:nil
                                                       cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete GIF"
                                                       otherButtonTitles:@"Report Problem", nil];

    [tmpActionSheet showFromToolbar:self.navigationController.toolbar];
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(GIFFlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        // [[segue destinationViewController] setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

@end
