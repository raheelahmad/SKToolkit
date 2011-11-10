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

@implementation SKLabeledTextField

@synthesize labelText;

#pragma mark - Label

- (void) setLabelText:(NSString *) newLabelText {
	labelText = newLabelText;
	[self setNeedsDisplay];
}

#pragma mark - UITextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
		labelWidth = MIN_LABEL_WIDTH;
		self.layer.borderColor = [UIColor grayColor].CGColor;
		self.layer.borderWidth = 1.0f;
		self.layer.cornerRadius = 6.0f;
		self.clipsToBounds = YES;
		labelBackgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"fieldsBackground.png"]].CGColor;
    }
    return self;
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
	
	
	NSLog(@"Drawing rect");
	
	// draw the label background
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, labelBackgroundColor);
	CGContextFillRect(context, CGRectMake(0, 0, labelWidth, self.bounds.size.height));
	
	// draw vertical separator line
	CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextSetLineWidth(context, 0.5f);
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, labelWidth, 0);
	CGPathAddLineToPoint(path, NULL, labelWidth, self.bounds.size.height);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);

	// draw the label text
	CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor);
	float stringMaxWidth = labelWidth;
	float stringMaxHeight = self.bounds.size.height;
	CGSize stringMaxSize = CGSizeMake(stringMaxWidth, stringMaxHeight);
	CGSize labelTextSize = [self.labelText sizeWithFont:[UIFont boldSystemFontOfSize:14] 
									  constrainedToSize:stringMaxSize 
										  lineBreakMode:UILineBreakModeWordWrap];
	CGRect labelTextRect = CGRectMake((stringMaxWidth - labelTextSize.width)/2, (stringMaxHeight  - labelTextSize.height)/2, labelTextSize.width, labelTextSize.height);
	[labelText drawInRect:labelTextRect
				 withFont:[UIFont boldSystemFontOfSize:14.0f] 
			lineBreakMode:UILineBreakModeWordWrap 
				alignment:UITextAlignmentCenter];
}

@end
