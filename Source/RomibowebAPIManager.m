//
//  RomibowebIntegrationManager.m
//  romiboController_7
//
//  Created by Daniel Brown on 9/22/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "RomibowebAPIManager.h"
#import "User.h"
#import "UserPalettesManager.h"
//const NSString * kRomiboWebURI          = @"http://create.romibo.com";
const NSString * kRomiboWebURI   = @"http://romiboweb-integration.herokuapp.com";
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
  NSString * authToken = [[User sharedUserInstance] token];
  if (_currentRequestType != LoginRequest && _currentRequestType != RegistrationRequest){
    [request setValue:authToken forHTTPHeaderField:@"Authorization"];
  }

  request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
  request.HTTPMethod = httpMethod;
  NSURLSessionDataTask *executeDataTask = [self.URLsession dataTaskWithRequest:request
                                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                        {
                                          [self processResponseData:data];
                                        }];
  [executeDataTask resume];
}

-(void)processResponseData:(NSData *)responseData
{
  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
  if (_currentRequestType == LoginRequest){
    [[User sharedUserInstance] fromDictionary:json];
  } else if (_currentRequestType == PalettesListRequest){
    [[UserPalettesManager sharedPalettesManagerInstance] processPalettesFromRomibowebAPI:json];
  }
}

-(void)registerNewUserAtRomiboWeb
{
 
}

-(void)loginToRomiboWeb
{
  _currentRequestType = LoginRequest;
  NSString* loginUrl = @"/api/v1/login";
  NSString* loginParams = @"{\"user\": {\"email\":\"danny@origamirobotics.com\",\"password\":\"nartey\"}}";
  [self connectToRomiboWebApi:HttpPostMethod forUrl:loginUrl withParams:loginParams];
}

-(void)getUserPalettesFromRomiboWeb
{
  _currentRequestType = PalettesListRequest;
  NSString* loginUrl = @"/api/v1/palettes";
  NSString* requestParams = @"";
  [self connectToRomiboWebApi:HttpGetMethod forUrl:loginUrl withParams:requestParams];
}

-(void)getUsersListFromRomiboWeb
{

}


@end
