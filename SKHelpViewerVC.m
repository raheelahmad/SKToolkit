//
//  SKHelpViewerVC.m
//
//  Created by Raheel Ahmad on 11/4/11.
//  Copyright (c) 2011 Sakun Labs. All rights reserved.
//

#import "SKHelpViewerVC.h"

// private labels

@interface SKHelpViewerVC ()

@property (nonatomic, strong) UIWebView *messageWebView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *labelsView; // used for the two labels
@property (nonatomic, strong) UIView *transparentView; // used to dim the background (parentVC's view)

- (void) setupViewFrames;

@end

@implementation SKHelpViewerVC

@synthesize parentVC;
@synthesize heightRatioOfParent;
@synthesize messageTitle;
@synthesize helpMessage;
@synthesize titleLabel;
@synthesize messageWebView;
@synthesize labelsView;
@synthesize transparentView;
@synthesize showing;
@synthesize messageFont;
@synthesize titleFont;
@synthesize backgroundColor;

#pragma mark - Event handlers

- (void) show {
	self.labelsView.frame = hiddenLabelsViewFrame;
	self.transparentView.alpha = 0.0f;
	
	if (!self.view.superview) {
		[self.parentVC.view addSubview:self.view];
	}
	
	[UIView animateWithDuration:0.3f animations:^{
		self.transparentView.alpha = 0.5f;
		self.labelsView.frame = labelsViewFrame;
	} completion:^(BOOL finished) {
		self.showing = YES;
	}];	
}

- (void) hide {
	[UIView animateWithDuration:0.3f animations:^{
		self.labelsView.frame = hiddenLabelsViewFrame;
		self.transparentView.alpha = 0.0f;
	} completion:^(BOOL finished) {
		[self.view removeFromSuperview];
		self.showing = NO;
	}];
}

#pragma mark - Helpers

- (void) setupViewFrames {
	float h = self.parentVC.view.bounds.size.height * heightRatio;
	labelsViewFrame = CGRectMake(0, viewFrame.size.height - h, viewFrame.size.width, h);
	
	hiddenLabelsViewFrame = CGRectOffset(labelsViewFrame, 0, labelsViewFrame.size.height);
	
	float xBuffer = labelsViewFrame.size.width/8;
	float yBuffer = 10;
	if (xBuffer > 10)
		xBuffer = 10;
	
	titleRect = CGRectMake(xBuffer, yBuffer, labelsViewFrame.size.width - 2 * xBuffer, 20);
	messageRect = CGRectMake(xBuffer, 20 + yBuffer, labelsViewFrame.size.width - 2 * xBuffer, labelsViewFrame.size.height - 20 - yBuffer);
	
	self.labelsView.frame = hiddenLabelsViewFrame;
	self.messageWebView.frame = messageRect;
	self.titleLabel.frame = titleRect;
}

#pragma mark - Setters

- (void) setBackgroundColor:(UIColor *) newColor {
	self.labelsView.backgroundColor = newColor;
}

- (void) setHeightRatioOfParent:(float) newRatio {
	// setup the backingView. This will be where the labels are added and will only take part of the full view's height
	if (newRatio <= 0)
		newRatio = 0.65;
	
	// if a 0.55 height ratio gives us managable height, let's use that
	float proposedHeight = viewFrame.size.height * newRatio;
	if (proposedHeight >= 100)
		heightRatio = newRatio;
	else
		heightRatio = viewFrame.size.height / 80;
	
	[self setupViewFrames];
}

- (void) setMessageTitle:(NSString *) newTitle {
	messageTitle = newTitle;
	titleLabel.text = messageTitle;
}

- (void) setHelpMessage:(NSString *) newMessage {
	helpMessage = newMessage;
	NSString *messageHTMLString = [NSString stringWithFormat:@"<body style='background-color:transparent'><span style='font-family: %@; font-size: %f pt'> %@ </span></body>", self.messageFont.fontName, self.messageFont.pointSize, newMessage];
	[self.messageWebView loadHTMLString:messageHTMLString baseURL:nil];
}

- (void) setMessageFont:(UIFont *) newFont {
	messageFont = newFont;
	[self setHelpMessage:self.helpMessage]; // so as to refresh the font
}

- (void) setTitleFont:(UIFont *) newFont {
	titleFont = newFont;
	titleLabel.font = titleFont;
}

- (CGFloat) heightRatioOfParent {
	return heightRatio;
}

#pragma mark - Basics

- (id)initWithParentVC: (UIViewController *) prntVC message:(NSString *)msg andTitle:(NSString *)ttl
{
    self = [super init];
    if (self) {
		parentVC = prntVC;
		messageTitle = ttl;
		helpMessage = msg;

		// set some defaults
		viewFrame = parentVC.view.frame;
		heightRatio = 0.65;
		messageFont = [UIFont fontWithName:@"Cochin" size:13];
		titleFont = [UIFont fontWithName:@"GillSans-Bold" size:16];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)loadView
{
	
	self.view = [[UIView alloc] initWithFrame:viewFrame];
	self.view.backgroundColor = [UIColor clearColor];
	
	self.transparentView = [[UIView alloc] initWithFrame:viewFrame];
	self.transparentView.backgroundColor = [UIColor darkGrayColor];
	self.transparentView.alpha = 0.0f;
	[transparentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)]];
	[self.view addSubview:self.transparentView];
	
	self.labelsView = [[UIView alloc] initWithFrame:hiddenLabelsViewFrame];
	self.labelsView.layer.borderColor = [UIColor darkGrayColor].CGColor;
	self.labelsView.layer.borderWidth = 1.0f;
	self.labelsView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"helpBackground.png"]];
	[self.view addSubview:self.labelsView];
	
	self.messageWebView = [[UIWebView alloc] initWithFrame:messageRect];
	self.messageWebView.opaque = NO;
	self.messageWebView.backgroundColor = [UIColor clearColor];
	// get rid of web view's "shadow" when scrolling; just an image view...
    for (UIView* subView in [self.messageWebView subviews]) {
        if ([subView isKindOfClass:[UIScrollView class]]) {
            for (UIView* shadowView in [subView subviews])
                if ([shadowView isKindOfClass:[UIImageView class]])
                    [shadowView setHidden:YES];
        }
	}
	[self setHelpMessage:helpMessage];
	[self.labelsView addSubview:self.messageWebView];
	
	self.titleLabel = [[UILabel alloc] initWithFrame:titleRect];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = self.titleFont;
	titleLabel.text = messageTitle;
	[self.labelsView addSubview:titleLabel];
	
	self.showing = NO;
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	self.labelsView = nil;
	self.transparentView = nil;
	self.titleLabel = nil;
	self.messageWebView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
