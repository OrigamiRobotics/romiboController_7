//
//  Palette.m
//  romiboController_7
//
//  Created by Daniel Brown on 9/20/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "Palette.h"

@interface Palette()

@property (nonatomic, assign) int lastRowNumber;
@property (nonatomic, assign) int lastColNumber;


@end

@implementation Palette

-(instancetype)init
{
  if (self = [super init]){
    self.index = -1;
    self.buttons = [[NSMutableDictionary alloc] init];
    self.lastRowNumber = 0;
    self.lastColNumber = 0;
  }
  return self;
}

-(void)addButton:(PaletteButton *)button
{
  if (button.palette_id == -1) {
    button.palette_id = self.index;
  }

  PaletteButton *paletteButton = [self setLastRowAndColNumbers:button];
  if (paletteButton.index < 1){
    NSArray * strButtonIds = [self.buttons allKeys];
    NSMutableArray * mButtonIds = [[NSMutableArray alloc] init];
    for (NSString * strId in strButtonIds){
      [mButtonIds addObject:[NSNumber numberWithInt:[strId intValue]]];
    }
    int nextAvailableId = [[mButtonIds valueForKeyPath:@"@max.intValue"] intValue];
    paletteButton.index = nextAvailableId + 1;
  }
  self.last_viewed_button_id = paletteButton.index;
  [self.buttons setObject:paletteButton forKey:[self buttonIdToString:paletteButton.index]];
  self.updated_at = [NSDate date];
}

-(void)addNewButton:(NSDictionary *)buttonData
{
  PaletteButton *button = [[PaletteButton alloc] initWithDictionary:buttonData];

  [self addButton:button];
}

-(void) deleteButton:(int)buttonId
{
  [self.buttons removeObjectForKey:[self buttonIdToString:buttonId]];
  NSArray *buttonIds = [self.buttons allKeys];
  if ([buttonIds count] != 0){
    self.last_viewed_button_id = [[buttonIds firstObject] intValue];
  } else {
    self.last_viewed_button_id = -1;
  }
  [self resetLastRowAndColNumbers];
  self.updated_at = [NSDate date];
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
  [encoder encodeObject: self.updated_at forKey:@"updated"];
  [encoder encodeInteger: self.lastRowNumber forKey:@"lastRowNumber"];
  [encoder encodeInteger: self.lastColNumber forKey:@"lastColNumber"];

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
    [self resetLastRowAndColNumbers];
    self.updated_at = [decoder decodeObjectForKey:@"updated"];
    self.lastRowNumber = [decoder decodeIntForKey:@"lastRowNumber"];
    self.lastColNumber = [decoder decodeIntForKey:@"lastColNumber"];
  }
  return self;
}

-(NSDate *)dateFromString:(NSString*)dateString
{
  //NSString* str = @"3/15/2012 9:15 PM";
  NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
  [formatter setDateFormat:@"MM/dd/yyyy HH:mm a"];
  return [formatter dateFromString:dateString];
}

