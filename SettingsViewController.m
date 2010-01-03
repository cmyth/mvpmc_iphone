//
//  SettingsViewController.m
//  mvpmc
//
//  Created by Jon Gettler on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "api.h"


@implementation SettingsViewController

@synthesize host;
@synthesize port;

-(IBAction) hideKeyboard:(id) sender
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	[userDefaults setObject:host.text forKey:@"myth_host"];
	[userDefaults setObject:port.text forKey:@"myth_port"];

	[userDefaults setObject:vlc_host.text forKey:@"vlc_host"];
	[userDefaults setObject:vlc_path.text forKey:@"vlc_path"];

	[userDefaults setObject:www_host.text forKey:@"www_host"];
	[userDefaults setObject:www_path.text forKey:@"www_path"];

	[host resignFirstResponder];
	[port resignFirstResponder];
	[vlc_host resignFirstResponder];
	[vlc_path resignFirstResponder];
	[www_host resignFirstResponder];
	[www_path resignFirstResponder];
}

-(IBAction) test_connection:(id) sender
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *host = [userDefaults stringForKey:@"myth_host"];
	NSString *port = [userDefaults stringForKey:@"myth_port"];
	cmyth *myth;
	UIAlertView *alert;
	NSString *message;

	if (host == nil) {
		message = @"IP Address not specified!";
	} else {
		myth = [[cmyth alloc] server:host port:port.intValue];

		if (myth != nil) {
			[myth release];
			message = @"Connection Succeeded!";
		} else {
			message = @"Connection Failed!";
		}
	}

//	[userDefaults release];
//	[host release];
//	[port release];

	alert = [[UIAlertView alloc]
			initWithTitle:@"Connectivity test"
			message:message
			delegate: nil
			cancelButtonTitle:@"Ok"
			otherButtonTitles: nil];
	[alert show];
	[alert release];
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

	host.text = [userDefaults stringForKey:@"myth_host"];
	port.text = [userDefaults stringForKey:@"myth_port"];

	vlc_host.text = [userDefaults stringForKey:@"vlc_host"];
	vlc_path.text = [userDefaults stringForKey:@"vlc_path"];

	www_host.text = [userDefaults stringForKey:@"www_host"];
	www_path.text = [userDefaults stringForKey:@"www_path"];

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
	[host release];
	[port release];
	[super dealloc];
}


@end
