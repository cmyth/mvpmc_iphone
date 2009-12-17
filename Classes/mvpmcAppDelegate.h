//
//  mvpmcAppDelegate.h
//  mvpmc
//
//  Created by Jon Gettler on 12/16/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

@interface mvpmcAppDelegate :
	NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {

	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;	    
	NSPersistentStoreCoordinator *persistentStoreCoordinator;

	UIWindow *window;
	IBOutlet UITabBarController *tabBarController;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

- (NSString *)applicationDocumentsDirectory;

@end

