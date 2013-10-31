//
//  GIFEditLibraryViewController.m
//  AirGIF
//
//  Created by Ian Meyer on 9/29/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import "GIFLibraryViewController.h"

#import "GIFLibrary.h"

#import "MMAlertView.h"

#define CellIdentifier @"GIFEditLibraryCellIdentifier"

typedef NS_ENUM(NSInteger, GIFEditLibraryTableSection) {
    GIFEditLibraryTableSectionFavorites = 0,
    GIFEditLibraryTableSectionRandom,
    GIFEditLibraryTableSectionBans,
    GIFEditLibraryTableSectionCount
};

@class GIFLibraryViewController, GIFEditLibraryTableViewCell;

@protocol GIFEditLibraryCellDelegate <NSObject>

@optional
- (BOOL)editLibraryCellCanEdit:(GIFEditLibraryTableViewCell *)cell;
- (void)editLibraryCellDidBeginEditing:(GIFEditLibraryTableViewCell *)cell;
- (void)editLibraryCellDidEndEditing:(GIFEditLibraryTableViewCell *)cell;
@end

@interface GIFEditLibraryTableViewCell : UITableViewCell <UITextFieldDelegate>
@property (nonatomic, weak) NSURL *gifurl;
@property (nonatomic, weak) UITextField *textField;
@property (nonatomic, weak) id<GIFEditLibraryCellDelegate>cellDelegate;
@end

@implementation GIFEditLibraryTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] )
    {
        // start off by taking up the whole space. later, we'll resize to match the label.
        UITextField *tmpTextField = [[UITextField alloc] initWithFrame:self.contentView.bounds];
        
        [tmpTextField setBackgroundColor:[UIColor clearColor]];
        [tmpTextField setTextColor:[UIColor blackColor]];
        [tmpTextField setFont:self.textLabel.font];
        [tmpTextField setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
        [tmpTextField setTextAlignment:NSTextAlignmentLeft];
        [tmpTextField setKeyboardType:UIKeyboardTypeURL];
        [tmpTextField setReturnKeyType:UIReturnKeyDone];
        [tmpTextField setDelegate:self];
        [tmpTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        
        [self.contentView addSubview:tmpTextField];
        [self setTextField:tmpTextField];

        [self.textLabel setBackgroundColor:[UIColor clearColor]];
        
        // for some reason, cursor was white and setting tint color here resolved it.
        [self setTintColor:[[[UIApplication sharedApplication] delegate] window].tintColor];
        
    }
    
    return self;
}

- (void)setGifurl:(NSURL *)gifurl
{
    _gifurl = gifurl;
    
    // get the filename
    NSString *tmpTextLabelString = [[gifurl absoluteString] lastPathComponent];

    // get rid of percent encoding
    tmpTextLabelString = [tmpTextLabelString stringByRemovingPercentEncoding];
    
    // and drop the extension
    tmpTextLabelString = [tmpTextLabelString stringByReplacingOccurrencesOfString:@".gif" withString:@""];
    
    [self.textLabel setText:tmpTextLabelString];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.textField resignFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // default yes
    BOOL rtnValue = YES;

    // unless the delegate has something else to say
    if ( self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(editLibraryCellCanEdit:)] )
        rtnValue = [self.cellDelegate editLibraryCellCanEdit:self];
    
    return rtnValue;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // get ready to edit
    
    // grab the label frame and text
    CGRect tmpNewFrame = self.textLabel.frame;
    tmpNewFrame.size.width = CGRectGetWidth(self.contentView.bounds)-CGRectGetMinX(tmpNewFrame);
    [self.textField setFrame:tmpNewFrame];
    [self.textField setText:self.textLabel.text];
    [self.textField setFont:self.textLabel.font];

    // hide the text label (clearing the text messes up its autolayout when the cell changes state eg: to delete)
    [self.textLabel setHidden:YES];

    if ( self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(editLibraryCellDidBeginEditing:)] )
        [self.cellDelegate editLibraryCellDidBeginEditing:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // update the label text
    [self.textLabel setText:textField.text];
    [self.textLabel setHidden:NO];
    
    // clear the text field
    [textField setText:@""];
    
    // reset to take up the whole frame (to make activation easy)
    [textField setFrame:self.contentView.bounds];
    
    if ( self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(editLibraryCellDidEndEditing:)] )
        [self.cellDelegate editLibraryCellDidEndEditing:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // end editing
    [textField resignFirstResponder];
    
    // and don't return
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    // TODO: validate

    return YES;
}

@end





@interface GIFLibraryViewController () <GIFEditLibraryCellDelegate>

@property (nonatomic, weak) UITextField *currentTextField;

@end

@implementation GIFLibraryViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self.tableView registerClass:[GIFEditLibraryTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    [self.tableView setAllowsSelectionDuringEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setEditing:YES animated:NO];
}

