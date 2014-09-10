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

   self.textOverlay = [GKTextOverlay overlayWithHeaderText:@"Header" bodyText:@"this is some body text" parentController:self];
}

- (IBAction)displayText:(id)sender
{
   [self.textOverlay present];
}

@end
