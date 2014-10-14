//
//  RegisterOnRomiboWebViewController.m
//  romiboController_7
//
//  Created by Daniel Brown on 10/6/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "RegisterOnRomiboWebViewController.h"
#import "RomibowebAPIManager.h"
#import "UserAccountsManager.h"


@interface RegisterOnRomiboWebViewController ()

@property (strong, nonatomic) IBOutlet UIButton *registrationButton;

@property (strong, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UILabel *connectionStatusLabel;
@property (strong, nonatomic) IBOutlet UILabel *guideMessageLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (strong, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (strong, nonatomic) IBOutlet UILabel *passwordsDoNotMatchLabel;
@property (strong, nonatomic) IBOutlet UIView *textFieldsContainerView;

@end

@implementation RegisterOnRomiboWebViewController


- (void)viewDidLoad {
  [super viewDidLoad];
  [self.firstNameTextField becomeFirstResponder];
  [self.spinner stopAnimating];
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
- (IBAction)registerButtonClicked:(id)sender
{

  //hide some widgets
  [self.spinner startAnimating];
  self.connectionStatusLabel.hidden = NO;
  [self.textFieldsContainerView setHidden:YES];
  [(UIButton *)sender setHidden:YES];
  [self.cancelButton setHidden:YES];
  [self.guideMessageLabel setHidden:YES];
  [self registerAsRomiboWebManagerObserver];
  
  //connect to RomiboWeb and attempt to log in
  RomibowebAPIManager *apiManager = [RomibowebAPIManager sharedRomibowebManagerInstance];
  [apiManager  registerNewUserAtRomiboWeb:self.firstNameTextField.text
                                 lastName:self.lastNameTextField.text
                                    email:self.emailAddressTextField.text
                                 password:self.passwordTextField.text
                    password_confirmation:self.confirmPasswordTextField.text ];
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
               forKeyPath:@"registrationObservable"
                  options:(NSKeyValueObservingOptionNew)
                  context:NULL];
  
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  if ([keyPath isEqual:@"registrationObservable"]) {
    [self handleRegistrationTaskCompletion];
  }
}

-(void)handleRegistrationTaskCompletion
{
  RomibowebAPIManager *apiManager = [RomibowebAPIManager sharedRomibowebManagerInstance];
  
  if (apiManager.responseCode == 201){//success: loging succeeded
    dispatch_async(dispatch_get_main_queue(), ^{
      self.connectionStatusLabel.textColor = [UIColor colorWithRed:0.2/255.0f green:102.0f/255.0f blue:51.0f/255.0f alpha:1.0];
      NSString *name = [[UserAccountsManager sharedUserAccountManagerInstance] getCurrentUserName];
      NSString *successMessage = [NSString stringWithFormat: @"Successfully registered on RomiboWeb as %@.", name];
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
        failureMessage = @"Failed to register to RomiboWeb. Invalid email/password combination.";
      } else {
        failureMessage = @"Failed to log in to RomiboWeb. Please try again.";
      }
      self.connectionStatusLabel.text = failureMessage;
      if ([self.spinner isAnimating]) {
        [self.spinner stopAnimating];
      }
      
      [self.registrationButton setHidden:NO];
      [self.cancelButton setHidden:NO];
      [self.guideMessageLabel setHidden:NO];
      [self.textFieldsContainerView setHidden:NO];
    });
  
  }
  
  //stop observing
  [apiManager removeObserver:self forKeyPath:@"registrationObservable"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  NSLog(@"got here");
  //
  [self.passwordsDoNotMatchLabel setHidden:YES];

  if (textField == self.firstNameTextField){
    NSLog(@"first name");
    [self.lastNameTextField becomeFirstResponder];
  } else if (textField == self.lastNameTextField){
    [self.emailAddressTextField becomeFirstResponder];
  } else if (textField == self.emailAddressTextField){
    [self.passwordTextField becomeFirstResponder];
  } else if (textField == self.passwordTextField){
    [self.confirmPasswordTextField becomeFirstResponder];
  } else {
    NSLog(@"confirmation");
    if ([self passwordAndPasswordConfirmationMatch]) {
      [textField resignFirstResponder];
      [self.registrationButton becomeFirstResponder];
    } else {
      [self.passwordsDoNotMatchLabel setHidden:NO];
      [self.passwordTextField becomeFirstResponder];
    }

  }
  
  return YES;
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  if (textField == self.confirmPasswordTextField){
    if ([self passwordAndPasswordConfirmationMatch]) {
      [self.passwordsDoNotMatchLabel setHidden:YES];
    } else {
      [self.passwordsDoNotMatchLabel setHidden:NO];
    }
  }
  return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
  if (textField == self.confirmPasswordTextField){
    if ([self passwordAndPasswordConfirmationMatch]) {
      [self.passwordsDoNotMatchLabel setHidden:YES];
    } else {
      [self.passwordsDoNotMatchLabel setHidden:NO];
    }
  }
  return YES;
}

-(BOOL)passwordAndPasswordConfirmationMatch
{
  return [self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text];
}
@end
