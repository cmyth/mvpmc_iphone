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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <sys/sockio.h>
#include <net/if.h>
#include <errno.h>
#include <net/if_dl.h>

#include <CFNetwork/CFSocketStream.h>

#include "mvpmc.h"

@implementation MVPMC

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

-(void)movieLoad:(NSNotification*)note
{
	MPMoviePlayerController *player = [note object];
	MPMovieLoadState loadState;
	MPMoviePlaybackState playState;

	MVPMCLog(@"preload done");

	loadState = [player loadState];
	playState = [player playbackState];

	MVPMCLog(@"load state %d player state %d", loadState, playState);

	NSError *error = [[note userInfo] objectForKey:@"error"];

	if (error == nil) {
		MVPMCLog(@"no preload error");
	} else {
		MVPMCLog(@"preload error %d", [error code]);
		[self popup:@"Error!" message:@"Playback failed!"];
	}

	[[NSNotificationCenter defaultCenter] removeObserver:self
					      name:MPMoviePlayerLoadStateDidChangeNotification
					      object:player];
}

-(void)movieDone:(NSNotification*)note
{
	MPMoviePlayerController *player = [note object];

	MVPMCLog(@"movie done");

	playing = NO;

	[[NSNotificationCenter defaultCenter] removeObserver:self
					      name:MPMoviePlayerPlaybackDidFinishNotification
					      object:player];

	[player.view removeFromSuperview];

	[player stop];
	[player release];
}

-(void)playURL:(NSURL*)URL
	    id:(UIViewController*)vc;
{
	MPMoviePlayerController *player;

	MVPMCLog(@"playing movie in view");

	MPMoviePlayerViewController *playerViewController =
		[[MPMoviePlayerViewController alloc] initWithContentURL:URL];

	[vc.view addSubview:playerViewController.view];

	player = [playerViewController moviePlayer];

	[[NSNotificationCenter defaultCenter] addObserver:self
					      selector:@selector(movieDone:)
					      name:MPMoviePlayerPlaybackDidFinishNotification
					      object:player];
	[[NSNotificationCenter defaultCenter] addObserver:self
					      selector:@selector(movieLoad:)
					      name:MPMoviePlayerLoadStateDidChangeNotification
					      object:player];

	[player play];

	playing = YES;
}

-(UIImage*)getBackgroundImage
{
	return image[imageNumber];
}

-(void)setBackgroundImage:(int)index
{
	if ((index < 0) || (index > 2)) {
		return;
	}

	imageNumber = index;
}

-(MVPMC*)init
{
	self = [super init];

	playing = NO;

	imageNumber = 0;

	image[0] = [UIImage imageNamed:@"slate_background.jpg"];
	image[1] = [UIImage imageNamed:@"stone_background.jpg"];
	image[2] = [UIImage imageNamed:@"bricks_background.jpg"];

	idiom = [[UIDevice currentDevice] userInterfaceIdiom];

	if (idiom == UIUserInterfaceIdiomPad) {
		MVPMCLog(@"running on an iPad");
	} else {
		MVPMCLog(@"running on an iPhone");
	}

	UIScreen* mainscr = [UIScreen mainScreen];
	if ([self isiPad]) {
		width = mainscr.currentMode.size.width;
		height = mainscr.currentMode.size.height;
	} else {
		// Use the old iphone resolution, since that is what all the
		// xib interface files use
		width = 320;
		height = 480;
	}

	MVPMCLog(@"Screen size is %d x %d", width, height);

	return self;
}

-(BOOL)isiPad
{
	return (idiom == UIUserInterfaceIdiomPad);
}

-(int)screenHeight
{
	return height;
}

-(int)screenWidth
{
	return width;
}

-(BOOL)isPlaying
{
	return playing;
}

#define IFCONFSZ 4096
#define max(a,b)	((a > b) ? a : b)

-(void) discoverIPAddresses;
{
	int i, len, flags;
	char buffer[IFCONFSZ], *ptr, lastname[IFNAMSIZ], *cptr;
	struct ifconf ifc;
	struct ifreq *ifr, ifrcopy;
	struct sockaddr_in *sin;
	char temp[80];
	int sockfd;

	addrs = 0;
	for (i=0; i<MAX_ETH_DEVS; ++i) {
		if (if_names[i] != NULL) {
			free(if_names[i]);
		}
		if (ip_names[i] != NULL) {
			free(ip_names[i]);
		}
		if_names[i] = ip_names[i] = NULL;
		ip_addrs[i] = 0;
	}

	sockfd = socket(AF_INET, SOCK_DGRAM, 0);
	if (sockfd < 0) {
		perror("socket failed");
		return;
	}

	ifc.ifc_len = IFCONFSZ;
	ifc.ifc_buf = buffer;
	if (ioctl(sockfd, SIOCGIFCONF, &ifc) < 0) {
		perror("ioctl error");
		return;
	}

	lastname[0] = '\0';

	for (ptr = buffer; ptr < buffer + ifc.ifc_len; ) {
		ifr = (struct ifreq *)ptr;
		len = max(sizeof(struct sockaddr), ifr->ifr_addr.sa_len);
		ptr += sizeof(ifr->ifr_name) + len;
		if (ifr->ifr_addr.sa_family != AF_INET) {
			continue;
		}
		if ((cptr = (char *)strchr(ifr->ifr_name, ':')) != NULL) {
			*cptr = 0;
		}
		if (strncmp(lastname, ifr->ifr_name, IFNAMSIZ) == 0) {
			continue;
		}
		memcpy(lastname, ifr->ifr_name, IFNAMSIZ);
		ifrcopy = *ifr;
		ioctl(sockfd, SIOCGIFFLAGS, &ifrcopy);
		flags = ifrcopy.ifr_flags;
		if ((flags & IFF_UP) == 0) {
			continue;
		}
		if_names[addrs] = (char *)malloc(strlen(ifr->ifr_name)+1);
		if (if_names[addrs] == NULL) {
			return;
		}
		strcpy(if_names[addrs], ifr->ifr_name);
		sin = (struct sockaddr_in *)&ifr->ifr_addr;
		strcpy(temp, inet_ntoa(sin->sin_addr));
		ip_names[addrs] = (char *)malloc(strlen(temp)+1);
		if (ip_names[addrs] == NULL) {
			return;
		}
		strcpy(ip_names[addrs], temp);
		ip_addrs[addrs] = sin->sin_addr.s_addr;
		addrs++;
	}

	close(sockfd);

}

-(NSString*)getIPAddress
{
	NSString *string = NULL;
	int i, dev = -1;
	char *c = "";

	[self discoverIPAddresses];

	/*
	 * Prefer the wifi address over the phone network
	 */
	for (i=0; i<addrs; i++) {
		if (strncmp(if_names[i], "en", 2) == 0) {
			dev = i;
		}
		if ((dev < 0) && (strncmp(if_names[i], "pdp_ip", 6) == 0)) {
			dev = i;
		}
		MVPMCLog(@"if: %s  addr: %s", if_names[i], ip_names[i]);
	}

	if (dev >= 0) {
		c = ip_names[dev];
		string = [[NSString alloc] initWithFormat: @"%s", c];
	}

	return string;
}

@end
