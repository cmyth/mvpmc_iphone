//
//  HelpViewController.m
//  mvpmc
//
//  Created by Jon Gettler on 1/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"


@implementation HelpViewController

-(IBAction) hide:(id) sender
{
	[self dismissModalViewControllerAnimated:YES];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	help.text = @
		"Welcome to mvpmc for the iPhone"
		"\n\n"
		"In order to play programs recorded with MythTV on the iPhone, "
		"it is required that they be in a format that the iPhone can "
		"read.  If your capture device does not create MPEG-4, H-264, "
		"or QuickTime video files, then you will need to transcode "
		"the files before playback.  mvpmc is capable of initiating "
		"the transcode step by using VLC on another computer, and "
		"playing back the transcoded files via a web server."
		"\n\n"
		"If your MythTV recordings are in a compatible format already, "
		"you can simply play the original recordings.  If not, you will "
		"have to play the transcoded version."
		"\n\n"
		"MythTV"
		"\n\n"
		"It is required that you specify the IP address or hostname "
		"of your MythTV master backend.  You may also specify a port "
		"number if you are using a non-standard port."
		"\n\n"
		"VLC"
		"\n\n"
		"If you require transcoding, you will need to set up the IP "
		"address or hostname and path for VLC transcoding.  The IP "
		"address is that of the host where VLC is running.  The path "
		"is the location on the server where the transcoded files "
		"will be written.  This should be accessible by your web "
		"server so you can watch the transcoded files with mvpmc."
		"\n\n"
		"You should run VLC on the server with the \"-I telnet\" "
		"option.  You will also need to ensure that you have support "
		"for MPEG-4 video and AAC audio in VLC."
		"\n\n"
		"If you prefer to transcode the files manually, simply "
		"transcode them to MPEG-4 with AAC audio and append \".mp4\" "
		"to the filename."
		"\n\n"
		"WWW"
		"\n\n"
		"In order to view transcoded files, you will need to specify "
		"the IP address or hostname and the path to the transcoded "
		"files."
		"\n\n";
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
