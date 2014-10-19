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
#import "JSAnalogueStick.h"
#import "ConnectionManager.h"


//Commands
#define kRMBOSpeakPhrase @"kRMBOSpeakPhrase"
#define kRMBOMoveRobot @"kRMBOMoveRobot"
#define kRMBOHeadTilt @"kRMBOHeadTilt"
#define kRMBODebugLogMessage @"kRMBODebugLogMessage"
#define kRMBOTurnInPlaceClockwise @"kRMBOTurnInPlaceClockwise"
#define kRMBOTurnInPlaceCounterClockwise @"kRMBOTurnInPlaceCounterClockwise"
#define kRMBOStopRobotMovement @"kRMBOStopRobotMovement"
#define kRMBOChangeMood @"kRMBOChangeMood"

#define kRMBOMaxMultipeerConnections 2
#define kRMBOServiceType @"origami-romibo"


typedef enum {
    eActionType_talk,
    eActionType_emotion,
    eActionType_drive,
    eActionType_tilt
} eActionType;



@interface MainViewController : UIViewController
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
    UIPopoverControllerDelegate,
    //  UIPickerViewDataSource,
    //  UIPickerViewDelegate,
    UIAlertViewDelegate,
    JSAnalogueStickDelegate,
    ConnectionManagerDelegate
>

@property (nonatomic, strong) MCPeerID *peerID;
@property (strong, nonatomic) MCSession * multipeerSession;
@property (nonatomic, strong) MCBrowserViewController * multipeerBrowser;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;

@property (assign, nonatomic) BOOL connectedToiPod;

@property (strong, nonatomic) NSURLSession * URLsession;
@property (strong, nonatomic) NSString * authTokenStr;
@property (strong, nonatomic) IBOutlet UICollectionView *paletteButtonsCollectionView;

@property (strong, nonatomic) IBOutlet UIView * actionsView;
@property (strong, nonatomic) IBOutlet UIView * paletteView;
@property (strong, nonatomic) IBOutlet UITableView * palettesListingTableView;
@property (strong, nonatomic) IBOutlet UIView * editView;

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

@property (weak, nonatomic) IBOutlet JSAnalogueStick *analogueStickview;


@property (strong, nonatomic) IBOutlet UIView *connectButton;

@property (strong, nonatomic) NSArray* paletteTitles;

// Robot motion
@property (nonatomic, strong) NSTimer *turningTimer;
@property (nonatomic, assign) BOOL isTurningClockwise;
@property (nonatomic, assign) BOOL isTurningCounterclockwise;
@property (nonatomic, assign) CGFloat lastX;
@property (nonatomic, assign) CGFloat lastY;
// Bluetooth connection
@property (nonatomic, assign) BOOL isScanning;
@property (nonatomic, strong) NSDate *lastBTMessageTime;
@property (nonatomic, assign) UInt32 lastBTCommandBytes;

// Hardware state
@property SInt8 last_leftMotor;
@property SInt8 last_rightMotor;
@property UInt8 last_tiltLeftRight;
@property UInt8 last_tiltForwardBack;
@property float leftRightMotorBalance;

@property (nonatomic, assign) BOOL isV6Hardware;

- (IBAction)textAction:(id)sender;
// - (IBAction)emoteAction:(id)sender;


- (IBAction) connectAction:(id)sender;
- (IBAction)toggleTagScanning:(id)sender;

// FIXME: these EditButton methods have no implementations.
// write the implementations or remove the calls to them in buttonSizePickerView
 - (void) setEditButtonColor:(UIColor *) color;
 - (void) setEditButtonSize:(NSString *) sizeStr;

- (void) displayButtonsForSelectedPalette:(NSInteger)index;

- (void)analogueStickDidChangeValue:(JSAnalogueStick *)analogueStick;

//# pragma mark UIPickerViewDataSource Delegate methods
//- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
//- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
//    
@end
