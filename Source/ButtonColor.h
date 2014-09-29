//
//  ButtonColors.h
//  romiboController_7
//
//  Created by Daniel Brown on 9/28/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ButtonColor : NSObject

@property (nonatomic, assign)int     index;
@property (nonatomic, copy)NSString* name;
@property (nonatomic, copy)NSString* hexValue;


-(instancetype)initWithName:(NSString*)name andHexValue:(NSString*)hexValue;

@end
