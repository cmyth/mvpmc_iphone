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

#import "aboutViewController.h"
#import "LicenseViewController.h"


@implementation aboutViewController

@synthesize link;
@synthesize version;
@synthesize license;
@synthesize ip;

-(IBAction) jump:(id) sender
{
	[[UIApplication sharedApplication]
		openURL:[NSURL URLWithString:@"http://www.mvpmc.org"]];
}

-(IBAction)showLicense:(id)sender
{
	LicenseViewController *licenseViewController = [[LicenseViewController alloc] initWithNibName:@"LicenseView" bundle:nil];
	licenseViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:licenseViewController animated:YES];
	[licenseViewController release];
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
