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
//thus, whenever we add, delete, edit a palette etc.
//we change this object to some arbitrary value then
//all registered observers would be notified
@property (nonatomic, copy) NSNumber* observeMe;
@property (nonatomic, strong)NSDictionary * defaultButtonData;

//palettes
-(void)createPalette:(NSString*)title;
-(void)addPalette:(Palette*)palette;
-(void)deletePalette:(int)palette_id;
-(void)loadPalettes;
-(void)savePalettes;
-(NSArray *)paletteTitles;
-(NSDictionary *)processPalettesFromRomibowebAPI:(NSDictionary*)json;
-(Palette*)getSelectedPalette:(int)paletteId;
-(int)lastViewedPalette;
-(NSUInteger)numberOfPalettes;
-(PaletteButton*)currentButton:(NSString*)buttonIdStr;
-(void)updateLastViewedPalette:(int)lastViewdPaletteId;
-(void)updateLastViewedButton:(int)lastViewedButtonId forPalette:(int)paletteId;
-(void)updateEditedPalette:(NSString*)title withId:(int)paletteId;
-(NSString *)getPaletteTitle:(int)paletteId;



//Button getters
-(NSString *)getButtonTitle:(int)buttonId forPalette:(int)paletteId;
-(float)getButtonSpeechSpeedRate:(int)buttonId forPalette:(int)paletteId;
-(NSString *)getButtonSpeechPhrase:(int)buttonId forPalette:(int)paletteId;
-(NSString *)getButtonColor:(int)buttonId forPalette:(int)paletteId;
-(int)getLastViewedButtonIdFor:(int)paletteId;

//button misc
-(void)updateButton:(int)buttonId withData:(NSDictionary*)buttonData forPalette:(int)paletteId;
-(void) addDefaultButton:(int)paletteId;

-(void)deleteButton:(int)buttonId forPalette:(int)paletteId;

@end
