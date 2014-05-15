//
//  rmbo_ViewController.m
//  romiboController_7
//
//  Created by Tracy Lakin on 4/29/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "rmbo_ViewController.h"
#import "rmbo_AppDelegate.h"
#import "PaletteEntity.h"
#import "ButtonEntity.h"
#import "ActionEntity.h"
#import "colorPickerViewController.h"
#import "buttonSizePickerViewController.h"
#import "UIColor+RMBOColors.h"

@interface rmbo_ViewController ()

@end

@implementation rmbo_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.connectedToiPod = NO;
    
    colorPickerViewController * colorPickerVC = [[colorPickerViewController alloc] init];
    colorPickerVC.mainViewController = self;

    CGRect colorFrame = colorPickerVC.view.frame;
    self.colorPickerViewPopoverController = [[UIPopoverController alloc] initWithContentViewController:colorPickerVC];
	self.colorPickerViewPopoverController.popoverContentSize = CGSizeMake(colorFrame.size.width, colorFrame.size.height);
    self.colorPickerViewPopoverController.backgroundColor = [UIColor lightGrayColor];
	self.colorPickerViewPopoverController.delegate = self;
    
    buttonSizePickerViewController * sizePickerVC = [[buttonSizePickerViewController alloc] init];
    sizePickerVC.mainViewController = self;

    CGRect sizeFrame = sizePickerVC.view.frame;
    self.sizePickerViewPopoverController = [[UIPopoverController alloc] initWithContentViewController:sizePickerVC];
	self.sizePickerViewPopoverController.popoverContentSize = CGSizeMake(sizeFrame.size.width, sizeFrame.size.height);
    self.sizePickerViewPopoverController.backgroundColor = [UIColor lightGrayColor];
	self.sizePickerViewPopoverController.delegate = self;

    self.speechSynth = [[AVSpeechSynthesizer alloc] init];

    [self setupMultipeerConnectivity];
    
    // UI specific
    
    self.edit_buttonColorView.backgroundColor = [UIColor rmbo_emeraldColor];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self layoutActionViewWithPallete: 0];      // Select first palette in table.
    });
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
    
    NSIndexPath * paletteIndexPath = self.paletteTableView.indexPathForSelectedRow;
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
        [self.paletteTableView reloadData];
        [self layoutActionViewWithPallete: paletteIndexPath.row];
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


#pragma mark - Server, Login

const NSString * kRomiboWebURL          = @"http://create.romibo.com";
const NSString * kRomiboWebURL_login    = @"/api/v1/login";
const NSString * kRomiboWebURL_palettes = @"/api/v1/palettes";

- (IBAction) logInAction:(id)sender
{
    NSString * logInName = self.loginName_TextField.text;
    NSString * password  = self.password_TextFIeld.text;

    BOOL doBuitInLogin = NO;
    if (   [logInName isEqualToString:@""]
        || [password  isEqualToString:@""] )
    {
        doBuitInLogin = YES;
    }
    
    NSString * loginStrURL = [kRomiboWebURL stringByAppendingString:(NSString*)kRomiboWebURL_login];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json"};
    
    self.URLsession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];

    NSString * loginStrParams = @"";

    if (doBuitInLogin == YES)
    {
        loginStrParams = @"{\"user\": {\"email\":\"tracy_lakin@earthlink.net\",\"password\":\"tracyromibo\"}}";
    }
    else
    {
        NSString * kLoginStrParams = @"{\"user\": {\"email\":\"%@\",\"password\":\"%@\"}}";
        loginStrParams = [NSString stringWithFormat:kLoginStrParams, logInName, password];
    }

    NSURL *url = [NSURL URLWithString:loginStrURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPBody = [loginStrParams dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    NSURLSessionDataTask *postDataTask = [self.URLsession dataTaskWithRequest:request
                                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                          {
//                                              NSLog(@"postDataTask completion error: %@   response: %@   data: %@", error, response, data);

                                              NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                                              NSLog(@"Login data as json: %@", json);
                                              
                                              NSString * tokenStr     = @"Token token=";
                                              NSString * jsonTokenStr = [json objectForKey:@"auth_token"];
                                              self.authTokenStr = [tokenStr stringByAppendingString:jsonTokenStr];
                                              
                                              NSLog(@"loginStrURL: %@",  loginStrURL);
                                              NSLog(@"jsonTokenStr: %@", jsonTokenStr);
                                              NSLog(@"authTokenStr: %@", self.authTokenStr);
                                          }];
    [postDataTask resume];

}



- (IBAction) fetchPalettes:(id)sender
{
    NSString * loginStrURL  = [kRomiboWebURL stringByAppendingString:(NSString*)kRomiboWebURL_palettes];

    NSURL * url = [NSURL URLWithString:loginStrURL];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:self.authTokenStr forHTTPHeaderField:@"Authorization"];
    
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *postDataTask = [self.URLsession dataTaskWithRequest:request
                                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                          {
//                                              NSLog(@"fetchPalettesFromWeb postDataTask completion error: %@   response: %@   data: %@", error, response, data);
                                              NSDictionary *paletteDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                              [self parsePalettes:paletteDict];
                                          }];
    [postDataTask resume];
}


