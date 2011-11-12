//
//  LabeledTextField.m
//  Off Road
//
//  Created by Raheel Ahmad on 11/1/11.
//  Copyright (c) 2011 Manchester College. All rights reserved.
//

#import "SKLabeledTextField.h"

#define MIN_LABEL_WIDTH 80
#define DISTANCE_BETWEEN_LABEL_FIELD 8

@interface SKLabeledTextField ()

- (void) _initialize;

@end

@implementation SKLabeledTextField

@synthesize labelText;
@synthesize labelBackgroundColor;
@synthesize labelTextColor;
@synthesize labelWidth;
@synthesize labelFont;

#pragma mark - Label

- (void) setLabelText:(NSString *) newLabelText {
	labelText = newLabelText;
	[self setNeedsDisplay];
}

- (void) setLabelBackgroundColor:(UIColor *) newColor {
	labelBackgroundColor = newColor;
	[self setNeedsDisplay];
}

- (void) setLabelTextColor:(UIColor *) newColor {
	labelTextColor = newColor;
	[self setNeedsDisplay];
}

- (void) setLabelFont:(UIFont *) newFont {
	labelFont = newFont;
	[self setNeedsDisplay];
}

#pragma mark - UITextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
		[self _initialize];
		
    return self;
}

- (id) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self)
		[self _initialize];
	
	return self;
}

- (void) _initialize {
	self.labelWidth = MIN_LABEL_WIDTH;
	labelFont = [UIFont boldSystemFontOfSize:14];
	self.layer.borderColor = [UIColor grayColor].CGColor;
	self.layer.borderWidth = 1.0f;
	self.layer.cornerRadius = 6.0f;
	self.clipsToBounds = YES;
	labelBackgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"fieldsBackground.png"]];
	labelTextColor = [UIColor darkGrayColor];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
	return UIEdgeInsetsInsetRect([super textRectForBounds:bounds], UIEdgeInsetsMake(0, labelWidth + DISTANCE_BETWEEN_LABEL_FIELD, 0, 0));
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
	return [self textRectForBounds:bounds];
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
	// draw the label background
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, labelBackgroundColor.CGColor);
	CGContextFillRect(context, CGRectMake(0, 0, self.labelWidth, self.bounds.size.height));
	
	// draw vertical separator line
	CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextSetLineWidth(context, 0.5f);
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, self.labelWidth, 0);
	CGPathAddLineToPoint(path, NULL, self.labelWidth, self.bounds.size.height);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);

	// draw the label text
	CGContextSetFillColorWithColor(context, self.labelTextColor.CGColor);
	float stringMaxWidth = self.labelWidth;
	float stringMaxHeight = self.bounds.size.height;
	CGSize stringMaxSize = CGSizeMake(stringMaxWidth, stringMaxHeight);
	CGSize labelTextSize = [self.labelText sizeWithFont:self.labelFont
									  constrainedToSize:stringMaxSize 
										  lineBreakMode:UILineBreakModeWordWrap];
	CGRect labelTextRect = CGRectMake((stringMaxWidth - labelTextSize.width)/2, (stringMaxHeight  - labelTextSize.height)/2, labelTextSize.width, labelTextSize.height);
	[labelText drawInRect:labelTextRect
				 withFont:self.labelFont
			lineBreakMode:UILineBreakModeWordWrap 
				alignment:UITextAlignmentCenter];
}

@end
