//
//  SKSegmentedControl.m
//
//  Created by Raheel Ahmad on 11/6/11.
//  Copyright (c) 2011 Sakun Labs. All rights reserved.
//

#import "SKSegmentedControl.h"
#import "SSLineView.h"

#define skSmallFontSize 20
#define skLargeFontSize 20

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

#pragma mark - Event handlers

- (void) selectAtIndex: (int) newIndex {
	float w = self.frame.size.width / [itemLabels count];
	float h = self.frame.size.height;
	
	// if proper newIndex, make it selected
	if (newIndex >= 0 && newIndex < [itemLabels count]) {
		CATextLayer *newSelectedLayer = [itemLabels objectAtIndex:newIndex];
		CGSize stringSize = [self sizeForString:newSelectedLayer.string];
		float txtHeight = stringSize.height;
		CGRect newFrame = CGRectMake(newIndex * w, h/2 - txtHeight/2, w, txtHeight);
		
		// set up line view if not available
		CGRect lineViewFrame = CGRectMake(newIndex * w + w/2 - stringSize.width/2, h/2 + txtHeight/2 + 4, stringSize.width, 6);
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
			newSelectedLayer.font = ctLargeFont;
			newSelectedLayer.foregroundColor = [UIColor blackColor].CGColor;
			[self addShadowToLayer:newSelectedLayer];
			newSelectedLayer.fontSize = skLargeFontSize;
			
			self.selectionLineView.frame = lineViewFrame;
		} completion:^(BOOL finished) {
			
		}];
		
		// if there was a previous selectedIndex, let's make it unselected
		if (newIndex != selectedIndex && selectedIndex >= 0 && selectedIndex < [itemLabels count]) {
			CATextLayer *oldSelectedLayer = [itemLabels objectAtIndex:selectedIndex];
			oldSelectedLayer.font = ctSmallFont;
			oldSelectedLayer.fontSize = skSmallFontSize;
			oldSelectedLayer.foregroundColor = [UIColor darkGrayColor].CGColor;
			[self removeShadowFromLayer:oldSelectedLayer];
		}
		selectedIndex = newIndex;
	}
}

#pragma mark - Helpers

- (UIImageView *) separatorAt: (int) xPosition {
	UIImageView *imgVw = nil;
	if (separatorType == SKSegItemSeparatorTypeBullet) {
		imgVw = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bulletSeparator.png"]];
		float h = self.frame.size.height;
		imgVw.frame = CGRectMake(xPosition - 2, h/2 - 2, 4, 4);
	}
	else if (separatorType == SKSegItemSeparatorTypeLine) {
		imgVw = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lineSeparator.png"]];
		float h = self.frame.size.height;
		imgVw.frame = CGRectMake(xPosition - 1, h/2 - h/6, 2, h/3);
	}
	
	return imgVw;
}

- (void) addShadowToLayer: (CALayer *) aLayer {
	aLayer.shadowColor = [UIColor colorWithWhite:0.2f alpha:0.5f].CGColor;
	aLayer.shadowOffset = CGSizeMake(0, 1);
	aLayer.shadowOpacity = 1.0f;
	aLayer.shadowRadius = 1.0f;
}

- (void) removeShadowFromLayer: (CALayer *) aLayer {
	aLayer.shadowOpacity = 0.0f;
	aLayer.shadowOffset = CGSizeMake(0.0f, 0.0f);
}


// always returns size considering the big font size
- (CGSize) sizeForString:(NSString *) aString {
	float w = self.frame.size.width;
	float h = self.frame.size.height;
	return [aString sizeWithFont:largeFont constrainedToSize:CGSizeMake(w, h)];
}

#pragma mark - UIView

- (id) initWithFrame:(CGRect)frame andItems: (NSArray *) itms {
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		self.separatorType = SKSegItemSeparatorTypeLine;
		self.itemLabels = [NSMutableArray arrayWithCapacity:[itms count]];
		self.separators = [NSMutableArray arrayWithCapacity:[itms count]-1];
		float w = frame.size.width / [itms count];
		float h = frame.size.height;
		self.ctSmallFont = CTFontCreateWithName((__bridge CFStringRef) @"HelveticaNeue-Bold", skSmallFontSize, NULL);
		self.ctLargeFont = CTFontCreateWithName((__bridge CFStringRef) @"HelveticaNeue-Bold", skLargeFontSize, NULL);
		self.smallFont = [UIFont boldSystemFontOfSize:skSmallFontSize];
		self.largeFont = [UIFont boldSystemFontOfSize:skLargeFontSize];
		for (int i=0; i < [itms count]; i++) {
			NSString *anItem = [itms objectAtIndex:i];
			CATextLayer *alayer = [[CATextLayer alloc] init];
			alayer.backgroundColor = [UIColor clearColor].CGColor;
			[alayer setString:anItem];
			[alayer setForegroundColor:[UIColor darkGrayColor].CGColor];
			[alayer setContentsScale:[[UIScreen mainScreen] scale]];
			[alayer setFont:ctSmallFont];
			[alayer setFontSize:skSmallFontSize];
			CGRect layerFrame;
			layerFrame.origin.x = w * i;
			layerFrame.size.width = w;
			float textHeight = [self sizeForString:anItem].height;
			layerFrame.origin.y = h/2 - textHeight/2;
			layerFrame.size.height = textHeight;
			[alayer setFrame:layerFrame];
			[alayer setAlignmentMode:kCAAlignmentCenter];
			[self removeShadowFromLayer:alayer];
			[[self layer] addSublayer:alayer];
			[itemLabels addObject:alayer];
			
			if (i < [itms count] - 1) {
				UIImageView *separator = [self separatorAt:(w * (i + 1))];
				[self addSubview:separator];
				[self.separators addObject:separator];
			}
		}
		
		[self selectAtIndex:0];
	}
	
	return self;
}

#pragma mark - UIControl

- (BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	return YES;
}

- (BOOL) continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	NSLog(@"continue tracking");
	[self sendActionsForControlEvents:UIControlEventValueChanged];
	return YES;
}

- (void) endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint pointAtUp = [touch locationInView:self];
	int indexAtUp = pointAtUp.x / (self.frame.size.width / [itemLabels count]);
	[self selectAtIndex:indexAtUp];
}

@end