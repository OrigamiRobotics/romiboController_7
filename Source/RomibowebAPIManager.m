//
//  RomibowebIntegrationManager.m
//  romiboController_7
//
//  Created by Daniel Brown on 9/22/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "RomibowebAPIManager.h"
#import "UserAccountsManager.h"
#import "UserPalettesManager.h"
#import "PaletteButtonColorsManager.h"

//TESTTING
const NSString * kRomiboWebURI   = @"http://romiboweb-integration.herokuapp.com";
//END OF TESTING VARIABLES


//PRODUCTION
//const NSString * kRomiboWebURI          = @"http://create.romibo.com";
static NSString * HttpPostMethod = @"POST";
static NSString * HttpGetMethod  = @"GET";
static NSString * HttpPutMethod  = @"PUT";



@interface RomibowebAPIManager()
{
  NSMutableData *_responseData;
  RequestType   _currentRequestType;
}
@end

@implementation RomibowebAPIManager

static RomibowebAPIManager *sharedRomibowebManagerInstance = nil;


+(id)sharedRomibowebManagerInstance
{
  if (sharedRomibowebManagerInstance == nil){
    static dispatch_once_t predicate; //lock
    dispatch_once(&predicate, ^{
      sharedRomibowebManagerInstance = [[RomibowebAPIManager alloc] init];
    });
  }
  
  return sharedRomibowebManagerInstance;
}

-(instancetype)init
{
  if (self = [super init]){
    self.loginObservable = nil;
    self.fetchPalettesObservable = nil;
    self.fetchedPalettes = [[NSDictionary alloc] init];
    self.registrationObservable = nil;
  }
  
  return self;
}

#pragma mark RomiboWeb API calls
- (void)connectToRomiboWebApi:(NSString*)httpMethod forUrl:(NSString*)requestUrl withParams:(NSString *)params
{
  NSString * connectionUrl = [kRomiboWebURI stringByAppendingString:(NSString*)requestUrl];
  
  NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
  sessionConfiguration.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json"};
  
  self.URLsession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
  
  NSURL *url = [NSURL URLWithString:connectionUrl];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  NSString * authToken = [[UserAccountsManager sharedUserAccountManagerInstance] getCurrentUserToken];
  if (_currentRequestType != LoginRequest && _currentRequestType != RegistrationRequest){
    [request setValue:authToken forHTTPHeaderField:@"Authorization"];
  }

  request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
  request.HTTPMethod = httpMethod;
  
  
  NSURLSessionDataTask *executeDataTask = [self.URLsession dataTaskWithRequest:request
                                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                        {
                                        [self processResponse:response withData:data];
                                        }];
  [executeDataTask resume];
}

-(void)processResponse:(NSURLResponse*)response withData:(NSData *)responseData
{
  NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
  NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
  
  self.responseCode   = [HTTPResponse statusCode];
  self.responseStatus = [headers objectForKey:@"Status"];
  
//  NSLog(@"responde code returned = %ld", (long)self.responseCode);
  // NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];

  //NSLog(@"returned json = %@", json);

  if ((self.responseCode == 200) || (self.responseCode == 201)){//success
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    UserAccountsManager *userAccountsMgr = [UserAccountsManager sharedUserAccountManagerInstance];

    if (_currentRequestType == LoginRequest){
      [userAccountsMgr addUser:json];
      [userAccountsMgr logInCurrentUser];
    } else if (_currentRequestType == RegistrationRequest){
      [userAccountsMgr addUser:json];
    } else if (_currentRequestType == PalettesListRequest){
      self.fetchedPalettes = [[UserPalettesManager sharedPalettesManagerInstance] processPalettesFromRomibowebAPI:json];
    } else if (_currentRequestType == ColorsListRequest){
      [[PaletteButtonColorsManager sharedColorsManagerInstance]  processColorsFromRomibowebAPI:json];
    }
  }
  
  if (_currentRequestType ==  LoginRequest){
    self.loginObservable = @"complete";
  } else if (_currentRequestType == PalettesListRequest){
    self.fetchPalettesObservable = @"complete";
  } else if (_currentRequestType == RegistrationRequest){
    NSLog(@"registered successfully!");
    self.registrationObservable = @"complete";
  } else if (_currentRequestType == ColorsListRequest){
    NSLog(@"fetched colors successfully!");
    self.colorsObservable = @"complete";
  }
}

-(void)registerNewUserAtRomiboWeb:(NSString*)firstName
                         lastName:(NSString*)lastName
                            email:(NSString*)email
                         password:(NSString*)password
            password_confirmation:(NSString *)password_confirmation

{
  _currentRequestType = RegistrationRequest;
  NSString* registrationUrl = @"/api/v1/register";
  NSString* registrationParams = @"{\"user\": {\"first_name\":\"";
  registrationParams = [registrationParams stringByAppendingString:firstName];
  registrationParams = [registrationParams stringByAppendingString:@"\",\"last_name\":\""];
  registrationParams = [registrationParams stringByAppendingString:lastName];
  registrationParams = [registrationParams stringByAppendingString:@"\",\"email\":\""];
  registrationParams = [registrationParams stringByAppendingString:email];
  registrationParams = [registrationParams stringByAppendingString:@"\",\"password\":\""];
  registrationParams = [registrationParams stringByAppendingString:password];
  registrationParams = [registrationParams stringByAppendingString:@"\",\"password_confirmation\":\""];
  registrationParams = [registrationParams stringByAppendingString:password_confirmation];
  registrationParams = [registrationParams stringByAppendingString:@"\"}}"];
  
  [self connectToRomiboWebApi:HttpPostMethod forUrl:registrationUrl withParams:registrationParams];
}

-(void)loginToRomiboWeb:(NSString*)email andPassword:(NSString *)password
{
  _currentRequestType = LoginRequest;
  NSString* loginUrl = @"/api/v1/login";
  NSString* loginParams = @"{\"user\": {\"email\":\"";
  loginParams = [loginParams stringByAppendingString:email];
  loginParams = [loginParams stringByAppendingString:@"\",\"password\":\""];
  loginParams = [loginParams stringByAppendingString:password];
  loginParams = [loginParams stringByAppendingString:@"\"}}"];

  [self connectToRomiboWebApi:HttpPostMethod forUrl:loginUrl withParams:loginParams];
}

-(void)getUserPalettesFromRomiboWeb
{
  _currentRequestType = PalettesListRequest;
  NSString* requestUrl    = @"/api/v1/palettes";
  NSString* requestParams = @"";
  [self connectToRomiboWebApi:HttpGetMethod forUrl:requestUrl withParams:requestParams];
}

-(void)getUsersListFromRomiboWeb
{

}

-(void)syncPalettesWithRomiboWeb
{
  
}

-(void)deletePaletteFromRomiboWeb
{
  
}

-(void)getColorsListFromRomiboWeb
{
  _currentRequestType = ColorsListRequest;
  NSString* requestUrl    = @"/api/v1/button_colors";
  NSString* requestParams = @"";
  [self connectToRomiboWebApi:HttpGetMethod forUrl:requestUrl withParams:requestParams];
}

@end
