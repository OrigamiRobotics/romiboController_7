//
//  User.m
//  romiboController_7
//
//  Created by Daniel Brown on 9/21/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "RomiboWebUser.h"
#define USER_STORAGE_KEY @"romiboUser"

@implementation RomiboWebUser

//static RomiboWebUser *sharedUserInstance = nil;
//
//+(id)sharedUserInstance
//{
//  if (sharedUserInstance == nil){
//    static dispatch_once_t predicate; //lock
//    dispatch_once(&predicate, ^{
//      sharedUserInstance = [[RomiboWebUser alloc] init];
//    });
//  }
//  
//  return sharedUserInstance;
//}

-(id)init
{
  if (self = [super init]){
    self.token      = @"";
    self.user_id    = 0;
    self.first_name = @"DEFAULT";
    self.last_name  = @"USER";
    self.email      = @"";
    self.last_viewed_palette_id = 0;
    self.isLoggedIn = NO;
  }
  return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
  [encoder encodeInteger:self.user_id   forKey:@"user_id"];
  [encoder encodeObject:self.first_name forKey:@"firstName"];
  [encoder encodeObject:self.last_name  forKey:@"lastName"];
  [encoder encodeObject:self.email      forKey:@"email"];
  [encoder encodeObject:self.token      forKey:@"token"];
  [encoder encodeInteger:self.last_viewed_palette_id forKey:@"lastViewedPaletteId"];
  [encoder encodeBool:  self.confirmed  forKey:@"confirmed"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
  if (self = [super init]){
    self.user_id    = [decoder decodeIntForKey:@"user_id"];
    self.first_name = [decoder decodeObjectForKey:@"firstName"];
    self.last_name  = [decoder decodeObjectForKey:@"lastName"];
    self.email      = [decoder decodeObjectForKey:@"email"];
    self.token      = [decoder decodeObjectForKey:@"token"];
    self.last_viewed_palette_id
                    = [decoder decodeIntForKey:@"lastViewedPaletteId"];
    self.confirmed  = [decoder decodeBoolForKey:@"confirmed"];
  }
  return self;
}

-(id)initWithDictionary:(NSDictionary *)dict
{
  if (self = [super init]){
    NSString * tokenStr     = @"Token token=";
    self.first_name = [dict objectForKey:@"first_name"];
    self.last_name  = [dict objectForKey:@"last_name"];
    self.email      = [dict objectForKey:@"email"];
    self.token      = [tokenStr stringByAppendingString: [dict objectForKey:@"auth_token"]];
    self.user_id    = [[dict objectForKey:@"id"] intValue];
    self.last_viewed_palette_id
    = [[dict objectForKey:@"last_viewed_palette_id"] intValue];
    int confirmed = [[dict objectForKey:@"confirmed"] intValue];
    if (confirmed == 1){
      self.confirmed = YES;
    } else {
      self.confirmed = NO;
    }
  }
  
  return self;
}

-(void)save
{
//  NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:self];
//  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
//  [defaults setObject:userData forKey:[self useInfoStorageKeyForCurrentAccount]];
//  [defaults synchronize];
}

-(void)loadData
{
  if (self){
    NSData *encodedUser = [[NSUserDefaults standardUserDefaults] objectForKey:[self useInfoStorageKeyForCurrentAccount]];
    RomiboWebUser *loadedUser = [NSKeyedUnarchiver unarchiveObjectWithData:encodedUser];
    self.user_id    = loadedUser.user_id;
    self.first_name = loadedUser.first_name;
    self.last_name  = loadedUser.last_name;
    self.email      = loadedUser.email;
    self.token      = loadedUser.token;
    self.last_viewed_palette_id
                    = loadedUser.last_viewed_palette_id;
    self.confirmed  = loadedUser.confirmed;
  }
}

-(void)fromDictionary:(NSDictionary *)dict
{
  NSString * tokenStr     = @"Token token=";
  self.first_name = [dict objectForKey:@"first_name"];
  self.last_name  = [dict objectForKey:@"last_name"];
  self.email      = [dict objectForKey:@"email"];
  self.token      = [tokenStr stringByAppendingString: [dict objectForKey:@"auth_token"]];
  self.user_id    = [[dict objectForKey:@"id"] intValue];
  self.last_viewed_palette_id
                  = [[dict objectForKey:@"last_viewed_palette_id"] intValue];
  int confirmed = [[dict objectForKey:@"confirmed"] intValue];
  NSLog(@"confirmed = %d", confirmed);
  if (confirmed == 1){
    self.confirmed = YES;
  } else {
    self.confirmed = NO;
  }
  [self save];
}

-(NSString*)name
{
  return [NSString stringWithFormat:@"%@ %@", self.first_name, self.last_name];
}

-(NSString*)description
{
  return [NSString stringWithFormat:@"First Name = %@\nLast Name = %@\nEmail = %@\nLast Viewed Palette = %d\n",
  self.first_name, self.last_name, self.email, self.last_viewed_palette_id];
}

-(NSString*)useInfoStorageKeyForCurrentAccount
{
  if ([self.email isEqualToString:@""]){
    return USER_STORAGE_KEY;
  } else {
    return [NSString stringWithFormat:@"%@%@", USER_STORAGE_KEY, self.email];
  }
}

@end
