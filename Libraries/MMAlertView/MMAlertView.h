//
//  MMAlertView.h
//  magicmap3
//
//  Created by Ian Meyer on 2/10/12.
//  Copyright (c) 2012 Adelie Software. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MMAlertViewButtonPressedBlockType)();

/**
 `MMAlertView` is a wrapper around `UIAlertView` that provides convenience constructers and block-based callbacks. Use it wherever you would use a one- or two-button `UIAlertView`. This module enables you to quickly use multiple alert views within one controller without having to track the different alert views to distinguish between them with the `UIAlertViewDelegate`.
 */
@interface MMAlertView : UIAlertView <UIAlertViewDelegate>
{
	MMAlertViewButtonPressedBlockType _cancelBlock;
	MMAlertViewButtonPressedBlockType _acceptBlock;
}

///----------------------------------
/// @name Block assignment properties
///----------------------------------

/**
 The block to be executed when the cancel/close button is pressed.
 */
@property (nonatomic, copy) MMAlertViewButtonPressedBlockType cancelBlock;
/**
 The block to be executed when the accept button is pressed.
 */
@property (nonatomic, copy) MMAlertViewButtonPressedBlockType acceptBlock;

///---------------------------------------------
/// @name Alert view convenience display methods
///---------------------------------------------

/**
 Creates and shows a `UIAlertView` with the specified title and message. Uses "Close" as the button close title.

 @param inTitle The title for the alert view.
 @param inMessage The message for the alert view.
 */
+ (void)showAlertViewWithTitle:(NSString *)inTitle message:(NSString *)inMessage;

/**
 Creates and shows a `UIAlertView` with the specified title, message, and close button title.
 
 @param inTitle The title for the alert view.
 @param inMessage The message for the alert view.
 @param inCloseButtonTitle The title for the close button.
 */
+ (void)showAlertViewWithTitle:(NSString *)inTitle message:(NSString *)inMessage closeButtonTitle:(NSString *)inCloseButtonTitle;

/**
 Creates and shows a `UIAlertView` with the specified title, message, close button title, and a block to execute when the alert view is dismissed.
 
 @param inTitle The title for the alert view.
 @param inMessage The message for the alert view.
 @param inCloseButtonTitle The title for the close button.
 @param inCloseBlock A block to execute when the alert view is dismissed.
 */
+ (void)showAlertViewWithTitle:(NSString *)inTitle message:(NSString *)inMessage closeButtonTitle:(NSString *)inCloseButtonTitle closeBlock:(MMAlertViewButtonPressedBlockType)inCloseBlock;

/**
 Creates and returns a `UIAlertView` with the specified title, message, and close button title.
 
 @param inTitle The title for the alert view.
 @param inMessage The message for the alert view.
 @param inCloseButtonTitle The title for the close button.
 */
+ (MMAlertView *)alertViewWithTitle:(NSString *)inTitle message:(NSString *)inMessage closeButtonTitle:(NSString *)inCloseButtonTitle closeBlock:(MMAlertViewButtonPressedBlockType)inCloseBlock;


/**
 Creates and shows a `UIAlertView` with the specified title, message, a cancel button, and an accept button. The titles of the buttons and the blocks to execute when the alert view is dismissed for each button type is also defined.
 
 @param inTitle The title for the alert view.
 @param inMessage The message for the alert view.
 @param inCancelButtonTitle The title for the cancel button.
 @param inAcceptButtonTitle The title for the accept button.
 @param inCancelBlock A block to execute when the alert view is dismissed with the cancel button.
 @param inAcceptBlock A block to execute when the alert view is dismissed with the accept button.
 */
+ (void)showAlertViewWithTitle:(NSString *)inTitle message:(NSString *)inMessage cancelButtonTitle:(NSString *)inCancelButtonTitle acceptButtonTitle:(NSString *)inAcceptButtonTitle cancelBlock:(MMAlertViewButtonPressedBlockType)inCancelBlock acceptBlock:(MMAlertViewButtonPressedBlockType)inAcceptBlock;


/**
 Creates and returns a `UIAlertView` with the specified title, message, a cancel button, and an accept button. The titles of the buttons and the blocks to execute when the alert view is dismissed for each button type is also defined.
 
 @param inTitle The title for the alert view.
 @param inMessage The message for the alert view.
 @param inCancelButtonTitle The title for the cancel button.
 @param inAcceptButtonTitle The title for the accept button.
 @param inCancelBlock A block to execute when the alert view is dismissed with the cancel button.
 @param inAcceptBlock A block to execute when the alert view is dismissed with the accept button.
 */
+ (MMAlertView *)alertViewWithTitle:(NSString *)inTitle message:(NSString *)inMessage cancelButtonTitle:(NSString *)inCancelButtonTitle acceptButtonTitle:(NSString *)inAcceptButtonTitle cancelBlock:(MMAlertViewButtonPressedBlockType)inCancelBlock acceptBlock:(MMAlertViewButtonPressedBlockType)inAcceptBlock;

@end
