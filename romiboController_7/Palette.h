//
//  Palette.h
//  romiboController_7
//
//  Created by Tracy Lakin on 5/1/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Action;

@interface Palette : NSManagedObject

@property (nonatomic, retain) NSData * color;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSSet *action;
@end

@interface Palette (CoreDataGeneratedAccessors)

- (void)addActionObject:(Action *)value;
- (void)removeActionObject:(Action *)value;
- (void)addAction:(NSSet *)values;
- (void)removeAction:(NSSet *)values;

@end
