//
//  EditButtonViewController.m
//  romiboController_7
//
//  Created by Daniel Brown on 10/3/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "EditButtonViewController.h"
#import "UserPalettesManager.h"


@interface EditButtonViewController ()

@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UITextField *buttonTitleTextfield;
@property (strong, nonatomic) IBOutlet UISlider *buttonSpeechRateSlider;
@property (strong, nonatomic) IBOutlet UILabel *buttonSpeechRateLabel;
@property (strong, nonatomic) IBOutlet UIButton *buttonColorSelectorButton;
@property (strong, nonatomic) IBOutlet UILabel *selectedButtonColorLabel;
@property (strong, nonatomic) IBOutlet UITextView *buttonSpeechPhraseTextview;
@property (copy, nonatomic)NSString* selectedColorHexValue;

@property (strong, nonatomic)NSDictionary* editedButtonValues;
@end

@implementation EditButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
  self.editedButtonValues = [self makeButtonDataDictionary];
}

- (IBAction)buttonTitleTextfieldChanged:(id)sender
{
}

-(NSDictionary*)makeButtonDataDictionary
{
  return @{ @"title":self.buttonTitleTextfield.text,
       @"speechRate":self.buttonSpeechRateLabel.text,
            @"color":self.selectedColorHexValue,
     @"speechPhrase":self.buttonSpeechPhraseTextview.text
        };
}

@end
