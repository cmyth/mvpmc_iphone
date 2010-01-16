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

#import "URLViewController.h"


@implementation URLViewController

@synthesize url;
@synthesize play;
@synthesize url_1;
@synthesize play_1;
@synthesize url_2;
@synthesize play_2;
@synthesize url_3;
@synthesize play_3;

-(IBAction) hideKeyboard:(id) sender
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	[userDefaults setObject:url.text forKey:@"url_0"];
	[userDefaults setObject:url_1.text forKey:@"url_1"];
	[userDefaults setObject:url_2.text forKey:@"url_2"];
	[userDefaults setObject:url_3.text forKey:@"url_3"];

	[url resignFirstResponder];
	[url_1 resignFirstResponder];
	[url_2 resignFirstResponder];
	[url_3 resignFirstResponder];
}

-(IBAction)play_movie:(id)sender
{
	MPMoviePlayerController *player;
	NSURL *URL;
	UIAlertView *alert;
	NSString *message = nil;
	NSString *u;

	[self hideKeyboard:nil];

	if (sender == play) {
		u = url.text;
	} else if (sender == play_1) {
		u = url_1.text;
	} else if (sender == play_2) {
		u = url_2.text;
	} else if (sender == play_3) {
		u = url_3.text;
	} else {
		return;
	}

	if (u.length > 0) {
		URL = [NSURL URLWithString: u];

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
	NSString *URL = [userDefaults stringForKey:@"url_0"];
	NSString *URL_1 = [userDefaults stringForKey:@"url_1"];
	NSString *URL_2 = [userDefaults stringForKey:@"url_2"];
	NSString *URL_3 = [userDefaults stringForKey:@"url_3"];

	url.text = URL;
	url_1.text = URL_1;
	url_2.text = URL_2;
	url_3.text = URL_3;

	url_2.delegate = self;
	url_3.delegate = self;

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

	if (textField == url_2) {
		distance = 70;
	} else if (textField == url_3) {
		distance = 145;
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
	[url release];
	[super dealloc];
}


@end
