//
//  SKHelpViewerVC.m
//
//  Created by Raheel Ahmad on 11/4/11.
//  Copyright (c) 2011 Sakun Labs. All rights reserved.
//

#import "SKHelpViewerVC.h"

// private labels

@interface SKHelpViewerVC ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIWebView *messageView;
@property (nonatomic, strong) UIView *labelsView; // used for the two labels
@property (nonatomic, strong) UIView *transparentView; // used to dim the background (parentVC's view)

@end

@implementation SKHelpViewerVC

@synthesize parentVC;
@synthesize heightRatioOfParent;
@synthesize messageTitle;
@synthesize helpMessage;
@synthesize titleLabel;
@synthesize messageView;
@synthesize labelsView;
@synthesize transparentView;
@synthesize showing;

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

#pragma mark - Basics

- (id)initWithParentVC: (UIViewController *) prntVC message:(NSString *)msg andTitle:(NSString *)ttl
{
    self = [super init];
    if (self) {
		parentVC = prntVC;
		messageTitle = ttl;
		helpMessage = msg;
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
	viewFrame = self.parentVC.view.frame;
	self.view = [[UIView alloc] initWithFrame:viewFrame];
	self.view.backgroundColor = [UIColor clearColor];
	
	
	// setup the backingView. This will be where the labels are added and will only take part of the full view's height
	if (self.heightRatioOfParent <= 0) {
		// if a 0.45 height ratio gives us managable height, let's use that
		float proposedHeight = viewFrame.size.height * 0.45f;
		if (proposedHeight >= 80)
			self.heightRatioOfParent = 0.45f;
		else {
			self.heightRatioOfParent = viewFrame.size.height / 80;
		}
	}
	
	self.transparentView = [[UIView alloc] initWithFrame:viewFrame];
	self.transparentView.backgroundColor = [UIColor darkGrayColor];
	self.transparentView.alpha = 0.0f;
	[transparentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)]];
	[self.view addSubview:self.transparentView];
	
	float h = self.parentVC.view.bounds.size.height * self.heightRatioOfParent;
	labelsViewFrame = CGRectMake(0, viewFrame.size.height - h, viewFrame.size.width, h);
	hiddenLabelsViewFrame = CGRectOffset(labelsViewFrame, 0, labelsViewFrame.size.height);
	self.labelsView = [[UIView alloc] initWithFrame:hiddenLabelsViewFrame];
	self.labelsView.layer.borderColor = [UIColor darkGrayColor].CGColor;
	self.labelsView.layer.borderWidth = 1.0f;
	self.labelsView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"helpBackground.png"]];
	[self.view addSubview:self.labelsView];
	
	float xBuffer = labelsViewFrame.size.width/8;
	float yBuffer = 10;
	if (xBuffer > 10)
		xBuffer = 10;
	CGRect titleRect = CGRectMake(xBuffer, yBuffer, labelsViewFrame.size.width - 2 * xBuffer, 20);
	CGRect messageRect = CGRectMake(xBuffer, 20 + yBuffer, labelsViewFrame.size.width - 2 * xBuffer, labelsViewFrame.size.height - 20 - yBuffer);
	self.titleLabel = [[UILabel alloc] initWithFrame:titleRect];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:18.0f];
	titleLabel.text = messageTitle;
	[self.labelsView addSubview:titleLabel];
	
	self.messageView = [[UIWebView alloc] initWithFrame:messageRect];
	messageView.opaque = NO;
	messageView.backgroundColor = [UIColor clearColor];
	// get rid of web view's "shadow" when scrolling; just an image view...
    for (UIView* subView in [messageView subviews]) {
        if ([subView isKindOfClass:[UIScrollView class]]) {
            for (UIView* shadowView in [subView subviews])
                if ([shadowView isKindOfClass:[UIImageView class]])
                    [shadowView setHidden:YES];
        }
	}
	NSString *messageHTMLString = [NSString stringWithFormat:@"<body style='background-color:transparent'><span style='font-family: Cochin; font-size: 13pt'> %@ </span></body>", helpMessage];
	[messageView loadHTMLString:messageHTMLString baseURL:nil];
	[self.labelsView addSubview:messageView];
	
	self.showing = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	self.labelsView = nil;
	self.transparentView = nil;
	self.titleLabel = nil;
	self.messageView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
