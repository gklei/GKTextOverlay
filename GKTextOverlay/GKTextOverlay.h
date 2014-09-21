//
//  GKTextOverlay.h
//  GKTextOverlay
//
//  Created by Gregory Klein on 9/9/14.
//  Copyright (c) 2014 HardFlip. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GKTextOverlay : UIViewController

// defautls to 20
@property (nonatomic) CGFloat bodyFontSize;

// Defaults to Helvetica Neue
@property (nonatomic) CGFloat textFont;

@property (nonatomic) BOOL hidesParentNavigationBarsOnZoom;

+ (instancetype)overlayWithHeaderText:(NSString*)headerText
                             bodyText:(NSString*)bodyText
                     parentController:(UIViewController*)parentController;

// Will do nothing if the stubstring is not found, if more than one is found, it will use the first occurance.
// Currently only supports one hyperlink in body text
- (void)makeSubstring:(NSString*)substring hyperlinkToDisplayImage:(UIImage*)image;
- (void)makeSubstring:(NSString *)substring hyperlinkToPlayVideoWithURL:(NSURL*)url;

- (void)present;

@end
