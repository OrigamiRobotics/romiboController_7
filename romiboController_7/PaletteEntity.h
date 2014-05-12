//
//  PaletteEntity.h
//  romiboController_7
//
//  Created by Tracy Lakin on 5/12/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ButtonEntity;

@interface PaletteEntity : NSManagedObject

@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *buttons;
@end

@interface PaletteEntity (CoreDataGeneratedAccessors)

- (void)addButtonsObject:(ButtonEntity *)value;
- (void)removeButtonsObject:(ButtonEntity *)value;
- (void)addButtons:(NSSet *)values;
- (void)removeButtons:(NSSet *)values;

@end
