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
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <netdb.h>

#include <cmyth/cmyth.h>
#include <refmem/refmem.h>

#import "mvpmc.h"

@implementation VLC

@synthesize lock;

static int
my_write(int fd, char *buf, int len)
{
	int tot = 0;
	int n, err;

	while (tot < len) {
		n = write(fd, buf+tot, len-tot);
		err = errno;
		if (n < 0) {
			break;
		}

		tot += n;
	}

	return tot;
}

static int send_password(int fd)
{
	char buf[128];
	char *passwd = "admin\n";

	memset(buf, 0, sizeof(buf));

	struct timeval tv;
	fd_set fds;

	tv.tv_sec = 5;
	tv.tv_usec = 0;

	FD_ZERO(&fds);
	FD_SET(fd, &fds);
	if (select(fd + 1, &fds, NULL, NULL, &tv) < 0) {
		return -1;
	}

	errno = 0;
	if (read(fd, buf, sizeof(buf)) <= 0) {
		return -1;
	}

	if (strncmp(buf, "Password:", 9) != 0) {
		return -1;
	}

	my_write(fd, passwd, strlen(passwd));

	memset(buf, 0, sizeof(buf));

	read(fd, buf, sizeof(buf));

	if (strstr(buf, "> ") == NULL) {
		return -1;
	}

	return 0;
}

static int issue_command(int fd, char *buf)
{
	struct timeval tv;
	fd_set fds;
	char input[512];

	if (my_write(fd, buf, strlen(buf)) != strlen(buf)) {
		return -1;
	}

	tv.tv_sec = 0;
	tv.tv_usec = 100;

	FD_ZERO(&fds);
	FD_SET(fd, &fds);
	if (select(fd + 1, &fds, NULL, NULL, &tv) < 0) {
		return -1;
	}

	read(fd, input, sizeof(input));

	return 0;
}

static int command_result(int fd, char *buf, char *result, int max)
{
	struct timeval tv;
	fd_set fds;
	int len;

	if (my_write(fd, buf, strlen(buf)) != strlen(buf)) {
		return -1;
	}

	len = 0;
	memset(result, 0, max);
	max--;
	while (len < max) {
		int n;

		tv.tv_sec = 1;
		tv.tv_usec = 0;

		FD_ZERO(&fds);
		FD_SET(fd, &fds);
		if (select(fd + 1, &fds, NULL, NULL, &tv) <= 0) {
			break;
		}

		n = read(fd, result+len, max-len);

		if (n <= 0) {
			break;
		}

		len += n;
	}

	return len;
}

static int send_commands(int fd, const char *src, const char *dest,
			 const char *file)
{
	char *cmd_del = "del %s\n";
	char *cmd_new = "new %s broadcast enabled\n";
	char *cmd_input = "setup %s input %s/%s\n";
	char *cmd_output = "setup %s output #transcode{width=480,canvas-height=320,vcodec=mp4v,vb=768,acodec=mp4a,ab=192,channels=2}:standard{access=file,mux=mp4,dst=%s/%s.mp4}\n";
	char *cmd_play = "control %s play\n";
	char buf[512], id[128];

	snprintf(id, sizeof(id), "mvpmc.iphone.%s", file);

	snprintf(buf, sizeof(buf), cmd_del, id);
	if (issue_command(fd, buf) != 0) {
		return -1;
	}

	snprintf(buf, sizeof(buf), cmd_new, id);
	if (issue_command(fd, buf) != 0) {
		return -1;
	}

	snprintf(buf, sizeof(buf), cmd_input, id, src, file);
	if (issue_command(fd, buf) != 0) {
		return -1;
	}

	snprintf(buf, sizeof(buf), cmd_output, id, dest, file);
	if (issue_command(fd, buf) != 0) {
		return -1;
	}

	snprintf(buf, sizeof(buf), cmd_play, id);
	if (issue_command(fd, buf) != 0) {
		return -1;
	}

	return 0;
}

-(void)transcoder
{
	const char *h = [vlc UTF8String];
	int fd, ret;
	struct sockaddr_in sa;
	struct hostent* server;

	server = gethostbyname(h);

	if ((fd=socket(AF_INET, SOCK_STREAM, 0)) < 0) {
		self->state = VLC_TRANSCODE_CONNECT_FAILED;
		return;
	}

	sa.sin_family = AF_INET;
	sa.sin_port = htons(4212);
	memcpy((char*)&sa.sin_addr,(char*)server->h_addr,server->h_length);

	int set = 1;
	setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, (void *)&set, sizeof(int));

