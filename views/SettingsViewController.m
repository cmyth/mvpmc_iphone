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

#import "mvpmc.h"

@implementation SettingsViewController

@synthesize host;
@synthesize port;
@synthesize path;
@synthesize vlc_host;
@synthesize vlc_path;
@synthesize vlc_port;
@synthesize www_base;
@synthesize vlc;
@synthesize test;
@synthesize help;
@synthesize background;

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

-(void)changeImage:(int)index
{
	if ((index >= 0) && (index <= 2)) {
		MVPMCLog(@"change background image to %d", index);

		[mvpmc setBackgroundImage:index];

		[parent changeImage];
	}
}

-(IBAction) display_help:(id) sender
{
	HelpViewController *helpViewController = [[HelpViewController alloc] initWithNibName:@"HelpView" bundle:nil];
	helpViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:helpViewController animated:YES];
	[helpViewController release];
}

-(void)busy:(BOOL)on
{
	if (on == YES) {
		float x, y;
		active = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
		x = [mvpmc screenWidth] / 2.0;
		y = [mvpmc screenHeight] / 2.0;
		[active setCenter:CGPointMake(x, y)];
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

- (void)viewWillAppear:(BOOL)animated {
	background.image = [mvpmc getBackgroundImage];
}

-(void)buttonPressed:(id)sender
{
	int index;

	MVPMCLog(@"Button pressed");

	if (sender == bgButton[0]) {
		index = 0;
	} else if (sender == bgButton[1]) {
		index = 1;
	} else if (sender == bgButton[2]) {
		index = 2;
	} else {
		MVPMCLog(@"button error!!!");
		return;
	}

	[mvpmc setBackgroundImage:index];

	[parent changeImage];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	char str[32];
	snprintf(str, sizeof(str), "%d", index);
	NSString *text = [[NSString alloc] initWithUTF8String:str];
	[userDefaults setObject:text forKey:@"background"];
}

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

	UIImage *image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"settings_background" ofType:@"png"]];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image]; 
	[self.view addSubview:imageView];   
	[self.view sendSubviewToBack:imageView];

	UIImage *bg = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"background_chooser" ofType:@"png"]];
	UIImageView *bgView = [[UIImageView alloc] initWithImage:bg]; 
	[self.view addSubview:bgView];   
	[self.view sendSubviewToBack:bgView];

	int offset;
	CGRect bgRect;

	offset = [mvpmc screenWidth] + 20;
	bgRect = CGRectMake(0, offset, [mvpmc screenWidth], 180);

	[bgView setFrame:bgRect];	

	imageView.contentMode = UIViewContentModeScaleAspectFit;
	bgView.contentMode = UIViewContentModeScaleAspectFit;

	CGRect buttonRect;
	UIButton *btn;

	buttonRect = CGRectMake(50, offset+60, 60, 60);
	btn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	bgButton[0] = btn;
	[btn setFrame:buttonRect];	
	[btn addTarget:self action:@selector(buttonPressed:)
	     forControlEvents:UIControlEventTouchUpInside];
	[[self view] addSubview:btn];
	[btn release];

	buttonRect = CGRectMake(130, offset+60, 60, 60);
	btn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	bgButton[1] = btn;
	[btn setFrame:buttonRect];
	[btn addTarget:self action:@selector(buttonPressed:)
	     forControlEvents:UIControlEventTouchUpInside];
	[[self view] addSubview:btn];
	[btn release];

	buttonRect = CGRectMake(210, offset+60, 60, 60);
	btn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	bgButton[2] = btn;
	[btn setFrame:buttonRect];	
	[btn addTarget:self action:@selector(buttonPressed:)
	     forControlEvents:UIControlEventTouchUpInside];
	[[self view] addSubview:btn];
	[btn release];

	NSString *bgimage = [userDefaults stringForKey:@"background"];

	if (bgimage) {
		int index = [bgimage intValue];
		[self changeImage:index];
	}

	MVPMCLog(@"settings view loaded");
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

-(void)addParent:(id)sender
{
	MVPMCLog(@"add parent");

	parent = sender;
}

-(SettingsViewController*)init
{
	self = [super init];

	return self;
}

@end
