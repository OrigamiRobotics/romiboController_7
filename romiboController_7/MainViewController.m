//
//  rmbo_ViewController.m
//  romiboController_7
//
//  Created by Tracy Lakin on 4/29/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "MainViewController.h"
#import "rmbo_AppDelegate.h"
#import "PaletteEntity.h"
#import "ButtonEntity.h"
#import "ActionEntity.h"
#import "colorPickerViewController.h"
#import "buttonSizePickerViewController.h"
#import "UIColor+RMBOColors.h"
#import "UserPalettesManager.h"
#import "RomibowebAPIManager.h"
#import "PaletteButtonsCollectionViewCell.h"
#import "PaletteButtonColors.h"
#import "GenericController.h"
#import "User.h"

@interface MainViewController ()


@property (strong, nonatomic)IBOutlet UIAlertView *alertView;

@property (nonatomic, weak)UserPalettesManager* palettesManager;
@property (nonatomic, strong)NSMutableDictionary* myPaletteIds;
@property (nonatomic, strong)NSMutableDictionary* currentButtonIds;
@property (nonatomic, strong)NSArray* buttonTitles;
@property (nonatomic, strong)NSMutableDictionary* myPaletteButtonIds;
@property (nonatomic, assign)NSInteger selectedTableRow;
@property (nonatomic, assign)NSInteger selectedButtonCellRow;

#pragma mark - Button details
@property (strong, nonatomic) IBOutlet UITextField *currentButtonTitle;
@property (strong, nonatomic) IBOutlet UITextView *currentButtonSpeechPhrase;

@property (strong, nonatomic) IBOutlet UISlider *currentButtonSpeechSpeedRate;

@property (strong, nonatomic) IBOutlet UILabel *currentButtonSpeedSpeedRateLabel;

@property (strong, nonatomic) IBOutlet UIButton *loginButton;

@property (strong, nonatomic) IBOutlet UILabel *currentButtonColorLabel;
@property (strong, nonatomic) IBOutlet UIButton *currentButtonColorSelector;

@property (strong, nonatomic) IBOutlet UILabel *selectedPaletteTitleLabel;
@property (weak, nonatomic) GenericController *genericController;
@property (strong, nonatomic) IBOutlet UIButton *addNewButton;

@property (strong, nonatomic) IBOutlet UIButton *fetchPalettesButton;
@property (strong, nonatomic) IBOutlet UILabel *logedInInfoLabel;

- (IBAction)sliderMoved:(UISlider *)sender;
@property (strong, nonatomic) IBOutlet UIButton *deleteCurrentButton;
@property (strong, nonatomic) IBOutlet UIView *toolbarContainerView;

@end

@implementation MainViewController



- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.connectedToiPod = NO;
  
  self.speechSynth = [[AVSpeechSynthesizer alloc] init];
  
  [self setupMultipeerConnectivity];
  self.genericController = [GenericController sharedGenericControllerInstance];
  
  [self setupRomiboWebUI];
  //init palettes stuff
  [self initializePalettesManager];

  [self setupAvailableColors];
  
  // UI specific
  NSLog(@"view did load");
  //set Palettes listing tableview background color
  self.palettesListingTableView.backgroundView = nil;
  CGFloat red   = 232.0f/255.0f;
  CGFloat green = 247.0f/255.0f;
  CGFloat blue  = 252.0f/255.0f;

  self.palettesListingTableView.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
  self.palettesListingTableView.tableFooterView = [[UIView alloc] init];
  [self registerAsObserver];
}


- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
  NSLog(@"NSURLSessionDelegate didBecomeInvalidWithError");
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
  NSLog(@"NSURLSessionDelegate didReceiveChallenge");
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
  NSLog(@"NSURLSessionDelegate URLSessionDidFinishEventsForBackgroundURLSession");
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
  NSLog(@"NSURLSessionDataDelegate didBecomeDownloadTask");
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
  NSLog(@"NSURLSessionDataDelegate didReceiveData");
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
  NSLog(@"NSURLSessionDataDelegate didReceiveResponse");
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
  NSLog(@"NSURLSessionDataDelegate willCacheResponse");
}


