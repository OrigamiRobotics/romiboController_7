//
//  rmbo_AppDelegate.m
//  romiboController_7
//
//  Created by Tracy Lakin on 4/29/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "rmbo_AppDelegate.h"
#import "rmbo_ViewController.h"
#import "Palette.h"
#import "Action.h"

@implementation rmbo_AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Core Data

- (void)saveContext
{
    NSError *error = nil;
    if (self.managedObjectContext != nil) {
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        self.managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PaletteModel" withExtension:@"momd"];
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PaletteModel.sqlite"];
    
    NSError *error = nil;
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES};
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (url){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Import Pallet?" message:@"Do you want to import this pallet into your library?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Import", nil];
        [alertView show];
        _jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        
    }
    return YES;
}


// Connect to iPod

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSError *error = nil;
        NSData *data = [_jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
//        NSDictionary * paletteDict = jsonDict[@"palette"];
        NSDictionary * paletteDict = jsonDict;
        NSDictionary * actionsDict = paletteDict[@"actions"];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Palette" inManagedObjectContext:self.managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        [request setSortDescriptors:@[descriptor]];

        NSArray *fetchedCategories = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        Palette * palette = [NSEntityDescription insertNewObjectForEntityForName:@"Palette" inManagedObjectContext:self.managedObjectContext];
        
        [palette setIndex:[NSNumber numberWithInteger:fetchedCategories.count + 1]];
        [palette setTitle:paletteDict[@"name"]];

        int32_t index = 0;
        for (NSDictionary *actionDict in actionsDict) {
            NSLog(@"actionDict: %@", actionDict);
            NSLog(@"buttonTitle    : %@", actionDict[@"buttonTitle"] );
            NSLog(@"speechPhrase   : %@", actionDict[@"speechPhrase"] );
            NSLog(@"speechSpeedRate: %@", actionDict[@"speechSpeedRate"] );
            NSLog(@"index          : %d", index);

            Action * action = [NSEntityDescription insertNewObjectForEntityForName:@"Action" inManagedObjectContext:self.managedObjectContext];
            [action setSpeechText:actionDict[@"speechPhrase"]];
            [action setTitle:actionDict[@"buttonTitle"]];
            [action setSpeechSpeed:actionDict[@"speechSpeedRate"]];
            [action setIndex:[NSNumber numberWithInt:index]];
            index++;
            
            [action setAction:nil];
            [action setPalette:palette];
            NSSet * actionSet = [NSSet setWithObject:action];
            [palette addAction:actionSet];
            
            NSLog(@"        action: %@", action);
        }
        
        [self.managedObjectContext save:nil];
        
        NSArray * fetchedPalettes = [self.managedObjectContext executeFetchRequest:request error:&error];
        NSLog(@"fetchedPalettes: %@", fetchedPalettes);

        rmbo_ViewController * mainViewController = (rmbo_ViewController *)  self.window.rootViewController;
        
        [mainViewController.paletteTableView reloadData];
        [mainViewController layoutActionViewWithPallete: [palette.index intValue]];

    }
}



@end
