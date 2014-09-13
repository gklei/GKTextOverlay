//
//  GKTextOverlay.h
//  GKTextOverlay
//
//  Created by Gregory Klein on 9/9/14.
//  Copyright (c) 2014 HardFlip. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GKTextOverlay : UIViewController

// defautls to 18
@property (nonatomic) CGFloat bodyFontSize;

// Defaults to Helvetica Neue
@property (nonatomic) CGFloat textFont;

@property (nonatomic) BOOL hidesParentNavigationBarsOnZoom;

+ (instancetype)overlayWithHeaderText:(NSString*)headerText
                             bodyText:(NSString*)bodyText
                     parentController:(UIViewController*)parentController;

- (void)present;

@end
