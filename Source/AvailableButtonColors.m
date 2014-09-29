//
//  AvailableButtonColors.m
//  romiboController_7
//
//  Created by Daniel Brown on 9/28/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "AvailableButtonColors.h"
#import "ButtonColor.h"

#define COLORS_STORAGE_KEY @"buttonColors"


@implementation AvailableButtonColors


static AvailableButtonColors *sharedButtonColorsManagerInstance = nil;

+(id)sharedColorsManagerInstance
{
  if (sharedButtonColorsManagerInstance == nil){
    static dispatch_once_t predicate; //lock
    dispatch_once(&predicate, ^{
      sharedButtonColorsManagerInstance = [[AvailableButtonColors alloc] init];
    });
  }
  
  return sharedButtonColorsManagerInstance;
}

-(void)usePredefinedAvailableColors
{
  self.buttonColors = [[NSMutableDictionary alloc] init];
  self.buttonColors = [[self predefinedButtonColors] mutableCopy];
}

-(void)addAvailableButtonColor:(NSString *)name andHexValue:(NSString *)hexValue
{
  ButtonColor *buttonColor = [[ButtonColor alloc] initWithName:name andHexValue:hexValue];
  [self.buttonColors setObject:buttonColor forKey:buttonColor.name];
}

-(void)loadColors
{
  if (self.buttonColors == NULL)
    self.buttonColors = [[NSMutableDictionary alloc] init];
  NSData *colorsData = [[NSUserDefaults standardUserDefaults] objectForKey:COLORS_STORAGE_KEY];
  
  NSDictionary *colorsDict = [NSKeyedUnarchiver unarchiveObjectWithData:colorsData];
  self.buttonColors = [colorsDict mutableCopy];
}

-(void)saveColors
{
  NSData *colorsData = [NSKeyedArchiver archivedDataWithRootObject:self.buttonColors];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  [defaults setObject:colorsData forKey:COLORS_STORAGE_KEY];
  [defaults synchronize];
}

-(NSDictionary*)predefinedButtonColors
{
  NSMutableDictionary* colorDict = [[NSMutableDictionary alloc] init];
  NSArray* colorsArray = [NSArray arrayWithObjects:@"Red #c1392d",
                          @"Yellow #f39b13",
                          @"Green #27ae61",
                          @"Turquoise #13c8b0",
                          @"Blue #3498db",
                          @"Purple #8d44af",
                          @"Pink #fe7a7a", nil];
  for (NSString *colr in colorsArray){
    NSArray* splitColorValues = [colr componentsSeparatedByString:@" "];
    NSString* name  = [splitColorValues objectAtIndex:0];
    NSString* value = [splitColorValues objectAtIndex:1];
    [colorDict setObject:value forKey:name];
  }
  
  return colorDict;
}

-(NSString*)nameForHexValue:(NSString *)hexValue
{
  NSString *name = @"";
  for(id key in self.buttonColors){
    NSString* value = [self.buttonColors objectForKey:key];
    if ([value isEqualToString:hexValue]){
      name = value;
    }
  }
  
  return name;
}

-(NSString*)hexValueForName:(NSString *)name
{
  return [self.buttonColors objectForKey:name];
}

@end
