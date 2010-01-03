//
//  MythViewController.m
//  mvpmc
//
//  Created by Jon Gettler on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "MythViewController.h"
#import "api.h"


@implementation MythViewController

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

-(void)play_movie:(int)port
{
	MPMoviePlayerController *player;
	NSURL *URL;
	NSString *message = nil;
	NSString *url;

	url = [NSString stringWithFormat:@"http://127.0.0.1:%d/foo.m4v",port];
	URL = [NSURL URLWithString: url];

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

	if (message != nil) {
		[self popup:@"Error!" message:message];
	}
}
-(void)connect
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *host = [userDefaults stringForKey:@"myth_host"];
	NSString *port = [userDefaults stringForKey:@"myth_port"];

	if (port == nil) {
		port = @"0";
	}

	if (host != nil) {
		myth = [[cmyth alloc] server:host port:port.intValue];
	}
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
		[counts addObject:[NSNumber numberWithInteger:count]];
	}
}

-(void)eraseTable
{
	if (sections) {
		[sections release];
	}
	if (counts) {
		[counts release];
	}
	if (list) {
		[list release];
		list = nil;
	}

	sections = [[NSMutableArray alloc] init];
	counts = [[NSMutableArray alloc] init];
}

-(cmythProgram*) atSection:(int) section
		    atRow:(int) row
{
	int i, n, count, limit;
	NSString *subtitle = nil;
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
	if (myth == nil) {
		[self connect];

		if (myth == nil) {
			[self popup:@"Error" message:@"Server not responding!"];
			[self eraseTable];
		} else {
			[self populateTable];
		}
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
					[self.tableView reloadData];

					[self popup:@"Error"
					      message:@"Server not responding!"];
				} else {
					[self populateTable];
					[self.tableView reloadData];
				}
				break;
			default:
				break;
			}
		}
	}
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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
	NSNumber *num = [counts objectAtIndex:section];
	int n = [num intValue];

	return n;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ([sections count] == 0) {
		return nil;
	}
	return [sections objectAtIndex:section];
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

	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];

	cmythProgram *p = [self atSection:indexPath.section atRow:indexPath.row];
	cmythFile *f = [[cmythFile alloc] openWith:p];

	NSString *message = nil;

	if (f != nil) {
		int port = [f portNumber];
		[self play_movie:port];
	} else {
		message = @"openWith failed!";
	}

	if (message) {
		[self popup:@"Selection" message:message];
	}
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

