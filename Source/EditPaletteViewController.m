//
//  EditPaletteViewController.m
//  romiboController_7
//
//  Created by Daniel Brown on 10/2/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "EditPaletteViewController.h"
#import "UserPalettesManager.h"

@interface EditPaletteViewController ()

@property (strong, nonatomic) IBOutlet UITextField *titleTextfield;
@property (weak, nonatomic) UserPalettesManager *palettesManager;
@property (strong, nonatomic)Palette *currentPalette;
@end

@implementation EditPaletteViewController

- (void)viewDidLoad {
  [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.palettesManager = [UserPalettesManager sharedPalettesManagerInstance];
  int last_viewed_palette_id = [self.palettesManager lastViewedPalette];
  self.currentPalette = [self.palettesManager getSelectedPalette:last_viewed_palette_id];
  self.titleTextfield.text = self.currentPalette.title;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)saveButtonClicked:(id)sender
{
  NSLog(@"changed text = %@", self.titleTextfield.text);
  [self.palettesManager updateEditedPalette:self.titleTextfield.text withId:self.currentPalette.index];
  [self performSegueWithIdentifier:@"ReturnToMain" sender:sender];
}

@end
