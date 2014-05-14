//
//  buttonSizePickerViewController.m
//  romiboController_7
//
//  Created by Tracy Lakin on 5/13/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "buttonSizePickerViewController.h"

@interface buttonSizePickerViewController ()

@end

@implementation buttonSizePickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)smallAction:(id)sender
{
    NSLog(@"smallAction");
    [self.mainViewController setEditButtonSize:@"Small"];
}

- (IBAction)mediumAction:(id)sender
{
    NSLog(@"mediumAction");
    [self.mainViewController setEditButtonSize:@"Medium"];
}

- (IBAction)largeAction:(id)sender
{
    NSLog(@"largeAction");
    [self.mainViewController setEditButtonSize:@"Large"];
}

@end
