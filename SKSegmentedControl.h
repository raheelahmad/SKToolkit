//
//  SKSegmentedControl.h
//
//  Created by Raheel Ahmad on 11/6/11.
//  Copyright (c) 2011 Sakun Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

typedef enum {
	SKSegItemSeparatorTypeBullet = 0,
	SKSegItemSeparatorTypeLine
} SKSegItemSeparatorType;

@interface SKSegmentedControl : UIControl

@property (strong, nonatomic) NSArray *itemTitles;
@property (strong, nonatomic) NSMutableArray *itemLabels;
@property (nonatomic) int selectedIndex;
@property (nonatomic) SKSegItemSeparatorType separatorType;
@property (nonatomic) int inactiveFontSize;
@property (nonatomic) int activeFontSize;
@property (nonatomic, retain) UIColor *activeLabelColor;
@property (nonatomic, retain) UIColor *inactiveLabelColor;

- (id) initWithFrame:(CGRect)frame andItems: (NSArray *) itms;
- (void) selectAtIndex: (int) newIndex;

@end
