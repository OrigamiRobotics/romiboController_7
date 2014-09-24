//
//  UserPalettesManager.h
//  romiboController_7
//
//  Created by Daniel Brown on 9/21/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Palette.h"

@interface UserPalettesManager : NSObject

+ (id)sharedPalettesManagerInstance;

-(void)createPalette:(NSString*)title;
-(void)addPalette:(Palette*)palette;
-(void)deletePalette:(int)palette_id;
-(void)loadPalettes;
-(void)savePalette;
@end
