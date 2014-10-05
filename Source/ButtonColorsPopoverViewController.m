//
//  ButtonColorsPopoverViewController.m
//  romiboController_7
//
//  Created by Daniel Brown on 9/28/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "ButtonColorsPopoverViewController.h"
#import "PaletteButtonColors.h"
#import "UserPalettesManager.h"

@interface ButtonColorsPopoverViewController ()

@property (nonatomic, weak)PaletteButtonColors* availableButtonColors;
@property (nonatomic, strong)NSMutableArray* buttonColorNames;
@property (nonatomic, strong)NSMutableDictionary* buttonColorRowsAndNames;
@property (weak, nonatomic) UserPalettesManager *palettesManager;
@property (assign, nonatomic)int selectButtonId;
@property (assign, nonatomic) int selectedPaletteId;

@end

@implementation ButtonColorsPopoverViewController
- (void)viewDidLoad {
  [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.palettesManager = [UserPalettesManager sharedPalettesManagerInstance];
  self.selectedPaletteId = [self.palettesManager lastViewedPalette];
  self.selectButtonId = [self.palettesManager getLastViewedButtonIdFor:self.selectedPaletteId];
  [self setupAvailableColors];
  self.selectedButtonColorFromPopoverRow = -1;
  self.buttonColorsListing.tableFooterView = [[UIView alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupAvailableColors
{
  self.availableButtonColors = [PaletteButtonColors sharedColorsManagerInstance];
  //TODO: Thisis temporary until we can get a list of colors from RomiboWeb
  [self.availableButtonColors usePredefinedAvailableColors];
  self.buttonColorNames = [[NSMutableArray alloc] initWithArray:[self.availableButtonColors buttonColorNames]];
  self.buttonColorRowsAndNames = [[NSMutableDictionary alloc] init];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - ButtonColor TableView Data Source and Delegates methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString * cellIdentifier = @"buttonColorsTableViewCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  
  if (cell == nil){
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
  }
  
  NSString* keyStr = [NSString stringWithFormat:@"%ld", (long)indexPath.row];

  [self.buttonColorRowsAndNames setObject:[self.buttonColorNames objectAtIndex:indexPath.row] forKey:keyStr];
  NSString *name = [self.buttonColorRowsAndNames objectForKey:keyStr];
  cell.textLabel.text = name;
  
  NSString * buttonColor = [self.palettesManager getButtonColor:self.selectButtonId forPalette:self.selectedPaletteId];

  NSString * buttonColorName = [self.availableButtonColors nameForHexValue:buttonColor];
  UIColor *uiColor = [self colorFromHexString:[self.availableButtonColors hexValueForName:name]];
  
  cell.backgroundColor = [UIColor whiteColor];
  cell.textLabel.backgroundColor = [UIColor clearColor];
  cell.textLabel.textColor = uiColor;

  UIView *bgColorView = [[UIView alloc] init];
  bgColorView.backgroundColor = uiColor;
  [cell setSelectedBackgroundView:bgColorView];
  cell.textLabel.highlightedTextColor = [UIColor whiteColor];

  if ([name isEqualToString:buttonColorName]){
    [tableView
     selectRowAtIndexPath:indexPath
     animated:TRUE
     scrollPosition:UITableViewScrollPositionNone
     ];
  }
  
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [[[self.availableButtonColors buttonColors] allKeys] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  dispatch_async(dispatch_get_main_queue(), ^{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.availableButtonColors.selectedColorSelectorPopoverCellValue = cell.textLabel.text;
  });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 40.0;
}

//- (void)highlightLastViewedPaletteCellInTable
//{
//  int lastViewedPalette = [[UserPalettesManager sharedPalettesManagerInstance] lastViewedPalette];
//  
//  NSUInteger row = 0;
//  for (id key in self.myPaletteIds){
//    NSNumber *paletteId = [self.myPaletteIds objectForKey:key];
//    if ([paletteId intValue] == lastViewedPalette){
//      row = [key longValue];
//      break;
//    }
//  }
//  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
//  [self.palettesListingTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:
//   UITableViewScrollPositionNone];
//  
//  
//  [self.palettesListingTableView.delegate tableView:self.palettesListingTableView didSelectRowAtIndexPath:indexPath];
//}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  //[cell setBackgroundColor:[UIColor colorWithPatternImage:pattern]];
}

- (UIColor *) colorFromHexString:(NSString *)hexString
{
  //NSString *stringColor = [NSString stringWithFormat:@"#%@", hexString];
  // NSLog(@"converted hex value = %@", stringColor);
  NSUInteger red, green, blue;
  sscanf([hexString UTF8String], "#%2lX%2lX%2lX", &red, &green, &blue);
  
  return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
  
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return @"Select Color";
}

@end
