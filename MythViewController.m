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
#import "api.h"


@implementation MythViewController

@synthesize lock;

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

-(void)connect
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *host = [userDefaults stringForKey:@"myth_host"];
	NSString *port = [userDefaults stringForKey:@"myth_port"];

	if (port == nil) {
		port = [[NSString alloc] initWithFormat:@"0"];
	}

	if (host != nil) {
		myth = [[cmyth alloc] server:host port:port.intValue];
	}

	[host release];
	[port release];

	[pool release];
}

-(void)populateTable
{
	int i, j, n;

	if (myth == nil) {
		[self connect];
	}

	if (myth == nil) {
		return;
	}

	if (list == nil) {
		list = [myth programList];
	}

	n = [list count];

	if (n == 0) {
		[self popup:@"Error" message:@"No recordings found!"];
		return;
	}

	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	NSMutableSet *set = [[NSMutableSet alloc] init];

	for (i=0; i<n; i++) {
		cmythProgram *program = [list progitem:i];
		NSString *title = [program title];
		[set addObject:title];
	}

	sections = [[NSMutableArray alloc] initWithArray:[set allObjects]];
	counts = [[NSMutableArray alloc] init];

	n = [list count];

	int limit = [sections count];

	for (i=0; i<limit; i++) {
		int count = 0;
		NSString *sec = [sections objectAtIndex:i];
		for (j=0; j<n; j++) {
			cmythProgram *program = [list progitem:j];
			NSString *title = [program title];
			if ([sec isEqualToString: title]) {
				count++;
			}
		}
		NSNumber *num = [[NSNumber alloc] initWithInteger:count];
		[counts addObject:num];
		[num release];
	}

	[pool release];
}

-(void)eraseTable
{
	if (sections) {
		[sections release];
		sections = nil;
	}
	if (counts) {
		[counts release];
		sections = nil;
	}
	if (list) {
		[list release];
		list = nil;
	}
}

-(cmythProgram*) atSection:(int) section
		    atRow:(int) row
{
	int i, n, count, limit;
	cmythProgram *rc = nil;

	n = [list count];
	limit = [sections count];
	if (limit == 0) {
		return nil;
	}
	count = 0;
	NSString *sec = [sections objectAtIndex:section];

	for (i=0; i<n; i++) {
		cmythProgram *program = [list progitem:i];
		NSString *title = [program title];
		if ([sec isEqualToString: title] == YES) {
			if (count == row) {
				rc = program;
				break;
			}
			count++;
		}
	}
	return rc;
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

-(void)loadData
{
	BOOL reload = NO;

	[lock lock];
	if (myth == nil) {
		[self connect];

		if (myth == nil) {
			[self popup:@"Error" message:@"Server not responding!"];
			[self eraseTable];
		} else {
			[self populateTable];
		}

		reload = YES;
	} else {
		cmyth_event_t e;
		if ([myth getEvent:&e] == 0) {
			switch (e) {
			case CMYTH_EVENT_UNKNOWN:
			case CMYTH_EVENT_SCHEDULE_CHANGE:
			case CMYTH_EVENT_QUIT_LIVETV:
			case CMYTH_EVENT_DONE_RECORDING:
			case CMYTH_EVENT_LIVETV_CHAIN_UPDATE:
			case CMYTH_EVENT_SIGNAL:
			case CMYTH_EVENT_ASK_RECORDING:
				break;
			case CMYTH_EVENT_CLOSE:
			case CMYTH_EVENT_RECORDING_LIST_CHANGE:
				[myth release];
				[self connect];
				if (myth == nil) {
					[self eraseTable];

					[self popup:@"Error"
					      message:@"Server not responding!"];
				} else {
					[self populateTable];
				}
				reload = YES;
				break;
			default:
				break;
			}
		}
	}
	[self busy:NO];
	[lock unlock];

	if (reload == YES) {
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		[self.tableView reloadData];
		[pool release];
	}
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

	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *host = [userDefaults stringForKey:@"myth_host"];

	[super viewWillAppear:animated];
	[lock lock];
	if (active == nil) {
		[self busy:YES];
		if (host) {
			if (ip && ![host isEqualToString: ip]) {
				[myth release];
				myth = nil;
				[self eraseTable];
				[self.tableView reloadData];
			}
			if (ip) {
				[ip release];
			}
			const char *h = [host UTF8String];
			ip = [[NSString alloc] initWithUTF8String:h];
		}
		[NSThread detachNewThreadSelector:@selector(loadData)
			  toTarget:self withObject:nil];
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
	return [sections count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	int n = 0;

	[lock lock];
	if ([counts count] > section) {
		NSNumber *num = [counts objectAtIndex:section];
		n = [num intValue];
	}
	[lock unlock];

	return n;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *ret;

	[lock lock];
	if ([sections count] == 0) {
		ret = nil;
	} else {
		ret =  [sections objectAtIndex:section];
	}
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

	cmythProgram *p = [self atSection:indexPath.section atRow:indexPath.row];
	NSString *subtitle = [p subtitle];

	[[cell textLabel] setText:subtitle];

	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];

	ProgramViewController *programViewController = [[ProgramViewController alloc] initWithNibName:@"ProgramView" bundle:nil];
	cmythProgram *p = [self atSection:indexPath.section atRow:indexPath.row];
	programViewController.prog = p;
//	programViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
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
	[myth release];
	[sections release];
	[counts release];
	[super dealloc];
}


@end

