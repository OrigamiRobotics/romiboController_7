//
//  Palette.h
//  romiboController_7
//
//  Created by Daniel Brown on 9/20/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaletteButton.h"

@interface Palette : NSObject<NSCoding>

@property (nonatomic, assign) int       index; //matches id from RomiboWeb
@property (nonatomic, copy)   NSString* title;
@property (nonatomic, assign) int       last_viewed_button_id;
@property (nonatomic, strong) NSMutableDictionary* buttons;
@property (nonatomic, assign) int       owner_id;

-(void) addButton:(PaletteButton*)button;
-(void) deleteButton:(int)buttonId;
-(PaletteButton*)getButton:(int)buttonId;
-(id)initWithDictionary:(NSDictionary *)dict;
-(NSArray*)buttonTitles;
-(PaletteButton *)getSelectedButton:(int)buttonId;


@end
