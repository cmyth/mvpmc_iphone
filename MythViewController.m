//
//  MythViewController.m
//  mvpmc
//
//  Created by Jon Gettler on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MythViewController.h"
#import "api.h"


@implementation MythViewController

-(void)connect
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *host = [userDefaults stringForKey:@"myth_host"];
	NSString *port = [userDefaults stringForKey:@"myth_port"];
	UIAlertView *alert;
	NSString *message = nil;

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
		UIAlertView *alert;

		alert = [[UIAlertView alloc]
				initWithTitle:@"Error"
				message:@"No recordings found!"
				delegate: nil
				cancelButtonTitle:@"Ok"
				otherButtonTitles: nil];
		[alert show];
		[alert release];
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

	[set release];

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

	if (myth == nil) {
		[self connect];
	}

	if (myth == nil) {
		UIAlertView *alert;

		alert = [[UIAlertView alloc]
				initWithTitle:@"Error"
				message:@"Server not responding!"
				delegate: nil
				cancelButtonTitle:@"Ok"
				otherButtonTitles: nil];
		[alert show];
		[alert release];
	} else {
		[self populateTable];
	}

	[super viewDidLoad];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
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
	return [num intValue];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
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

	if (myth != nil) {
		int i, n, count, limit;
		NSString *subtitle = nil;

		n = [list count];
		limit = [sections count];
		count = 0;
		NSString *sec = [sections objectAtIndex:indexPath.section];

		for (i=0; i<n; i++) {
			cmythProgram *program = [list progitem:i];
			NSString *title = [program title];
			if ([sec isEqualToString: title] == YES) {
				if (count == indexPath.row) {
					subtitle = [program subtitle];
					break;
				}
				count++;
			}
		}

		if (subtitle == nil) {
			[[cell textLabel] setText:@""];
		} else {
			[[cell textLabel] setText:subtitle];
		}
	}
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
		UIAlertView *alert;
		NSString *message;

		message = [NSString stringWithFormat:@"section %d row %d", indexPath.section, indexPath.row];

		alert = [[UIAlertView alloc]
				initWithTitle:@"Selection"
				message:message
				delegate: nil
				cancelButtonTitle:@"Ok"
				otherButtonTitles: nil];
		[alert show];
		[alert release];
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
	if (myth != nil) {
		[myth release];
	}
	[sections release];
	[counts release];
	[super dealloc];
}


@end

