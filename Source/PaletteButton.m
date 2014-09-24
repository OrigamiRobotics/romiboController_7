//
//  Button.m
//  romiboController_7
//
//  Created by Daniel Brown on 9/20/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "PaletteButton.h"

@implementation PaletteButton


-(instancetype)init
{
  if (self = [super init]){
    self.index = -1;
    self.row = 1;
    self.col = 1;
  }
  return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
  [encoder encodeInteger:self.index forKey:@"index"];
  [encoder encodeInteger:self.row forKey:@"row"];
  [encoder encodeInteger:self.col forKey:@"col"];
  [encoder encodeObject: self.title forKey:@"title"];
  [encoder encodeObject: self.speech_phrase forKey:@"phrase"];
  [encoder encodeFloat:  self.speech_speed_rate forKey:@"rate"];
  [encoder encodeObject: self.size forKey:@"size"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
  if (self = [super init]){
    self.index  = [decoder decodeIntForKey:@"index"];
    self.row    = [decoder decodeIntForKey:@"row"];
    self.col    = [decoder decodeIntForKey:@"col"];
    self.title  = [decoder decodeObjectForKey:@"title"];
    self.speech_phrase = [decoder decodeObjectForKey:@"phrase"];
    self.speech_speed_rate = [decoder decodeFloatForKey:@"rate"];
    self.size   = [decoder decodeObjectForKey:@"size"];
  }
  return self;
}

+(PaletteButton*)createFromDictionary:(NSDictionary *)buttonData
{
  PaletteButton *button = [[PaletteButton alloc] init];
  button.index = (int)[buttonData objectForKey:@"index"];
  button.row   = (int)[buttonData objectForKey:@"row"];
  button.col   = (int)[buttonData objectForKey:@"col"];
  button.title =      [buttonData objectForKey:@"title"];
  button.speech_phrase =
                      [buttonData objectForKey:@"phrase"];
  button.speech_speed_rate =
                      [[buttonData objectForKey:@"rate"] floatValue];
  button.size  =      [buttonData objectForKey:@"size"];
  
  return button;
}

@end