- (IBAction)done:(id)sender
{
    if ( self.currentTextField )
        [self.currentTextField resignFirstResponder];
    else
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Cell Delegate
// this supports the done button, but keeps the actual text field encapsulated in the cell
- (void)editLibraryCellDidBeginEditing:(GIFEditLibraryTableViewCell *)cell
{
    [self setCurrentTextField:cell.textField];
}

- (void)editLibraryCellDidEndEditing:(GIFEditLibraryTableViewCell *)cell
{
    // TODO: save changed filename
    // NOTE: if the cell was deleted while the text field was active,
    // this is called after the item was removed via commitEditingStyle
    // so don't rename something that's been deleted!

    NSURL *tmpCurrentFavorite = cell.gifurl;
    NSString *tmpNewFilename = cell.textLabel.text;
    NSInteger tmpFavoritesIndex = [[GIFLibrary favorites] indexOfObject:tmpCurrentFavorite];
    if ( tmpFavoritesIndex != NSNotFound )
    {
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
        
        if ( [[tmpCurrentFavorite lastPathComponent] isEqualToString:tmpNewFilename] ) {
            // NSLog(@"new name is same as old name");
        }
        else
        {
            // NSLog(@"want to rename %@ to %@",[tmpCurrentFavorite lastPathComponent],tmpNewFilename);
            [GIFLibrary renameFavorite:tmpCurrentFavorite toFilename:tmpNewFilename withCompletionBlock:^(BOOL success, NSURL *newFavoriteURL) {
                
                if ( success ) {
                    NSIndexPath *tmpIndexPath = [self.tableView indexPathForCell:cell];
                    [self.tableView reloadRowsAtIndexPaths:@[tmpIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic]; // reload with the new name
                }
                else
                {
                    [cell.textField becomeFirstResponder];
                    [MMAlertView showAlertViewWithTitle:@"💩" message:@"An error occurred." ];
                }
            }];
        }
    }
    else
    {
        // NSLog(@"finished editing a file that's been deleted?");
    }
    
    [self setCurrentTextField:nil];
}

// and allows preventing editing of items without the cells having to know everything
- (BOOL)editLibraryCellCanEdit:(GIFEditLibraryTableViewCell *)cell
{
    // default no
    BOOL rtnValue = NO;
    
    NSIndexPath *tmpIndexPath = [self.tableView indexPathForCell:cell];
    
    // but we can edit our favorites' filenames
    if ( self.isEditing && tmpIndexPath.section == GIFEditLibraryTableSectionFavorites )
        rtnValue = YES;

    return rtnValue;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return GIFEditLibraryTableSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger rtnCount = 0;
    
    switch ( section ) {
        case GIFEditLibraryTableSectionFavorites:
            rtnCount = [GIFLibrary favorites].count;
            break;
        case GIFEditLibraryTableSectionRandom:
            rtnCount = [GIFLibrary randoms].count;
            break;
        case GIFEditLibraryTableSectionBans:
            rtnCount = [GIFLibrary blacklist].count;
            break;
        default:
            break;
    }
    
    return rtnCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *rtnString = @"";
    
    switch ( section ) {
        case GIFEditLibraryTableSectionFavorites:
            rtnString = @"Favorites - Tap to edit name";
            break;
        case GIFEditLibraryTableSectionRandom:
            rtnString = @"Cached Random URLs";
            break;
        case GIFEditLibraryTableSectionBans:
            rtnString = @"Deleted URLs";
            break;
        default:
            break;
    }

    return rtnString;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GIFEditLibraryTableViewCell *rtnCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    // [rtnCell.textLabel setText:@"http://foo.bar/baz.gif"];
    
    NSURL *tmpURLforCell = nil;
    
    switch ( indexPath.section ) {
        case GIFEditLibraryTableSectionFavorites:
            tmpURLforCell = [GIFLibrary favorites][indexPath.row];
            break;
        case GIFEditLibraryTableSectionRandom:
            tmpURLforCell = [GIFLibrary randoms][indexPath.row];
            break;
        case GIFEditLibraryTableSectionBans:
            tmpURLforCell = [GIFLibrary blacklist][indexPath.row];
            break;
        default:
            break;
    }
    
    // send url to cell to display
    if ( tmpURLforCell && [rtnCell respondsToSelector:@selector(setGifurl:)] )
        [rtnCell setGifurl:tmpURLforCell];
    
    // listen for editing events
    if ( [rtnCell respondsToSelector:@selector(setCellDelegate:)] )
        [rtnCell setCellDelegate:self];
    
    return rtnCell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle rtnStyle = UITableViewCellEditingStyleDelete;
    
    /* idea: put insert editing controls on web urls, to add to favorites?
    switch ( indexPath.section ) {
        case 0:
        case 2:
            rtnStyle = UITableViewCellEditingStyleDelete;
            break;
        case 1:
        default:
            rtnStyle = UITableViewCellEditingStyleInsert;
            break;
    }
    */
    
    return rtnStyle;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {   // Delete the row from the data source

        NSURL *tmpURLToDelete = nil;
        
        switch ( indexPath.section ) {
            case GIFEditLibraryTableSectionFavorites:
                tmpURLToDelete = [GIFLibrary favorites][indexPath.row];
                break;
            case GIFEditLibraryTableSectionRandom:
                tmpURLToDelete = [GIFLibrary randoms][indexPath.row];
                break;
            case GIFEditLibraryTableSectionBans:
                tmpURLToDelete = [GIFLibrary blacklist][indexPath.row];
                break;
        }
        
        if ( tmpURLToDelete )
        {
            [GIFLibrary deleteGif:tmpURLToDelete];
        
            [tableView beginUpdates];
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            
            // if the deleted item was in the randoms...
            if ( indexPath.section == GIFEditLibraryTableSectionRandom )
            {
                // see if its been added to the blacklist...
                NSInteger tmpBanIndex = [[GIFLibrary blacklist] indexOfObject:tmpURLToDelete];
                if ( tmpBanIndex != NSNotFound )
                {   // and if it has, insert it
                    NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:tmpBanIndex inSection:GIFEditLibraryTableSectionBans];
                    [tableView insertRowsAtIndexPaths:@[tmpIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
                }
            }
            
            [tableView endUpdates];
        }
    }
    /*
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    } 
    */
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
