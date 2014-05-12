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

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session;

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


const NSString * kRomiboWebURL = @"http://create.romibo.com";
const NSString * kRomiboWebURL_login = @"/api/v1/login";
const NSString * kRomiboWebURL_palettes = @"/api/v1/palettes";



- (IBAction) logInAction:(id)sender
{
    NSString * logInName = self.loginName_TextField.text;
    NSString * password  = self.password_TextFIeld.text;

    
    NSString * loginStrURL = [kRomiboWebURL stringByAppendingString:(NSString*)kRomiboWebURL_login];
    
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{
                                                   @"Content-Type"  : @"application/json"
                                                   };
    
    self.URLsession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];

#define auto_login 1
#if auto_login
    NSString * loginStrParams = @"{\"user\": {\"email\":\"tracy_lakin@earthlink.net\",\"password\":\"tracyromibo\"}}";
#else
    NSString * kLoginStrParams = @"{\"user\": {\"email\":\"%@\",\"password\":\"%@\"}}";
    NSString * loginStrParams = [NSString stringWithFormat:kLoginStrParams, logInName, password];
#endif
    
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
//            NSLog(@"buttonsDict: %@", buttonsDict);
//            NSLog(@"theButtonDict: %@", theButtonDict);
            
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
                [buttonEntity setWidth:[NSNumber numberWithInt:1]];
                [buttonEntity setHeight:[NSNumber numberWithInt:1]];
            }
            else if ([size isEqualToString:@"Medium"])
            {
                [buttonEntity setWidth:[NSNumber numberWithInt:2]];
                [buttonEntity setHeight:[NSNumber numberWithInt:1]];
            }
            else if ([size isEqualToString:@"Large"])
            {
                [buttonEntity setWidth:[NSNumber numberWithInt:4]];
                [buttonEntity setHeight:[NSNumber numberWithInt:1]];
            }
 
            [buttonEntity setPalette:newPaletteEntity];
            numButtons++;
            [buttonEntity setIndex:[NSNumber numberWithInt:(uint32_t)numButtons]];
            NSLog(@"numButtons          : %d", (uint32_t)numButtons);
            
            ActionEntity * actionEntity = [NSEntityDescription insertNewObjectForEntityForName:@"ActionEntity" inManagedObjectContext:appDelegate.managedObjectContext];
            [actionEntity setSpeechText:theButtonDict[@"speech_phrase"]];
            [actionEntity setSpeechSpeed:theButtonDict[@"speech_speed_rate"]];
            [actionEntity setActionType:[NSNumber numberWithInt:eActionType_talk]];
            numActions++;
            [actionEntity setIndex: [NSNumber numberWithInt:(uint32_t)numActions]];
            NSLog(@"numActions          : %d", (uint32_t)numActions);
            
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

    dispatch_sync(dispatch_get_main_queue(), ^{
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




#pragma mark - action button view

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];

    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip # if it appears
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
} 



const CGFloat kButtonSizeUnit     =  50.0;

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

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PaletteEntity" inManagedObjectContext:appDelegate.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    [request setSortDescriptors:@[descriptor]];

    NSError * error;
    NSArray * fetchedPalettes = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"fetchedPalettes: %@", fetchedPalettes);
    
    if (index >= fetchedPalettes.count)
        return;
    
    PaletteEntity * palette = fetchedPalettes[index];
    NSSet * buttons = palette.buttons;
    
    NSSortDescriptor *actionSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSArray * sortDescArray = [NSArray arrayWithObject:actionSortDescriptor];
    NSArray * sortedButtons = [buttons sortedArrayUsingDescriptors:sortDescArray];

    ButtonEntity * firstButton = sortedButtons[0];
    BOOL hasRowCol = [firstButton.width integerValue] != 0;

    NSInteger max_columns = 6;      // right now no size info. So use all medium buttons. Allow 6 max in 630 pixel wide view.
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
            UIColor * buttonColor = [self colorWithHexString:buttonEntity.color];
//            [actionButton setTintColor:buttonTintColor];
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
    uint32_t index = (uint32_t)indexPath.row;

    NSArray * subViews = [self.actionsView subviews];
    for (UIView * subView in subViews)
    {
        [subView removeFromSuperview];
    }

    [self layoutActionViewWithPallete:index];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

@end
