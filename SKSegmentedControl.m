//
//  SKSegmentedControl.m
//
//  Created by Raheel Ahmad on 11/6/11.
//  Copyright (c) 2011 Sakun Labs. All rights reserved.
//

#import "SKSegmentedControl.h"
#import "SSLineView.h"

// -- private parts

@interface SKSegmentedControl ()

@property (nonatomic) CTFontRef ctSmallFont;
@property (nonatomic) CTFontRef ctLargeFont;
@property (nonatomic, strong) UIFont *smallFont;
@property (nonatomic, strong) UIFont *largeFont;
@property (nonatomic, strong) SSLineView *selectionLineView;
@property (nonatomic, retain) NSMutableArray *separators;

- (UIImageView *) separatorAt: (int) xPosition;
- (CGSize) sizeForString:(NSString *) aString;
- (void) addShadowToLayer: (CALayer *) aLayer;
- (void) removeShadowFromLayer: (CALayer *) aLayer;
- (BOOL) horizontalOrientation;
- (void) setupLabels;
- (void) setupSeparators;

@end

// --

@implementation SKSegmentedControl

@synthesize separators;
@synthesize separatorType;
@synthesize itemLabels;
@synthesize selectedIndex;
@synthesize ctSmallFont;
@synthesize ctLargeFont;
@synthesize smallFont;
@synthesize largeFont;
@synthesize selectionLineView;
@synthesize itemTitles;
@synthesize inactiveFontSize;
@synthesize activeFontSize;
@synthesize activeLabelColor;
@synthesize inactiveLabelColor;

#pragma mark - Event handlers

- (void) selectAtIndex: (int) newIndex {
	float w = 0; 
	float h = 0;
	
	if ([self horizontalOrientation]) { // horizontal orientation
		w = self.frame.size.width / [itemTitles count];
		h = self.frame.size.height;
	} else {
		w = self.frame.size.width;
		h = self.frame.size.height / [itemTitles count];
	}
	
	// if proper newIndex, make it selected
	if (newIndex >= 0 && newIndex < [itemLabels count]) {
		CATextLayer *newSelectedLayer = [itemLabels objectAtIndex:newIndex];
		CGSize stringSize = [self sizeForString:newSelectedLayer.string];
		float txtHeight = stringSize.height;
		CGRect newFrame;
		CGRect lineViewFrame;
		
		if ([self horizontalOrientation]) {
			newFrame = CGRectMake(newIndex * w, h/2 - txtHeight/2, w, txtHeight);
			lineViewFrame = CGRectMake(newIndex * w + w/2 - stringSize.width/2, h/2 + txtHeight/2 - 6, stringSize.width, 6);
		}
		else {
			newFrame = CGRectMake(0, h * newIndex + txtHeight/2, w, txtHeight);
			lineViewFrame = CGRectMake(w - stringSize.width, h * (newIndex+1) - h/2 + txtHeight/2 - 6, stringSize.width, 6);
		}
				
		// set up line view if not available
		
		if (!self.selectionLineView) {
			self.selectionLineView = [[SSLineView alloc] initWithFrame:lineViewFrame];
			self.selectionLineView.lineColor = [UIColor blackColor];
			self.selectionLineView.insetColor = [UIColor colorWithRed:0.474 green:0.567 blue:0.894 alpha:1.000];
			[self.selectionLineView setShowInset:YES];
		}
		if (!self.selectionLineView.superview)
			[self addSubview:self.selectionLineView];
			
		// animate the selection
		[UIView animateWithDuration:0.3f delay:0.0f options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
			newSelectedLayer.frame = newFrame;
			newSelectedLayer.font = self.ctLargeFont;
			newSelectedLayer.foregroundColor = self.activeLabelColor.CGColor;
			[self addShadowToLayer:newSelectedLayer];
			newSelectedLayer.fontSize = self.activeFontSize;
			
			self.selectionLineView.frame = lineViewFrame;
		} completion:^(BOOL finished) {
			
		}];
		
		// if there was a previous selectedIndex, let's make it unselected
		if (newIndex != selectedIndex && selectedIndex >= 0 && selectedIndex < [itemTitles count]) {
			CATextLayer *oldSelectedLayer = [itemLabels objectAtIndex:selectedIndex];
			oldSelectedLayer.font = self.ctSmallFont;
			oldSelectedLayer.fontSize = self.inactiveFontSize;
			oldSelectedLayer.foregroundColor = self.inactiveLabelColor.CGColor;
			[self removeShadowFromLayer:oldSelectedLayer];
		}
		selectedIndex = newIndex;
	}
}

