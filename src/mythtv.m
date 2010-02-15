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
#include "refmem/refmem.h"

static void
add_episode(struct mythtv_show *show, cmyth_proginfo_t program)
{
	if (show->n == 0) {
		show->episodes = ref_alloc(sizeof(struct mythtv_episode));
		show->episodes[0].prog = program;
		show->episodes[0].file = NULL;
	} else {
		show->episodes = ref_realloc(show->episodes,
					     sizeof(struct mythtv_episode)*(show->n+1));
	}

	show->episodes[show->n].prog = program;
	show->episodes[show->n].file = NULL;

	show->n++;
}

@implementation MythTV

@synthesize error;
@synthesize lock;

-(void)addProgram:(cmyth_proginfo_t)program
{
	char *title;
	int i;

	title = cmyth_proginfo_title(program);

	for (i=0; i<nAll; i++) {
		if (strcmp(title, allShows[i].title) == 0) {
			add_episode(allShows+i, program);
			goto done;
		}
	}

	allShows = ref_realloc(allShows, sizeof(allShows[0])*(nAll+1));
	allShows[nAll].title = ref_hold(title);
	allShows[nAll].n = 0;
	allShows[nAll].episodes = NULL;
	add_episode(allShows+nAll, program);
	nAll++;

done:
	ref_release(title);
}

-(void)connect
{
	int tcp = 4096;
	int len = 16*1024;
	int i, count;

	[lock lock];

	NSLog(@"connect to backend");

	error = MYTHTV_ERROR_NONE;

	const char *h = [hostName UTF8String];

	if ((control=cmyth_conn_connect_ctrl(h, hostPort, len, tcp)) == NULL) {
		error = MYTHTV_ERROR_CONNECT_FAILED;
		goto err;
	}
	if ((event=cmyth_conn_connect_event(h, hostPort, len, tcp)) == NULL) {
		error = MYTHTV_ERROR_CONNECT_FAILED;
		goto err;
	}

	NSLog(@"connected to the MythTV backend");

	cmyth_proglist_t list;

	if ((list=cmyth_proglist_get_all_recorded(control)) == NULL) {
		error = MYTHTV_ERROR_CONNECT_FAILED;
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
	for (i=0; i<nAll; i++) {
		int j;
		for (j=0; j<allShows[i].n; j++) {
			count++;
		}
	}

	shows = allShows;
	n = nAll;

	NSLog(@"found %d shows and %d episodes", n, count);

err:
	[lock unlock];

	NSLog(@"thread finished");
}

-(BOOL)isConnected
{
	BOOL ret = NO;

	if ([lock tryLock] == NO) {
		return NO;
	}

	if (control != NULL) {
		ret = YES;
	}

	[lock unlock];

	return ret;
}

-(int)host:(NSString*)host
      port:(unsigned short)port
{
	int rc = 0;
	int i, j;

	[lock lock];

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

	[host retain];
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
			ref_release(shows[i].episodes);
		}
		ref_release(shows[i].title);
	}

	if (shows) {
		ref_release(shows);
		shows = NULL;
	}
	n = 0;

	controlThread = [[NSThread alloc] initWithTarget:self
					  selector:@selector(connect)
					  object:nil];
	[controlThread start];

done:
	[lock unlock];

	return rc;
}

-(NSInteger)numberOfSections
{
	int ret;

	[lock lock];
	ret = n;
	[lock unlock];

	return ret;
}

-(NSInteger)numberOfRowsInSection:(NSInteger)section
{
	int ret;

	[lock lock];
	if (section > n) {
		ret = 0;
	} else {
		ret = shows[section].n;
	}
	[lock unlock];

	return ret;
}

-(NSString*)titleForSection:(NSInteger)section
{
	NSString *ret;

	[lock lock];

	if (section > n) {
		ret = @"";
	} else {
		ret = [[NSString alloc] initWithUTF8String:shows[section].title];
	}

	[lock unlock];

	return ret;
}

-(cmyth_proginfo_t)progAtIndexPath:(NSIndexPath*)indexPath
{
	cmyth_proginfo_t prog;
	int section, row;

	section = indexPath.section;
	row = indexPath.row;

	[lock lock];
	if (section > n) {
		prog = NULL;
	} else if (row > shows[section].n) {
		prog = NULL;
	} else {
		prog = shows[section].episodes[row].prog;
	}
	[lock unlock];

	return prog;
}

static struct mythtv_episode*
hold_episode(struct mythtv_episode *episode)
{
	ref_hold(episode->prog);
	ref_hold(episode->file);

	return episode;
}

static struct mythtv_show*
hold_show(struct mythtv_show *show)
{
	int i;

	ref_hold(show->title);
	ref_hold(show->episodes);

	for (i=0; i<show->n; i++) {
		hold_episode(show->episodes+i);
	}

	return show;
}

