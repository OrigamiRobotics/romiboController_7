//
//  rmbo_ViewController.m
//  romiboController_7
//
//  Created by Tracy Lakin on 4/29/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "rmbo_ViewController.h"
#import "rmbo_AppDelegate.h"
#import "Palette.h"
#import "Action.h"

@interface rmbo_ViewController ()

@end

@implementation rmbo_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.connectedToiPod = NO;
    
    [self setupMultipeerConnectivity];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self.multipeerSession disconnect];
        self.connectedToiPod = NO;
        [self setupMultipeerConnectivity];
    }
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
    RMBOEyeBlink
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

- (IBAction)textAction:(id)sender
{
    UIButton * button = (UIButton *)sender;
    UILabel * textToSpeak = button.titleLabel;
    NSLog(@"textAction  speak: %@", textToSpeak.text);
    
    float speechRate = 0.2;
    [self sendSpeechPhraseToRobot:textToSpeak.text atSpeechRate:speechRate];
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
    else {
        return;
    }
    
    if (self.connectedToiPod) {
        NSDictionary *params = @{@"command" : kRMBOChangeMood, @"mood" : mood};
        NSData *paramsData = [NSKeyedArchiver archivedDataWithRootObject:params];
        [self sendDataToRobot:paramsData];
    }
}

- (IBAction)driveAction:(id)sender
{

}

#define kRomiboWebServer @"create.romibo.com"

- (IBAction) logInAction:(id)sender
{
    NSString * logInName = self.loginName_TextField.text;
    NSString * password  = self.password_TextFIeld.text;

    NSLog(@"Logging Into %@   with name: %@  password: %@ ", kRomiboWebServer, logInName, password);
}

#pragma mark - action button view

const CGFloat kSmallButtonWidth     =  50.0;
const CGFloat kMediumButtonWidth    = 102.0;
const CGFloat kLargeButtonWidth     = 206.0;
const CGFloat kButtonSeparatorWidth =   2.0;
const CGFloat kButtonHeight         =  50.0;

const CGFloat kButtonInset_x =   4.0;
const CGFloat kButtonInset_y =   4.0;


- (void) layoutActionViewWithPallete:(uint32_t)index
{
    rmbo_AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Palette" inManagedObjectContext:appDelegate.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    [request setSortDescriptors:@[descriptor]];

    NSError * error;
    NSArray * fetchedPalettes = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"fetchedPalettes: %@", fetchedPalettes);
    
    if (index >= fetchedPalettes.count)
        return;
    
    Palette * palette = fetchedPalettes[index];
    NSSet * actions = palette.action;
    
    NSSortDescriptor *actionSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSArray * sortDescArray = [NSArray arrayWithObject:actionSortDescriptor];
    NSArray * sortedActions = [actions sortedArrayUsingDescriptors:sortDescArray];


    NSInteger max_columns = 6;      // right now no size info. So use all medium buttons. Allow 6 max in 630 pixel wide view.
    NSInteger current_row = 0;
    NSInteger current_column = 0;
    for (Action * action in sortedActions) {
        
        NSLog(@"action: %@", action);
        NSLog(@"action   title     : %@", action.title);
        NSLog(@"action   SpeechText: %@", action.speechText);
        NSLog(@"action   index     : %@", action.index);
 
        if (current_column == max_columns)
        {
            current_column = 0;
            current_row++;
        }

        CGFloat xPosition = kButtonInset_x + (current_column * (kMediumButtonWidth + kButtonSeparatorWidth));
        CGFloat yPosition = kButtonInset_y + (current_row    * (kButtonHeight + kButtonSeparatorWidth));
        NSLog(@"xPosition: %f   yPosition: %f", xPosition, yPosition);

        UIButton * actionButton = [UIButton buttonWithType:UIButtonTypeCustom];

        UIFont * titleFont = [UIFont fontWithName:@"Helvetica" size:14.0];
        NSDictionary * titleStringAttrDict = [NSDictionary dictionaryWithObjectsAndKeys:titleFont, NSFontAttributeName, nil];

        NSAttributedString * attrString = [[NSAttributedString alloc] initWithString:action.title attributes:titleStringAttrDict];
        [actionButton setAttributedTitle:attrString forState:UIControlStateNormal];

        [actionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        [actionButton setBackgroundImage: [UIImage imageNamed:@"smActionButton"]
                      forState: UIControlStateNormal];

//        UIImage *buttonImage = [UIImage imageNamed:@"smActionButton" withTintColor:[action buttonColor]];
//        [actionButton setTintColor:[action buttonTitleColor]];

        CGRect actionFrame      = actionButton.frame;
        actionFrame.origin.x    = xPosition;
        actionFrame.origin.y    = yPosition;
        actionFrame.size.height = kButtonHeight;
        actionFrame.size.width  = kMediumButtonWidth;

        actionButton.frame = actionFrame;
        actionButton.titleLabel.frame = actionFrame;

        [self.actionsView addSubview:actionButton];

        current_column++;
    }
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
    rmbo_AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Palette" inManagedObjectContext:appDelegate.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError * error;
    NSArray * fetchedPalettes = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"fetchedPalettes: %@", fetchedPalettes);
    if (fetchedPalettes != nil) {
        Palette * palette = fetchedPalettes[0];
        cell.textLabel.text = palette.title;
    }
    else {
        cell.textLabel.text = @"";
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    rmbo_AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Palette" inManagedObjectContext:appDelegate.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];

    NSError * error;
    NSArray * fetchedPalettes = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"fetchedPalettes: %@", fetchedPalettes);
    
    NSInteger count = fetchedPalettes.count;
    return count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    uint32_t index = (uint32_t)indexPath.row;
    [self layoutActionViewWithPallete:index];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

@end
