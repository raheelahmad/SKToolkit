//
//  LabeledTextField.h
//  Off Road
//
//  Created by Raheel Ahmad on 11/1/11.
//  Copyright (c) 2011 Manchester College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

/**
A labeled text field. You would specify the width for the label, the default being 100 px
 */
@interface SKLabeledTextField : UITextField {
	int labelWidth;
	CGColorRef labelBackgroundColor;
	UIFont *labelFont;
}

@property (nonatomic, strong) NSString *labelText;
@property (nonatomic) CGColorRef labelBackgroundColor;
@property (nonatomic, strong) UIFont *labelFont;
@property (nonatomic) int labelWidth;

@end
