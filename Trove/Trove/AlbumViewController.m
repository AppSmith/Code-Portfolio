//
//  ViewController.m
//  Trove
//
//  Created by Dana Smith on 9/9/12.
//  Copyright (c) 2012 Dana Smith. All rights reserved.
//

#import "AlbumViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "AppDelegate.h"
#import "Print.h"

const NSUInteger kHorizontalSpace = 10.0;
const NSUInteger kVerticalSpace = 10.0;

@interface AlbumViewController ()
{
	NSFetchedResultsController *resultsController;
}

@end

@implementation AlbumViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	AppDelegate *appDelegate = [AppDelegate appDelegate];
	__autoreleasing NSError *error = nil;
	
	NSFetchRequest *allPrintsRequest = [NSFetchRequest fetchRequestWithEntityName:@"Print"];
	NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"url" ascending:YES];
	allPrintsRequest.sortDescriptors = @[sortOrder];
	resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:allPrintsRequest
															managedObjectContext:appDelegate.managedObjectContext
															  sectionNameKeyPath:nil
																	   cacheName:nil];
	resultsController.delegate = self;
	
	[resultsController performFetch:&error];
	if (nil != error)
	{
		NSLog(@"Error with fetch results controller: %@", error.localizedDescription);
		error = nil;
	}
	
	[self refreshView];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	for (UIView *view in self.view.subviews)
	{
		[view removeFromSuperview];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

#pragma mark - Fetch Results Controller Delegate

- (void)refreshView
{
	for (UIView *view in self.view.subviews)
	{
		[view removeFromSuperview];
	}
	
	// Make sure we have all the images from the device represented in the prints database.
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	NSArray *allPrints = [resultsController fetchedObjects];
	
	__block CGPoint position = CGPointMake(kHorizontalSpace, kVerticalSpace);
	__block CGFloat maxY = 0;
	
	for (Print *print in allPrints)
	{
		[library assetForURL:[NSURL URLWithString:print.url] resultBlock:^(ALAsset *asset)
		 {
			 CGImageRef printImage = [asset thumbnail];
			 UIImageView *printView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:printImage]];
			 
			 // We've hit the end of the row; start a new row by descending the distance of the largest thumbnail we've hit on this row.
			 if (position.x + CGImageGetWidth(printImage) > self.view.bounds.size.width)
			 {
				 position.x = kHorizontalSpace;
				 position.y += maxY + kVerticalSpace;
				 maxY = 0;
			 }
			 
			 // Set the frame and add the view
			 printView.frame = CGRectMake(position.x, position.y, CGImageGetWidth(printImage), CGImageGetHeight(printImage));
			 [self.view addSubview:printView];
			 
			 // Set up the positioning for the next image
			 position.x = position.x + CGImageGetWidth(printImage) + kHorizontalSpace;
			 if (CGImageGetHeight(printImage) > maxY)
			 {
				 // We need to remember the highest thumbnail so we know how far down the next row should start.
				 maxY = CGImageGetHeight(printImage);
			 }
		 }
		 
				failureBlock:^(NSError *error) {
					
				}];
	}
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self refreshView];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
	if (type == NSFetchedResultsChangeUpdate)
	{
		// This is an excessive response - I should just add the one that's new.
//		[self refreshView];
	}
}

@end
