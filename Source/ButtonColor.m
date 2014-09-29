//
//  ButtonColors.m
//  romiboController_7
//
//  Created by Daniel Brown on 9/28/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "ButtonColor.h"
#define BUTTON_COLOR_KEY @"buttonColor"


@implementation ButtonColor

-(instancetype)init
{
  if (self = [super init]){
    self.name     = @"Turquoise";
    self.hexValue = @"13c8b0";
  }
  
  return self;
}

-(instancetype)initWithName:(NSString*)name andHexValue:(NSString*)hexValue
{
  if (self = [super init]){
    self.name = name;
    self.hexValue = [hexValue stringByReplacingOccurrencesOfString:@"#" withString:@""];
  }
  
  return self;
}


-(void)encodeWithCoder:(NSCoder *)encoder
{
  [encoder encodeInteger:self.index   forKey:@"index"];
  [encoder encodeObject:self.name     forKey:@"name"];
  [encoder encodeObject:self.hexValue forKey:@"value"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
  if (self = [super init]){
    self.index    = [decoder decodeIntForKey:   @"index"];
    self.name     = [decoder decodeObjectForKey:@"name"];
    self.hexValue = [decoder decodeObjectForKey:@"value"];
  }
  return self;
}

-(void)fromDictionary:(NSDictionary *)dict
{
  self.name = [dict objectForKey:@"name"];
  self.hexValue  = [dict objectForKey:@"value"];
  [self save];
}

@end
