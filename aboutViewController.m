//
//  aboutViewController.m
//  mvpmc
//
//  Created by Jon Gettler on 12/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "aboutViewController.h"


@implementation aboutViewController

@synthesize link;
@synthesize version;

-(IBAction) jump:(id) sender
{
	[[UIApplication sharedApplication]
		openURL:[NSURL URLWithString:@"http://www.mvpmc.org"]];
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
	NSString *ver =[[NSBundle mainBundle]
			       objectForInfoDictionaryKey:@"CFBundleVersion"];
	NSString *text = [NSString stringWithFormat:@"iPhone Version %@",ver];
	NSString *ipaddr;
	NSHost *host = [NSHost currentHost];

	if (host) {
		NSString *address = [host address];
		ipaddr = [NSString stringWithFormat:@"IP Address: %@", address];
	} else {
		ipaddr = @"IP Address: Unknown";
	}

	version.text = text;
	ip.text = ipaddr;

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
