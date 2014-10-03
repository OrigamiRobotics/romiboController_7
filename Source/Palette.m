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
  if (button.palette_id == -1) {
    button.palette_id = self.index;
  }
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
  [encoder encodeObject: self.title     forKey:@"title"];
  [encoder encodeInteger:self.last_viewed_button_id
                                        forKey:@"last_viewed_button_id"];
  [encoder encodeInteger:self.owner_id  forKey:@"owner_id"];
  [encoder encodeObject: self.buttons   forKey:@"buttons"];
}

-(id) initWithCoder:(NSCoder *)decoder
{
  if (self = [super init]){
    self.index    = [decoder decodeIntForKey:@"index"];
    self.title    = [decoder decodeObjectForKey:@"title"];
    self.last_viewed_button_id =
                    [decoder decodeIntForKey:@"last_viewed_button_id"];
    self.owner_id = [decoder decodeIntForKey:@"owner_id"];
    self.buttons  = [decoder decodeObjectForKey:@"buttons"];
  }
  return self;
}

-(id)initWithDictionary:(NSDictionary *)dict
{
  if (self = [super init]){
    self.buttons = [[NSMutableDictionary alloc] init];

    self.index = [[dict objectForKey:@"id"] intValue];
    self.title = [dict objectForKey:@"title"];
    self.last_viewed_button_id = [[dict objectForKey:@"lastViewedButton"] intValue];
    self.owner_id = [[dict objectForKey:@"owner_id"] intValue];
    NSArray * buttonsArray= [dict objectForKey:@"buttons"];
    for (id buttonData in buttonsArray){
      PaletteButton *button = [[PaletteButton alloc ]initWithDictionary:buttonData[@"button"]];
      [self addButton:button];
    }

  }
  return self;
}

-(NSArray*)buttonTitles
{
  NSMutableArray *titles = [[NSMutableArray alloc] init];
  for (id key in self.buttons){
    PaletteButton* button = [self.buttons objectForKey:key];
    [titles addObject:[button.title stringByAppendingFormat:@"---+++---%d", button.index]];
  }
  return [titles mutableCopy];
}

-(PaletteButton *)getSelectedButton:(int)buttonId
{
  PaletteButton *button = [self.buttons objectForKey:[self buttonIdToString:buttonId]];
  if (button){
    self.last_viewed_button_id = buttonId;
  }
  return button;
}

-(PaletteButton *)getSelectedButton
{
  return[self getSelectedButton:[self lastViewedButton]];
}

-(int)lastViewedButton
{
  if (self.last_viewed_button_id == 0){
    return  [[[self.buttons allKeys] firstObject] intValue];
  } else {
    return self.last_viewed_button_id;
  }
}

@end
