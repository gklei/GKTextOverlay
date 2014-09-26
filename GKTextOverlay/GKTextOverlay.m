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

@import MediaPlayer;

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

typedef NS_ENUM(NSUInteger, GKTextOverlayState)
{
   GKTextOverlayStateDefault,
   GKTextOverlayStateDisplay,
};

static NSString* const GKTextOverlayImageLink = @"GKTextOverlayImage";
static NSString* const GKTextOverlayVideoLink = @"GKTextOverlayVideo";

static NSAttributedString* _attributedLinkForImage(NSString* text, CGFloat textSize)
{
   NSURL* url = [NSURL URLWithString:GKTextOverlayImageLink];
   UIFont* font = [UIFont fontWithName:@"HelveticaNeue-Light" size:textSize];
   NSDictionary* attributes = @{NSLinkAttributeName : url, NSFontAttributeName : font,
                                NSUnderlineStyleAttributeName : @1};
   NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];

   return attributedString;
}

static NSAttributedString* _attributedLinkForVideo(NSString* text, CGFloat textSize)
{
   NSURL* url = [NSURL URLWithString:GKTextOverlayVideoLink];
   UIFont* font = [UIFont fontWithName:@"HelveticaNeue-Light" size:textSize];
   NSDictionary* attributes = @{NSLinkAttributeName : url,
                                NSFontAttributeName : font,
                                NSUnderlineStyleAttributeName : @1};
   NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];

   return attributedString;
}

@interface GKTextOverlay () <UITextViewDelegate>

@property (nonatomic) UIView* topMostSuperview;

@property (nonatomic) UILabel* headerLabel;
@property (nonatomic) UITextView* bodyTextView;
@property (nonatomic) UIImageView* imageView;

@property (nonatomic) UIViewController* parentController;

@property (nonatomic) CALayer* dimLayer;
@property (nonatomic) FlatPillButton* doneButton;
@property (nonatomic) FlatPillButton* resizeButton;

@property (nonatomic) NSString* headerText;
@property (nonatomic) NSString* bodyText;
@property (nonatomic) GKTextOverlayState state;

@property (nonatomic) BOOL textViewEnlarged;
@property (nonatomic) NSAttributedString* bodyTextViewAttributedText;

@property (nonatomic) UIImage* image;
@property (nonatomic) MPMoviePlayerViewController* moviePlayerViewController;

@property (nonatomic) CGRect expandedTextViewFrame;

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
      //      [self setupResizeButton];

      self.textViewEnlarged = YES;
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
   //   self.bodyTextView.backgroundColor = [UIColor colorWithRed:.45 green:0 blue:.8 alpha:.4];
   self.bodyTextView.backgroundColor = [UIColor clearColor];
   self.bodyTextView.textColor = [UIColor whiteColor];
   self.bodyTextView.showsVerticalScrollIndicator = YES;
   self.bodyTextView.editable = NO;
   self.bodyTextView.text = self.bodyText;
   //   self.bodyTextView.attributedText = self.bodyTextViewAttributedText;
   self.bodyTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 10, 0);
   self.bodyTextView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
   self.bodyTextView.linkTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:0 green:1 blue:1 alpha:1],
                                            NSUnderlineColorAttributeName : [UIColor colorWithRed:0 green:1 blue:1 alpha:1]};
}

