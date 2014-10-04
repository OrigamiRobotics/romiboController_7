//
//  CreateOrEditButtonViewController.m
//  romiboController_7
//
//  Created by Daniel Brown on 10/3/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "CreateOrEditButtonViewController.h"
#import "UserPalettesManager.h"
#import "PaletteButtonColors.h"


@interface CreateOrEditButtonViewController ()

@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UITextField *buttonTitleTextfield;
@property (strong, nonatomic) IBOutlet UISlider *buttonSpeechRateSlider;
@property (strong, nonatomic) IBOutlet UILabel *buttonSpeechRateLabel;
@property (strong, nonatomic) IBOutlet UIButton *buttonColorSelectorButton;
@property (strong, nonatomic) IBOutlet UILabel *selectedButtonColorLabel;
@property (strong, nonatomic) IBOutlet UITextView *buttonSpeechPhraseTextview;
@property (copy, nonatomic)NSString* selectedColorName;
@property (weak, nonatomic) UserPalettesManager *palettesManager;
@property (strong, nonatomic)NSDictionary* editedButtonValues;
@property (assign, nonatomic)int selectButtonId;
@property (assign, nonatomic) int selectedPaletteId;

@end

@implementation CreateOrEditButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.palettesManager = [UserPalettesManager sharedPalettesManagerInstance];
  self.selectedPaletteId = [self.palettesManager lastViewedPalette];
  self.selectButtonId = [self.palettesManager getLastViewedButtonIdFor:self.selectedPaletteId];
  [self prepopulateFieldsWithSelectedButton];
  self.selectedColorName = [[PaletteButtonColors sharedColorsManagerInstance] nameForHexValue:[self.palettesManager getButtonColor:self.selectButtonId forPalette:self.selectedPaletteId]];

  [self registerAsColorSelectorPopoverObserver];
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
  [self.palettesManager updateButton:self.selectButtonId
                            withData:[self makeButtonDataDictionary]
                          forPalette:self.selectedPaletteId];
  [self performSegueWithIdentifier:@"ReturnToMain" sender:sender];
}

- (IBAction)sliderMoved:(id)sender
{
  self.buttonSpeechRateLabel.text = [NSString stringWithFormat:@"%.1f", self.buttonSpeechRateSlider.value];
}

- (IBAction)buttonTitleTextfieldChanged2:(UITextField *)sender
{
}

- (void)textViewDidChange:(UITextView *)textView
{
  NSLog(@"textViewDidChange:");
}

-(NSDictionary*)makeButtonDataDictionary
{
  return @{ @"title":self.buttonTitleTextfield.text,
       @"speechRate":self.buttonSpeechRateLabel.text,
            @"color":[[PaletteButtonColors sharedColorsManagerInstance] hexValueForName:self.selectedColorName],
     @"speechPhrase":self.buttonSpeechPhraseTextview.text
        };
}

-(void) prepopulateFieldsWithSelectedButton
{
  self.buttonTitleTextfield.text = [self.palettesManager getButtonTitle:self.selectButtonId forPalette:self.selectedPaletteId];
      float speechRate = [self.palettesManager getButtonSpeechSpeedRate:self.selectButtonId forPalette:self.selectedPaletteId];
  self.buttonSpeechRateSlider.value = speechRate;
  self.buttonSpeechPhraseTextview.text = [self.palettesManager getButtonSpeechPhrase:self.selectButtonId forPalette:self.selectedPaletteId];
  self.buttonSpeechRateLabel.text = [NSString stringWithFormat:@"%0.1f", speechRate];
    NSString * buttonColor = [self.palettesManager getButtonColor:self.selectButtonId forPalette:self.selectedPaletteId];
  [self setColorFieldValues:buttonColor];
}

- (UIColor *) colorFromHexString:(NSString *)hexString
{
  NSString *stringColor = [NSString stringWithFormat:@"%@", hexString];
  NSUInteger red, green, blue;
  sscanf([stringColor UTF8String], "#%2lX%2lX%2lX", &red, &green, &blue);
  
  return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
  
}

-(void)setColorFieldValues:(NSString*)buttonColor
{
  UIColor *uiColor = [self colorFromHexString:buttonColor];
  
  self.selectedButtonColorLabel.backgroundColor = uiColor;
  self.selectedButtonColorLabel.text = @"";
  [self.buttonColorSelectorButton setTitle:[[PaletteButtonColors sharedColorsManagerInstance] nameForHexValue:buttonColor] forState:UIControlStateNormal];
}

- (IBAction)colorSelectorClicked:(id)sender
{
  NSLog(@"clicked");
}

#pragma mark - Olor Selector PopupViewController related
- (void)observeValueForKeyPath:(NSString *)keyPath

                      ofObject:(id)object

                        change:(NSDictionary *)change

                       context:(void *)context
{
  if ([keyPath isEqual:@"selectedColorSelectorPopoverCellValue"]) {
    self.selectedColorName = [(PaletteButtonColors*)object selectedColorSelectorPopoverCellValue];
    NSString *buttonColorHexValue = [[PaletteButtonColors sharedColorsManagerInstance] hexValueForName:self.selectedColorName];
    [self setColorFieldValues:buttonColorHexValue];
  }
}

- (void)registerAsColorSelectorPopoverObserver
{
  [[PaletteButtonColors sharedColorsManagerInstance] addObserver:self
   
                                                      forKeyPath:@"selectedColorSelectorPopoverCellValue"
   
                                                         options:(NSKeyValueObservingOptionNew)
   
                                                         context:NULL];
  
}

@end
