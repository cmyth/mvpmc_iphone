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

#include "mvpmc.h"

@implementation MVPMC

-(void)popup:(NSString*)title
     message:(NSString*)message
{
	UIAlertView *alert;
	alert = [[UIAlertView alloc]
			initWithTitle:title
			message:message
			delegate: nil
			cancelButtonTitle:@"Ok"
			otherButtonTitles: nil];
	[alert show];
	[alert release];
}

-(void)movieLoad:(NSNotification*)note
{
	MPMoviePlayerController *player = [note object];

	NSLog(@"preload done");

	NSError *error = [[note userInfo] objectForKey:@"error"];

	if (error == nil) {
		NSLog(@"no preload error");
	} else {
		int e = [error code];
		NSLog(@"preload error %d", e);
		[self popup:@"Error!" message:@"Playback failed!"];
	}

	[[NSNotificationCenter defaultCenter] removeObserver:self
					      name:MPMoviePlayerContentPreloadDidFinishNotification
					      object:player];
}

-(void)movieDone:(NSNotification*)note
{
	MPMoviePlayerController *player = [note object];

	NSLog(@"movie done");

	[[NSNotificationCenter defaultCenter] removeObserver:self
					      name:MPMoviePlayerPlaybackDidFinishNotification
					      object:player];

	[player release];
}

-(void)playURL:(NSURL*)URL
{
	MPMoviePlayerController *player;

	player = [[MPMoviePlayerController alloc] initWithContentURL: URL];

	[[NSNotificationCenter defaultCenter] addObserver:self
					      selector:@selector(movieDone:)
					      name:MPMoviePlayerPlaybackDidFinishNotification
					      object:player];
	[[NSNotificationCenter defaultCenter] addObserver:self
					      selector:@selector(movieLoad:)
					      name:MPMoviePlayerContentPreloadDidFinishNotification
					      object:player];

	[player play];
}

-(UIImage*)getBackgroundImage
{
	return image[imageNumber];
}

-(void)setBackgroundImage:(int)index
{
	if ((index < 0) || (index >= 7)) {
		return;
	}

	imageNumber = index;
}

-(MVPMC*)init
{
	self = [super init];

	imageNumber = 0;

	image[0] = [UIImage imageNamed:@"bricks_background.jpg"];
	image[1] = [UIImage imageNamed:@"crack_background.jpg"];
	image[2] = [UIImage imageNamed:@"granite_background.jpg"];
	image[3] = [UIImage imageNamed:@"ice_background.jpg"];
	image[4] = [UIImage imageNamed:@"plasma_background.jpg"];
	image[5] = [UIImage imageNamed:@"slate_background.jpg"];
	image[6] = [UIImage imageNamed:@"stone_background.jpg"];

	return self;
}

@end
