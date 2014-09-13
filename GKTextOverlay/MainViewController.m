//
//  ViewController.m
//  GKTextOverlay
//
//  Created by Gregory Klein on 9/9/14.
//  Copyright (c) 2014 HardFlip. All rights reserved.
//

#import "MainViewController.h"
#import "GKTextOverlay.h"

@interface MainViewController ()

@property (nonatomic) GKTextOverlay* textOverlay;

@end

@implementation MainViewController

- (void)viewDidLoad
{
   [super viewDidLoad];

   NSString* headerText = @"Barber Polling";
   NSString* bodyText = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.";
   self.textOverlay = [GKTextOverlay overlayWithHeaderText:headerText bodyText:bodyText parentController:self];
}

- (IBAction)displayText:(id)sender
{
   [self.textOverlay present];
}

@end