#if defined(TCP_CONNECTIONTIMEOUT)
	struct timeval tv;
	tv.tv_sec = 5;
	tv.tv_usec = 0;
	setsockopt(fd, IPPROTO_TCP, TCP_CONNECTIONTIMEOUT, &tv, sizeof(tv));
#endif

	NSLog(@"VLC connect to %@", vlc);
	ret = connect(fd, (struct sockaddr *)&sa, sizeof(sa));

	if (ret < 0) {
		NSLog(@"VLC connect failed");
		close(fd);
		self->state = VLC_TRANSCODE_CONNECT_FAILED;
		return;
	}

	setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, (void *)&set, sizeof(int));

	if (send_password(fd) != 0) {
		NSLog(@"VLC login failed");
		close(fd);
		self->state = VLC_TRANSCODE_CONNECT_FAILED;
		return;
	}

	NSLog(@"VLC password accepted");

	self->state = VLC_TRANSCODE_STARTING;

	char *f = cmyth_proginfo_pathname(prog);
	ret = send_commands(fd, [srcPath UTF8String],
			    [dstPath UTF8String], f);

	if (ret == 0) {
		state = VLC_TRANSCODE_IN_PROGRESS;
	} else {
		state = VLC_TRANSCODE_ERROR;
		close(fd);
		return;
	}

	const char *fn = (const char*) f;
	char *pos = "position : ";
	while (!done) {
		char id[256], cmd[512], output[4096];
		int n;

		sleep(1);
		snprintf(id, sizeof(id), "mvpmc.iphone.%s", fn);
		snprintf(cmd, sizeof(cmd), "show %s\n", id);

		if ((n=command_result(fd, cmd, output, sizeof(output))) > 0) {
			char *p = strstr(output, pos);
			if (p != NULL) {
				char *R = strchr(p, '\r');
				char *N = strchr(p, '\n');

				if (R) {
					*R = '\0';
				}
				if (N) {
					*N = '\0';
				}

				p += strlen(pos);
				progress = strtof(p, NULL);
			} else {
				done = 1;
				progress = 1;
				break;
			}
		} else {
			NSLog(@"VLC read failed with n %d",n);
		}
	}

	if (done == 1) {
		char id[256], cmd[512];

		state = VLC_TRANSCODE_STOPPING;

		snprintf(id, sizeof(id), "mvpmc.iphone.%s", fn);
		snprintf(cmd, sizeof(cmd), "del %s\n", id);

		NSLog(@"VLC %s",cmd);

		issue_command(fd, cmd);

		if (progress == 1) {
			state = VLC_TRANSCODE_COMPLETE;
		} else {
			state = VLC_TRANSCODE_STOPPED;
		}
	}

	close(fd);

	[lock lock];
	done = 2;
	[lock unlock];

	if (state == VLC_TRANSCODE_COMPLETE) {
		NSLog(@"transcode is complete");
	} else {
		NSLog(@"transcode is stopped");
	}
}

-(VLC*)transcodeWith:(cmyth_proginfo_t)program
	    mythPath:(NSString*)myth
	     vlcHost:(NSString*)host
	     vlcPath:(NSString*)path
{
	if ((program == NULL) || (myth == nil) ||
	    (host == nil) || (path == nil)) {
		return nil;
	}

	self = [super init];

	self->state = VLC_TRANSCODE_UNKNOWN;
	self->prog = program;
	self->srcPath = myth;
	self->dstPath = path;
	self->vlc = host;

	lock = [[NSLock alloc] init];

	[NSThread detachNewThreadSelector:@selector(transcoder)
		  toTarget:self withObject:nil];

	return self;
}

-(void)transcodeStop
{
	[lock lock];
	if (done == 0) {
		done = 1;
	}
	[lock unlock];
}

-(float)transcodeProgress
{
	float ret;

	switch (state) {
	case VLC_TRANSCODE_COMPLETE:
		ret = 1.0;
		break;
	case VLC_TRANSCODE_IN_PROGRESS:
		ret = progress;
		break;
	default:
		ret = 0.0;
		break;
	}

	return ret;
}

-(int)portNumber
{
	return portno;
}

-(vlcTranscodeState)transcodeState
{
	return state;
}

-(cmyth_proginfo_t*)getProg
{
	return prog;
}

@end
