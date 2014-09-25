//
//  UserPalettesManager.m
//  romiboController_7
//
//  Created by Daniel Brown on 9/21/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "UserPalettesManager.h"
#import "Palette.h"
#define PALETTES_STORAGE_KEY @"userPalettes"


@interface UserPalettesManager()
//key id as NSString, value: palette
@property (nonatomic, strong)NSMutableDictionary* palettes;
//use to keep track of the next available index, locally
//this may conflict with an existing Palete id in the DB
//and it should be resolved during synch
@property (nonatomic, assign) int highestPaletteId;
@end

@implementation UserPalettesManager

static UserPalettesManager *sharedUserPalettesManagerInstance = nil;

+(id)sharedPalettesManagerInstance
{
  if (sharedUserPalettesManagerInstance == nil){
    static dispatch_once_t predicate; //lock
    dispatch_once(&predicate, ^{
      sharedUserPalettesManagerInstance = [[UserPalettesManager alloc] init];
    });
  }
  
  return sharedUserPalettesManagerInstance;
}

-(id)init
{
  if (self = [super init]){
    self.highestPaletteId = 0;
    self.palettes = [[NSMutableDictionary alloc] init];
  }
  return self;
}

-(void)createPalette:(NSString *)title
{
  NSLog(@"create palette called");
  Palette *palette = [[Palette alloc] init];
  palette.title = title;
  [self addPalette:palette];
}

-(void)addPalette:(Palette *)palette
{
  [self assignHighestId];
  if (palette.index == -1) {
    self.highestPaletteId += 1;
    palette.index = self.highestPaletteId;
  }
  [self.palettes setObject:palette forKey:[self paletteIdToString:palette.index]];
  [self savePalettes];
  [self updateObserveMe];
}

-(void)deletePalette:(int)palette_id
{
  [self.palettes removeObjectForKey:[self paletteIdToString:palette_id]];
}

-(void)loadPalettes
{
  NSLog(@"palettes loaded");
  if (self.palettes == NULL)
    self.palettes = [[NSMutableDictionary alloc] init];
  NSData *palettesData = [[NSUserDefaults standardUserDefaults] objectForKey:PALETTES_STORAGE_KEY];
  
  NSDictionary *palettesDict = [NSKeyedUnarchiver unarchiveObjectWithData:palettesData];
  self.palettes = [palettesDict mutableCopy];

  NSLog(@"load Palettes: %@", self.palettes);

  [self assignHighestId];
  [self updateObserveMe];
}

-(NSString*)paletteIdToString:(int)palette_id
{
  return [NSString stringWithFormat:@"%d", palette_id];
}

-(void)savePalettes
{
  NSData *palettesData = [NSKeyedArchiver archivedDataWithRootObject:self.palettes];
  NSLog(@"savePaletes: %@", self.palettes);
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  [defaults setObject:palettesData forKey:PALETTES_STORAGE_KEY];
  [defaults synchronize];
}

-(NSArray *)paletteTitles
{
  NSMutableArray * titles = [[NSMutableArray alloc] init];
  self.highestPaletteId = 0;
  for (NSString *key in self.palettes){
    Palette *palette = [self.palettes objectForKey:key];
    if (palette.index > self.highestPaletteId)
      self.highestPaletteId = palette.index;
    [titles addObject:palette.title];
  }
  return [NSArray arrayWithArray:titles];
}

-(void)updateObserveMe
{
  NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
  // NSTimeInterval is defined as double
  self.observeMe = [NSNumber numberWithDouble: timeStamp];
  NSLog(@"updated observe me");
}

-(void)assignHighestId
{
  self.highestPaletteId = 0;
  for (id key in self.palettes){
    Palette *palette = [self.palettes objectForKey:key];
    if (palette.index > self.highestPaletteId)
      self.highestPaletteId = palette.index;
  }
}
@end
