/*
 *  Copyright (C) 2010, Jon Gettler
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

#ifndef MVPMC_H
#define MVPMC_H

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

#include "api.h"

@interface MVPMC : NSObject {
	UIImage *image[7];
	int imageNumber;
}

-(void)popup:(NSString*)title message:(NSString*)message;
-(void)playURL:(NSURL*)URL;
-(void)movieDone:(NSNotification*)note;
-(void)movieLoad:(NSNotification*)note;
-(UIImage*)getBackgroundImage;
-(void)setBackgroundImage:(int)index;

@end

enum mythtv_error {
	MYTHTV_ERROR_NONE = 0,
	MYTHTV_ERROR_CONNECT_FAILED,
};

struct mythtv_episode {
	cmyth_proginfo_t prog;
	cmyth_file_t file;
};

struct mythtv_show {
	char *title;
	int n;
	struct mythtv_episode *episodes;
};

@interface MythTV : NSObject {
	NSString *hostName;
	unsigned short hostPort;
	cmyth_conn_t control;
	cmyth_conn_t event;
	int n;
	struct mythtv_show *shows;
	NSLock *theLock;
	NSThread *controlThread;
}

-(MythTV*)init;

-(int)host:(NSString*)host port: (unsigned short) port;
-(void)connect;
-(void)addProgram:(cmyth_proginfo_t)program;
-(BOOL)isConnected;
-(NSInteger)numberOfSections;
-(NSInteger)numberOfRowsInSection:(NSInteger)section;
-(NSString*)titleForSection:(NSInteger)section;
-(cmyth_proginfo_t)progAtIndexPath:(NSIndexPath*)indexPath;

@end

extern MVPMC *mvpmc;
extern MythTV *mythtv;

#endif /* MVPMC_H */
