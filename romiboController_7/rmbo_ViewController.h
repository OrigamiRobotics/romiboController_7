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

@interface rmbo_ViewController : UIViewController
<
    UITableViewDataSource,
    UITableViewDelegate,
    MCSessionDelegate,
    MCBrowserViewControllerDelegate
>

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


@property (strong, nonatomic) MCSession * multipeerSession;
@property (nonatomic, strong) MCBrowserViewController * multipeerBrowser;

@property (assign, nonatomic) BOOL connectedToiPod;

@property (strong, nonatomic) IBOutlet UIView * actionsView;
@property (strong, nonatomic) IBOutlet UIView * paletteView;
@property (strong, nonatomic) IBOutlet UITableView * paletteTableView;
@property (strong, nonatomic) IBOutlet UIView * editView;

@property (strong, nonatomic) IBOutlet UIButton * emote1_button;
@property (strong, nonatomic) IBOutlet UIButton * emote2_button;
@property (strong, nonatomic) IBOutlet UIButton * emote3_button;
@property (strong, nonatomic) IBOutlet UIButton * emote4_button;

@property (strong, nonatomic) IBOutlet UIButton * text1_button;
@property (strong, nonatomic) IBOutlet UIButton * text2_button;
@property (strong, nonatomic) IBOutlet UIButton * text3_button;
@property (strong, nonatomic) IBOutlet UIButton * text4_button;
@property (strong, nonatomic) IBOutlet UIButton * text5_button;

@property (strong, nonatomic) IBOutlet UIButton * drive_button;

@property (strong, nonatomic) IBOutlet UITextField * loginName_TextField;
@property (strong, nonatomic) IBOutlet UITextField * password_TextFIeld;

@property (strong, nonatomic) IBOutlet UIView *connect_button;
@property (strong, nonatomic) IBOutlet UIButton *logIn_button;

- (IBAction)textAction:(id)sender;
- (IBAction)emoteAction:(id)sender;
- (IBAction)driveAction:(id)sender;

- (IBAction) connectAction:(id)sender;
- (IBAction) logInAction:(id)sender;

- (void) layoutActionViewWithPallete:(uint32_t)index;

@end
