//
//  GIFMainCollectionViewController.m
//  AirGIF
//
//  Created by Ian Meyer on 10/4/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import "GIFMainCollectionViewController.h"

#import "UIImage+animatedGIF.h"
#import "GIFActivityProvider.h"

#import "GIFLibrary.h"

#define collectionCellIdentifier @"collectionCellIdentifier"

#define kGIFMainViewControllerAnimationDuration 0.5f

@implementation GIFMainCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.imageView setClipsToBounds:YES];
}

- (void)setGIF:(UIImage *)GIF
{
    // set the first frame to the image view. when the collection view is done scrolling, it'll load the animated image into the visibie cells. or something like that.
    _GIF = GIF;
    
//    [self.imageView setImage:[GIF images].firstObject];
    [self.imageView setImage:GIF];
}

@end


@interface GIFMainCollectionViewController ()

@property (nonatomic) BOOL statusbarHidden;
@property (nonatomic, strong) NSURL *openedURL;
@property (nonatomic) BOOL scaleImages; // default YES, UIViewContentModeScaleAspectFill. NO results in UIViewContentModeScaleAspectFit.

@property (nonatomic, strong) NSIndexPath *currentItem;

@property (nonatomic, strong) NSArray *cachedToolbarItems;

@end

@implementation GIFMainCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // load default image
    // NSURL *url = [[NSBundle mainBundle] URLForResource:@"gilles" withExtension:@"gif"];
    // NSURL *url = [[GIFLibrary randoms] firstObject];
    // self.imageView.image = [UIImage animatedImageWithAnimatedGIFURL:url];
    // self.openedURL = url;
    
    // set up the cell size
    [(UICollectionViewFlowLayout *)self.collectionViewLayout setItemSize:[UIScreen mainScreen].bounds.size];
    NSLog(@"set item size: %@",NSStringFromCGSize([UIScreen mainScreen].bounds.size));
    NSLog(@"collection view frame: %@",NSStringFromCGRect(self.collectionView.frame));
    
    // register our collection view cell
    // [self.collectionView registerClass:[GIFMainCollectionViewCell class] forCellWithReuseIdentifier:collectionCellIdentifier];
    
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
                         // hide the collection view
                         [self.collectionView setAlpha:0.0f];
                     }
                     completion:^(BOOL finished) {
                         if ( finished ) {
                             
                             // update the contentMode in the cells by calling...
                             [self.collectionView reloadData];
                             
                             // and bring it back
                             [UIView animateWithDuration:kGIFMainViewControllerAnimationDuration/2
                                              animations:^{
                                                  [self.collectionView setAlpha:1.0f];
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
    
    // [self.imageView setAlpha:1.0f];
    // [self.imageView setHidden:NO];
    // [self.imageView setImage:[UIImage animatedImageWithAnimatedGIFURL:url]];
    
    // stop scrolling
    [self.collectionView setScrollEnabled:NO];
    
    // hijack the current cell
    [[(GIFMainCollectionViewCell *)[[self.collectionView visibleCells] firstObject] imageView] setImage:[UIImage animatedImageWithAnimatedGIFURL:url]];
    
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

    // the collection view
    [self.collectionView reloadData];

    // and the rest of the UI, too
    [UIView animateWithDuration:kGIFMainViewControllerAnimationDuration
                     animations:^{
                         
                         self.navigationItem.title = @"x of y";
                     }
                     completion:^(BOOL finished) {
                         if ( finished ) {
                             [self.collectionView setScrollEnabled:YES];
                         }
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
    
    if ( success ) {
        
        // scroll to it silently
        [self.collectionView reloadData];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[GIFLibrary favorites].count-1 inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];

        // and take care of the rest of the ui too.
        [UIView animateWithDuration:kGIFMainViewControllerAnimationDuration
                         animations:^{
                             NSInteger tmpTotalFavorites = [GIFLibrary favorites].count;
                             [self setTitle:[NSString stringWithFormat:@"%ld of %ld",(long)tmpTotalFavorites,(long)tmpTotalFavorites]];
                             
                             // reset the toolbar
                             if ( self.cachedToolbarItems ) {
                                 [self setToolbarItems:self.cachedToolbarItems];
                                 [self setCachedToolbarItems:nil];
                             }
                         }
                         completion:^(BOOL finished) {
                             if ( finished ) {
                                 // re-enable scrolling
                                 [self.collectionView setScrollEnabled:YES];
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

#pragma mark - Collection View
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [GIFLibrary favorites].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GIFMainCollectionViewCell *rtnCell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellIdentifier forIndexPath:indexPath];
    
    [rtnCell setGIF:[UIImage animatedImageWithAnimatedGIFURL:[GIFLibrary favorites][indexPath.row]]];
    [rtnCell.imageView setContentMode:(self.scaleImages?UIViewContentModeScaleAspectFill:UIViewContentModeScaleAspectFit)];

//    if ( !self.collectionView.isDragging )
//        rtnCell.imageView.image = rtnCell.GIF;
    
    return rtnCell;
}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    for ( GIFMainCollectionViewCell *tmpCell in [self.collectionView visibleCells] ) {
//        tmpCell.imageView.image = tmpCell.GIF.images.firstObject;
//    }
//}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    for ( GIFMainCollectionViewCell *tmpCell in [self.collectionView visibleCells] ) {
//        tmpCell.imageView.image = tmpCell.GIF;
//    }
//}

#pragma mark - Scrolling
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ( !decelerate )
        [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.currentItem = self.collectionView.indexPathsForVisibleItems.firstObject;
}

#pragma mark - Rotation
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                               duration:(NSTimeInterval)duration
//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//                                         duration:(NSTimeInterval)duration
{
    CGSize tmpSize;
    
    CGFloat tmpScreenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat tmpScreenWidth = [UIScreen mainScreen].bounds.size.width;
    
    switch ( toInterfaceOrientation ) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            tmpSize = CGSizeMake(tmpScreenHeight, tmpScreenWidth);
            break;
            
        case UIInterfaceOrientationPortrait:
        default:
            tmpSize = CGSizeMake(tmpScreenWidth, tmpScreenHeight);
            break;
    }
    
    [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setItemSize:tmpSize];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //    [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setItemSize:self.view.bounds.size];
    //    [self.collectionView.collectionViewLayout invalidateLayout];
    //    [self.collectionView reloadData];

    [self.collectionView scrollToItemAtIndexPath:self.currentItem atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

@end