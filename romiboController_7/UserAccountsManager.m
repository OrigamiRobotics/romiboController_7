//
//  UserAccountsManager.m
//  romiboController_7
//
//  Created by Daniel Brown on 10/9/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "UserAccountsManager.h"
#import "RomiboWebUser.h"

#define ACCOUNTS_STORAGE_KEY @"userAccounts"
#define LAST_USED_ACCOUNT_STORAGE_KEY @"lastUsedAccount"


@interface UserAccountsManager()

//userEmail: RomiboWebUser
@property (nonatomic, strong) NSMutableDictionary* userAccounts;

@end

@implementation UserAccountsManager

static UserAccountsManager *sharedAccountsInstance = nil;

+(id)sharedUserAccountManagerInstance
{
  if (sharedAccountsInstance == nil){
    static dispatch_once_t predicate; //lock
    dispatch_once(&predicate, ^{
      sharedAccountsInstance = [[UserAccountsManager alloc] init];
    });
  }
  
  return sharedAccountsInstance;
}

-(id)init
{
  if (self = [super init]){
    self.lastUsedAccountEmail = @"";
    self.userAccounts = [[NSMutableDictionary alloc] init];
    self.justLoggedInObservable = @"";

    [self loadAccounts];
    [self createDefaultUser];
  }
  return self;
}

-(void)createDefaultUser
{
  RomiboWebUser *user = [[RomiboWebUser alloc] init];
  RomiboWebUser *defaultUser = [self.userAccounts objectForKey:user.email];
  if (!defaultUser){
    [self.userAccounts setObject:user forKey:user.email];
    self.lastUsedAccountEmail = user.email;
    [self saveAccounts];
  }
}

-(void)saveAccounts
{
  NSData *usersData = [NSKeyedArchiver archivedDataWithRootObject:self.userAccounts];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  [defaults setObject:usersData forKey:ACCOUNTS_STORAGE_KEY];
  [defaults setObject:self.lastUsedAccountEmail forKey:LAST_USED_ACCOUNT_STORAGE_KEY];
  [defaults synchronize];
}

-(void)loadAccounts
{
  if (self.userAccounts == NULL)
    self.userAccounts = [[NSMutableDictionary alloc] init];
  NSData *usersData = [[NSUserDefaults standardUserDefaults] objectForKey:ACCOUNTS_STORAGE_KEY];
  
  if (usersData != NULL){
    NSDictionary *usersDict = [NSKeyedUnarchiver unarchiveObjectWithData:usersData];
    self.userAccounts = [usersDict mutableCopy];
    
    NSData *lastUsedAccountData = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_USED_ACCOUNT_STORAGE_KEY];

    self.lastUsedAccountEmail = (NSString*)lastUsedAccountData;
  }

}

-(void) addUser:(NSDictionary *)userDict
{
  RomiboWebUser *user = [[RomiboWebUser alloc] initWithDictionary:userDict];
  
  [self.userAccounts setObject:user forKey:user.email];
  self.lastUsedAccountEmail = user.email;
  [self saveAccounts];
}

-(NSString*) getCurrentUserName
{
  RomiboWebUser *user = [self.userAccounts objectForKey:self.lastUsedAccountEmail];
  return user.name;
}

-(NSString*)getCurrentUserEmail
{
  return self.lastUsedAccountEmail;
}

-(NSString*)getCurrentUserToken
{
  RomiboWebUser *user = [self.userAccounts objectForKey:self.lastUsedAccountEmail];
  return user.token;
}

-(void)switchCurrentUser:(NSString *)email
{
  RomiboWebUser *user = [self.userAccounts objectForKey:email];
  if (user){
    self.lastUsedAccountEmail = user.email;
    [self saveAccounts];
  }
}

-(int)lastViewedPaletteIdForCurrentUser
{
  RomiboWebUser *user = [self.userAccounts objectForKey:self.lastUsedAccountEmail];
  if (user){
    return user.lastViewedPaletteId;
  }
  
  return 0;
}

-(void)updateLastViewedPaletteForCurrentuser:(int)paleteId
{
  RomiboWebUser *user = [self.userAccounts objectForKey:self.lastUsedAccountEmail];
  if (user){
    [[self.userAccounts objectForKey:self.lastUsedAccountEmail] setLastViewedPaletteId:paleteId];
    [self saveAccounts];
  }
}

-(void)logInCurrentUser
{
  [[self.userAccounts objectForKey:self.lastUsedAccountEmail] setIsLoggedIn:YES];
  [self saveAccounts];
  self.justLoggedInObservable = @"yes";
}

-(BOOL)currentUserIsLoggedIn
{
  return [[self.userAccounts objectForKey:self.lastUsedAccountEmail] isLoggedIn];
}

-(int)numberOfUsers
{
  return (int)[[self.userAccounts allKeys] count];
}

-(BOOL)currentUserIsRegisteredButUnconfirmed
{
  if ([self.lastUsedAccountEmail isEqualToString:@""]){//default user
    return NO;
  }

  int confirmed = [[self.userAccounts objectForKey:self.lastUsedAccountEmail] confirmed];
  return confirmed == 0;
}

-(BOOL)currentUserIsDefaultUser
{
  return [self.lastUsedAccountEmail isEqualToString:@""];
}

-(NSArray*)nonCurrentLocalUserNamesAndEmails
{
  NSMutableArray *usersInfo = [[NSMutableArray alloc] init];
  for (id key in self.userAccounts){
    RomiboWebUser *user = [self.userAccounts objectForKey:key];
    if (![user.email isEqualToString:self.lastUsedAccountEmail]){
      NSString *nameAndEmail = @"";
      if ([user.email isEqualToString:@""]){
        nameAndEmail = [NSString stringWithFormat:@"%@---+++---%@", user.name, user.email];
      } else {
        nameAndEmail = [NSString stringWithFormat:@"%@ (%@)---+++---%@", user.name, user.email, user.email];
      }
      
      [usersInfo addObject:nameAndEmail];
    }
  }
  return [usersInfo copy];
}

-(NSString*)getCurrentUserNameAndEmail
{
  RomiboWebUser *user = [self.userAccounts objectForKey:self.lastUsedAccountEmail];
  if ([user.email isEqualToString:@""]){
    return user.name;
  } else {
    return[NSString stringWithFormat:@"%@ (%@)", user.name, user.email];
  }
}

@end
