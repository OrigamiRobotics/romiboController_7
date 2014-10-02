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
@property (copy, nonatomic)   NSString     * authTokenStr;
@property (nonatomic, assign) NSInteger      responseCode;
@property (nonatomic, copy)   NSString     * responseStatus;

//properties for task observers
@property (nonatomic, copy)   NSString     * loginObservable;
@property (nonatomic, copy)   NSString     * fetchPalettesObservable;
@property (nonatomic, strong) NSDictionary * fetchedPalettes;

+ (id)sharedRomibowebManagerInstance;
-(void)registerNewUserAtRomiboWeb;
-(void)loginToRomiboWeb:(NSString*)email andPassword:(NSString*)password;
-(void)getUserPalettesFromRomiboWeb;
-(void)getUsersListFromRomiboWeb;
-(void)getColorsListFromRomiboWeb;
-(void)syncPalettesWithRomiboWeb;
-(void)deletePaletteFromRomiboWeb;

@end
