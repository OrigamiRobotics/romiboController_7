//
//  ActionEntity.h
//  romiboController_7
//
//  Created by Tracy Lakin on 5/12/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ActionEntity, ButtonEntity;

@interface ActionEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSNumber * speechSpeed;
@property (nonatomic, retain) NSString * speechText;
@property (nonatomic, retain) NSNumber * actionType;
@property (nonatomic, retain) NSSet *actions;
@property (nonatomic, retain) ButtonEntity *button;
@end

@interface ActionEntity (CoreDataGeneratedAccessors)

- (void)addActionsObject:(ActionEntity *)value;
- (void)removeActionsObject:(ActionEntity *)value;
- (void)addActions:(NSSet *)values;
- (void)removeActions:(NSSet *)values;

@end
