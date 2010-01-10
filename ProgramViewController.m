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

#import <MediaPlayer/MediaPlayer.h>
#import "ProgramViewController.h"


@implementation ProgramViewController

@synthesize prog;
@synthesize title;

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

-(void)play_movie:(int)port
{
	MPMoviePlayerController *player;
	NSURL *URL;
	NSString *url;

	url = [NSString stringWithFormat:@"http://127.0.0.1:%d/mythtv.m4v",port];
	URL = [NSURL URLWithString: url];

	player = [[MPMoviePlayerController alloc] initWithContentURL: URL];

	[player play];
}

-(IBAction) hide:(id) sender
{
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction) playOriginal:(id) sender
{
	cmythFile *f = [[cmythFile alloc] openWith:prog];

	if (f) {
		int port = [f portNumber];
		[self play_movie:port];
	} else {
		[self popup:@"Error!" message:@"Failed to open file!"];
	}
}

-(IBAction) playTranscoded:(id) sender
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *www_base = [userDefaults stringForKey:@"www_base"];

	if ([www_base isEqualToString: @""]) {
		[self popup:@"Error!" message:@"WWW options not set!"];
		return;
	}

	NSString *fn = [prog pathname];

	MPMoviePlayerController *player;
	NSURL *URL;
	NSString *url;

	url = [NSString stringWithFormat:@"%@/%@.mp4",www_base,fn];
	URL = [NSURL URLWithString: url];

	player = [[MPMoviePlayerController alloc] initWithContentURL: URL];

	[player play];
}

-(IBAction) transcode:(id) sender
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *vlc_host = [userDefaults stringForKey:@"vlc_host"];
	NSString *vlc_path = [userDefaults stringForKey:@"vlc_path"];
	NSString *myth_path = [userDefaults stringForKey:@"myth_path"];

	if (([vlc_host isEqualToString: @""]) ||
	    ([vlc_path isEqualToString: @""])) {
		[self popup:@"Error!" message:@"VLC options not set!"];
		return;
	}

	cmythFile *f = [[cmythFile alloc]
			       transcodeWith:prog
			       mythPath:myth_path
			       vlcHost:vlc_host vlcPath:vlc_path];

	if (f) {
		[self popup:@"Started!" message:@"VLC transcode is underway!"];
	} else {
		[self popup:@"Error!" message:@"VLC transcode failed!"];
	}
}

-(IBAction) stopTranscode:(id) sender
{
}

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSString *t = [prog title];
	NSString *s = [prog subtitle];
	NSString *d = [prog description];
	NSString *start = [prog date];
	int sec = [prog seconds];
	int h, m;

	h = (sec / (60*60));
	sec -= (h * 60 * 60);
	m = (sec / 60);

	NSString *l = [NSString stringWithFormat:@"%.2d:%.2d",h,m];

	title.text = t;
	subtitle.text = s;
	description.text = d;
	date.text = start;
	length.text = l;

	[super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
