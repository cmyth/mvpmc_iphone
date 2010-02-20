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

#import "mvpmc.h"

#include "refmem/refmem.h"

static Httpd *httpd;

@implementation ProgramViewController

@synthesize progTitle;
@synthesize subtitle;
@synthesize description;
@synthesize date;
@synthesize length;
@synthesize back;
@synthesize progress;
@synthesize background;

-(void)play_movie:(int)port
{
	NSURL *URL;
	NSString *url;

	url = [NSString stringWithFormat:@"http://127.0.0.1:%d/mythtv.m4v",port];
	URL = [NSURL URLWithString: url];

	[mvpmc playURL:URL];
}

-(IBAction) hide:(id) sender
{
	[timer invalidate];
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction) playOriginal:(id) sender
{
	NSLog(@"play original");

	if (httpd != nil) {
		[httpd shutdown];
		[httpd release];
	}
	httpd = [[Httpd alloc] openWith:proginfo];

	NSLog(@"original file opened");

	if (httpd) {
		int port = [httpd portNumber];
		[self play_movie:port];
	} else {
		[mvpmc popup:@"Error!" message:@"Failed to open file!"];
	}
}

-(IBAction) playTranscoded:(id) sender
{
	NSLog(@"play transcoded");

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *www_base = [userDefaults stringForKey:@"www_base"];

	if ([www_base isEqualToString: @""]) {
		[mvpmc popup:@"Error!" message:@"WWW options not set!"];
		return;
	}

	if (file) {
		vlcTranscodeState state = [file transcodeState];
		if ((state != VLC_TRANSCODE_STOPPED) &&
		    (state != VLC_TRANSCODE_COMPLETE)) {
			[mvpmc popup:@"Error!"
			       message:@"VLC transcode in progress!"];
			return;
		}
	}

	char *str;
	NSString *fn;
	str = cmyth_proginfo_pathname(proginfo);
	fn = [[NSString alloc] initWithUTF8String:str];
	ref_release(str);

	NSURL *URL;
	NSString *url;

	url = [NSString stringWithFormat:@"%@/%@.mp4",www_base,fn];
	URL = [NSURL URLWithString: url];

	[mvpmc playURL:URL];
}

-(IBAction) transcode:(id) sender
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *vlc_host = [userDefaults stringForKey:@"vlc_host"];
	NSString *vlc_path = [userDefaults stringForKey:@"vlc_path"];
	NSString *myth_path = [userDefaults stringForKey:@"myth_path"];

	NSLog(@"start transcode");

	if (([vlc_host isEqualToString: @""]) ||
	    ([vlc_path isEqualToString: @""])) {
		[mvpmc popup:@"Error!" message:@"VLC options not set!"];
		return;
	}

	if (file) {
		vlcTranscodeState state = [file transcodeState];
		if (state == VLC_TRANSCODE_IN_PROGRESS) {
			[mvpmc popup:@"Error!"
			       message:@"VLC transcode is already running!"];
			return;
		}
		[file release];
	}

	file = [[VLC alloc] transcodeWith:proginfo
			    mythPath:myth_path
			    vlcHost:vlc_host vlcPath:vlc_path];

	if (file == nil) {
		[mvpmc popup:@"Error!" message:@"VLC transcode failed!"];
		return;
	}

	[mythtv addVLC:file];

	progress.progress = 0.0;
	progress.hidden = NO;

	// Schedule timer to update progress
	timer = [NSTimer scheduledTimerWithTimeInterval: 1.0
			 target: self
			 selector: @selector(handleTimer:)
			 userInfo: nil
			 repeats: YES];

}

-(void)handleTimer:(NSTimer*)t
{
	if (file) {
		NSString *message = nil;
		vlcTranscodeState state = [file transcodeState];

		switch (state) {
		case VLC_TRANSCODE_CONNECT_FAILED:
			NSLog(@"VLC connect failed error");
			message = @"VLC server not found!";
			break;
		case VLC_TRANSCODE_ERROR:
			NSLog(@"VLC transcode failed error");
			message = @"VLC transcode failed!";
			break;
		case VLC_TRANSCODE_STOPPED:
		case VLC_TRANSCODE_COMPLETE:
			[timer invalidate];
			timer = nil;
			break;
		default:
			break;
		}

		if (message) {
			[timer invalidate];
			timer = nil;
			[mvpmc popup:@"Error!" message:message];
			progress.hidden = YES;
			return;

		}

		if (state == VLC_TRANSCODE_STOPPED) {
			progress.hidden = YES;
		} else {
			float p = [file transcodeProgress];

			progress.progress = p;
			progress.hidden = NO;
		}
	}
}

-(IBAction) stopTranscode:(id) sender
{
	NSLog(@"stop transcode");

	if (file == nil) {
		[mvpmc popup:@"Error!" message:@"VLC transcode not in progress!"];
		return;
	} else {
		switch ([file transcodeState]) {
		case VLC_TRANSCODE_STARTING:
		case VLC_TRANSCODE_IN_PROGRESS:
			break;
		default:
			[mvpmc popup:@"Error!"
			       message:@"VLC transcode not in progress!"];
			return;
		}
	}

	[file transcodeStop];

	progress.progress = 0.0;
	progress.hidden = YES;

	[mythtv removeVLC:file];
}

-(void)setProgInfo:(cmyth_proginfo_t)p
{
	proginfo = p;
}

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	background.image = [mvpmc getBackgroundImage];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSString *t, *s, *d, *start;
	time_t sec;
	int h, m;
	char *str;

	str = cmyth_proginfo_title(proginfo);
	t = [[NSString alloc] initWithUTF8String:str];
	ref_release(str);

	str = cmyth_proginfo_subtitle(proginfo);
	s = [[NSString alloc] initWithUTF8String:str];
	ref_release(str);

	str = cmyth_proginfo_description(proginfo);
	d = [[NSString alloc] initWithUTF8String:str];
	ref_release(str);

	str = cmyth_proginfo_description(proginfo);
	d = [[NSString alloc] initWithUTF8String:str];
	ref_release(str);

	cmyth_timestamp_t ts;
	time_t tm;

	ts = cmyth_proginfo_rec_start(proginfo);
	tm = cmyth_timestamp_to_unixtime(ts);

	NSDate *dt = [NSDate dateWithTimeIntervalSince1970:tm];

	ref_release(ts);

	start = [dt description];

	cmyth_timestamp_t te;

	ts = cmyth_proginfo_rec_start(proginfo);
	te = cmyth_proginfo_rec_end(proginfo);

	sec = cmyth_timestamp_to_unixtime(te) - cmyth_timestamp_to_unixtime(ts);

	ref_release(ts);
	ref_release(te);

	h = (sec / (60*60));
	sec -= (h * 60 * 60);
	m = (sec / 60);

	NSString *l = [NSString stringWithFormat:@"%.2d:%.2d",h,m];

	progTitle.text = t;
	subtitle.text = s;
	description.text = d;
	date.text = start;
	length.text = l;

	[super viewDidLoad];

	file = [mythtv getVLC:proginfo];

	if (file == nil) {
		progress.hidden = YES;
	} else {
		NSLog(@"found VLC transcode object");
		progress.hidden = NO;
		// Schedule timer to update progress
		timer = [NSTimer scheduledTimerWithTimeInterval: 1.0
				 target: self
				 selector: @selector(handleTimer:)
				 userInfo: nil
				 repeats: YES];
	}
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
	NSLog(@"dealloc ProgramView");
	[super dealloc];
}


@end