- (void) parsePalettes:(NSDictionary *)paletteDict
{
    NSLog(@"paletteDict: %@", paletteDict);
    
    
    rmbo_AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    
    
    NSError * error;

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PaletteEntity" inManagedObjectContext:appDelegate.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    [request setSortDescriptors:@[descriptor]];
    
    NSArray *fetchedPalettes = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    
    entity = [NSEntityDescription entityForName:@"ButtonEntity" inManagedObjectContext:appDelegate.managedObjectContext];
    request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    descriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    [request setSortDescriptors:@[descriptor]];
    
    NSArray *fetchedButtons = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    
    entity = [NSEntityDescription entityForName:@"ActionEntity" inManagedObjectContext:appDelegate.managedObjectContext];
    request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    descriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    [request setSortDescriptors:@[descriptor]];
    
    NSArray *fetchedActions = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    
    
    NSUInteger numPalettes = fetchedPalettes.count;
    NSUInteger numButtons  = fetchedButtons.count;
    NSUInteger numActions  = fetchedActions.count;

    
    
    
    NSDictionary * palettes = paletteDict[@"palettes"];
    for (NSDictionary *palette in palettes) {
        NSLog(@"palette: %@", palette);
        PaletteEntity * newPaletteEntity = [NSEntityDescription insertNewObjectForEntityForName:@"PaletteEntity" inManagedObjectContext:appDelegate.managedObjectContext];

        NSDictionary * thePaletteDict = palette[@"palette"];
        NSLog(@"thePaletteDict: %@", thePaletteDict);

        numPalettes++;
        [newPaletteEntity setIndex:[NSNumber numberWithInteger:numPalettes]];
        [newPaletteEntity setTitle:thePaletteDict[@"title"]];
//        [newPalette setColor:thePaletteDict[@"color"]];   // Deal with nil  TODO:
        
        
        NSDictionary * buttons = thePaletteDict[@"buttons"];

        for (NSDictionary *buttonsDict in buttons) {
            NSDictionary * theButtonDict = buttonsDict[@"button"];
            
            NSLog(@"buttonTitle    : %@", theButtonDict[@"title"] );
            NSLog(@"speechPhrase   : %@", theButtonDict[@"speech_phrase"] );
            NSLog(@"speechSpeedRate: %@", theButtonDict[@"speech_speed_rate"] );
            NSLog(@"size           : %@", theButtonDict[@"size"] );

            ButtonEntity * buttonEntity = [NSEntityDescription insertNewObjectForEntityForName:@"ButtonEntity" inManagedObjectContext:appDelegate.managedObjectContext];
            
            [buttonEntity setTitle :theButtonDict[@"title"]];
            [buttonEntity setColor :theButtonDict[@"color"]];
            [buttonEntity setRow   :theButtonDict[@"row"]];
            [buttonEntity setColumn:theButtonDict[@"col"]];
            NSString * size = theButtonDict[@"size"];
            if ([size isEqualToString:@"Small"])
            {
                [buttonEntity setWidth:  [NSNumber numberWithInt:1]];
                [buttonEntity setHeight: [NSNumber numberWithInt:1]];
            }
            else if ([size isEqualToString:@"Medium"])
            {
                [buttonEntity setWidth:  [NSNumber numberWithInt:2]];
                [buttonEntity setHeight: [NSNumber numberWithInt:1]];
            }
            else if ([size isEqualToString:@"Large"])
            {
                [buttonEntity setWidth:  [NSNumber numberWithInt:4]];
                [buttonEntity setHeight: [NSNumber numberWithInt:1]];
            }
 
            [buttonEntity setPalette:newPaletteEntity];
            numButtons++;
            [buttonEntity setIndex:[NSNumber numberWithInt:(uint32_t)numButtons]];
            
            ActionEntity * actionEntity = [NSEntityDescription insertNewObjectForEntityForName:@"ActionEntity" inManagedObjectContext:appDelegate.managedObjectContext];
            [actionEntity setSpeechText:theButtonDict[@"speech_phrase"]];
            [actionEntity setSpeechSpeed:theButtonDict[@"speech_speed_rate"]];
            [actionEntity setActionType:[NSNumber numberWithInt:eActionType_talk]];
            numActions++;
            [actionEntity setIndex: [NSNumber numberWithInt:(uint32_t)numActions]];
            
            [actionEntity setActions:nil];
            [actionEntity setButton:buttonEntity];
            
            NSSet * actionsSet = [NSSet setWithObject:actionEntity];
            [buttonEntity setActions:actionsSet];
            
            NSSet * buttonSet = [NSSet setWithObject:buttonEntity];
            if (newPaletteEntity.buttons == nil) {
                [newPaletteEntity addButtons:buttonSet];
            }
            else {
                NSMutableSet *newSet = [[NSMutableSet alloc] init];
                [newSet setSet:newPaletteEntity.buttons];
                [newSet unionSet:buttonSet];
                [newPaletteEntity addButtons:newSet];
            }
        }
    }
    
    [appDelegate.managedObjectContext save:nil];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.paletteTableView reloadData];
        [self layoutActionViewWithPallete: 0];
    });


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
const CGFloat kLargeButtonWidth     = 206.0;
const CGFloat kButtonSeparatorWidth =   2.0;
const CGFloat kButtonHeight         =  50.0;

