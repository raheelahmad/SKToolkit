//
//  SKHelpViewerVC.h
//  Off Road
//
//  Created by Raheel Ahmad on 11/4/11.
//  Copyright (c) 2011 Sakun Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SKHelpViewerVC : UIViewController {
	CGRect viewFrame;
	CGRect labelsViewFrame;
	CGRect hiddenLabelsViewFrame;
	CGRect titleRect;
	CGRect messageRect;
	float heightRatio;
}

@property (nonatomic, weak) UIViewController *parentVC;
@property (nonatomic, strong) NSString *messageTitle;
@property (nonatomic, strong) NSString *helpMessage;
@property (nonatomic, strong) UIFont *messageFont;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic) float heightRatioOfParent;
@property (nonatomic) BOOL showing;

- (id)initWithParentVC: (UIViewController *) prntVC message:(NSString *)msg andTitle:(NSString *)ttl;
- (void) hide;
- (void) show;

@end