#pragma mark - UIControl

- (BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	return YES;
}

- (BOOL) continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	return YES;
}

- (void) endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint pointAtUp = [touch locationInView:self];
	int indexAtUp = -1;
	
	if ([self horizontalOrientation])
		indexAtUp = pointAtUp.x / (self.frame.size.width / [itemTitles count]);
	else
		indexAtUp = pointAtUp.y / (self.frame.size.height / [itemTitles count]);
	
	[self selectAtIndex:indexAtUp];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - Helpers
			
- (BOOL) horizontalOrientation {
	return (self.frame.size.width > self.frame.size.height);
}

- (UIImageView *) separatorAt: (int) xPosition {
	UIImageView *imgVw = nil;
	if (separatorType == SKSegItemSeparatorTypeBullet) {
		imgVw = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bulletSeparator.png"]];
		float h = self.frame.size.height;
		imgVw.frame = CGRectMake(xPosition - 2, h/2 - 2, 6, 6);
	}
	else if (separatorType == SKSegItemSeparatorTypeLine) {
		imgVw = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lineSeparator.png"]];
		float h = self.frame.size.height;
		imgVw.frame = CGRectMake(xPosition - 1, h/2 - h/6, 2, h/3);
	}
	
	return imgVw;
}

- (void) addShadowToLayer: (CALayer *) aLayer {
	aLayer.shadowColor = [UIColor colorWithWhite:0.2f alpha:0.7f].CGColor;
	aLayer.shadowOffset = CGSizeMake(0, 1);
	aLayer.shadowOpacity = 1.0f;
	aLayer.shadowRadius = 2.0f;
}

- (void) removeShadowFromLayer: (CALayer *) aLayer {
	aLayer.shadowOpacity = 0.0f;
	aLayer.shadowOffset = CGSizeMake(0.0f, 0.0f);
}


// always returns size considering the big font size
- (CGSize) sizeForString:(NSString *) aString {
	float w = 0;
	float h = 0; 
	if ([self horizontalOrientation]) {
		w = self.frame.size.width/[itemTitles count];
		h = self.frame.size.height;
	}
	else {
		w = self.frame.size.width;
		h = self.frame.size.height/[itemTitles count];
	}
	
	return [aString sizeWithFont:largeFont constrainedToSize:CGSizeMake(w, h)];
}

- (void) setupLabels {
	if (!IsEmpty(itemLabels)) // get rid of previous ones if any
		for (CATextLayer *aLayer in itemLabels) {
			[aLayer removeFromSuperlayer];
		}
	
	self.itemLabels = [NSMutableArray arrayWithCapacity:[self.itemTitles count]];
	float w = 0;
	float h = 0;
	
	if ([self horizontalOrientation]) { // if horizontal orientation
		w = self.frame.size.width / [itemTitles count];
		h = self.frame.size.height;
	}
	else {
		w = self.frame.size.width;
		h = self.frame.size.height / [itemTitles count];
	}
		
	for (int i=0; i < [itemTitles count]; i++) {
		NSString *anItem = [itemTitles objectAtIndex:i];
		CATextLayer *alayer = [[CATextLayer alloc] init];
		alayer.backgroundColor = [UIColor clearColor].CGColor;
		[alayer setString:anItem];
		[alayer setForegroundColor:self.inactiveLabelColor.CGColor];
		[alayer setContentsScale:[[UIScreen mainScreen] scale]];
		[alayer setFont:ctSmallFont];
		[alayer setFontSize:self.inactiveFontSize];
		CGRect layerFrame;
		if ([self horizontalOrientation]) { // if horizontal orientation
			layerFrame.origin.x = w * i;
			layerFrame.size.width = w;
			float textHeight = [self sizeForString:anItem].height;
			layerFrame.origin.y = h/2 - textHeight/2;
			layerFrame.size.height = textHeight;
		}
		else {
			layerFrame.origin.x = 0;
			layerFrame.size.width = w;
			float textHeight = [self sizeForString:anItem].height;
			layerFrame.origin.y = h * i + textHeight/2;
			layerFrame.size.height = textHeight;
		}
		
		
		[alayer setFrame:layerFrame];
		if ([self horizontalOrientation])
			[alayer setAlignmentMode:kCAAlignmentCenter];
		else
			[alayer setAlignmentMode:kCAAlignmentRight];
		[self removeShadowFromLayer:alayer];
		[[self layer] addSublayer:alayer];
		[itemLabels addObject:alayer];
	}
}