static void
release_shows(struct mythtv_show *shows, int n)
{
	int i, j;

	if ((shows == NULL) || (n == 0)) {
		return;
	}

	for (i=0; i<n; i++) {
		ref_release(shows[i].title);
		for (j=0; j<shows[i].n; j++) {
			ref_release(shows[i].episodes[j].prog);
			ref_release(shows[i].episodes[j].file);
		}
		ref_release(shows[i].episodes);
	}

	ref_release(shows);
}

-(int)filterTitle:(NSString*)text
{
	int i, j;
	int ret;

	if ([self isConnected] == NO) {
		return -1;
	}

	[lock lock];

	release_shows(filteredShows, nFiltered);

	nFiltered = 0;
	filteredShows = (struct mythtv_show*)ref_alloc(sizeof(struct mythtv_show)*nAll);
	for (i=0; i<nAll; i++) {
		if (strcasestr(allShows[i].title, [text UTF8String]) != 0) {
			hold_show(allShows+i);
			memcpy(filteredShows+nFiltered, allShows+i,
			       sizeof(struct mythtv_show));
			nFiltered++;
		}
	}

	n = nFiltered;
	shows = filteredShows;

	NSLog(@"searched %@ found %d titles, %p", text, n, shows);

	ret = n;

	[lock unlock];

	return ret;
}

-(int)filterSubtitle:(NSString*)text
{
	int i, j;
	int ret;

	if ([self isConnected] == NO) {
		return -1;
	}

	[lock lock];

	release_shows(filteredShows, nFiltered);

	nFiltered = 0;
	filteredShows = (struct mythtv_show*)ref_alloc(sizeof(struct mythtv_show)*nAll);
	for (i=0; i<nAll; i++) {
		struct mythtv_show *show = &(allShows[i]);
		int found = 0;
		for (j=0; j<show->n; j++) {
			char *subtitle;
			struct mythtv_episode *episode = &(show->episodes[j]);
			subtitle = cmyth_proginfo_subtitle(episode->prog);
			if (strcasestr(subtitle, [text UTF8String]) != 0) {
				hold_episode(episode);
				if (found == 0) {
					filteredShows[nFiltered].episodes =
						ref_alloc(sizeof(struct mythtv_episode)*show->n);
					memcpy(filteredShows[nFiltered].episodes,
					       episode, sizeof(*episode));
					filteredShows[nFiltered].title =
						ref_hold(show->title);
					filteredShows[nFiltered].n = 1;
					nFiltered++;
					found = 1;
				} else {
					int n = filteredShows[nFiltered].n;
					memcpy(filteredShows[nFiltered].episodes+n,
					       episode, sizeof(*episode));
					filteredShows[nFiltered].n++;
				}
			}
			ref_release(subtitle);
		}
	}

	n = nFiltered;
	shows = filteredShows;

	NSLog(@"searched %@ found %d titles, %p", text, n, shows);

	ret = n;

	[lock unlock];

	return 0;
}

-(int)filterDescription:(NSString*)text
{
	int i, j;
	int ret;

	if ([self isConnected] == NO) {
		return -1;
	}

	[lock lock];

	release_shows(filteredShows, nFiltered);

	nFiltered = 0;
	filteredShows = (struct mythtv_show*)ref_alloc(sizeof(struct mythtv_show)*nAll);
	for (i=0; i<nAll; i++) {
		struct mythtv_show *show = &(allShows[i]);
		int found = 0;
		for (j=0; j<show->n; j++) {
			char *description;
			struct mythtv_episode *episode = &(show->episodes[j]);
			description = cmyth_proginfo_description(episode->prog);
			if (strcasestr(description, [text UTF8String]) != 0) {
				hold_episode(episode);
				if (found == 0) {
					filteredShows[nFiltered].episodes =
						ref_alloc(sizeof(struct mythtv_episode)*show->n);
					memcpy(filteredShows[nFiltered].episodes,
					       episode, sizeof(*episode));
					filteredShows[nFiltered].title =
						ref_hold(show->title);
					filteredShows[nFiltered].n = 1;
					nFiltered++;
					found = 1;
				} else {
					int n = filteredShows[nFiltered].n;
					memcpy(filteredShows[nFiltered].episodes+n,
					       episode, sizeof(*episode));
					filteredShows[nFiltered].n++;
				}
			}
			ref_release(description);
		}
	}

	n = nFiltered;
	shows = filteredShows;

	NSLog(@"searched %@ found %d titles, %p", text, n, shows);

	ret = n;

	[lock unlock];

	return 0;
}

-(void)filterCancel
{
	[lock lock];

	shows = allShows;
	n = nAll;

	release_shows(filteredShows, nFiltered);

	filteredShows = NULL;
	nFiltered = 0;

	[lock unlock];
}

-(MythTV*)init
{
	self = [super init];

	error = MYTHTV_ERROR_NONE;
	lock = [[NSLock alloc] init];

	return self;
}

@end
