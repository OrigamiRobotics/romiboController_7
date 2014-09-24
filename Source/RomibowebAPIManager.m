//
//  RomibowebIntegrationManager.m
//  romiboController_7
//
//  Created by Daniel Brown on 9/22/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "RomibowebAPIManager.h"
//const NSString * kRomiboWebURL          = @"http://create.romibo.com";
const NSString * kRomiboWebURL   = @"http://romiboweb-integration.herokuapp.com";
const NSString * kHttpPostMethod = @"POST";
const NSString * kHttpGetMethod  = @"GET";
const NSString * kHttpPutMethod  = @"PUT";

const NSString * kRomiboWebURL_login    = @"/api/v1/login";
const NSString * kRomiboWebURL_palettes = @"/api/v1/palettes";



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

#pragma mark RomiboWeb API calls
- (void)connectToRomiboWebApi:(NSString*)httpMethod forUrl:(NSString*)requestUrl withParams:(NSString *)params
{
  NSString * connectionUrl = [kRomiboWebURL stringByAppendingString:(NSString*)requestUrl];
  
  NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
  sessionConfiguration.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json"};
  
  self.URLsession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
  
  NSURL *url = [NSURL URLWithString:connectionUrl];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
  request.HTTPMethod = httpMethod;
  NSURLSessionDataTask *postDataTask = [self.URLsession dataTaskWithRequest:request
                                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                        {
                                          NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                          //                                              NSLog(@"Login data as json: %@", json);
                                          
                                          NSString * tokenStr     = @"Token token=";
                                          NSString * jsonTokenStr = [json objectForKey:@"auth_token"];
                                          self.authTokenStr = [tokenStr stringByAppendingString:jsonTokenStr];
                                          
                                          NSLog(@"jsonTokenStr: %@", jsonTokenStr);
                                          NSLog(@"authTokenStr: %@", self.authTokenStr);
                                        }];
  [postDataTask resume];
}

-(void)registerNewUserAtRomiboWeb
{
  NSString* loginUrl = @"/api/v1/login";
  NSString* loginParams = @"{\"user\": {\"email\":\"tracy_lakin@earthlink.net\",\"password\":\"tracyromibo\"}}";
  NSString* loginHtpMethod = @"POST";
}

-(void)loginToRomiboWeb
{
  _currentRequestType = LoginRequest;
  NSString* loginUrl = @"/api/v1/login";
  NSString* loginParams = @"{\"user\": {\"email\":\"tracy_lakin@earthlink.net\",\"password\":\"tracyromibo\"}}";
  [self connectToRomiboWebApi:kHttpPostMethod forUrl:loginUrl withParams:loginParams];
}

-(void)getUserPalettesFromRomiboWeb
{
  _currentRequestType = UsersListRequest;
  // Create the request.
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]];
  
  // Create url connection and fire request
  NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  // A response has been received, this is where we initialize the instance var you created
  // so that we can append data to it in the didReceiveData method
  // Furthermore, this method is called each time there is a redirect so reinitializing it
  // also serves to clear it
  _responseData = [[NSMutableData alloc] init];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  // Append the new data to the instance variable you declared
  [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
  // Return nil to indicate not necessary to store a cached response for this connection
  return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  // The request is complete and data has been received
  // You can parse the stuff in your instance variable now
  
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  // The request has failed for some reason!
  // Check the error var
}
@end
