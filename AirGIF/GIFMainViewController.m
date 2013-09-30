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

@interface GIFMainViewController ()

@property (nonatomic) BOOL statusbarHidden;

@end

@implementation GIFMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"gilles" withExtension:@"gif"];
    self.imageView.image = [UIImage animatedImageWithAnimatedGIFURL:url];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(hideBars) withObject:nil afterDelay:2.0f];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBars) object:nil];
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
    [self.imageView setImage:[UIImage animatedImageWithAnimatedGIFURL:url]];
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
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"gilles" withExtension:@"gif"];
    GIFActivityProvider *activityProvider = [[GIFActivityProvider alloc] initWithData:[NSData dataWithContentsOfURL:url]];
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