#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
  NSLog(@"NSURLSessionTaskDelegate didCompleteWithError");
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
  NSLog(@"NSURLSessionTaskDelegate didReceiveChallenge");
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
  NSLog(@"NSURLSessionTaskDelegate didSendBodyData");
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{
  NSLog(@"NSURLSessionTaskDelegate needNewBodyStream");
}

#pragma mark - Multipeer Connectivity

- (IBAction) connectAction:(id)sender
{
  [self manageRobotConnection];
}


- (void)manageRobotConnection
{
  if (self.connectedToiPod == NO) {
    self.multipeerBrowser = [[MCBrowserViewController alloc] initWithServiceType:kRMBOServiceType session:self.multipeerSession];
    [self.multipeerBrowser setMaximumNumberOfPeers:kRMBOMaxMutlipeerConnections];
    [self.multipeerBrowser setDelegate:self];
    [self presentViewController:self.multipeerBrowser animated:YES completion:nil];
  }
  else {
    UIAlertView *disconnectView = [[UIAlertView alloc] initWithTitle:@"Disconnect from Robot?" message:@"Are you sure you want to disconect from the robot?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Disconnect", nil];
    [disconnectView show];
  }
  NSLog(@"manageRobotConnection");
  
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
  [self.multipeerBrowser dismissViewControllerAnimated:YES completion:nil];
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
  [self.multipeerBrowser dismissViewControllerAnimated:YES completion:nil];
  self.connectedToiPod = YES;
}


- (void)setupMultipeerConnectivity
{
  MCPeerID *peerId = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
  self.multipeerSession = [[MCSession alloc] initWithPeer:peerId];
  [self.multipeerSession setDelegate:self];
  
}


- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
  self.connectedToiPod = YES;
  if (state == MCSessionStateConnected) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.multipeerBrowser dismissViewControllerAnimated:YES completion:^{
        
      }];
      
    });
  }
  else {
    self.connectedToiPod = NO;
  }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
  //    NSDictionary *command = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
  //    if ([command[@"command"] isEqualToString:kRMBODebugLogMessage]) {
  //        dispatch_async(dispatch_get_main_queue(), ^{
  //            NSLog(@"%@: %@", [peerID displayName], command[@"message"]);
  //        });
  //    }
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress { }

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error { }

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID { }

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler
{
  certificateHandler(YES);
}



typedef NS_ENUM(NSInteger, RMBOEyeMood) {
  RMBOEyeMood_Normal,
  RMBOEyeMood_Curious,
  RMBOEyeMood_Excited,
  RMBOEyeMood_Indifferent,
  RMBOEyeMood_Twitterpated,
  RMBOEyeMood_Blink
};


- (void)sendDataToRobot:(NSData *)data
{
  NSError *error = nil;
  [self.multipeerSession sendData:data toPeers:self.multipeerSession.connectedPeers withMode:MCSessionSendDataUnreliable error:&error];
}


- (void)sendSpeechPhraseToRobot:(NSString *)phrase atSpeechRate:(float)speechRate
{
  if (self.connectedToiPod) {
    NSDictionary *params = @{@"command" : kRMBOSpeakPhrase, @"phrase" : phrase, @"speechRate" : [NSNumber numberWithFloat:speechRate]};
    NSData *paramsData = [NSKeyedArchiver archivedDataWithRootObject:params];
    
    [self sendDataToRobot:paramsData];
  }
}

#pragma mark - button actions

- (IBAction)speakText:(id)sender
{
  NSString * speakTextStr = self.speakText_TextField.text;
  float speechRate = 0.2;
  [self sendSpeechPhraseToRobot:speakTextStr atSpeechRate:speechRate];
}

