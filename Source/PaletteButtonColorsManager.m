//
//  PaletteButtonColorsManager.m
//  romiboController_7
//
//  Created by Daniel Brown on 9/28/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "PaletteButtonColorsManager.h"
#import "ButtonColor.h"

#define COLORS_STORAGE_KEY @"buttonColors"


@implementation PaletteButtonColorsManager


static PaletteButtonColorsManager *sharedButtonColorsManagerInstance = nil;

+(id)sharedColorsManagerInstance
{
  if (sharedButtonColorsManagerInstance == nil){
    static dispatch_once_t predicate; //lock
    dispatch_once(&predicate, ^{
      sharedButtonColorsManagerInstance = [[PaletteButtonColorsManager alloc] init];
    });
  }
  
  return sharedButtonColorsManagerInstance;
}
-(instancetype)init
{
  if (self = [super init]){
    self.selectedColorSelectorPopoverCellValue = @""; //[NSNumber numberWithInt:-1];
  }
  
  return self;
}

-(void)usePredefinedAvailableColors
{
  self.buttonColors = [[NSMutableDictionary alloc] init];
  NSDictionary * colors = [[self predefinedButtonColors] mutableCopy];
  for (id key in colors){
    [self addAvailableButtonColor:key andHexValue:[colors objectForKey:key]];
  }
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
    NSMutableDictionary* colorDict = [@{
                                        @"Red": @"#c1392d",
                                        @"Yellow": @"#f39b13",
                                        @"Green": @"#27ae61",
                                        @"Turquoise": @"#13c8b0",
                                        @"Blue": @"#3498db",
                                        @"Purple": @"#8d44af",
                                        @"Pink": @"#fe7a7a",
                                        
                                        } mutableCopy];
//    
//  NSMutableDictionary* colorDict = [[NSMutableDictionary alloc] init];
//  NSArray* colorsArray = [NSArray arrayWithObjects:@"Red #c1392d",
//                          @"Yellow #f39b13",
//                          @"Green #27ae61",
//                          @"Turquoise #13c8b0",
//                          @"Blue #3498db",
//                          @"Purple #8d44af",
//                          @"Pink #fe7a7a", nil];
//  for (NSString *colr in colorsArray){
//    NSArray* splitColorValues = [colr componentsSeparatedByString:@" "];
//    NSString* name  = [splitColorValues objectAtIndex:0];
//    NSString* value = [splitColorValues objectAtIndex:1];
//    [colorDict setObject:value forKey:name];
//  }
  
  return colorDict;
}

-(NSString*)nameForHexValue:(NSString *)hexValue
{
  NSString *name = @"";
  for(id key in self.buttonColors){
    ButtonColor* buttonColor = [self.buttonColors objectForKey:key];
    if ([buttonColor.hexValue isEqualToString:hexValue]){
      name = buttonColor.name;
    }
  }
  return name;
}

-(NSString*)hexValueForName:(NSString *)name
{
  return [[self.buttonColors objectForKey:name] hexValue];
}

-(NSArray*)buttonColorNames
{
  NSMutableArray * names = [[NSMutableArray alloc] init];
  for (NSString *key in self.buttonColors){
    ButtonColor *buttonColor = [self.buttonColors objectForKey:key];
    [names addObject:buttonColor.name];
  }
  return [NSArray arrayWithArray:names];
}

-(void)processColorsFromRomibowebAPI:(NSDictionary *)json
{
  //NSLog(@"json = %@", json);
  NSMutableDictionary *processedColors = [[NSMutableDictionary alloc] init];
  NSArray *palettesArray = [[NSArray alloc] initWithArray:json[@"button_colors"]];
  if ([palettesArray count] != 0) {
    for (id pal in palettesArray){
      NSDictionary* colorDict = pal[@"button_color"];
      ButtonColor *buttonColor = [[ButtonColor alloc] initWithDictionary:colorDict];
      [processedColors setObject:buttonColor forKey:buttonColor.name];
    }
  }

  if ([[processedColors allKeys] count] != 0) {
    self.buttonColors = [processedColors mutableCopy];
    [self saveColors];
  }
}

-(void)initializeColors
{
  [self loadColors];
  if ([[self.buttonColors allKeys] count] == 0) {
    NSLog(@"loading predefined colors ...");
    [self usePredefinedAvailableColors];
  }
  // NSLog(@"colors = %@", self.buttonColors);
}

@end
