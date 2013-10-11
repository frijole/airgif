//
//  GIFEditLibraryViewController.m
//  AirGIF
//
//  Created by Ian Meyer on 9/29/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import "GIFEditLibraryViewController.h"

#import "GIFLibrary.h"

#define CellIdentifier @"GIFEditLibraryCellIdentifier"

typedef NS_ENUM(NSInteger, GIFEditLibraryTableSection) {
    GIFEditLibraryTableSectionFavorites = 0,
    GIFEditLibraryTableSectionRandom,
    GIFEditLibraryTableSectionBans,
    GIFEditLibraryTableSectionCount
};

@interface GIFEditLibraryViewController ()

@end

@implementation GIFEditLibraryViewController

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

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setEditing:YES animated:NO];
}

- (IBAction)done:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
            rtnString = @"Favorites";
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
    UITableViewCell *rtnCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    // [rtnCell.textLabel setText:@"http://foo.bar/baz.gif"];
    
    switch ( indexPath.section ) {
        case GIFEditLibraryTableSectionFavorites:
            [rtnCell.textLabel setText:[[(NSURL *)[GIFLibrary favorites][indexPath.row] absoluteString] lastPathComponent]];
            break;
        case GIFEditLibraryTableSectionRandom:
            [rtnCell.textLabel setText:[(NSURL *)[GIFLibrary randoms][indexPath.row] absoluteString]];
            break;
        case GIFEditLibraryTableSectionBans:
            [rtnCell.textLabel setText:[(NSURL *)[GIFLibrary blacklist][indexPath.row] absoluteString]];
            break;
        default:
            break;
    }
    
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
        
        switch ( indexPath.section ) {
            case GIFEditLibraryTableSectionFavorites:
                [(NSMutableArray *)[GIFLibrary favorites] removeObjectAtIndex:indexPath.row];
                break;
            case GIFEditLibraryTableSectionRandom:
                [(NSMutableArray *)[GIFLibrary randoms] removeObjectAtIndex:indexPath.row];
                break;
            case GIFEditLibraryTableSectionBans:
                [(NSMutableArray *)[GIFLibrary blacklist] removeObjectAtIndex:indexPath.row];
                break;
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    /*
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    } 
    */
}



// Override to support rearranging the table view.
/*
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if ( fromIndexPath.section != 0 ) {
        // ?
    }
    else {
        // ?
    }
    
    [tableView reloadRowsAtIndexPaths:@[toIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
*/


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}



#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ( [segue.identifier isEqualToString:@"done"] ) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}



@end