- (IBAction)textAction:(id)sender
{
  UIButton * button = (UIButton *)sender;
  NSString * textToSpeak = button.titleLabel.text;
  NSLog(@"textAction  speak: %@", textToSpeak);
  
  float speechRate = 0.2;
  [self sendSpeechPhraseToRobot:textToSpeak atSpeechRate:speechRate];
}

- (IBAction)emoteAction:(id)sender
{
  NSNumber *mood;
  if ([sender isEqual:self.emote1_button]) {
    mood = [NSNumber numberWithInteger:RMBOEyeMood_Curious];
  }
  else if ([sender isEqual:self.emote2_button]) {
    mood = [NSNumber numberWithInteger:RMBOEyeMood_Excited];
  }
  else if ([sender isEqual:self.emote3_button]) {
    mood = [NSNumber numberWithInteger:RMBOEyeMood_Indifferent];
  }
  else if ([sender isEqual:self.emote4_button]) {
    mood = [NSNumber numberWithInteger:RMBOEyeMood_Twitterpated];
  }
  else if ([sender isEqual:self.emote5_button]) {
    mood = [NSNumber numberWithInteger:RMBOEyeMood_Blink];
  }
  else {
    return;
  }
  
  if (self.connectedToiPod) {
    NSDictionary *params = @{@"command" : kRMBOChangeMood, @"mood" : mood};
    NSData *paramsData = [NSKeyedArchiver archivedDataWithRootObject:params];
    [self sendDataToRobot:paramsData];
  }
}



