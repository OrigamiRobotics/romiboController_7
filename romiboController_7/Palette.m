//
//  Palette.m
//  romiboController_7
//
//  Created by Daniel Brown on 9/20/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "Palette.h"

@implementation Palette

-(instancetype)init
{
  if (self = [super init]){
    self.index = -1;
    self.buttons = [[NSMutableDictionary alloc] init];
  }
  return self;
}

-(void)addButton:(PaletteButton *)button
{
  [self.buttons setObject:button forKey:[self buttonIdToString:button.index]];
}

-(void) deleteButton:(int)buttonId
{
  [self.buttons removeObjectForKey:[self buttonIdToString:buttonId]];
  self.last_viewed_button_id = [self nextButtonId:buttonId];
}

-(PaletteButton*)getButton:(int)buttonId
{
  return [self.buttons objectForKey:[self buttonIdToString:buttonId]];
}

-(NSString*)buttonIdToString:(int)buttonId
{
  return [NSString stringWithFormat:@"%d", buttonId];
}

-(int)nextButtonId:(int)currentButtonId
{
  NSArray *Ids = [self.buttons allKeys];
  int prev_id = -1;;
  if ([[self.buttons allKeys] count] <= 1){
    prev_id = -1;
  } else if ([[Ids lastObject] isEqualToString:[self buttonIdToString:currentButtonId]]){
    prev_id = [[Ids firstObject] intValue];
  } else if ([[Ids firstObject] isEqualToString:[self buttonIdToString:currentButtonId]]){
    NSUInteger currentButtonKeyindex = [Ids indexOfObject:[self buttonIdToString:currentButtonId]];
    prev_id = (int)[Ids objectAtIndex:currentButtonKeyindex + 1];
  } else {
    int next_id;
    for(NSString * strId in Ids){
      next_id = [strId intValue];
      if (next_id == currentButtonId){
        break;
      } else {
        prev_id = next_id;
      }
    }
  }
  
  return prev_id;
}

-(void) encodeWithCoder:(NSCoder *)encoder
{
  [encoder encodeInteger:self.index     forKey:@"index"];
  [encoder encodeObject:self.title      forKey:@"title"];
  [encoder encodeInteger:self.last_viewed_button_id      forKey:@"last_viewed_button_id"];
  [encoder encodeObject:self.buttons    forKey:@"buttons"];
}

-(id) initWithCoder:(NSCoder *)decoder
{
  if (self = [super init]){
    self.index    = [decoder decodeIntForKey:@"index"];
    self.title    = [decoder decodeObjectForKey:@"title"];
    self.last_viewed_button_id = [decoder decodeIntForKey:@"last_viewed_button_id"];
    self.buttons = [decoder decodeObjectForKey:@"buttons"];
  }
  return self;
}

+(Palette *)createFromDictionary:(NSDictionary *)paletteData
{
  Palette *palette = [[Palette alloc] init];
  palette.index = [[paletteData objectForKey:@"index"] intValue];
  palette.title = [paletteData objectForKey:@"title"];
  palette.last_viewed_button_id = [[paletteData objectForKey:@"lastViewedButton"] intValue];
  
  NSArray * buttonsHash = [paletteData objectForKey:@"buttons"];
  for (NSDictionary * buttonDict in buttonsHash){
    PaletteButton *button = [PaletteButton createFromDictionary:buttonDict];
    [palette addButton:button];
  }
  return palette;
}
   
@end
