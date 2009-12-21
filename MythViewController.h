//
//  MythViewController.h
//  mvpmc
//
//  Created by Jon Gettler on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <api.h>

@interface MythViewController : UITableViewController {
	cmyth *myth;
	cmythProgramList *list;
	NSMutableArray *sections;
	NSMutableArray *counts;
}

-(void)connect;
-(void)populateTable;

@end
