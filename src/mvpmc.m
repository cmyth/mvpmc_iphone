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
	MPMovieLoadState loadState;
	MPMoviePlaybackState playState;

	MVPMCLog(@"preload done");

	loadState = [player loadState];
	playState = [player playbackState];

	MVPMCLog(@"load state %d player state %d", loadState, playState);

	NSError *error = [[note userInfo] objectForKey:@"error"];

	if (error == nil) {
		MVPMCLog(@"no preload error");
	} else {
		MVPMCLog(@"preload error %d", [error code]);
		[self popup:@"Error!" message:@"Playback failed!"];
	}

	[[NSNotificationCenter defaultCenter] removeObserver:self
					      name:MPMoviePlayerLoadStateDidChangeNotification
					      object:player];
}

-(void)movieDone:(NSNotification*)note
{
	MPMoviePlayerController *player = [note object];

	MVPMCLog(@"movie done");

	[[NSNotificationCenter defaultCenter] removeObserver:self
					      name:MPMoviePlayerPlaybackDidFinishNotification
					      object:player];

	[player.view removeFromSuperview];

	[player stop];
	[player release];
}

-(void)playURL:(NSURL*)URL
	    id:(UIViewController*)vc;
{
	MPMoviePlayerController *player;

	MVPMCLog(@"playing movie in view");

	MPMoviePlayerViewController *playerViewController =
		[[MPMoviePlayerViewController alloc] initWithContentURL:URL];

	[vc.view addSubview:playerViewController.view];

	player = [playerViewController moviePlayer];

	[[NSNotificationCenter defaultCenter] addObserver:self
					      selector:@selector(movieDone:)
					      name:MPMoviePlayerPlaybackDidFinishNotification
					      object:player];
	[[NSNotificationCenter defaultCenter] addObserver:self
					      selector:@selector(movieLoad:)
					      name:MPMoviePlayerLoadStateDidChangeNotification
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

	image[0] = [UIImage imageNamed:@"slate_background.jpg"];
	image[1] = [UIImage imageNamed:@"stone_background.jpg"];
	image[2] = [UIImage imageNamed:@"bricks_background.jpg"];

	idiom = [[UIDevice currentDevice] userInterfaceIdiom];

	if (idiom == UIUserInterfaceIdiomPad) {
		MVPMCLog(@"running on an iPad");
	} else {
		MVPMCLog(@"running on an iPhone");
	}

	return self;
}

-(BOOL)isiPad
{
	return (idiom == UIUserInterfaceIdiomPad);
}

@end
