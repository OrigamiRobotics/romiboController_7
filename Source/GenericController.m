//
//  GenericController.m
//  romiboController_7
//
//  Created by Daniel Brown on 10/4/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "GenericController.h"

@implementation GenericController

static GenericController *sharedControllerInstance = nil;


+(id)sharedGenericControllerInstance
{
  if (sharedControllerInstance == nil){
    static dispatch_once_t predicate; //lock
    dispatch_once(&predicate, ^{
      sharedControllerInstance = [[GenericController alloc] init];
    });
  }
  
  return sharedControllerInstance;
}

-(instancetype)init
{
  if (self = [super init]){
    self.selectedButtonMenuItem = @"";
  }
  
  return self;
}

@end
