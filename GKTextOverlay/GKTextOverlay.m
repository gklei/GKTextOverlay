//
//  GKTextOverlay.m
//  GKTextOverlay
//
//  Created by Gregory Klein on 9/9/14.
//  Copyright (c) 2014 HardFlip. All rights reserved.
//

#import "GKTextOverlay.h"
#import "FlatPillButton.h"

typedef NS_ENUM(NSUInteger, GKTextOverlayState)
{
   GKTextOverlayStateDefault,
   GKTextOverlayStateDisplay,
};

@interface GKTextOverlay ()

@property (nonatomic) UIView* topMostSuperview;
@property (nonatomic) UITextView* textView;

@property (nonatomic) UIViewController* parentController;

@property (nonatomic) CALayer* dimLayer;
@property (nonatomic) FlatPillButton* doneButton;

@property (nonatomic) NSString* headerText;
@property (nonatomic) NSString* bodyText;
@property (nonatomic) GKTextOverlayState state;

@end

@implementation GKTextOverlay

#pragma mark - Init
- (instancetype)initWithHeaderText:(NSString*)headerText bodyText:(NSString*)bodyText parentController:(UIViewController*)parentController
{
   if (self = [super init])
   {
      self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];

      self.headerText = headerText;
      self.bodyText = bodyText;
      self.parentController = parentController;

      [self setupTextView];
      [self setupDimLayer];
      [self setupDoneButton];
   }
   return self;
}

+ (instancetype)overlayWithHeaderText:(NSString*)headerText bodyText:(NSString*)bodyText parentController:(UIViewController*)parentController
{
   return [[GKTextOverlay alloc] initWithHeaderText:headerText bodyText:bodyText parentController:parentController];
}

#pragma mark - Setup
- (void)setupTextView
{
   self.textView = [[UITextView alloc] init];
   [self.textView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
   self.textView.backgroundColor = [UIColor redColor];
   self.textView.textColor = [UIColor whiteColor];
   self.textView.showsVerticalScrollIndicator = NO;
   self.textView.editable = NO;
   self.textView.selectable = NO;
   self.textView.text = self.bodyText;
}

- (void)setupDimLayer
{
   self.dimLayer = [CALayer layer];
   self.dimLayer.frame = [UIScreen mainScreen].bounds;
   self.dimLayer.opacity = .9;
   self.dimLayer.backgroundColor = [UIColor blackColor].CGColor;
   self.dimLayer.actions = @{@"frame" : [NSNull null], @"bounds" : [NSNull null], @"position" : [NSNull null]};
}

- (void)setupDoneButton
{
   self.doneButton = [FlatPillButton button];
   [self.doneButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];

   CGSize doneButtonSize = {60, 30};
   CGFloat padding = 5;
   self.doneButton.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - doneButtonSize.width - padding,
                                      CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + padding,
                                      60.0,
                                      30.0);

   UIFont* font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
   NSAttributedString* attrString = [[NSAttributedString alloc] initWithString:@"Done" attributes:@{NSFontAttributeName : font,
                                                                                                    NSForegroundColorAttributeName : [UIColor whiteColor]}];
   [self.doneButton setAttributedTitle:attrString forState:UIControlStateNormal];
   [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

#pragma mark - Property Overrides
- (UIView*)topMostSuperview
{
   UIView* superview = self.parentController.view.superview;
   while (true)
   {
      if (superview.superview == nil)
      {
         return superview;
      }
      superview = superview.superview;
   }
}

- (void)setState:(GKTextOverlayState)state
{
   if (_state != state)
   {
      _state = state;
      [self animateWithState:state];
   }
}

#pragma mark - Private
- (void)updateDoneButtonWithState:(GKTextOverlayState)state
{
   if (state == GKTextOverlayStateDisplay)
   {
      [self.topMostSuperview addSubview:self.doneButton];
   }
   else
   {
      [self.doneButton removeFromSuperview];
   }
}

- (void)setParentNavigationBarsHidden:(BOOL)hidden
{
   UIViewController* parentViewController = self.parentController;
   while (parentViewController != nil)
   {
      parentViewController.navigationController.navigationBarHidden = hidden;
      parentViewController = parentViewController.parentViewController;
   }
}

- (void)animateWithState:(GKTextOverlayState)state
{
   switch (state)
   {
      case GKTextOverlayStateDefault:
         [self dismissTextOverlay];
         break;

      case GKTextOverlayStateDisplay:
         [self presentTextOverlay];
         break;

      default:
         break;
   }
}

- (void)presentTextOverlay
{
   [self.topMostSuperview addSubview:self.doneButton];
   [self.topMostSuperview.layer insertSublayer:self.dimLayer below:self.doneButton.layer];
   [self setParentNavigationBarsHidden:YES];
}

- (void)dismissTextOverlay
{
   [self.doneButton removeFromSuperview];
   [self.dimLayer removeFromSuperlayer];
   [self setParentNavigationBarsHidden:NO];
}

- (void)dismiss:(FlatPillButton*)sender
{
   self.state = GKTextOverlayStateDefault;
}

#pragma mark - Public
- (void)present
{
   self.state = GKTextOverlayStateDisplay;
}

@end
