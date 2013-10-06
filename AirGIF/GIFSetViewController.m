//
//  GIFSetViewController.m
//  AirGIF
//
//  Created by Ian Meyer on 9/20/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import "GIFSetViewController.h"
#import "GIFSoloViewController.h"

#import "UIImage+animatedGIF.h"
#import "GIFActivityProvider.h"

#import "GIFLibrary.h"

#define cellIdentifier @"setCellIdentifier"

#define kGIFSetViewControllerAnimationDuration 0.5f

@interface GIFSetViewController ()

@property (nonatomic) BOOL statusbarHidden;
@property (nonatomic, strong) NSURL *openedURL;
@property (nonatomic) BOOL scaleImages; // default YES, UIViewContentModeScaleAspectFill. NO results in UIViewContentModeScaleAspectFit.

@end

@implementation GIFSetViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [self.view setUserInteractionEnabled:YES];
    
    // load default image
    // NSURL *url = [[NSBundle mainBundle] URLForResource:@"gilles" withExtension:@"gif"];
    NSURL *url = [[GIFLibrary favorites] firstObject];
    self.imageView.image = [UIImage animatedImageWithAnimatedGIFURL:url];
    self.openedURL = url;
    
    // image view is ScaleAspectFill in storyboard, set default value here.
    self.scaleImages = YES;
    
    // tweak the tap handling
    [self.tapRecognizer requireGestureRecognizerToFail:self.doubleTapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.scrollView setContentSize:CGSizeMake(CGRectGetMaxX(self.nextImageView.frame), CGRectGetMaxY(self.nextImageView.frame))];
    [self.scrollView setContentOffset:CGPointMake(320.0f, 0.0f)];
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
    [UIView animateWithDuration:kGIFSetViewControllerAnimationDuration/2
                     animations:^{
                         // hide the image
                         [self.imageView setAlpha:0.0f];
                     }
                     completion:^(BOOL finished) {
                         if ( finished ) {
                             
                             // update the contentMode
                             [self.imageView setContentMode:(self.scaleImages?UIViewContentModeScaleAspectFill:UIViewContentModeScaleAspectFit)];
                             
                             // and bring it back
                             [UIView animateWithDuration:kGIFSetViewControllerAnimationDuration/2
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
    [self performSegueWithIdentifier:@"openURL" sender:url];
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


@end
