//
//  UserPalettesManager.m
//  romiboController_7
//
//  Created by Daniel Brown on 9/21/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "UserPalettesManager.h"
#import "Palette.h"
#import "UserAccountsManager.h"

#define PALETTES_STORAGE_KEY @"userPalettesFor"


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
    
    [[UserAccountsManager sharedUserAccountManagerInstance] loadAccounts];
    [self initializeDefaultButtonData];
  }
  return self;
}

-(void)initializeDefaultButtonData
{
  self.defaultButtonData = @{
                             @"title": @"I'm a button",
                     @"speech_phrase": @"This is what I say",
                 @"speech_speed_rate": @0.2,
                             @"color": @"#13c8b0",
                              @"size": @"Large",
                               @"row": @-1,
                               @"col": @-1
                             };
}

-(void)createPalette:(NSString *)title
{
  Palette *palette = [[Palette alloc] init];
  palette.updated_at = [NSDate date];
  palette.title = title;
  [self addPalette:palette];
  [self updateLastViewedPalette:palette.index];
  [self addDefaultButton:palette.index];
  
}

-(void)addPalette:(Palette *)palette
{
  if (self.palettes == NULL){
    self.palettes = [[NSMutableDictionary alloc] init];
  }
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
  [self savePalettes];
  NSArray * paletteIds = [self.palettes allKeys];
  if ([paletteIds count] != 0){
    [self updateLastViewedPalette:[[paletteIds firstObject] intValue]];
  }
  [self updateObserveMe];
}

-(void)loadPalettes
{
  if (self.palettes == NULL)
    self.palettes = [[NSMutableDictionary alloc] init];
  NSData *palettesData = [[NSUserDefaults standardUserDefaults] objectForKey:[self paletteStorageKeyForCurrentUser]];
  
  NSDictionary *palettesDict = [NSKeyedUnarchiver unarchiveObjectWithData:palettesData];
  self.palettes = [palettesDict mutableCopy];
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
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  [defaults setObject:palettesData forKey:[self paletteStorageKeyForCurrentUser]];
  [defaults synchronize];
}

-(NSString*)paletteStorageKeyForCurrentUser
{
  NSString *currentUserEmail = [[UserAccountsManager sharedUserAccountManagerInstance] getCurrentUserEmail];
  if ( [currentUserEmail isEqualToString:@""]){
    return PALETTES_STORAGE_KEY;
  } else {
    return [NSString stringWithFormat:@"%@%@", PALETTES_STORAGE_KEY, currentUserEmail];
  }
}

-(NSArray *)paletteTitles
{
  NSMutableArray * titles = [[NSMutableArray alloc] init];
  self.highestPaletteId = 0;
  for (NSString *key in self.palettes){
    Palette *palette = [self.palettes objectForKey:key];
    if (palette.index > self.highestPaletteId)
      self.highestPaletteId = palette.index;
    NSString* augmentedTitle = [palette.title stringByAppendingFormat:@"---+++---%d", palette.index];
    [titles addObject:augmentedTitle];
  }
  return [NSArray arrayWithArray:titles];
}