- (void)setupDimLayer
{
   self.dimLayer = [CALayer layer];
   self.dimLayer.frame = [UIScreen mainScreen].bounds;
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
                                      doneButtonSize.width,
                                      doneButtonSize.height);

   UIFont* font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
   NSAttributedString* attrString = [[NSAttributedString alloc] initWithString:@"Done" attributes:@{NSFontAttributeName : font,
                                                                                                    NSForegroundColorAttributeName : [UIColor whiteColor]}];
   [self.doneButton setAttributedTitle:attrString forState:UIControlStateNormal];
   [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)setupResizeButton
{
   self.resizeButton = [FlatPillButton button];
   [self.resizeButton addTarget:self action:@selector(resizeTextView:) forControlEvents:UIControlEventTouchUpInside];

   CGSize resizeButtonSize = {70, 30};
   CGFloat padding = 5;
   self.resizeButton.frame = CGRectMake(padding,
                                        CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + padding,
                                        resizeButtonSize.width,
                                        resizeButtonSize.height);

   UIFont* font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
   NSAttributedString* attrString = [[NSAttributedString alloc] initWithString:@"Resize" attributes:@{NSFontAttributeName : font,
                                                                                                      NSForegroundColorAttributeName : [UIColor whiteColor]}];
   [self.resizeButton setAttributedTitle:attrString forState:UIControlStateNormal];
   [self.resizeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
   _image = image;
   if (image != nil)
   {
      CGFloat padding = 10;
      self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.doneButton.frame) + padding, CGRectGetWidth([UIScreen mainScreen].bounds), 0)];
      self.imageView.image = _image;
   }
   else
   {
      self.imageView = nil;
   }
}

#pragma mark - Private
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
   [topMostSuperview addSubview:self.resizeButton];
   [topMostSuperview addSubview:self.bodyTextView];
   [topMostSuperview addSubview:self.headerLabel];

   [topMostSuperview.layer addSublayer:self.dimLayer];
   UIImage* blurredBackground = [self blurredSnapshot];

   self.dimLayer.contents = (id)blurredBackground.CGImage;

   CGFloat padding = 10;
   [self setParentNavigationBarsHidden:YES];

   self.headerLabel.layer.zPosition = 100;
   self.doneButton.layer.zPosition = 100;
   self.resizeButton.layer.zPosition = 100;
   self.bodyTextView.layer.zPosition = 100;

   CGFloat textViewYPosition = CGRectGetMaxY(self.doneButton.frame) + padding*2 + CGRectGetHeight(self.imageView.frame);
   CGFloat textViewHeight = CGRectGetHeight([UIScreen mainScreen].bounds) - textViewYPosition;

   self.bodyTextView.frame = CGRectMake(0, textViewYPosition, CGRectGetWidth([UIScreen mainScreen].bounds), textViewHeight);
   self.expandedTextViewFrame = self.bodyTextView.frame;
}

- (void)dismissTextOverlay
{
   [self.headerLabel removeFromSuperview];
   [self.bodyTextView removeFromSuperview];
   [self.imageView removeFromSuperview];
   [self.doneButton removeFromSuperview];
   [self.resizeButton removeFromSuperview];
   [self.dimLayer removeFromSuperlayer];

   CGFloat padding = 10;
   CGRect imageViewCollapsedFrame = CGRectMake(0, CGRectGetMaxY(self.doneButton.frame) + padding, CGRectGetWidth([UIScreen mainScreen].bounds), 0);
   CGFloat textViewHeight = CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetMaxY(imageViewCollapsedFrame) - padding;
   self.bodyTextView.frame = CGRectMake(0, CGRectGetMaxY(imageViewCollapsedFrame), CGRectGetWidth([UIScreen mainScreen].bounds), textViewHeight);
   self.imageView.frame = imageViewCollapsedFrame;
   self.textViewEnlarged = YES;

   [self setParentNavigationBarsHidden:NO];
}

- (void)dismiss:(FlatPillButton*)sender
{
   self.state = GKTextOverlayStateDefault;
}

