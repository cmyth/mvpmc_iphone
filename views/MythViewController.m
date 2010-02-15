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

#import <MediaPlayer/MediaPlayer.h>
#import "MythViewController.h"
#import "ProgramViewController.h"

#import "mvpmc.h"

@implementation MythViewController

@synthesize lock;

-(IBAction) hideKeyboard:(id) sender
{
}

-(void)busy:(BOOL)on
{
	if (on == YES) {
		active = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
		[active setCenter:CGPointMake(160.0f, 208.0f)];
		[active setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
		[active startAnimating];
		[[self tableView] addSubview:active];
	} else {
		[active stopAnimating];
		[active release];
		active = nil;
	}
}

-(void)waitForData
{
	time_t start, t;
	BOOL connected;

	[lock lock];

	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	NSLog(@"waiting for data");

	time(&start);
	t = start;
	while (((connected=[mythtv isConnected]) == NO) && ((t-start) < 10)) {
		usleep(1000);
		time(&t);
	}

	[self busy:NO];

	if (connected == NO) {
		NSLog(@"connection failed");
		[mvpmc popup:@"Error!" message:@"MythTV connection failed!"];
	} else {
		NSLog(@"data loaded");
		if ([mythtv numberOfSections] == 0) {
			[mvpmc popup:@"Warning!" message:@"No recordings found!"];
		}
	}

	[self.tableView reloadData];

	[pool release];

	[lock unlock];
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

	search.delegate = self;

	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *host = [userDefaults stringForKey:@"myth_host"];
	NSString *port = [userDefaults stringForKey:@"myth_port"];

	if (port == nil) {
		port = [[NSString alloc] initWithFormat:@"0"];
	}

	[super viewWillAppear:animated];

	[lock lock];

	if (host) {
		[self busy:YES];
		if ((ip == nil) || (ip && ![host isEqualToString: ip])) {
			[mythtv host:host port:port.intValue];
		}
		if (ip) {
			[ip release];
		}
		const char *h = [host UTF8String];
		ip = [[NSString alloc] initWithUTF8String:h];

		[NSThread detachNewThreadSelector:@selector(waitForData)
			  toTarget:self withObject:nil];
	} else {
		[mvpmc popup:@"Error!" message:@"MythTV connection failed!"];
	}

	[lock unlock];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	int n;

	[lock lock];
	n = [mythtv numberOfSections];
	[lock unlock];

	return n;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	int n = 0;

	[lock lock];
	n = [mythtv numberOfRowsInSection:section];
	[lock unlock];

	return n;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *ret;

	[lock lock];
	ret = [mythtv titleForSection:section];
	[lock unlock];

	return ret;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
    
	// Set up the cell...

	[lock lock];
	cmyth_proginfo_t p = [mythtv progAtIndexPath:indexPath];
	char *subtitle = cmyth_proginfo_subtitle(p);
	NSString *s = [[NSString alloc] initWithUTF8String:subtitle];
	[[cell textLabel] setText:s];
	[lock unlock];

	ref_release(subtitle);

	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];

	cmyth_proginfo_t p = [mythtv progAtIndexPath:indexPath];
	ProgramViewController *programViewController = [[ProgramViewController alloc] initWithNibName:@"ProgramView" bundle:nil];

	[programViewController setProgInfo:p];
	programViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:programViewController animated:YES];
	[programViewController release];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	[sections release];
	[counts release];
	[super dealloc];
}

-(void)searchBarCancelButtonClicked:(UISearchBar*)searchBar
{
	[search resignFirstResponder];

	[mythtv filterCancel];
	[self.tableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	int n = -1;

	[search resignFirstResponder];

	switch (searchScope) {
	case 0:
		n = [mythtv filterTitle:searchText];
		break;
	case 1:
		n = [mythtv filterSubtitle:searchText];
		break;
	case 2:
		n = [mythtv filterDescription:searchText];
		break;
	}

	if (n < 0) {
		NSLog(@"search error");
	} else {
		NSLog(@"reload table with %d results", n);
		[self.tableView reloadData];
	}
}

-(void)searchBar:(UISearchBar*)searchBar
       selectedScopeButtonIndexDidChange:(NSInteger)scope
{
	searchScope = scope;

	if (searchText != nil) {
		NSLog(@"scope changed");
		[self searchBarSearchButtonClicked:nil];
	}
}

-(void)searchBar:(UISearchBar *)searchBar
   textDidChange:(NSString *)text
{
	NSLog(@"search text '%@'", text);

	if (searchText != nil) {
		[searchText release];
	}

	searchText = text;
	[searchText retain];
}

@end

