//
//  colorPickerViewController.m
//  romiboController_7
//
//  Created by Tracy Lakin on 5/13/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "colorPickerViewController.h"
#import "UIColor+RMBOColors.h"

@interface colorPickerViewController ()

@end

@implementation colorPickerViewController

const NSInteger kColorButtonSize    = 50.0;     // Square, so Width and Height
const NSInteger kColorButtonSpacing = 4.0;

const NSInteger kMaxColorRows = 6;
const NSInteger kMaxColorColumns = 4;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSArray * colors = [UIColor rmbo_sortedColorPallet];
    
    NSInteger viewWidth   = kColorButtonSpacing + (kMaxColorColumns * (kColorButtonSize + kColorButtonSpacing));
    NSInteger viewWHeight = kColorButtonSpacing + (kMaxColorRows    * (kColorButtonSize + kColorButtonSpacing));

    CGRect viewFrame = self.view.frame;
    viewFrame.size.height = viewWHeight;
    viewFrame.size.width  = viewWidth;
    self.view.frame = viewFrame;

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        for (NSInteger row = 0; row < kMaxColorRows; row++)
        {
            for (NSInteger column = 0; column < kMaxColorColumns; column++)
            {
                NSInteger x = kColorButtonSpacing + (column * (kColorButtonSize + kColorButtonSpacing));
                NSInteger y = kColorButtonSpacing + (row    * (kColorButtonSize + kColorButtonSpacing));
                
                UIButton * colorButton = [UIButton buttonWithType:UIButtonTypeCustom];
                
                UIColor * buttonColor = colors[(row * kMaxColorColumns) + column];
                [colorButton setBackgroundColor:buttonColor];

                CGRect buttonFrame = CGRectMake(x, y, kColorButtonSize, kColorButtonSize);
                colorButton.frame = buttonFrame;
                
                [colorButton addTarget:self action:@selector(colorButtonAction:) forControlEvents:UIControlEventTouchUpInside];

                [self.view addSubview:colorButton];
            }
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction) colorButtonAction:(id)sender
{
    UIButton * tappedButton = (UIButton *)sender;
    UIColor * color = tappedButton.backgroundColor;
    NSLog(@"colorButtonAction color: %@", color);
    
    [self.mainViewController setEditButtonColor:color];
}



@end
