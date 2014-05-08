//
//  Action.h
//  romiboController_7
//
//  Created by Tracy Lakin on 5/1/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Action, Palette;

@interface Action : NSManagedObject

@property (nonatomic, retain) NSData * color;
@property (nonatomic, retain) NSNumber * speechSpeed;
@property (nonatomic, retain) NSString * speechText;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * row;
@property (nonatomic, retain) NSNumber * column;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) Action *action;
@property (nonatomic, retain) Palette *palette;

@end
