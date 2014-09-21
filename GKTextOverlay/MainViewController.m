//
//  ViewController.m
//  GKTextOverlay
//
//  Created by Gregory Klein on 9/9/14.
//  Copyright (c) 2014 HardFlip. All rights reserved.
//

#import "MainViewController.h"
#import "GKTextOverlay.h"
#import "UIImage+ImageEffects.h"

@interface MainViewController ()

@property (weak) IBOutlet UIImageView* backgroundImageView;
@property (nonatomic) GKTextOverlay* textOverlay;

@end

@implementation MainViewController

- (void)viewDidLoad
{
   [super viewDidLoad];
   self.backgroundImageView.image = [[UIImage imageNamed:@"Silos"] applyLightEffect];

   NSString* headerText = @"Barber Polling";
   NSString* bodyText = @"Edge quality in stretch film is very important.  The edge should appear even and round when viewed on end.  Rolls that are either “feathered”, or rough cut can cause film to tear at the edge of the web or roll as in the case of “barber polling”.  Poor edge quality can result from dull slitting blades, bad resin blending, or poor winding.  All Sigma machine film rolls are packaged on a hexacomb sheet that has been engineered with crumple zones to protect the roll edges.  Additionally, the rolls are packaged in polyethylene bags to prevent abrasion.  This protective packaging can create an imprint on the edge surface however it does not affect the films performance.";

   self.textOverlay = [GKTextOverlay overlayWithHeaderText:headerText bodyText:bodyText parentController:self];
   [self.textOverlay makeSubstring:@"imprint on the edge surface" hyperlinkToDisplayImage:[UIImage imageNamed:@"Silos"]];
}

- (IBAction)displayText:(id)sender
{
   [self.textOverlay present];
}

@end
