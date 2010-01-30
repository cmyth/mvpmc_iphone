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

#include "mvpmc.h"

static void
add_episode(struct mythtv_show *show, cmyth_proginfo_t program)
{
	if (show->n == 0) {
		show->episodes = malloc(sizeof(struct mythtv_episode));
		show->episodes[0].prog = program;
		show->episodes[0].file = NULL;
	} else {
		show->episodes = realloc(show->episodes,
					 sizeof(struct mythtv_episode)*(show->n+1));
	}

	show->episodes[show->n].prog = program;
	show->episodes[show->n].file = NULL;

	show->n++;
}

@implementation MythTV

-(void)addProgram:(cmyth_proginfo_t)program
{
	char *title;
	int i;

	title = cmyth_proginfo_title(program);

	for (i=0; i<n; i++) {
		if (strcmp(title, shows[i].title) == 0) {
			add_episode(shows+i, program);
			goto done;
		}
	}

	shows = realloc(shows, sizeof(shows[0])*(n+1));
	shows[n].title = ref_hold(title);
	shows[n].n = 0;
	shows[n].episodes = NULL;
	add_episode(shows+n, program);
	n++;

done:
	ref_release(title);
}

-(void)connect
{
	int tcp = 4096;
	int len = 16*1024;
	int i, count;

	[theLock lock];

	const char *h = [hostName cString];

	if ((control=cmyth_conn_connect_ctrl(h, hostPort, len, tcp)) == NULL) {
		goto err;
	}
	if ((event=cmyth_conn_connect_event(h, hostPort, len, tcp)) == NULL) {
		goto err;
	}

	NSLog(@"connected to the MythTV backend");

	cmyth_proglist_t list;

	if ((list=cmyth_proglist_get_all_recorded(control)) == NULL) {
		goto err;
	}

	count = cmyth_proglist_get_count(list);

	for (i=0; i<count; i++) {
		cmyth_proginfo_t prog;

		prog = cmyth_proglist_get_item(list, i);

		[self addProgram:prog];
	}

	ref_release(list);

	count = 0;
	for (i=0; i<n; i++) {
		int j;
		for (j=0; j<shows[i].n; j++) {
			count++;
		}
	}

	NSLog(@"found %d shows and %d episodes", n, count);

err:
	[theLock unlock];

	NSLog(@"thread finished");
}

-(BOOL)isConnected
{
	BOOL ret = NO;

	[theLock lock];

	if (control != NULL) {
		ret = YES;
	}

	[theLock unlock];

	return ret;
}

-(int)host:(NSString*)host
      port:(unsigned short)port
{
	int rc = 0;
	int i, j;

	[theLock lock];

	NSLog(@"start connection");

	if (hostName && [host isEqualToString: hostName] && (port == hostPort)) {
		goto done;
	}

	if (control) {
		ref_release(control);
		control = NULL;
	}
	if (event) {
		ref_release(event);
		event = NULL;
	}

	if (hostName) {
		[hostName release];
	}

	hostName = host;
	if (port == 0) {
		hostPort = 6543;
	} else {
		hostPort = port;
	}

	for (i=0; i<n; i++) {
		for (j=0; j<shows[i].n; j++) {
			ref_release(shows[i].episodes[j].prog);
			ref_release(shows[i].episodes[j].file);
		}
		if (shows[i].episodes) {
			free(shows[i].episodes);
		}
		[shows[i].title release];
	}

	if (shows) {
		free(shows);
		shows = NULL;
	}
	n = 0;

	controlThread = [[NSThread alloc] initWithTarget:self
					  selector:@selector(connect)
					  object:nil];
	[controlThread start];

done:
	[theLock unlock];

	return rc;
}

-(NSInteger)numberOfSections
{
	int ret;

	[theLock lock];
	ret = n;
	[theLock unlock];

	return ret;
}

-(NSInteger)numberOfRowsInSection:(NSInteger)section
{
	int ret;

	[theLock lock];
	if (section > n) {
		ret = 0;
	} else {
		ret = shows[section].n;
	}
	[theLock unlock];

	return ret;
}

-(NSString*)titleForSection:(NSInteger)section
{
	NSString *ret;

	[theLock lock];

	if (section > n) {
		ret = @"";
	} else {
		ret = [[NSString alloc] initWithUTF8String:shows[section].title];
	}

	[theLock unlock];

	return ret;
}

-(cmyth_proginfo_t)progAtIndexPath:(NSIndexPath*)indexPath
{
	cmyth_proginfo_t prog;
	int section, row;

	section = indexPath.section;
	row = indexPath.row;

	[theLock lock];
	if (section > n) {
		prog = NULL;
	} else if (row > shows[section].n) {
		prog = NULL;
	} else {
		prog = shows[section].episodes[row].prog;
	}
	[theLock unlock];

	return prog;
}

-(MythTV*)init
{
	self = [super init];

	theLock = [[NSLock alloc] init];

	return self;
}

@end
