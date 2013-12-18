//
//  GIFWebViewController.m
//  AirGIF
//
//  Created by Ian Meyer on 12/2/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import "GIFWebViewController.h"

@interface GIFWebViewController ()

@end

@implementation GIFWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.webView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    UIBarButtonItem *tmpCloseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:tmpCloseButton];
}

- (void)doneButtonPressed:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