const CGFloat kButtonInset_x =   4.0;
const CGFloat kButtonInset_y =   4.0;


- (void) layoutActionViewWithPallete:(NSInteger)row
{
    if ([self.paletteTableView numberOfRowsInSection:0] == 0)
        return;

    
    rmbo_AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.paletteTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PaletteEntity" inManagedObjectContext:appDelegate.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    [request setSortDescriptors:@[descriptor]];

    NSError * error;
    NSArray * fetchedPalettes = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"fetchedPalettes: %@", fetchedPalettes);
    
    if (row >= fetchedPalettes.count)
        return;
    
    PaletteEntity * palette = fetchedPalettes[row];
    NSSet * buttons = palette.buttons;
    
    NSSortDescriptor *actionSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSArray * sortDescArray = [NSArray arrayWithObject:actionSortDescriptor];
    NSArray * sortedButtons = [buttons sortedArrayUsingDescriptors:sortDescArray];

    ButtonEntity * firstButton = sortedButtons[0];
    BOOL hasRowCol = [firstButton.width integerValue] != 0;

    NSInteger max_columns = 6;      // Allow 6 max in 630 pixel wide view.
    NSInteger current_row = 0;
    NSInteger current_column = 0;
    for (ButtonEntity * buttonEntity in sortedButtons) {
        
        NSLog(@"buttonEntity: %@", buttonEntity);
        
        NSLog(@"buttonEntity   title     : %@", buttonEntity.title);
        NSLog(@"buttonEntity   index     : %@", buttonEntity.index);
 
        if (current_column == max_columns)
        {
            current_column = 0;
            current_row++;
        }

        CGFloat xPosition = 0;
        CGFloat yPosition = 0;
        if (hasRowCol == YES) {
            NSInteger zeroBasedRow    = [buttonEntity.row integerValue] - 1;
            NSInteger zeroBasedColumn = [buttonEntity.column integerValue] - 1;
            xPosition = kButtonInset_x + (zeroBasedColumn * (kButtonSizeUnit + kButtonSeparatorWidth));
            yPosition = kButtonInset_y + (zeroBasedRow    * (kButtonSizeUnit + kButtonSeparatorWidth));
            NSLog(@"xPosition: %f   yPosition: %f", xPosition, yPosition);
        }
        else {
            xPosition = kButtonInset_x + (current_column * (kMediumButtonWidth + kButtonSeparatorWidth));
            yPosition = kButtonInset_y + (current_row    * (kButtonHeight + kButtonSeparatorWidth));
            NSLog(@"xPosition: %f   yPosition: %f", xPosition, yPosition);
        }

        UIButton * actionButton = [UIButton buttonWithType:UIButtonTypeCustom];

        UIFont * titleFont = [UIFont fontWithName:@"Helvetica" size:14.0];
        NSDictionary * titleStringAttrDict = [NSDictionary dictionaryWithObjectsAndKeys:titleFont, NSFontAttributeName, nil];

        NSAttributedString * attrString = [[NSAttributedString alloc] initWithString:buttonEntity.title attributes:titleStringAttrDict];
        [actionButton setAttributedTitle:attrString forState:UIControlStateNormal];

        [actionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];


        if (hasRowCol == YES)
        {
            UIColor * buttonColor = [UIColor colorWithHexString:buttonEntity.color];
            [actionButton setBackgroundColor:buttonColor];
        }

//        [actionButton setBackgroundImage: [UIImage imageNamed:@"smActionButton"]
//                                forState: UIControlStateNormal];

        CGRect actionFrame      = actionButton.frame;
        actionFrame.origin.x    = xPosition;
        actionFrame.origin.y    = yPosition;
        
        if (hasRowCol == YES)
        {
            actionFrame.size.height = kButtonHeight;
            
            NSInteger widthUnits = [buttonEntity.width integerValue];
            NSInteger internalSpacing = (widthUnits - 1) * kButtonSeparatorWidth;
            actionFrame.size.width    = (widthUnits * kButtonSizeUnit) + internalSpacing;
        }
        else
        {
            actionFrame.size.height = kButtonHeight;
            actionFrame.size.width  = kMediumButtonWidth;
        }

        NSLog(@"actionFrame: %@", NSStringFromCGRect(actionFrame));

        actionButton.frame = actionFrame;
        actionButton.titleLabel.frame = actionFrame;

        [actionButton addTarget:self action:@selector(doActionFromButton:) forControlEvents:UIControlEventTouchUpInside];

        actionButton.tag = [buttonEntity.index integerValue]; // To fetch button and action from button press

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
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PaletteEntity" inManagedObjectContext:appDelegate.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    [request setSortDescriptors:@[descriptor]];

    NSError * error;
    NSArray * fetchedPalettes = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
//    NSLog(@"fetchedPalettes: %@", fetchedPalettes);
    if (fetchedPalettes != nil) {
        PaletteEntity * palette = fetchedPalettes[indexPath.row];
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

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PaletteEntity" inManagedObjectContext:appDelegate.managedObjectContext];
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

    NSArray * subViews = [self.actionsView subviews];
    for (UIView * subView in subViews)
    {
        [subView removeFromSuperview];
    }

    [self layoutActionViewWithPallete:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

@end
