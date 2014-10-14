//
//  MenuSelectionsController.h
//  romiboController_7
//
//  Created by Daniel Brown on 10/4/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>

//used to pass data between view controllers
@interface MenuSelectionsController : NSObject

//pbserves are notified when a button menu item is selected
@property (copy, nonatomic)NSString *selectedButtonMenuItem;
@property (copy, nonatomic)NSString *selectedNewUser;

+ (id)sharedGenericControllerInstance;


@end
