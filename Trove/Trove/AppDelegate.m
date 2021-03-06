//
//  AppDelegate.m
//  Trove
//
//  Created by Dana Smith on 9/9/12.
//  Copyright (c) 2012 Dana Smith. All rights reserved.
//

#import "AppDelegate.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "Print.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (AppDelegate *)appDelegate
{
	return [UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop)
	 {
		 if( group == nil )
		 {
			 *stop = YES;
			 __autoreleasing NSError *error = nil;
			 [self.managedObjectContext save:&error];
			 if (nil != error)
			 {
				 NSLog(@"Error saving context %@", error.localizedDescription);
				 error = nil;
			 }
		 }
		 else
		 {
			 [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index,BOOL *stop) {
				 if (asset)
				 {
					 ALAssetRepresentation *rep = [asset defaultRepresentation];
					 NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Print"];
					 request.predicate = [NSPredicate predicateWithFormat:@"url LIKE %@", rep.url.absoluteString];
					 
					 __autoreleasing NSError *error = nil;
					 NSArray *foundPrints = [self.managedObjectContext executeFetchRequest:request error:&error];
					 
					 if (nil != error)
					 {
						 NSLog(@"Error executing fetch to find items in album: %@", error.localizedDescription);
					 }
					 
					 if (foundPrints.count > 1) {
						 NSLog(@"Error - print %@ found %i times", rep.url.absoluteString, foundPrints.count);
					 }
					 
					 if (foundPrints.count == 0)
					 {
						 // This is a new image. We need to add a print for it.
						 Print *newPrint = [NSEntityDescription insertNewObjectForEntityForName:@"Print" inManagedObjectContext:self.managedObjectContext];
						 newPrint.url = rep.url.absoluteString;
					 }
				 }
				 else
				 {
					 *stop = YES;
				 }
			 }];
		 }
	 }
	 failureBlock:^(NSError *error){
		 
	 }];
	

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


#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
	if (_managedObjectContext != nil)
	{
		return _managedObjectContext;
	}
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil)
	{
		_managedObjectContext = [[NSManagedObjectContext alloc] init];
		[_managedObjectContext setPersistentStoreCoordinator:coordinator];
		
		_managedObjectContext.undoManager = [[NSUndoManager alloc] init];
	}
	return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
	if (_managedObjectModel != nil)
	{
		return _managedObjectModel;
	}
	
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TroveDataModel" withExtension:@"momd"];
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	
	return _managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (_persistentStoreCoordinator != nil)
	{
		return _persistentStoreCoordinator;
	}
	
	NSURL *appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
	NSURL *storeURL = [appSupportURL URLByAppendingPathComponent:@"Trove.sqlite"];
	
	NSError *error = nil;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
	{
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a
		 shipping application, although it may be useful during development.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible;
		 * The schema for the persistent store is incompatible with current managed object model.
		 Check the error message to determine what the actual problem was.
		 
		 
		 If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file
		 URL is pointing into the application's resources directory instead of a writeable directory.
		 
		 If you encounter schema incompatibility errors during development, you can reduce their frequency by:
		 * Simply deleting the existing store:
		 [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
		 
		 * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
		 [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
		 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
		 
		 Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data
		 Migration Programming Guide" for details.
		 */
		
		NSLog(@"Error loading the persistent store.  Probably scheme related.  Deleting and trying again");
		
		// We're going to be making a lot of changes to the schema, so for now let's just delete the store and start new.
		// We should probably try the automatic migration, but for now, just bail.
		BOOL removedSuccessfully = [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
		
		if(removedSuccessfully == NO)
		{
			/*Maybe the Application Support Directory isn't there, lets try creating it*/
			[[NSFileManager defaultManager] createDirectoryAtPath:[appSupportURL path] withIntermediateDirectories:NO attributes:nil error:&error];
		}
		
		_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
		if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
		{
			NSLog(@"Ok, that wasn't it.  Here's the error: %@, %@", error, [error userInfo]);
			abort();
		}
		
		// Stop iOS from saving the database to the cloud.
		NSError *error = nil;
		BOOL success = [storeURL setResourceValue: [NSNumber numberWithBool: YES]
										   forKey: NSURLIsExcludedFromBackupKey error: &error];
		if(!success){
			NSLog(@"Error excluding %@ from backup %@", [storeURL lastPathComponent], error);
		}
	}
	
	return _persistentStoreCoordinator;
}

@end