-(void)updateObserveMe
{
  NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
  // NSTimeInterval is defined as double
  self.observeMe = [NSNumber numberWithDouble: timeStamp];
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

-(void)deleteAllPalettes
{
  self.palettes = [[NSMutableDictionary alloc] init];
}

-(NSDictionary *)processPalettesFromRomibowebAPI:(NSDictionary *)json
{
  //NSLog(@"json = %@", json);
  NSMutableDictionary *processedPalettes = [[NSMutableDictionary alloc] init];
  NSArray *palettesArray = [[NSArray alloc] initWithArray:json[@"palettes"]];
  if ([palettesArray count] != 0) {
    for (id pal in palettesArray){
      NSDictionary* paletteDict = pal[@"palette"];
      Palette *palette = [[Palette alloc] initWithDictionary:paletteDict];
      [processedPalettes setObject:palette forKey:[self paletteIdToString:palette.index]];
    }
  }
  return [processedPalettes copy];
}

-(Palette *)getSelectedPalette:(int)paletteId
{
  Palette* palette = [self.palettes objectForKey:[self paletteIdToString:paletteId]];
  if (palette){
    [[UserAccountsManager sharedUserAccountManagerInstance] updateLastViewedPaletteForCurrentuser:paletteId];
  }
  return palette;
}

-(int)lastViewedPalette
{
  int lastViewedPalette = [[UserAccountsManager sharedUserAccountManagerInstance] lastViewedPaletteIdForCurrentUser];
  if (lastViewedPalette < 1){
    NSArray *palettesArray = [self.palettes allValues];
    if ([palettesArray count] != 0){
      lastViewedPalette = [[palettesArray objectAtIndex:0] index];
    } else {
      lastViewedPalette = 0;
    }
  }
  
  return lastViewedPalette;
}

-(NSUInteger)numberOfPalettes
{
  return [[self.palettes allKeys] count];
}

-(PaletteButton*)currentButton:(NSString*)buttonIdStr
{
  int lastViewdPaletteId = [[UserPalettesManager sharedPalettesManagerInstance] lastViewedPalette];
  Palette *palette = [self getSelectedPalette:lastViewdPaletteId];
  return [palette getButton:[buttonIdStr intValue]];
}


-(void)updateLastViewedPalette:(int)lastViewdPaletteId
{
  [[UserAccountsManager sharedUserAccountManagerInstance] updateLastViewedPaletteForCurrentuser:lastViewdPaletteId];
}

-(void)updateLastViewedButton:(int)lastViewedButtonId forPalette:(int)paletteId
{
  [[self.palettes objectForKey:[self paletteIdToString:paletteId]] setLastViewedButtonId:lastViewedButtonId];
  [self savePalettes];
  [self updateObserveMe];
}

-(void)updateEditedPalette:(NSString *)title withId:(int)palette_id
{
  [[self.palettes objectForKey:[self paletteIdToString:palette_id]] setTitle:title];
  [self savePalettes];
  [self updateObserveMe];
}

-(NSString *)getPaletteTitle:(int)paletteId
{
  Palette *palette = [[self palettes] objectForKey:[self paletteIdToString:paletteId]];
  return palette.title;
}

-(NSString *)getButtonTitle:(int)buttonId forPalette:(int)paletteId
{
  Palette *palette = [[self palettes] objectForKey:[self paletteIdToString:paletteId]];
  return [palette getButtonTitle:buttonId];
}

-(NSString *)getButtonSpeechPhrase:(int)buttonId forPalette:(int)paletteId
{
  Palette *palette = [[self palettes] objectForKey:[self paletteIdToString:paletteId]];
  return [palette getButtonSpeechPhrase:buttonId];
}

-(NSString *)getButtonColor:(int)buttonId forPalette:(int)paletteId
{
  Palette *palette = [[self palettes] objectForKey:[self paletteIdToString:paletteId]];
  return [palette getButtonColor:buttonId];
}

-(float)getButtonSpeechSpeedRate:(int)buttonId forPalette:(int)paletteId
{
  Palette *palette = [[self palettes] objectForKey:[self paletteIdToString:paletteId]];
  return [palette getButtonSpeechSpeedRate:buttonId];
}

-(int)getLastViewedButtonIdFor:(int)paletteId
{
  Palette *palette = [[self palettes] objectForKey:[self paletteIdToString:paletteId]];
  return [palette lastViewedButton];
}

-(void)updateButton:(int)buttonId withData:(NSDictionary *)buttonData forPalette:(int)paletteId
{
  [[[self palettes] objectForKey:[self paletteIdToString:paletteId]] updateButton:buttonId withData:buttonData];
  [self savePalettes];
}

-(void)addDefaultButton:(int)paletteId
{
  [[[self palettes] objectForKey:[self paletteIdToString:paletteId]] addNewButton:self.defaultButtonData];
  [self savePalettes];
}

-(void)deleteButton:(int)buttonId forPalette:(int)paletteId
{
  [[[self palettes] objectForKey:[self paletteIdToString:paletteId]] deleteButton:buttonId];
  [self savePalettes];
}

@end
