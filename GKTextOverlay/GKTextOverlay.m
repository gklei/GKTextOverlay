//
//  GKTextOverlay.m
//  GKTextOverlay
//
//  Created by Gregory Klein on 9/9/14.
//  Copyright (c) 2014 HardFlip. All rights reserved.
//

#import "GKTextOverlay.h"
#import "FlatPillButton.h"
#import "UIImage+ImageEffects.h"

typedef NS_ENUM(NSUInteger, GKTextOverlayState)
{
   GKTextOverlayStateDefault,
   GKTextOverlayStateDisplay,
};

@interface GKTextOverlay ()

@property (nonatomic) UIView* topMostSuperview;

@property (nonatomic) UILabel* headerLabel;
@property (nonatomic) UITextView* bodyTextView;
@property (nonatomic) UIImageView* imageView;

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

      _headerText = headerText;

      _bodyFontSize = 20;
      _bodyText = bodyText;

      self.parentController = parentController;

      [self setupTextView];
      [self setupDimLayer];
      [self setupDoneButton];
      [self setupHeaderLabel];
   }
   return self;
}

+ (instancetype)overlayWithHeaderText:(NSString*)headerText bodyText:(NSString*)bodyText parentController:(UIViewController*)parentController
{
   return [[GKTextOverlay alloc] initWithHeaderText:headerText bodyText:bodyText parentController:parentController];
}

#pragma mark - Setup
- (void)setupHeaderLabel
{
   CGFloat widthOfButtonAndPadding = CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetMinX(self.doneButton.frame);
   CGFloat headerWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - widthOfButtonAndPadding*2 - 8;
   CGFloat headerHeight = CGRectGetMaxY(self.doneButton.frame) - CGRectGetMinY(self.doneButton.frame);
   CGFloat headerXPosition = CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetMinX(self.doneButton.frame);
   CGFloat headerYPosition = CGRectGetMinY(self.doneButton.frame);

   self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(headerXPosition, headerYPosition, headerWidth, headerHeight)];
   self.headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:24];
   self.headerLabel.textColor = [UIColor whiteColor];
   self.headerLabel.textAlignment = NSTextAlignmentCenter;
   self.headerLabel.text = self.headerText;

   [self sizeLabel:self.headerLabel toRect:self.headerLabel.frame];
}

- (void)setupTextView
{
   self.bodyTextView = [[UITextView alloc] init];
   [self.bodyTextView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:self.bodyFontSize]];
   self.bodyTextView.backgroundColor = [UIColor clearColor];
   self.bodyTextView.textColor = [UIColor whiteColor];
   self.bodyTextView.showsVerticalScrollIndicator = YES;
   self.bodyTextView.editable = NO;
   self.bodyTextView.selectable = NO;
   self.bodyTextView.text = self.bodyText;
   self.bodyTextView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
}

