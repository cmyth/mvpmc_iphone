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

#import "SettingsViewController.h"
#import "HelpViewController.h"
#import "api.h"


@implementation SettingsViewController

@synthesize host;
@synthesize port;

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

-(IBAction) hideKeyboard:(id) sender
{
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
	HelpViewController *helpViewController = [[HelpViewController alloc] initWithNibName:@"HelpView" bundle:nil];
	[self presentModalViewController:helpViewController animated:YES];
	[helpViewController release];
}

-(void)busy:(BOOL)on
{
	if (on == YES) {
		active = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
		[active setCenter:CGPointMake(160.0f, 208.0f)];
		[active setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
		[active startAnimating];
		[[self view] addSubview:active];
	} else {
		[active stopAnimating];
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

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self animateTextField: textField up: YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
	[self animateTextField: textField up: NO];
}

-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
	int distance;
	float duration = 0.25f;

	if (textField == www_base) {
		distance = 135;
	} else if (textField == vlc_path) {
		distance = 60;
	} else if (textField == path) {
		distance = 20;
	} else {
		return;
	}

	int movement = (up ? -distance : distance);

	[UIView beginAnimations: @"anim" context: nil];
	[UIView setAnimationBeginsFromCurrentState: YES];
	[UIView setAnimationDuration: duration];
	self.view.frame = CGRectOffset(self.view.frame, 0, movement);
	[UIView commitAnimations];
}

- (void)dealloc {
	[host release];
	[port release];
	[super dealloc];
}


@end
