//
//  AvailableButtonColors.h
//  romiboController_7
//
//  Created by Daniel Brown on 9/28/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AvailableButtonColors : NSObject

@property (nonatomic, strong)NSMutableDictionary* buttonColors;

+ (id)sharedColorsManagerInstance;

-(void) addAvailableButtonColor:(NSString*)name andHexValue:(NSString*)hexValue;
-(NSString*)hexValueForName:(NSString*)name;
-(NSString*)nameForHexValue:(NSString*)hexValue;
-(void)saveColors;
-(void)loadColors;
-(void)usePredefinedAvailableColors;

@end
