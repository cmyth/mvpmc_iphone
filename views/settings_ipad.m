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

#import "settings_ipad.h"
#import "mvpmc.h"
#import "HelpViewController.h"

@implementation settings_ipad

@synthesize host;
@synthesize port;
@synthesize path;
@synthesize vlc_host;
@synthesize vlc_path;
@synthesize www_base;
@synthesize help;

-(IBAction) hideKeyboard:(id) sender
{
	MVPMCLog(@"hide keyboard");

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	[userDefaults setObject:host.text forKey:@"myth_host"];
	[userDefaults setObject:port.text forKey:@"myth_port"];
	[userDefaults setObject:path.text forKey:@"myth_path"];

	[userDefaults setObject:vlc_host.text forKey:@"vlc_host"];
	[userDefaults setObject:vlc_path.text forKey:@"vlc_path"];

	[userDefaults setObject:www_base.text forKey:@"www_base"];

	[host resignFirstResponder];
	[port resignFirstResponder];
	[path resignFirstResponder];
	[vlc_host resignFirstResponder];
	[vlc_path resignFirstResponder];
	[www_base resignFirstResponder];
}

-(IBAction) display_help:(id) sender
{
	HelpViewController *helpViewController = [[HelpViewController alloc] initWithNibName:@"HelpView_ipad" bundle:nil];
	helpViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentModalViewController:helpViewController animated:YES];
	[helpViewController release];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
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
	path.text = [userDefaults stringForKey:@"myth_path"];

	vlc_host.text = [userDefaults stringForKey:@"vlc_host"];
	vlc_path.text = [userDefaults stringForKey:@"vlc_path"];

	www_base.text = [userDefaults stringForKey:@"www_base"];

	www_base.delegate = self;
	vlc_path.delegate = self;
	path.delegate = self;

	[super viewDidLoad];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
