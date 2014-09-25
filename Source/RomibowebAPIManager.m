//
//  RomibowebIntegrationManager.m
//  romiboController_7
//
//  Created by Daniel Brown on 9/22/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "RomibowebAPIManager.h"
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
  request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
  request.HTTPMethod = httpMethod;
  NSURLSessionDataTask *postDataTask = [self.URLsession dataTaskWithRequest:request
                                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                        {
                                          [self processResponseData:data];
                                        }];
  [postDataTask resume];
}

-(void)processResponseData:(NSData *)responseData
{
  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
  NSLog(@"Login data as json: %@", json);
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
  // Create the request.
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]];
  
  // Create url connection and fire request
  NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)getUsersListFromRomiboWeb
{
  _currentRequestType = PalettesListRequest;
  // Create the request.
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]];
  
  // Create url connection and fire request
  NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
  NSLog(@"NSURLSessionDataDelegate didReceiveData");
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
  NSLog(@"NSURLSessionDataDelegate didReceiveResponse");
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
  NSLog(@"NSURLSessionDataDelegate willCacheResponse");
}

@end
