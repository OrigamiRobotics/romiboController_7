//
//  LoginToRomiboWebViewController.m
//  romiboController_7
//
//  Created by Daniel Brown on 9/29/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "LoginToRomiboWebViewController.h"
#import "RomibowebAPIManager.h"
#import "User.h"


@interface LoginToRomiboWebViewController ()

@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UILabel *connectionStatusLabel;
@property (strong, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) IBOutlet UILabel *guideMessageLabel;

- (IBAction)loginButtonClicked:(id)sender;

@end

@implementation LoginToRomiboWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  [self.spinner stopAnimating];
  self.passwordTextField.secureTextEntry = YES;
  [[User sharedUserInstance] loadData];

  self.emailAddressTextField.text = [[User sharedUserInstance] email];
  [self.emailAddressTextField setDelegate:self];
  [self.passwordTextField setDelegate:self];
  [self.passwordTextField becomeFirstResponder];
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

//[[RomibowebAPIManager sharedRomibowebManagerInstance] loginToRomiboWeb];

- (IBAction)loginButtonClicked:(id)sender
{
  //hide some widgets
  [self.spinner startAnimating];
  self.connectionStatusLabel.hidden = NO;
  [self.emailAddressTextField setHidden:YES];
  [self.passwordTextField setHidden:YES];
  [(UIButton *)sender setHidden:YES];
  [self.cancelButton setHidden:YES];
  [self.guideMessageLabel setHidden:YES];
  [self registerAsRomiboWebManagerObserver];
  
  //connect to RomiboWeb and attempt to log in
  RomibowebAPIManager *apiManager = [RomibowebAPIManager sharedRomibowebManagerInstance];
  [apiManager loginToRomiboWeb:self.emailAddressTextField.text andPassword:self.passwordTextField.text];
}

- (void)registerAsRomiboWebManagerObserver
{
  
  /*
   
   Register 'self' to receive change notifications for the "loginObservable" property of
   
   the 'RomibowebAPIManager' object and specify that new values of "loginObservable"
   
   should be provided in the observe… method.
   We are using this so that we get notified when the login to
   RomiboWeb task is completed
   */
  
  RomibowebAPIManager *apiManager = [RomibowebAPIManager sharedRomibowebManagerInstance];
  [apiManager addObserver:self
               forKeyPath:@"loginObservable"
                  options:(NSKeyValueObservingOptionNew)
                  context:NULL];
  
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  if ([keyPath isEqual:@"loginObservable"]) {
    [self handleLoginTaskCompletion];
  }
}

-(void)handleLoginTaskCompletion
{
  RomibowebAPIManager *apiManager = [RomibowebAPIManager sharedRomibowebManagerInstance];
  
  if (apiManager.responseCode == 201){//success: loging succeeded
    dispatch_async(dispatch_get_main_queue(), ^{
      self.connectionStatusLabel.textColor = [UIColor colorWithRed:0.2/255.0f green:102.0f/255.0f blue:51.0f/255.0f alpha:1.0];
      NSString *name = [[User sharedUserInstance] name];
      NSString *successMessage = [NSString stringWithFormat: @"Successfully logged in to RomiboWeb as %@.", name];
      self.connectionStatusLabel.text = successMessage;
      if ([self.spinner isAnimating]) {
        [self.spinner stopAnimating];
      }
      
      [self.okButton setHidden:NO];
    });
  } else {//failure: login failed
    dispatch_async(dispatch_get_main_queue(), ^{
      self.connectionStatusLabel.textColor = [UIColor redColor];
      NSString *failureMessage = @"";
      NSLog(@"status = %@", apiManager.responseStatus);
      if ([apiManager.responseStatus isEqualToString:@"401 Unauthorized"]){
        failureMessage = @"Failed to log in to RomiboWeb. Invalid email/password combination.";
      } else {
        failureMessage = @"Failed to log in to RomiboWeb. Please try again.";
      }
      self.connectionStatusLabel.text = failureMessage;
      if ([self.spinner isAnimating]) {
        [self.spinner stopAnimating];
      }
      
      [self.loginButton setHidden:NO];
      [self.cancelButton setHidden:NO];
      [self.guideMessageLabel setHidden:NO];
      [self.emailAddressTextField setHidden:NO];
      [self.passwordTextField setHidden:NO];

    });

  }
  
  //stop observing
  [apiManager removeObserver:self forKeyPath:@"loginObservable"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  
  return YES;
}

@end
