/*
 *  Copyright (C) 2009-2010, Jon Gettler
 *  http://www.mvpmc.org/
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#import <UIKit/UIKit.h>

#import <api.h>

@interface MythViewController : UITableViewController {
	cmyth *myth;
	cmythProgramList *list;
	NSMutableArray *sections;
	NSMutableArray *counts;
	UIActivityIndicatorView *active;
	NSLock *lock;
	NSString *ip;
}

-(void)connect;
-(void)populateTable;
-(void)eraseTable;
-(void)loadData;
-(void)popup:(NSString*)title message:(NSString*)message;
-(void)busy:(BOOL)on;

-(cmythProgram*)atSection:(int)section atRow:(int)row;

@property (retain,nonatomic) NSLock *lock;

@end