- (void)resizeTextView:(FlatPillButton*)sender
{
   if (self.imageView.image)
   {
      UIView* topMostSuperview = self.topMostSuperview;
      [topMostSuperview addSubview:self.imageView];

      CGFloat padding = 10;
      CGRect imageViewCollapsedFrame = CGRectMake(0, CGRectGetMaxY(self.doneButton.frame) + padding, CGRectGetWidth([UIScreen mainScreen].bounds), 0);
      CGRect imageViewExpandedFrame = CGRectMake(0, CGRectGetMaxY(self.doneButton.frame) + padding, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)*.5);

      if (self.textViewEnlarged)
      {
         [self.bodyTextView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
         self.imageView.frame = imageViewCollapsedFrame;
         [UIView animateWithDuration:.75
                               delay:0
              usingSpringWithDamping:.65
               initialSpringVelocity:1.5
                             options:UIViewAnimationOptionCurveEaseInOut
                          animations:^
         {
            CGFloat textViewHeight = CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetMaxY(imageViewExpandedFrame);
            self.bodyTextView.frame = CGRectMake(0, CGRectGetMaxY(imageViewExpandedFrame) + 5, CGRectGetWidth([UIScreen mainScreen].bounds), textViewHeight);
            self.imageView.frame = imageViewExpandedFrame;

            self.bodyTextView.attributedText = nil;
            self.bodyTextView.attributedText = self.bodyTextViewAttributedText;
          } completion:nil];
      }
      else
      {
         [UIView animateWithDuration:.3
                          animations:^
         {
            [self.bodyTextView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            self.bodyTextView.frame = self.expandedTextViewFrame;
            self.imageView.frame = imageViewCollapsedFrame;

            self.bodyTextView.attributedText = nil;
            self.bodyTextView.attributedText = self.bodyTextViewAttributedText;
          }];
      }
      self.textViewEnlarged = !self.textViewEnlarged;
   }
}

#pragma mark - Helpers
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

   UIGraphicsEndImageContext();

   return blurredSnapshotImage;
}

#pragma mark - Public
- (void)present
{
   self.state = GKTextOverlayStateDisplay;
}

- (void)makeSubstring:(NSString *)substring hyperlinkToDisplayImage:(UIImage *)image
{
   self.image = image;
   NSRange range = [self.bodyText rangeOfString:substring];

   if (range.length > 0)
   {
      NSString* firstSubstring = [self.bodyText substringWithRange:NSMakeRange(0, range.location)];
      NSString* secondSubstring = [self.bodyText substringFromIndex:(range.location + range.length)];

      UIFont* font = [UIFont fontWithName:@"HelveticaNeue-Light" size:self.bodyFontSize];
      NSDictionary* attributes = @{NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor whiteColor]};

      NSMutableAttributedString *attributedText = [NSMutableAttributedString new];
      [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:firstSubstring attributes:attributes]];
      [attributedText appendAttributedString:_attributedLinkForImage(substring, self.bodyFontSize)];
      [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:secondSubstring attributes:attributes]];

      self.bodyTextViewAttributedText = attributedText;
      self.bodyTextView.attributedText = attributedText;
      self.bodyTextView.delegate = self;
   }
}

- (void)makeSubstring:(NSString *)substring hyperlinkToPlayVideoWithURL:(NSURL *)url
{
   self.moviePlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
   NSRange range = [self.bodyText rangeOfString:substring];

   if (range.length > 0)
   {
      NSString* firstSubstring = [self.bodyText substringWithRange:NSMakeRange(0, range.location)];
      NSString* secondSubstring = [self.bodyText substringFromIndex:(range.location + range.length)];

      UIFont* font = [UIFont fontWithName:@"HelveticaNeue-Light" size:self.bodyFontSize];
      NSDictionary* attributes = @{NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor whiteColor]};

      NSMutableAttributedString *attributedText = [NSMutableAttributedString new];
      [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:firstSubstring attributes:attributes]];
      [attributedText appendAttributedString:_attributedLinkForVideo(substring, self.bodyFontSize)];
      [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:secondSubstring attributes:attributes]];

      self.bodyTextViewAttributedText = attributedText;
      self.bodyTextView.attributedText = attributedText;
      self.bodyTextView.delegate = self;
   }
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL*)URL inRange:(NSRange)characterRange
{
   if ([URL.path isEqualToString:GKTextOverlayImageLink])
   {
      [self resizeTextView:nil];
   }
   else if ([URL.path isEqualToString:GKTextOverlayVideoLink] && self.moviePlayerViewController)
   {
      [self dismiss:nil];
      [self.parentController presentMoviePlayerViewControllerAnimated:self.moviePlayerViewController];
      [self.moviePlayerViewController.moviePlayer play];
   }
   
   return NO;
}

@end