- (IBAction) newButtonAction:(id)sender
{
  NSError * error;
  rmbo_AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
  
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"PaletteEntity" inManagedObjectContext:appDelegate.managedObjectContext];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:entity];
  
  NSIndexPath * paletteIndexPath = self.palettesListingTableView.indexPathForSelectedRow;
  NSInteger paletteCoreDataIndex = paletteIndexPath.row + 1; // indexing in coreData starts at 1, not 0
  NSString *attributeName = @"index";
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %d",
                            attributeName, paletteCoreDataIndex];
  
  [request setPredicate:(NSPredicate *)predicate];
  
  NSArray *fetchedPalettes = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
  
  PaletteEntity * selectedPaletteEntity = (PaletteEntity *) fetchedPalettes[0]; // Should only be one
  
  entity = [NSEntityDescription entityForName:@"ButtonEntity" inManagedObjectContext:appDelegate.managedObjectContext];
  request = [[NSFetchRequest alloc] init];
  [request setEntity:entity];
  
  NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
  [request setSortDescriptors:@[descriptor]];
  
  NSArray *fetchedButtons = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
  
  entity = [NSEntityDescription entityForName:@"ActionEntity" inManagedObjectContext:appDelegate.managedObjectContext];
  request = [[NSFetchRequest alloc] init];
  [request setEntity:entity];
  
  descriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
  [request setSortDescriptors:@[descriptor]];
  
  NSArray *fetchedActions = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
  
  
  NSUInteger numButtons  = fetchedButtons.count;
  NSUInteger numActions  = fetchedActions.count;
  
  
  ButtonEntity * newButtonEntity = [NSEntityDescription insertNewObjectForEntityForName:@"ButtonEntity" inManagedObjectContext:appDelegate.managedObjectContext];
  
  [newButtonEntity setTitle: self.edit_buttonTitle_TextField.text];
  NSString * hexColorStr = [UIColor hexValuesFromUIColor:self.edit_buttonColorView.backgroundColor];
  [newButtonEntity setColor: hexColorStr];
  
  
  NSString * size = self.edit_buttonSize_Label.text;
  if ([size isEqualToString:@"Small"])
  {
    [newButtonEntity setWidth:  [NSNumber numberWithInt:1]];
    [newButtonEntity setHeight: [NSNumber numberWithInt:1]];
  }
  else if ([size isEqualToString:@"Medium"])
  {
    [newButtonEntity setWidth:  [NSNumber numberWithInt:2]];
    [newButtonEntity setHeight: [NSNumber numberWithInt:1]];
  }
  else if ([size isEqualToString:@"Large"])
  {
    [newButtonEntity setWidth:  [NSNumber numberWithInt:4]];
    [newButtonEntity setHeight: [NSNumber numberWithInt:1]];
  }
  
  
  // Go through the buttons in this palette to determine position of new button
  NSInteger maxRow = 0;
  for (ButtonEntity * buttonEntity in selectedPaletteEntity.buttons) {
    if ([buttonEntity.row integerValue] > maxRow) {
      maxRow = [buttonEntity.row integerValue];
    }
  }
  
  NSInteger maxColumnInLastRow = 0;
  NSInteger lastWidth = 0;
  for (ButtonEntity * buttonEntity in selectedPaletteEntity.buttons) {
    if ([buttonEntity.row integerValue] == maxRow) {
      if ([buttonEntity.column integerValue] > maxColumnInLastRow) {
        maxColumnInLastRow = [buttonEntity.column integerValue];
        lastWidth = [buttonEntity.width integerValue];
      }
    }
  }
  
  NSInteger nextFreeColumn = maxColumnInLastRow += lastWidth;
  if (nextFreeColumn + ([newButtonEntity.width integerValue] - 1) > 12) {
    maxRow = maxRow + 1;
    nextFreeColumn = 1;
  }
  
  [newButtonEntity setRow    : [NSNumber numberWithInteger:maxRow]];
  [newButtonEntity setColumn : [NSNumber numberWithInteger:nextFreeColumn]];
  
  
  [newButtonEntity setPalette:selectedPaletteEntity];
  numButtons++;
  [newButtonEntity setIndex:[NSNumber numberWithInt:(uint32_t)numButtons]];
  
  ActionEntity * actionEntity = [NSEntityDescription insertNewObjectForEntityForName:@"ActionEntity" inManagedObjectContext:appDelegate.managedObjectContext];
  [actionEntity setSpeechText  : self.edit_actionSpeechPhrase_TextView.text];
  [actionEntity setSpeechSpeed : [NSNumber numberWithFloat: [self.edit_actionSpeechRate_TextField.text floatValue]]];
  
  [actionEntity setActionType:[NSNumber numberWithInt:eActionType_talk]];
  numActions++;
  [actionEntity setIndex: [NSNumber numberWithInt:(uint32_t)numActions]];
  
  [actionEntity setActions:nil];
  [actionEntity setButton:newButtonEntity];
  
  NSSet * actionsSet = [NSSet setWithObject:actionEntity];
  [newButtonEntity setActions:actionsSet];
  
  NSSet * buttonSet = [NSSet setWithObject:newButtonEntity];
  if (selectedPaletteEntity.buttons == nil) {
    [selectedPaletteEntity addButtons:buttonSet];
  }
  else {
    NSMutableSet *newSet = [[NSMutableSet alloc] init];
    [newSet setSet:selectedPaletteEntity.buttons];
    [newSet unionSet:buttonSet];
    [selectedPaletteEntity addButtons:newSet];
  }
  
  [appDelegate.managedObjectContext save:nil];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.palettesListingTableView reloadData];
    [self displayButtonsForSelectedPalette: paletteIndexPath.row];
  });
  
}

