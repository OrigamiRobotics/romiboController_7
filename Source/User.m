//
//  User.m
//  romiboController_7
//
//  Created by Daniel Brown on 9/21/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "User.h"
#define USER_STORAGE_KEY @"romibo_user"

@implementation User

static User *sharedUserInstance = nil;

+(id)sharedUserInstance
{
  if (sharedUserInstance == nil){
    static dispatch_once_t predicate; //lock
    dispatch_once(&predicate, ^{
      sharedUserInstance = [[User alloc] init];
    });
  }
  
  return sharedUserInstance;
}

-(id)init
{
  if (self = [super init]){
    self.token      = @"";
    self.user_id    = 0;
    self.first_name = @"";
    self.last_name  = @"";
  }
  return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
  [encoder encodeInteger:self.user_id   forKey:@"user_id"];
  [encoder encodeObject:self.first_name forKey:@"firstName"];
  [encoder encodeObject:self.last_name  forKey:@"lastName"];
  [encoder encodeObject:self.token      forKey:@"token"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
  if (self = [super init]){
    self.user_id    = [decoder decodeIntForKey:@"user_id"];
    self.first_name = [decoder decodeObjectForKey:@"firstName"];
    self.last_name  = [decoder decodeObjectForKey:@"lastName"];
    self.token      = [decoder decodeObjectForKey:@"token"];
  }
  return self;
}

-(void)save
{
  NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:self];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  [defaults setObject:userData forKey:USER_STORAGE_KEY];
  [defaults synchronize];
}

-(void)load
{
  NSData *encodedUser = [[NSUserDefaults standardUserDefaults] objectForKey:USER_STORAGE_KEY];
  User *loadedUser = [NSKeyedUnarchiver unarchiveObjectWithData:encodedUser];
  self.user_id    = loadedUser.user_id;
  self.first_name = loadedUser.first_name;
  self.last_name  = loadedUser.last_name;
  self.token      = loadedUser.token;
}

-(void)fromDictionary:(NSDictionary *)dict
{
  self.first_name = [dict objectForKey:@"first_name"];
  self.last_name  = [dict objectForKey:@"last_name"];
  self.email      = [dict objectForKey:@"email"];
  self.token      = [dict objectForKey:@"auth_token"];
  self.user_id    = [[dict objectForKey:@"id"] intValue];
  [self save];
}
@end
