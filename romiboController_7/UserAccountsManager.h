//
//  UserAccountsManager.h
//  romiboController_7
//
//  Created by Daniel Brown on 10/9/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//
// Manages RomiboWeb user accounts which have logged in
// to RomibiWeb on this device through this app

#import <Foundation/Foundation.h>


@interface UserAccountsManager : NSObject

@property (nonatomic, copy) NSString* lastUsedAccountEmail;

+ (id)sharedUserAccountManagerInstance;
-(void) addUser:(NSDictionary *)userDict;
-(NSString*) getCurrentUserName;
-(NSString*) getCurrentUserEmail;
-(NSString*) getCurrentUserToken;
-(int)lastViewedPaletteIdForCurrentUser;
-(BOOL)currentUserIsLoggedIn;
-(int)numberOfUsers;
-(BOOL)currentUserIsRegisteredButUnconfirmed;
-(BOOL)currentUserIsDefaultUser;
-(NSArray*)nonCurrentLocalUserNamesAndEmails;
-(NSString*)getCurrentUserNameAndEmail;

-(void)updateLastViewedPaletteForCurrentuser:(int)paleteId;
-(void)saveAccounts;
-(void)loadAccounts;
-(void)logInCurrentUser;
-(void)switchCurrentUser:(NSString*)email;

@property (nonatomic, copy)  NSString* justLoggedInObservable;


@end