- (IBAction)showColorPopoverAction:(id)sender
{
	UIButton *tappedButton = (UIButton *)sender;
	
  CGRect buttonRectInSelfView = [self.editView convertRect:tappedButton.frame toView:self.view];
  
	[self.colorPickerViewPopoverController presentPopoverFromRect:buttonRectInSelfView inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

- (IBAction)showSizePopoverAction:(id)sender
{
	UIButton *tappedButton = (UIButton *)sender;
	
  CGRect buttonRectInSelfView = [self.editView convertRect:tappedButton.frame toView:self.view];
  
	[self.sizePickerViewPopoverController presentPopoverFromRect:buttonRectInSelfView inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

- (void) setEditButtonColor:(UIColor *) color
{
  self.edit_buttonColorView.backgroundColor = color;
}

- (void) setEditButtonSize:(NSString *) sizeStr
{
  self.edit_buttonSize_Label.text = sizeStr;
}

- (IBAction)speakEditSpeechPhrase:(id)sender
{
  NSString * speechPhrase2 = self.edit_actionSpeechPhrase_TextView.text;
  CGFloat speechRate = [self.edit_actionSpeechRate_TextField.text floatValue];
  
  [self speakUtterance:speechPhrase2 atSpeechRate:speechRate withVoice:nil];
}

- (void)speakUtterance:(NSString *)phrase atSpeechRate:(float)speechRate withVoice:(AVSpeechSynthesisVoice *)voice
{
  if (!voice) {
    voice = [AVSpeechSynthesisVoice voiceWithLanguage:[AVSpeechSynthesisVoice currentLanguageCode]];
  }
  
  AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:phrase];
  [utterance setRate:speechRate];
  [utterance setVoice:voice];
  [self.speechSynth speakUtterance:utterance];
}



#pragma mark Popover controller delegates

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
  NSLog(@"popoverControllerDidDismissPopover");
}



- (IBAction)doActionFromButton:(id)sender
{
  UIButton * theButton = (UIButton *)sender;
  NSInteger buttonIndex = theButton.tag;
  
  // Fetch button with buttonIndex
  rmbo_AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
  
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"ButtonEntity" inManagedObjectContext:appDelegate.managedObjectContext];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:entity];
  
  NSString *attributeName = @"index";
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %d",
                            attributeName, buttonIndex];
  
  [request setPredicate:(NSPredicate *)predicate];
  
  NSError * error;
  NSArray * fetchedButtons = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
  
  if (fetchedButtons.count != 1)
    return;
  
  ButtonEntity * buttonEntity = (ButtonEntity *)fetchedButtons[0];
  
  NSSet * actionSet = buttonEntity.actions;
  ActionEntity * actionEntity = [actionSet anyObject];        // Right now only one action present ever
  
  // do action
  
  switch ([actionEntity.actionType integerValue]) {
      
    case eActionType_talk:
    {
      NSString * textToSpeak = actionEntity.speechText;
      float speechRate = [actionEntity.speechSpeed floatValue];
      [self sendSpeechPhraseToRobot:textToSpeak atSpeechRate:speechRate];
    }
      break;
      
    case eActionType_emotion:
      ;
      break;
      
    case eActionType_drive:
      ;
      break;
      
    case eActionType_tilt:
      ;
      break;
      
    default:
      break;
  }
  
}


#pragma mark - Side Views

- (IBAction)leftSideViewAction:(id)sender
{
  
}

- (IBAction)rightSideViewAction:(id)sender
{
  
}

#pragma mark - action button view



const CGFloat kButtonSizeUnit     =  50.0;

const CGFloat kSmallButtonWidth     =  50.0;
const CGFloat kMediumButtonWidth    = 102.0;
const CGFloat kLargeButtonWidth     = 150.0;
const CGFloat kButtonSeparatorWidth =   2.0;
const CGFloat kButtonHeight         =  50.0;

const CGFloat kButtonInset_x =   4.0;
const CGFloat kButtonInset_y =   4.0;


- (void) displayButtonsForSelectedPalette:(NSInteger)row
{
  //    if ([self.paletteTableView numberOfRowsInSection:0] == 0)
  //        return;
  NSLog(@"cell tapped");

  self.selectedTableRow = row;
  [self handleSelectedPalette];
}


