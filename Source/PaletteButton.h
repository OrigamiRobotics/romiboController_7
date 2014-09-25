//
//  Button.h
//  romiboController_7
//
//  Created by Daniel Brown on 9/20/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaletteButton : NSObject<NSCoding>

@property (nonatomic, assign) int index;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* speech_phrase;
@property (nonatomic, assign) float speech_speed_rate;
@property (nonatomic, copy) NSString* size;
@property (nonatomic, assign) int row;
@property (nonatomic, assign) int col;

+(PaletteButton*)createFromDictionary:(NSDictionary*)buttonData;

@end