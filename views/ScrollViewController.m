//
//  ScrollViewController.m
//  mvpmc
//
//  Created by Jon Gettler on 1/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ScrollViewController.h"
#import "SettingsViewController.h"
#import "HelpViewController.h"
#import "mvpmc.h"


@implementation ScrollViewController

@synthesize scroll;
@synthesize background;
@synthesize logo;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

-(IBAction) displayHelp:(id) sender
{
	HelpViewController *helpViewController = [[HelpViewController alloc] initWithNibName:@"HelpView" bundle:nil];
	helpViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:helpViewController animated:YES];
	[helpViewController release];
}

-(void)changeImage
{
	background.image = [mvpmc getBackgroundImage];
}

- (void)viewWillAppear:(BOOL)animated {
	[self changeImage];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	NSLog(@"scroll view loaded");

	scroll.alwaysBounceVertical = YES;
	scroll.alwaysBounceHorizontal = NO;
	scroll.clipsToBounds = YES;
	scroll.delegate = self;
	scroll.scrollEnabled = YES;
	scroll.showsVerticalScrollIndicator = YES;
	scroll.showsHorizontalScrollIndicator = NO;
	[scroll setContentSize:CGSizeMake(320, 640)];
        [scroll setCanCancelContentTouches:NO];
        scroll.clipsToBounds = YES;
        scroll.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        [scroll setScrollEnabled:YES];

	logo.hidden = NO;

	SettingsViewController *settings = [[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:nil];
	settings.view.backgroundColor = [UIColor clearColor];
	[settings addParent:self];
	[scroll addSubview:settings.view];
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
