//
//  RomibowebIntegrationManager.h
//  romiboController_7
//
//  Created by Daniel Brown on 9/22/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  RegistrationRequest,
  LoginRequest,
  CreatePaletteRequest,
  PalettesListRequest,
  DeletePaletteRequest,
  UsersListRequest,
  ColorsListRequest
  
} RequestType;

@interface RomibowebAPIManager : NSObject<NSURLSessionTaskDelegate>

@property (strong, nonatomic) NSURLSession * URLsession;
@property (strong, nonatomic) NSString * authTokenStr;

+ (id)sharedRomibowebManagerInstance;
-(void)registerNewUserAtRomiboWeb;
-(void)loginToRomiboWeb;
-(void)getUserPalettesFromRomiboWeb;
-(void)getUsersListFromRomiboWeb;
-(void)getColorsListFromRomiboWeb;
-(void)synchPalettesWithROmiboWeb;
-(void)deletePaletteFromRomiboWeb;

@end
