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
    self.row = [NSNumber numberWithInt:-1];
    self.col = [NSNumber numberWithInt:-1];
    self.palette_id = -1;
  }
  return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
  [encoder encodeInteger:self.index forKey:@"index"];
  [encoder encodeObject: self.row forKey:@"row"];
  [encoder encodeObject: self.col forKey:@"col"];
  [encoder encodeObject: self.title forKey:@"title"];
  [encoder encodeObject: self.speech_phrase forKey:@"phrase"];
  [encoder encodeFloat:  self.speech_speed_rate forKey:@"rate"];
  [encoder encodeObject: self.color     forKey:@"color"];
  [encoder encodeObject: self.size forKey:@"size"];
  [encoder encodeInteger:self.palette_id forKey:@"paletteId"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
  if (self = [super init]){
    self.index  = [decoder decodeIntForKey:@"index"];
    self.row    = [decoder decodeObjectForKey:@"row"];
    self.col    = [decoder decodeObjectForKey:@"col"];
    self.title  = [decoder decodeObjectForKey:@"title"];
    self.speech_phrase = [decoder decodeObjectForKey:@"phrase"];
    self.speech_speed_rate = [decoder decodeFloatForKey:@"rate"];
    self.color  = [decoder decodeObjectForKey:@"color"];
    self.size   = [decoder decodeObjectForKey:@"size"];
    self.palette_id = [decoder decodeIntForKey:@"paletteId"];
  }
  return self;
}

-(id)initWithDictionary:(NSDictionary *)dict
{
  if (self = [super init]){
    self.index = [[dict objectForKey:@"id"]   intValue];
    self.row   = [dict objectForKey:@"row"];
    self.col   = [dict objectForKey:@"col"];
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

-(id)initWithPaletteButton:(PaletteButton *)paletteButton
{
  if (self = [super init]){
    self.index  = paletteButton.index;
    self.row    = paletteButton.row;
    self.col    = paletteButton.col;
    self.title  = paletteButton.title;
    self.speech_phrase = paletteButton.speech_phrase;
    self.speech_speed_rate = paletteButton.speech_speed_rate;
    self.color  = paletteButton.color;
    self.size   = paletteButton.size;
    self.palette_id = paletteButton.palette_id;
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

-(NSString*)toJSONString
{
  NSString *json = @"{";
  json = [json stringByAppendingFormat:@"\"title\":\"%@\", ", self.title];
  json = [json stringByAppendingFormat:@"\"speech_phrase\":\"%@\", ", self.speech_phrase];
  json = [json stringByAppendingFormat:@"\"speech_speed_rate\":\"%0.1f\", ", self.speech_speed_rate];
  json = [json stringByAppendingFormat:@"\"color\":\"%@\", ", self.color];
  json = [json stringByAppendingFormat:@"\"size\":\"%@\", ", self.size];
  json = [json stringByAppendingFormat:@"\"id\":\"%d\", ", self.index];
  json = [json stringByAppendingFormat:@"\"row\":\"%d\", ", [self.row intValue]];
  json = [json stringByAppendingFormat:@"\"col\":\"%d\", ",  [self.col intValue]];
  json = [json stringByAppendingString:@"}"];

  return json;
}

@end
