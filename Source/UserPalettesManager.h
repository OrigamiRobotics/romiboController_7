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

//using this to implement the KVO pattern (iOS's form of the observer design pattern)
//client can register to be notified
//when this object changes.
//thus, wehever we add, delete, edit a palette etc.
//we change this object to some arbitrary value then
//all registered observers will be notified
@property (nonatomic, copy) NSNumber* observeMe;

-(void)createPalette:(NSString*)title;
-(void)addPalette:(Palette*)palette;
-(void)deletePalette:(int)palette_id;
-(void)loadPalettes;
-(void)savePalettes;
-(NSArray *)paletteTitles;
-(void)processPalettesFromRomibowebAPI:(NSDictionary*)json;
-(Palette*)getSelectedPalette:(int)paletteId;
-(int)lastViewedPalette;
-(NSUInteger)numberOfPalettes;

@end
