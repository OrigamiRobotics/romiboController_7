//
//  PaletteButtonColorsManager.h
//  romiboController_7
//
//  Created by Daniel Brown on 9/28/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaletteButtonColorsManager : NSObject

@property (nonatomic, strong)NSMutableDictionary* buttonColors;
@property (nonatomic, strong)NSNumber *selectedColorSelectorPopoverCellValue;

+ (id)sharedColorsManagerInstance;

-(void) addAvailableButtonColor:(NSString*)name andHexValue:(NSString*)hexValue;
-(NSString*)hexValueForName:(NSString*)name;
-(NSString*)nameForHexValue:(NSString*)hexValue;
-(void)saveColors;
-(void)loadColors;
-(void)usePredefinedAvailableColors;
-(NSArray*)buttonColorNames;
-(void)processColorsFromRomibowebAPI:(NSDictionary *)json;
-(void)initializeColors;

@end
