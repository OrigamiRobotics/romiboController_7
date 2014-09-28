//
//  buttonSizePickerViewController.h
//  romiboController_7
//
//  Created by Tracy Lakin on 5/13/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MainViewController.h"

@interface buttonSizePickerViewController : UIViewController

@property (strong, nonatomic) MainViewController * mainViewController;


- (IBAction)smallAction:(id)sender;
- (IBAction)mediumAction:(id)sender;
- (IBAction)largeAction:(id)sender;

@end