-(id)initWithDictionary:(NSDictionary *)dict
{
  if (self = [super init]){
    self.buttons = [[NSMutableDictionary alloc] init];

    self.index = [[dict objectForKey:@"id"] intValue];
    self.title = [dict objectForKey:@"title"];
    self.last_viewed_button_id = [[dict objectForKey:@"lastViewedButton"] intValue];
    self.owner_id = [[dict objectForKey:@"owner_id"] intValue];
    self.updated_at = [self dateFromString:[dict objectForKey:@"updated_at"]];
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
  NSArray *buttonsArray = [self sortedButtonsArray];
  for (PaletteButton* button in buttonsArray){
    [titles addObject:[button.title stringByAppendingFormat:@"---+++---%d", button.index]];
  }
  return [titles copy];
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

-(NSString *)getButtonTitle:(int)buttonId
{
  PaletteButton *button = [self.buttons objectForKey:[self buttonIdToString:buttonId]];
  return button.title;
}

-(NSString*)getButtonColor:(int)buttonId
{
  PaletteButton *button = [self.buttons objectForKey:[self buttonIdToString:buttonId]];
  return button.color;
}

-(NSString *)getButtonSpeechPhrase:(int)buttonId
{
  PaletteButton *button = [self.buttons objectForKey:[self buttonIdToString:buttonId]];
  return button.speech_phrase;
}

-(float)getButtonSpeechSpeedRate:(int)buttonId
{
  PaletteButton *button = [self.buttons objectForKey:[self buttonIdToString:buttonId]];
  return button.speech_speed_rate;
}

-(void)updateButton:(int)buttonId withData:(NSDictionary *)buttonData
{
  [[self.buttons objectForKey:[self buttonIdToString:buttonId]] updateWithData:buttonData];
  self.updated_at = [NSDate date];
}

-(NSString*)toJSONString
{
  NSString *json = @"{\"palette\":{";
  json = [json stringByAppendingFormat:@"\"title\":\"%@\", ", self.title];
  json = [json stringByAppendingFormat:@"\"last_viewed_button_id\":\"%d\", ", self.last_viewed_button_id];
  json = [json stringByAppendingFormat:@"\"updated_at\":\"%d\", ", self.last_viewed_button_id];
  json = [json stringByAppendingFormat:@"\"owner_id\":\"%d\", ", self.owner_id];
  json = [json stringByAppendingFormat:@"\"updated_at\":\"%@\", ", [self dateToString:self.updated_at]];
  json = [json stringByAppendingFormat:@"\"buttons\":\"%@\", ", [self buttonsToJSONString]];
  
  json = [json stringByAppendingString:@"}}"];

  return json;
}

-(NSString*)dateToString:(NSDate *)date
{
  NSString *dateString = [NSDateFormatter localizedStringFromDate:date
                                                        dateStyle:NSDateFormatterMediumStyle
                                                        timeStyle:NSDateFormatterFullStyle];
  NSLog(@"%@",dateString);
  return dateString;
}

-(NSString*)buttonsToJSONString
{
  NSString *json = @"[";
  int count = 0;
  int numberOfButtons = (int)[self.buttons count];
  for (id key in self.buttons){
    count += 1;
    PaletteButton *button = [self.buttons objectForKey:key];
    json = [json stringByAppendingString:[button toJSONString]];
    if (count < numberOfButtons){
      json = [json stringByAppendingString:@","];
    }
  }
  json = [json stringByAppendingString:@"]"];
  return json;
}

//use row and col numbers to
//sort buttons
-(NSArray*)sortedButtonsArray
{
  NSSortDescriptor *rowDescriptor = [[NSSortDescriptor alloc] initWithKey:@"row" ascending:YES];
  NSSortDescriptor *colDescriptor = [[NSSortDescriptor alloc] initWithKey:@"col" ascending:YES];

  NSArray *sortDescriptors = @[rowDescriptor, colDescriptor];
  
  return [[self.buttons allValues] sortedArrayUsingDescriptors:sortDescriptors];
}

-(PaletteButton*)setLastRowAndColNumbers:(PaletteButton *)button
{
  PaletteButton *paletteButton = [[PaletteButton alloc] initWithPaletteButton:button];
  if ([[self.buttons allKeys] count] == 0){
    if ([paletteButton.row intValue] == -1){
      self.lastRowNumber = 1;
      self.lastColNumber = 1;
      paletteButton.row = [NSNumber numberWithInt:self.lastRowNumber];
      paletteButton.col = [NSNumber numberWithInt:self.lastColNumber];
    } else {
      [self updateLastRowAndColOrCol:paletteButton];
    }
  } else {
    if ([paletteButton.row intValue] == -1){
      [self updateLastRowAndColWhenNewButton:paletteButton];
      NSLog(@"last row number = %d, last col number = %d", self.lastRowNumber, self.lastColNumber);
      paletteButton.row = [NSNumber numberWithInt:self.lastRowNumber];
      paletteButton.col = [NSNumber numberWithInt:self.lastColNumber];
    } else {
      [self updateLastRowAndColOrCol:paletteButton];
    }
  }

  return paletteButton;
}

-(void)updateLastRowAndColWhenNewButton:(PaletteButton*)button
{
  if (self.lastColNumber < 5){
    self.lastColNumber += 1;
  } else {
    self.lastColNumber  = 1;
    self.lastRowNumber += 1;
  }
}


-(void) updateLastRowAndColOrCol:(PaletteButton*)button
{
  if ([button.row intValue] > self.lastRowNumber) {
    self.lastRowNumber = [button.row intValue];
    self.lastColNumber = [button.col intValue];
  } else if (([button.row intValue] == self.lastRowNumber) &&
             ([button.col intValue]  > self.lastColNumber)){
    self.lastColNumber = [button.col intValue];
  }
}

-(void)resetLastRowAndColNumbers
{
  NSArray *buttons = [self sortedButtonsArray];
  self.buttons = [[NSMutableDictionary alloc] init];
  for (id b in buttons){
    PaletteButton *button = (PaletteButton*)b;
    button.row = [NSNumber numberWithInt:-1];
    button.col = [NSNumber numberWithInt:-1];
    [self addButton:button];
  }
}

@end