#pragma mark - palette table delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString * cellIdentifier = @"paletteTableViewCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  
	if (cell == nil)
  {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
  }
  UIView* bgview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"palettes_table_cell_bg_image"]];
  UIView* selectedBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"palettes_table_cell_bg_image"]];;
  
  bgview.opaque = YES;
  cell.selectedBackgroundView = bgview;
  [cell setBackgroundView:selectedBgView];
  cell.textLabel.textColor = [UIColor colorWithHexString:@"6794A2"];
  cell.textLabel.highlightedTextColor = [UIColor colorWithHexString:@"00517D"];
  NSArray *splitTitleAndId = [self.paletteTitles[indexPath.row] componentsSeparatedByString:@"---+++---"];

  cell.textLabel.text = [splitTitleAndId objectAtIndex:0];

  NSString *strPaletteId = [splitTitleAndId objectAtIndex:1];
  [self.myPaletteIds setObject:strPaletteId forKey:[NSNumber numberWithLong:indexPath.row]];
  NSUInteger numberOfPalettes = [[UserPalettesManager sharedPalettesManagerInstance] numberOfPalettes];
  if ([[self.myPaletteIds allKeys] count] == numberOfPalettes ){
    [self highlightLastViewedPaletteCellInTable];
  }
  
  int lastViewedPaletteId = [[UserPalettesManager sharedPalettesManagerInstance] lastViewedPalette];
  if ([strPaletteId intValue] == lastViewedPaletteId){
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.selectedTableRow = indexPath.row;
  }
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.paletteTitles count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    [self displayButtonsForSelectedPalette:indexPath.row];
  });
}


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 40.0;
}

