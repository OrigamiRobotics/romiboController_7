//
//  NewPaletteViewController.m
//  romiboController_7
//
//  Created by Daniel Brown on 9/20/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "AddNewPaletteViewController.h"
#import "UserPalettesManager.h"
#import "rmbo_ViewController.h"

@interface AddNewPaletteViewController ()

@property (weak, nonatomic) IBOutlet UITextField *addPaletteTitle;
@property (weak, nonatomic) IBOutlet UIButton *addPaletteButton;

@end

@implementation AddNewPaletteViewController

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
  self.addPaletteButton.hidden = YES;
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createPaletteButtonPressed:(id)sender
{
  NSLog(@"create button pressed: %@", self.addPaletteTitle.text);
  [[UserPalettesManager sharedPalettesManagerInstance] createPalette:self.addPaletteTitle.text];
  
  //back to main view
  [self performSegueWithIdentifier:@"backToMain" sender:self];
}

- (IBAction)paletteTitleChanged:(id)sender
{
  NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
  if ([[self.addPaletteTitle.text stringByTrimmingCharactersInSet: set] length] == 0){
    self.addPaletteButton.hidden = YES;
  } else {
    self.addPaletteButton.hidden = NO;
  }
  
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
