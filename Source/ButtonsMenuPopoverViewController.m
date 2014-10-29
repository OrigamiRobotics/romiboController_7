//
//  ButtonMenusPopoverViewControlle.m
//  romiboController_7
//
//  Created by Daniel Brown on 10/4/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "ButtonsMenuPopoverViewController.h"
#import "MenuSelectionsController.h"
#import "UIColor+GSAdditions.h"

@interface ButtonsMenuPopoverViewController ()

@property (strong, nonatomic)NSArray* menuItems;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic)MenuSelectionsController *genericController;

@end

@implementation ButtonsMenuPopoverViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.menuItems = @[@"New", @"Edit"];
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.genericController = [MenuSelectionsController sharedGenericControllerInstance];
}

- (void)didReceiveMemoryWarning
{
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

#pragma mark - ButtonColor TableView Data Source and Delegates methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"buttonColorsTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    //  NSString* keyStr = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    //
    //  [self.buttonColorRowsAndNames setObject:[self.buttonColorNames objectAtIndex:indexPath.row] forKey:keyStr];
    //  NSString *name = [self.buttonColorRowsAndNames objectForKey:keyStr];
    //  cell.textLabel.text = name;
    //
    //  NSString * buttonColor = [self.palettesManager getButtonColor:self.selectButtonId forPalette:self.selectedPaletteId];
    //
    //  NSString * buttonColorName = [self.availableButtonColors nameForHexValue:buttonColor];
    UIColor *textColor = [UIColor colorWithHexString:@"#3498db"];
    //
    //  cell.backgroundColor = [UIColor whiteColor];
    //  cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = textColor;
    //
    //  UIView *bgColorView = [[UIView alloc] init];
    //  bgColorView.backgroundColor = uiColor;
    //  [cell setSelectedBackgroundView:bgColorView];
    //  cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    //
    //  if ([name isEqualToString:buttonColorName]){
    //    [tableView
    //     selectRowAtIndexPath:indexPath
    //     animated:TRUE
    //     scrollPosition:UITableViewScrollPositionNone
    //     ];
    //  }
    cell.textLabel.text = [self.menuItems objectAtIndex:indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuItems count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self.genericController setSelectedButtonMenuItem:cell.textLabel.text];
        [self dismissViewControllerAnimated:YES completion:^{
            [self.genericController setSelectedButtonMenuItem:@""];
        }];
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //[cell setBackgroundColor:[UIColor colorWithPatternImage:pattern]];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Buttons Menu";
}



@end