- (void)highlightLastViewedPaletteCellInTable
{
  int lastViewedPalette = [[UserPalettesManager sharedPalettesManagerInstance] lastViewedPalette];
  
  NSUInteger row = 0;
  for (id key in self.myPaletteIds){
    NSNumber *paletteId = [self.myPaletteIds objectForKey:key];
    if ([paletteId intValue] == lastViewedPalette){
      row = [key longValue];
      break;
    }
  }
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
  [self.palettesListingTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:
   UITableViewScrollPositionNone];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

  //[cell setBackgroundColor:[UIColor colorWithPatternImage:pattern]];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  return [self.buttonTitles count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *reuseIdentifier = @"CellID";
  PaletteButtonsCollectionViewCell *cell = (PaletteButtonsCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
  
  // Configure the cell
  NSArray *splitTitleAndId = [[self.buttonTitles objectAtIndex:indexPath.row] componentsSeparatedByString:@"---+++---"];
  
  //set button title
  NSString* buttonIdStr = [splitTitleAndId objectAtIndex:1];
  [self.myPaletteButtonIds setObject:buttonIdStr forKey:[NSNumber numberWithLong:indexPath.row]];
  NSString* title = [splitTitleAndId objectAtIndex:0];
  cell.foregroundLabel.text = [NSString stringWithFormat:@" %@", title];
  
  //get current palette and use it to get current button
  PaletteButton *buttonForPalette = [self.palettesManager currentButton:buttonIdStr];
  
  //set button color for display
  NSString *colorString = [buttonForPalette.color stringByReplacingOccurrencesOfString:@"#" withString:@""];
  cell.backgroundLabel.backgroundColor = [UIColor colorWithHexString:colorString];
  
  int lastViewedPaletteId = [[UserPalettesManager sharedPalettesManagerInstance] lastViewedPalette];
  Palette* palette = [[UserPalettesManager sharedPalettesManagerInstance] getSelectedPalette:lastViewedPaletteId];
  if (buttonForPalette.index == palette.last_viewed_button_id){
    [cell.checkmarkImage setHidden:NO];
  } else {
    [cell.checkmarkImage setHidden:YES];
  }
  
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  self.selectedButtonCellRow = indexPath.row;
  int numberOfCells = (int)[self.buttonTitles count];
  for (int i = 0; i < numberOfCells; i++){
    NSIndexPath *indPath = [NSIndexPath indexPathForRow:i inSection:0];
    PaletteButtonsCollectionViewCell * cell = (PaletteButtonsCollectionViewCell *)[collectionView cellForItemAtIndexPath:indPath];
    if (i == self.selectedButtonCellRow){
      [cell.checkmarkImage setHidden:NO];
    } else {
      [cell.checkmarkImage setHidden:YES];
    }
  }

  [self handleSelectedButton];
}

#pragma mark - Button Colors stuff
-(void)setupAvailableColors
{
  //TODO: Thisis temporary until we can get a list of colors from RomiboWeb
  [[PaletteButtonColors sharedColorsManagerInstance] usePredefinedAvailableColors];
}

#pragma mark - RomiboWeb UI
-(void) setupRomiboWebUI
{
  if ([[User sharedUserInstance] isLoggedIn]){
    [self.toolbarContainerView setHidden:NO];
    [self.loginButton setHidden:YES];
  } else {
    [self.toolbarContainerView setHidden:YES];
    [self.loginButton setHidden:NO];
  }
}

#pragma mark - Palettes stuff
-(void) initializePalettesManager
{
  self.myPaletteIds = [[NSMutableDictionary alloc] init];

  if (self.palettesManager == NULL)
    self.palettesManager = [UserPalettesManager sharedPalettesManagerInstance];
  [self.palettesManager loadPalettes];
  self.paletteTitles = [self.palettesManager paletteTitles];
  [self buttonsForSelectedPalette];
  [self handleSelectedPalette];
}

-(void) buttonsForSelectedPalette
{
  self.myPaletteButtonIds = [[NSMutableDictionary alloc] init];

  int selectedPaletteId = [self extractSelectedPaletteId];
  Palette *palette = [self.palettesManager getSelectedPalette:selectedPaletteId];
  self.buttonTitles = [[NSArray alloc] initWithArray:[palette buttonTitles]];
  //show last view button details
  [self displaySelectedButtonDetails:[palette getSelectedButton]];
}

-(int)extractSelectedPaletteId
{
  int selectPaletteId = 0;

  if ([[self.myPaletteIds allKeys] count] == 0){//when first loaded
    selectPaletteId = [[UserPalettesManager sharedPalettesManagerInstance] lastViewedPalette];
  } else{
    selectPaletteId = [[self.myPaletteIds objectForKey:[NSNumber numberWithLong:self.selectedTableRow]] intValue];
    [[UserPalettesManager sharedPalettesManagerInstance] updateLastViewedPalette:selectPaletteId];
  }
  
  return selectPaletteId;
}

-(void)handleSelectedPalette
{
  [self buttonsForSelectedPalette];
  [self.paletteButtonsCollectionView reloadData];
  
  [self.palettesManager updateLastViewedPalette:[self extractSelectedPaletteId]];
  int selectedPaletteId = [self extractSelectedPaletteId];
  Palette *palette = [self.palettesManager getSelectedPalette:selectedPaletteId];
  self.selectedPaletteTitleLabel.text = palette.title;
}

-(void)handleSelectedButton
{
  PaletteButton *buttonForPalette = [self extractCurrentSelectedButton];
  [self.palettesManager updateLastViewedButton:buttonForPalette.index forPalette:[self extractSelectedPaletteId]];
  [self displaySelectedButtonDetails:buttonForPalette];
}

-(PaletteButton *)extractCurrentSelectedButton
{
  NSString* buttonIdStr = [self.myPaletteButtonIds objectForKey:[NSNumber numberWithLong:self.selectedButtonCellRow]];
  //get current palette and use it to get current button
  PaletteButton *buttonForPalette = [self.palettesManager currentButton:buttonIdStr];
  return buttonForPalette;
}

- (void)registerAsObserver
{
  
  /*
   
   Register 'self' to receive change notifications for the "observeMe" property of
   
   the 'palettesManager' object and specify that new values of "observeMe"
   
   should be provided in the observe… method.
   
   */
  
  NSLog(@"when called");
  [self.palettesManager addObserver:self
   
                         forKeyPath:@"observeMe"
   
                            options:(NSKeyValueObservingOptionNew)
   
                            context:NULL];
  
  [self.genericController addObserver:self
                           forKeyPath:@"selectedButtonMenuItem"
                              options:(NSKeyValueObservingOptionNew)
                              context:NULL];
  
}

- (void)observeValueForKeyPath:(NSString *)keyPath

                      ofObject:(id)object

                        change:(NSDictionary *)change

                       context:(void *)context
{
  NSLog(@"Observed");
  if ([keyPath isEqual:@"observeMe"]) {
    self.paletteTitles = [self.palettesManager paletteTitles];
    [self.palettesListingTableView reloadData];
  } else if ([keyPath isEqual:@"selectedButtonMenuItem"]){
    NSString *selectedMenuItem = [(GenericController *)object selectedButtonMenuItem];
    NSLog(@"selectedMenuItem = %@", selectedMenuItem);
    if ([selectedMenuItem isEqualToString:@"New"]){
      dispatch_async(dispatch_get_main_queue(), ^{
        [self addNewPaletteButton];
      });
    }
  }
}


#pragma mark - Button Details Methods
-(void)displaySelectedButtonDetails:(PaletteButton *)button
{
  self.currentButtonTitle.text               = button.title;
  self.currentButtonSpeechPhrase.text        = button.speech_phrase;
  self.currentButtonSpeechSpeedRate.value    = button.speech_speed_rate;
  self.currentButtonSpeedSpeedRateLabel.text = [NSString stringWithFormat:@"%.1f", button.speech_speed_rate];
  UIColor *uiColor = [self colorFromHexString:button.color];

  self.currentButtonColorLabel.backgroundColor = uiColor;
  self.currentButtonColorLabel.text = @"";
  [self.currentButtonColorSelector setTitle:[[PaletteButtonColors sharedColorsManagerInstance] nameForHexValue:button.color] forState:UIControlStateNormal];
}

- (UIColor *) colorFromHexString:(NSString *)hexString
{
  NSString *stringColor = [NSString stringWithFormat:@"%@", hexString];
  NSUInteger red, green, blue;
  sscanf([stringColor UTF8String], "#%2lX%2lX%2lX", &red, &green, &blue);
  
  return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
  
}


- (IBAction)addButtonToPalette:(id)sender
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self addNewPaletteButton];
  });
}

