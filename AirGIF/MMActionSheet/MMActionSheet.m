//
//  MMActionSheet.m
//  AirGIF
//
//  Created by Ian on 10/7/13.
//  Copyright (c) 2013 Ian Meyer. All rights reserved.
//

#import "MMActionSheet.h"

/**
 
 MMActionSheet is an easy-to-use subclass of UIActionSheet that simplifies the creation, alteration, and execution handling of the class.  Built around code blocks, the developer can easily create new buttons and assign callback methods to be executed when that button is pressed. Developers can instantiate an instance with just the default buttons - the dark grey 'cancel' and bright red 'destructive' ones - or add new buttons and change the default cancel button index.  All callback blocks are stored in a private mutable dictionary that is indexed by button title, so the developer must be sure to give each button a unique name to avoid collisions.
 
 */

@implementation MMActionSheet

/**
 
 Creates and returns an action sheet object using the supplied parameters.
 
 @return An new instance of MMActionSheet
 
 @param inTitle The text to be shown at the top center of the sheet
 @param inCancelButtonTitle The text that will be shown over the system default cancel button which has a grey color that is darker than other 'normal' buttons
 @param inCancelBlock The action to be performed when the user presses the cancel button
 @param destructiveButtonTitle The text that will be shown over the red-colored button
 @param inDestructiveBlock The action to be performed when the user presses the destructive button
 
 */



- (id)initWithTitle:(NSString *)inTitle cancelButtonTitle:(NSString *)inCancelButtonTitle cancelBlock:(MMActionSheetButtonPressedBlockType)inCancelBlock destructiveButtonTitle:(NSString *)inDestructiveButtonTitle destructiveBlock:(MMActionSheetButtonPressedBlockType)inDestructiveBlock
{
	if ((self = [super initWithTitle:inTitle delegate:self cancelButtonTitle:inCancelButtonTitle destructiveButtonTitle:inDestructiveButtonTitle otherButtonTitles:nil]))
	{
		_blockDictionary = [[NSMutableDictionary alloc] init];

		if (inCancelButtonTitle && inCancelBlock)
		{
			// MMActionSheetButtonPressedBlockType tmpBlock = [inCancelBlock copy];
			[_blockDictionary setObject:inCancelBlock forKey:inCancelButtonTitle];
			// [tmpBlock release];
		}
		if (inDestructiveButtonTitle && inDestructiveBlock)
		{
			// MMActionSheetButtonPressedBlockType tmpBlock = [inDestructiveBlock copy];
			[_blockDictionary setObject:inDestructiveBlock forKey:inDestructiveButtonTitle];
			// [tmpBlock release];
		}
	}
	return self;
}

/**
 
 Adds an additional light-grey button to an existing MMActionSheet instance.
 
 @return An integer representing the index of the newly-added button. This index starts at 0 and increases with each added button.
 
 @param inTitle The title to be displayed over the new button
 @param inButtonBlock The action to be performed when this button is pressed
 
 */

- (NSInteger)addButtonWithTitle:(NSString *)inTitle buttonBlock:(MMActionSheetButtonPressedBlockType)inButtonBlock
{
	if (inButtonBlock)
	{
		// MMActionSheetButtonPressedBlockType tmpBlock = [inButtonBlock copy];
		[_blockDictionary setObject:inButtonBlock forKey:inTitle];
		// [tmpBlock release];
	}

	return [super addButtonWithTitle:inTitle];
}

/**
 
 Adds a new button to an existing MMActionSheet that will become the new cancel button, which will be dark-grey with white text.  This will override any previous assignment of a cancel button.
 
 @param inTitle The text that will be shown over the system default cancel button which has a grey color that is darker than other 'normal' buttons
 @param inCancelButtonBlock The action to be performed when the user presses the cancel button
 
 */

- (void)addCancelButtonWithTitle:(NSString *)inTitle cancelButtonBlock:(MMActionSheetButtonPressedBlockType)inCancelButtonBlock
{
	NSInteger tmpInteger = [self addButtonWithTitle:inTitle buttonBlock:inCancelButtonBlock];
	[self setCancelButtonIndex:tmpInteger];
}

#pragma mark -
#pragma mark UIActionSheet delegate functions
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	MMActionSheetButtonPressedBlockType tmpBlock = [_blockDictionary objectForKey:[self buttonTitleAtIndex:buttonIndex]];
	if (tmpBlock)
		tmpBlock();
}

- (void)dealloc
{
	_blockDictionary = nil;
}

@end