- (void)setupDimLayer
{
   self.dimLayer = [CALayer layer];
   self.dimLayer.frame = [UIScreen mainScreen].bounds;
   self.dimLayer.actions = @{@"frame" : [NSNull null], @"bounds" : [NSNull null], @"position" : [NSNull null]};
   self.dimLayer.opacity = 0;
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

- (void)setHeaderText:(NSString *)headerText
{
   if (_headerText != headerText)
   {
      _headerText = headerText;
      self.headerLabel.text = _headerText;
   }
}

- (void)setBodyText:(NSString *)bodyText
{
   if (_bodyText != bodyText)
   {
      _bodyText = bodyText;
      self.bodyTextView.text = _bodyText;
   }
}

- (void)setImage:(UIImage *)image
{
   if (image != nil)
   {
      self.imageView = [[UIImageView alloc] initWithImage:image];
   }
   else
   {
      self.imageView = nil;
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
   UIViewController* parentViewController = self.parentController.parentViewController;
   while (parentViewController != nil)
   {
      parentViewController.navigationController.navigationBarHidden = hidden;
      parentViewController = parentViewController.parentViewController;
   }
}

- (void)animateWithState:(GKTextOverlayState)state
{
   [[UIApplication sharedApplication] setStatusBarStyle: (state != GKTextOverlayStateDisplay) ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent];
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
   UIView* topMostSuperview = self.topMostSuperview;
   [topMostSuperview addSubview:self.doneButton];
   [topMostSuperview addSubview:self.bodyTextView];
   [topMostSuperview addSubview:self.headerLabel];

   [topMostSuperview.layer addSublayer:self.dimLayer];
   UIImage* blurredBackground = [self blurredSnapshot];

   self.dimLayer.contents = (id)blurredBackground.CGImage;

   CGFloat padding = 10;
   if (self.imageView)
   {
      [topMostSuperview addSubview:self.imageView];
      self.imageView.frame = CGRectMake(0, CGRectGetMaxY(self.doneButton.frame) + padding, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)*.5);
   }

   [self setParentNavigationBarsHidden:YES];

   self.headerLabel.layer.zPosition = 100;
   self.doneButton.layer.zPosition = 100;
   self.bodyTextView.layer.zPosition = 100;

   CGFloat textViewYPosition = CGRectGetMaxY(self.doneButton.frame) + padding + CGRectGetHeight(self.imageView.frame);
   CGFloat textViewHeight = self.imageView ? CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetMaxY(self.imageView.frame) - padding : CGRectGetHeight([UIScreen mainScreen].bounds) - textViewYPosition - padding;

   self.bodyTextView.frame = CGRectMake(0, textViewYPosition, CGRectGetWidth([UIScreen mainScreen].bounds), textViewHeight);

   self.dimLayer.opacity = 1;
}

- (void)dismissTextOverlay
{
   self.dimLayer.opacity = 0;
   [self.headerLabel removeFromSuperview];
   [self.bodyTextView removeFromSuperview];
   [self.imageView removeFromSuperview];
   [self.doneButton removeFromSuperview];
   [self.dimLayer removeFromSuperlayer];
   [self setParentNavigationBarsHidden:NO];
}

- (void)dismiss:(FlatPillButton*)sender
{
   self.state = GKTextOverlayStateDefault;
}

- (void)sizeLabel:(UILabel*)label toRect:(CGRect)labelRect
{
   // Set the frame of the label to the targeted rectangle
   label.frame = labelRect;

   // Try all font sizes from largest to smallest font size
   int fontSize = 300;
   int minFontSize = 5;

   // Fit label width wize
   CGSize constraintSize = CGSizeMake(label.frame.size.width, MAXFLOAT);

   do {
      // Set current font size
      label.font = [UIFont fontWithName:label.font.fontName size:fontSize];

      // Find label size for current font size
      CGRect textRect = [[label text] boundingRectWithSize:constraintSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:label.font}
                                                   context:nil];

      CGSize labelSize = textRect.size;

      // Done, if created label is within target size
      CGFloat labelWidth = [label.text sizeWithAttributes:@{NSFontAttributeName : label.font}].width;
      if (labelSize.height <= CGRectGetHeight(label.frame) && labelWidth <= CGRectGetWidth(label.frame))
      {
         break;
      }

      // Decrease the font size and try again
      fontSize -= 2;

   } while (fontSize > minFontSize);
}

- (UIImage *)blurredSnapshot
{
   UIView* topMostSuperview = self.topMostSuperview;
   UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth(topMostSuperview.frame),
                                                     CGRectGetHeight(topMostSuperview.frame)),
                                          NO, 1.0f);
   [topMostSuperview drawViewHierarchyInRect:CGRectMake(0, 0, CGRectGetWidth(topMostSuperview.frame), CGRectGetHeight(topMostSuperview.frame)) afterScreenUpdates:NO];
   UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();

   // Now apply the blur effect using Apple's UIImageEffect category
   UIImage *blurredSnapshotImage = [snapshotImage applyDarkEffect];
   // Or apply any other effects available in "UIImage+ImageEffects.h"
   // UIImage *blurredSnapshotImage = [snapshotImage applyDarkEffect];
   // UIImage *blurredSnapshotImage = [snapshotImage applyExtraLightEffect];

   UIGraphicsEndImageContext();

   return blurredSnapshotImage;
}

#pragma mark - Public
- (void)present
{
   self.state = GKTextOverlayStateDisplay;
}

@end
