//
//  URLViewController.m
//  mvpmc
//
//  Created by Jon Gettler on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "URLViewController.h"


@implementation URLViewController

@synthesize url;
@synthesize play;

-(IBAction) hideKeyboard:(id) sender
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	[userDefaults setObject:url.text forKey:@"movie_url"];

	[url resignFirstResponder];
}

-(IBAction)play_movie:(id)sender
{
	MPMoviePlayerController *player;
	NSURL *URL;
	UIAlertView *alert;
	NSString *message = nil;

	if (self.url.text.length > 0) {
		URL = [NSURL URLWithString: self.url.text];

		if (URL) {
			if ([URL scheme]) {
				player = [[MPMoviePlayerController alloc]
						 initWithContentURL: URL];

				[player play];
			} else {
				message = @"URL scheme is invalid";
			}
		} else {
			message = @"URL is invalid";
		}
	} else {
		message = @"URL is empty";
	}

	if (message != nil) {
		alert = [[UIAlertView alloc]
				initWithTitle:@"Error!"
				message:message
				delegate: nil
				cancelButtonTitle:@"Ok"
				otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
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
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *URL = [userDefaults stringForKey:@"movie_url"];

	url.text = URL;

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
	[url release];
	[super dealloc];
}


@end