-(void)addNewPaletteButton
{
  int currentPaletteId = [self.palettesManager lastViewedPalette];
  [self.palettesManager addDefaultButton:currentPaletteId];
  [self initializePalettesManager];
  [self.palettesListingTableView reloadData];
  [self.paletteButtonsCollectionView reloadData];
}


- (IBAction)deleteSelectedPalette:(id)sender
{
  self.alertView = [[UIAlertView alloc] initWithTitle:@"Delete Palette?" message:@"Are you sure you want to delete the selected palette?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
  self.alertView.tag = 0;
  [self.alertView show];
}

- (IBAction)deleteSelectedButton:(id)sender
{
  self.alertView = [[UIAlertView alloc] initWithTitle:@"Delete Palette Button?" message:@"Are you sure you want to delete the selected palette button?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
  self.alertView.tag = 1;
  [self.alertView show];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if (alertView.tag == 0){//delete palette
    if (buttonIndex == 1) {
      int currentPaletteId = [self.palettesManager lastViewedPalette];
      [self.palettesManager deletePalette:currentPaletteId];
      [self initializePalettesManager];
      [self.palettesListingTableView reloadData];
      [self.paletteButtonsCollectionView reloadData];
    }
  } else if (alertView.tag == 1){//delete button
    int currentPaletteId = [self.palettesManager lastViewedPalette];
    PaletteButton *currentButton = [self extractCurrentSelectedButton];
    [self.palettesManager deleteButton:currentButton.index forPalette:currentPaletteId];
    [self initializePalettesManager];
    [self.palettesListingTableView reloadData];
    [self.paletteButtonsCollectionView reloadData];
  } else {
    if (buttonIndex == 1) {
      [self.multipeerSession disconnect];
      self.connectedToiPod = NO;
      [self setupMultipeerConnectivity];
    }
  }
}

@end
