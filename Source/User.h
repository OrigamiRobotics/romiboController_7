//
//  User.h
//  romiboController_7
//
//  Created by Daniel Brown on 9/21/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject<NSCoding>

@property (nonatomic, assign)int user_id;
@property (nonatomic, copy)  NSString* email;
@property (nonatomic, copy)  NSString* first_name;
@property (nonatomic, copy)  NSString* last_name;
@property (nonatomic, copy)  NSString* token;

+ (id)sharedUserInstance;
- (void)save;
- (void)load;
- (void)fromDictionary:(NSDictionary*) dict;
@end
