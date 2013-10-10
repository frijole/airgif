//
//  MMAlertView.m
//  magicmap3
//
//  Created by Ian Meyer on 2/10/12.
//  Copyright (c) 2012 Adelie Software. All rights reserved.
//

#import "MMAlertView.h"

@implementation MMAlertView

@synthesize cancelBlock = _cancelBlock;
@synthesize acceptBlock = _acceptBlock;

#pragma mark -
#pragma mark MMAlertView class methods
+ (void)showAlertViewWithTitle:(NSString *)inTitle message:(NSString *)inMessage
{
	[self showAlertViewWithTitle:inTitle message:inMessage closeButtonTitle:@"Close"];
}

+ (void)showAlertViewWithTitle:(NSString *)inTitle message:(NSString *)inMessage closeButtonTitle:(NSString *)inCloseButtonTitle
{
	[self showAlertViewWithTitle:inTitle message:inMessage closeButtonTitle:inCloseButtonTitle closeBlock:nil];
}

+ (void)showAlertViewWithTitle:(NSString *)inTitle message:(NSString *)inMessage closeButtonTitle:(NSString *)inCloseButtonTitle closeBlock:(MMAlertViewButtonPressedBlockType)inCloseBlock
{
	[self showAlertViewWithTitle:inTitle message:inMessage cancelButtonTitle:inCloseButtonTitle acceptButtonTitle:nil cancelBlock:inCloseBlock acceptBlock:nil];
}

+ (void)showAlertViewWithTitle:(NSString *)inTitle message:(NSString *)inMessage cancelButtonTitle:(NSString *)inCancelButtonTitle acceptButtonTitle:(NSString *)inAcceptButtonTitle cancelBlock:(MMAlertViewButtonPressedBlockType)inCancelBlock acceptBlock:(MMAlertViewButtonPressedBlockType)inAcceptBlock
{
	MMAlertView *tmpAlertView = [[MMAlertView alloc] initWithTitle:inTitle message:inMessage delegate:nil cancelButtonTitle:inCancelButtonTitle otherButtonTitles:inAcceptButtonTitle, nil];
	[tmpAlertView setDelegate:tmpAlertView];
	[tmpAlertView setCancelBlock:inCancelBlock];
	[tmpAlertView setAcceptBlock:inAcceptBlock];
	[tmpAlertView show];
}

#pragma mark -
#pragma mark UIAlertView property functions
- (void)setDelegate:(id)delegate
{
	NSAssert(delegate == self || delegate == nil, @"The delegate must not be overwritten.");
	[super setDelegate:delegate];
}

#pragma mark -
#pragma mark UIAlertView delegate functions
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == [alertView cancelButtonIndex])
	{
		if (_cancelBlock)
			_cancelBlock();
	}
	else
	{
		if (_acceptBlock)
			_acceptBlock();
	}
}

@end
