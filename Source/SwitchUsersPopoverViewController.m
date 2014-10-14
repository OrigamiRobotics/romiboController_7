//
//  SwitchUsersPopoverViewController.m
//  romiboController_7
//
//  Created by Daniel Brown on 10/9/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "SwitchUsersPopoverViewController.h"
#import "MenuSelectionsController.h"
#import "UserAccountsManager.h"

@interface SwitchUsersPopoverViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic)MenuSelectionsController *menuSelectorController;
@property (strong, nonatomic) NSArray *localUsers;

@end

@implementation SwitchUsersPopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.localUsers = [[UserAccountsManager sharedUserAccountManagerInstance] nonCurrentLocalUserNamesAndEmails];
  // This will remove extra separators from tableview
  self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
  
  self.menuSelectorController = [MenuSelectionsController sharedGenericControllerInstance];

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

#pragma mark - ButtonColor TableView Data Source and Delegates methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString * cellIdentifier = @"switchUsersTableViewCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  
  if (cell == nil){
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
  }
  
  UIColor *textColor = [self colorFromHexString:@"#3498db"];

  cell.textLabel.textColor = textColor;
  cell.textLabel.font = [UIFont systemFontOfSize:14];

  NSArray *userInfo = [[self.localUsers objectAtIndex:indexPath.row] componentsSeparatedByString:@"---+++---"];
  cell.textLabel.text = userInfo[0];
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.localUsers count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  dispatch_async(dispatch_get_main_queue(), ^{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self dismissViewControllerAnimated:YES completion:^{
      [self.menuSelectorController setSelectedNewUser:[self extractSelectedUserEmail:indexPath]];
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
  return @"Select a User";
}


-(NSString*)extractSelectedUserEmail:(NSIndexPath *)indexPath
{
  NSString *selection = [self.localUsers objectAtIndex:indexPath.row];
  NSArray *strArray = [selection componentsSeparatedByString:@"---+++---"];
  return strArray[1];
}
@end
