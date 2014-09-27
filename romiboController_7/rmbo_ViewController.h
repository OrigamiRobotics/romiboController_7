//
//  rmbo_ViewController.h
//  romiboController_7
//
//  Created by Tracy Lakin on 4/29/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <CoreData/CoreData.h>
#import "AVFoundation/AVFoundation.h"
#import "PaletteButtonsCollectionViewCell.h"


//Commands
#define kRMBOSpeakPhrase @"kRMBOSpeakPhrase"
#define kRMBOMoveRobot @"kRMBOMoveRobot"
#define kRMBOHeadTilt @"kRMBOHeadTilt"
#define kRMBODebugLogMessage @"kRMBODebugLogMessage"
#define kRMBOTurnInPlaceClockwise @"kRMBOTurnInPlaceClockwise"
#define kRMBOTurnInPlaceCounterClockwise @"kRMBOTurnInPlaceCounterClockwise"
#define kRMBOStopRobotMovement @"kRMBOStopRobotMovement"
#define kRMBOChangeMood @"kRMBOChangeMood"

#define kRMBOMaxMutlipeerConnections 1
#define kRMBOServiceType @"origami-romibo"


typedef enum {
    eActionType_talk,
    eActionType_emotion,
    eActionType_drive,
    eActionType_tilt
} eActionType;



@interface rmbo_ViewController : UIViewController
<
  UITableViewDataSource,
  UITableViewDelegate,
  UICollectionViewDataSource,
  UICollectionViewDelegate,
  MCSessionDelegate,
  MCBrowserViewControllerDelegate,
  NSURLSessionTaskDelegate,
  NSURLSessionDataDelegate,
  NSURLSessionDelegate,
  UIPopoverControllerDelegate
>


@property (strong, nonatomic) MCSession * multipeerSession;
@property (nonatomic, strong) MCBrowserViewController * multipeerBrowser;

@property (assign, nonatomic) BOOL connectedToiPod;

@property (strong, nonatomic) NSURLSession * URLsession;
@property (strong, nonatomic) NSString * authTokenStr;
@property (strong, nonatomic) IBOutlet UICollectionView *paletteButtonsCollectionView;

@property (strong, nonatomic) IBOutlet UIView * actionsView;
@property (strong, nonatomic) IBOutlet UIView * paletteView;
@property (strong, nonatomic) IBOutlet UITableView * paletteTableView;
@property (strong, nonatomic) IBOutlet UIView * editView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *rightSideView_SegmentedControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl *leftSideView_SegmentedControl;

@property (strong, nonatomic) AVSpeechSynthesizer * speechSynth;

@property (strong, nonatomic) IBOutlet UITextField * edit_buttonTitle_TextField;
@property (strong, nonatomic) IBOutlet UITextView *edit_actionSpeechPhrase_TextView;
@property (strong, nonatomic) IBOutlet UITextField * edit_actionSpeechRate_TextField;
@property (strong, nonatomic) IBOutlet UIButton *edit_speakPhrase_button;
@property (strong, nonatomic) IBOutlet UIView *edit_buttonColorView;
@property (strong, nonatomic) IBOutlet UILabel     * edit_buttonSize_Label;
@property (strong, nonatomic) IBOutlet UIButton    * edit_showColorPopover_button;
@property (strong, nonatomic) IBOutlet UIButton    * edit_showSizePopover_button;
@property (strong, nonatomic) UIPopoverController * colorPickerViewPopoverController;
@property (strong, nonatomic) UIPopoverController * sizePickerViewPopoverController;

@property (strong, nonatomic) IBOutlet UIButton    * speak_button;
@property (strong, nonatomic) IBOutlet UITextField * speakText_TextField;

@property (strong, nonatomic) IBOutlet UIButton * emote1_button;
@property (strong, nonatomic) IBOutlet UIButton * emote2_button;
@property (strong, nonatomic) IBOutlet UIButton * emote3_button;
@property (strong, nonatomic) IBOutlet UIButton * emote4_button;
@property (strong, nonatomic) IBOutlet UIButton * emote5_button;

@property (strong, nonatomic) IBOutlet UIButton * text1_button;
@property (strong, nonatomic) IBOutlet UIButton * text2_button;
@property (strong, nonatomic) IBOutlet UIButton * text3_button;
@property (strong, nonatomic) IBOutlet UIButton * text4_button;
@property (strong, nonatomic) IBOutlet UIButton * text5_button;


@property (strong, nonatomic) IBOutlet UITextField * loginName_TextField;
@property (strong, nonatomic) IBOutlet UITextField * password_TextFIeld;

@property (strong, nonatomic) IBOutlet UIView *connect_button;
@property (strong, nonatomic) IBOutlet UIButton *logIn_button;

@property (copy, nonatomic) NSArray* paletteTitles;

- (IBAction)textAction:(id)sender;
- (IBAction)emoteAction:(id)sender;

- (IBAction)leftSideViewAction:(id)sender;
- (IBAction)rightSideViewAction:(id)sender;

- (IBAction) connectAction:(id)sender;
- (IBAction) logInAction:(id)sender;

- (IBAction) newButtonAction:(id)sender;
- (IBAction) showColorPopoverAction:(id)sender;
- (IBAction) showSizePopoverAction:(id)sender;
- (IBAction) doActionFromButton:(id)sender;

- (void) setEditButtonColor:(UIColor *) color;
- (void) setEditButtonSize:(NSString *) sizeStr;

- (void) layoutActionViewWithPallete:(NSInteger)index;

@end