- (void) setupSeparators {
	if (!IsEmpty(self.separators)) {
		for (UIImageView *separator in separators) {
			[separator removeFromSuperview];
		}
	}
	
	self.separators = [NSMutableArray arrayWithCapacity:[itemTitles count]-1];
	float w = 0;
	if ([self horizontalOrientation]) // if horizontal orientation
		w = self.frame.size.width / [itemTitles count];
	else
		w = self.frame.size.width;
	
	if ([self horizontalOrientation]) { // if horizontal orientation
		for (int i = 0; i < [itemTitles count]; i++) {
			if (i < [itemTitles count] - 1) {
				UIImageView *separator = [self separatorAt:(w * (i + 1))];
				[self addSubview:separator];
				[self.separators addObject:separator];
			}
		}
	}
}

#pragma mark - Setters

- (void) setInactiveFontSize:(int) aSize {
	inactiveFontSize = aSize;
	
	self.ctSmallFont = CTFontCreateWithName((__bridge CFStringRef) @"HelveticaNeue-Bold", aSize, NULL);
	self.smallFont = [UIFont boldSystemFontOfSize:aSize];
	
	[self setupLabels];
	[self selectAtIndex:selectedIndex];
}

- (void) setActiveFontSize:(int) aSize {
	activeFontSize = aSize;
	
	self.ctLargeFont = CTFontCreateWithName((__bridge CFStringRef) @"HelveticaNeue-Bold", aSize, NULL);
	self.largeFont = [UIFont boldSystemFontOfSize:aSize];
	
	[self setupLabels];
	[self selectAtIndex:selectedIndex];
}

- (void) setSeparatorType:(SKSegItemSeparatorType) newSeparatorType {
	separatorType = newSeparatorType;
	[self setupSeparators];
}

- (void) setActiveLabelColor:(UIColor *) aColor {
	activeLabelColor = aColor;
	if (selectedIndex < 0 || selectedIndex >= [itemLabels count])
		return;
	CATextLayer *aLayer = [itemLabels objectAtIndex:selectedIndex];
	[aLayer setForegroundColor:aColor.CGColor];
}

- (void) setInactiveLabelColor:(UIColor *) aColor {
	inactiveLabelColor = aColor;
	for (int i=0; i < [itemLabels count]; i++) {
		if (i == selectedIndex)
			continue;
		CATextLayer *aLayer = [itemLabels objectAtIndex:i];
		[aLayer setForegroundColor:aColor.CGColor];
	}
}


#pragma mark - UIView

- (id) initWithFrame:(CGRect)frame andItems: (NSArray *) itms {
	self = [super initWithFrame:frame];
	if (self) {
		self.activeFontSize = 18; // default font sizes
		self.inactiveFontSize = 17;
		self.activeLabelColor = [UIColor blackColor];
		self.inactiveLabelColor = [UIColor grayColor];
		
		self.backgroundColor = [UIColor clearColor];
		self.itemTitles = itms;
		self.separatorType = SKSegItemSeparatorTypeLine;
		
		[self setupLabels];
		
		[self selectAtIndex:0];
	}
	
	return self;
}

@end