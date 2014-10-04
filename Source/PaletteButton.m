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
    self.palette_id = -1;
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
  [encoder encodeObject: self.color     forKey:@"color"];
  [encoder encodeObject: self.size forKey:@"size"];
  [encoder encodeInteger:self.palette_id forKey:@"palette_id"];
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
    self.color  = [decoder decodeObjectForKey:@"color"];
    self.size   = [decoder decodeObjectForKey:@"size"];
    self.palette_id = [decoder decodeIntForKey:@"row"];
  }
  return self;
}

-(id)initWithDictionary:(NSDictionary *)dict
{
  if (self = [super init]){
    self.index = [[dict objectForKey:@"id"]   intValue];
    self.row   = [[dict objectForKey:@"row"]  intValue];
    self.col   = [[dict objectForKey:@"col"]  intValue];
    self.title =  [dict objectForKey:@"title"];
    self.speech_phrase =
                  [dict objectForKey:@"speech_phrase"];
    self.speech_speed_rate =
                 [[dict objectForKey:@"speech_speed_rate"] floatValue];
    self.size  =  [dict objectForKey:@"size"];
    self.color =  [dict objectForKey:@"color"];
    self.palette_id = [[dict objectForKey:@"palette_id"] intValue];
  }
  return self;
}

-(void)updateWithData:(NSDictionary *)data
{
  self.title             = [data objectForKey:@"title"];
  self.speech_phrase     = [data objectForKey:@"speechPhrase"];
  self.speech_speed_rate = [[data objectForKey:@"speechRate"] floatValue];
  self.color             = [data objectForKey:@"color"];
}

@end
