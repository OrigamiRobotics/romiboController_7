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
  Palette *palette = [[Palette alloc] init];
  palette.title = title;
  [self addPalette:palette];
  NSLog(@"palette created");
}

-(void)addPalette:(Palette *)palette
{
  if (palette.index == -1)//uninitialized?
    palette.index = self.highestPaletteId + 1;
  
  [self.palettes setObject:palette forKey:[self paletteIdToString:palette.index]];
  if (palette.index > self.highestPaletteId)
    self.highestPaletteId = palette.index;
}

-(void)deletePalette:(int)palette_id
{
  [self.palettes removeObjectForKey:[self paletteIdToString:palette_id]];
}

-(void)loadPalettes
{
  NSLog(@"palettes loaded");
  if ([self.palettes count] != 0)
    return;
  NSData *palettesData = [[NSUserDefaults standardUserDefaults] objectForKey:PALETTES_STORAGE_KEY];
  
  NSArray *palettesArray = [NSKeyedUnarchiver unarchiveObjectWithData:palettesData];
  self.palettes = [palettesArray mutableCopy];
}

-(NSString*)paletteIdToString:(int)palette_id
{
  return [NSString stringWithFormat:@"%d", palette_id];
}

-(void)savePalattes
{
  NSData *palettesData = [NSKeyedArchiver archivedDataWithRootObject:self.palettes];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  [defaults setObject:palettesData forKey:PALETTES_STORAGE_KEY];
  [defaults synchronize];
}

@end
