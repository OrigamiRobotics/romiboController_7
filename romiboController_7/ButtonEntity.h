//
//  ButtonEntity.h
//  romiboController_7
//
//  Created by Tracy Lakin on 5/12/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ActionEntity, PaletteEntity;

@interface ButtonEntity : NSManagedObject

@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSNumber * column;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSNumber * row;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSSet *actions;
@property (nonatomic, retain) PaletteEntity *palette;
@end

@interface ButtonEntity (CoreDataGeneratedAccessors)

- (void)addActionsObject:(ActionEntity *)value;
- (void)removeActionsObject:(ActionEntity *)value;
- (void)addActions:(NSSet *)values;
- (void)removeActions:(NSSet *)values;

@end
