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

@implementation Httpd

typedef struct {
	char *command;
	char *file;
	long long start;
	long long end;
} url_t;

static url_t*
read_header(int fd)
{
	char buf[512];
	char request[512];
	char line[512];
	int l = 0;
	url_t *u;
	char *p, *b, *o;
	static int seen = 0;

	read(fd, buf, sizeof(buf));

	u = (url_t*)malloc(sizeof(url_t));
	memset(u, 0, sizeof(*u));

	memset(request, 0, sizeof(request));
	memset(line, 0, sizeof(line));

	b = strstr(buf, "\r\n");
	*b = '\0';
	strcpy(request, buf);
	*b = '\r';
	b += 2;

	u->command = strdup(request);
	if ((p=strchr(u->command, ' ')) != NULL) {
		*(p++) = '\0';
		u->file = p;
		if ((p=strchr(p, ' ')) != NULL) {
			*(p++) = '\0';
		}
	}

	while (1) {
		char *field, *value;

		o = b;
		b = strstr(o, "\r\n");
		*b = '\0';
		strcpy(line, o);
		*b = '\r';
		b += 2;
		if (*b == '\r') {
			break;
		}

		if (strcmp(line, "\r\n") == 0) {
			break;
		}

		field = line;
		if ((value=strchr(field, ':')) != NULL) {
			*(value++) = '\0';
		}

		if (strcasecmp(field, "range") == 0) {
			char *start, *end;

			start = strchr(value, '=');
			start++;
			end = strchr(start, '-');
			*(end++) = '\0';

			u->start = strtoll(start, NULL, 0);
			u->end = strtoll(end, NULL, 0);
		}

		l++;
	}

	seen++;

	return u;
}

static void
handler(int sig)
{
}

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

static int
send_header(int fd, url_t *u, long long length)
{
	long long size = u->end - u->start + 1;
	char buf[512];

	memset(buf, 0, sizeof(buf));

	sprintf(buf, "HTTP/1.1 206 Partial Content\r\n");
	sprintf(buf+strlen(buf), "Server: mvpmc\r\n");
	sprintf(buf+strlen(buf), "Accept-Ranges: bytes\r\n");
	sprintf(buf+strlen(buf), "Content-Length: %lld\r\n", size);
	sprintf(buf+strlen(buf), "Content-Range: bytes %lld-%lld/%lld\r\n",
		u->start, u->end, length);
	sprintf(buf+strlen(buf), "Connection: close\r\n");
	sprintf(buf+strlen(buf), "\r\n");

	if (my_write(fd, buf, strlen(buf)) != strlen(buf)) {
		return -1;
	}

	return 0;
}

static long long
send_data(int fd, url_t *u, cmyth_file_t file)
{
	char *buf;
	unsigned long long pos;
	long long wrote = 0;

#define BSIZE (8*1024)
	if ((buf=(char*)malloc(BSIZE)) == NULL) {
		return 0;
	}

	pos = cmyth_file_seek(file, u->start, SEEK_SET);

	while (pos <= (u->end)) {
		int size, tot, len, l;

		size = ((u->end - pos) >= BSIZE) ? BSIZE : (u->end - pos + 1);

		len = cmyth_file_request_block(file, size);

		tot = 0;
		while (tot < len) {
			int n;
			n = cmyth_file_get_block(file, buf+tot, len-tot);
			if (n <= 0) {
				goto err;
			}
			tot += n;
		}

		if ((l=my_write(fd, buf, len)) != len) {
			wrote += l;
			break;
		}

		wrote += len;

		pos += len;
	}

err:
	free(buf);

	return wrote;
}

-(void)server
{
	int attempts = 0;
	long long w, wrote = 0;

	NSLog(@"http server started");

	while (1) {
		url_t *u;

		fd = -1;

		if (listen(sockfd, 5) != 0) {
			break;
		}

		if ((fd=accept(sockfd, NULL, NULL)) < 0) {
			break;
		}

		int set = 1;
		setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, (void *)&set, sizeof(int));

		attempts++;

		u = read_header(fd);

		if (strcasecmp(u->command, "GET") == 0) {
			NSLog(@"GET command");
			if (send_header(fd, u, length) == 0) {
				w = send_data(fd, u, file);
				NSLog(@"wrote %lld bytes", w);
				wrote += w;
			}
		}

		close(fd);

		if (w <= 0) {
			break;
		}
	}

	NSLog(@"server exiting, wrote %d bytes", wrote);
}

static int
create_socket(int *f, int *p)
{
	int fd, port, rc;
	int attempts = 0;
	struct sockaddr_in sa;

	if ((fd=socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0) {
		return -1;
	}

	int set = 1;
	setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, (void *)&set, sizeof(int));

	do {
		port = (random() % 32768) + 5001;

		memset(&sa, 0, sizeof(sa));

		sa.sin_family = AF_INET;
		sa.sin_port = htons(port);
		sa.sin_addr.s_addr = INADDR_ANY;

		rc = bind(fd, (void*)&sa, sizeof(sa));
	} while ((rc != 0) && (attempts++ < 100));

	if (rc != 0) {
		close(fd);
		return -1;
	}

	*f = fd;
	*p = port;

	return 0;
}

-(Httpd*)openWith:(cmyth_proginfo_t)prog
{
	int tcp_control = 4096;
	int tcp_program = 128*1024;
	int port;
	char *host;

	if (create_socket(&sockfd, &portno) != 0) {
		return nil;
	}

	if ((host=cmyth_proginfo_host(prog)) == NULL) {
		goto err;
	}

	if ((port=cmyth_proginfo_port(prog)) < 0) {
		goto err;
	}

	NSLog(@"opening myth connection");

	if ((conn=cmyth_conn_connect_ctrl(host, port, 16*1024,
					  tcp_control)) == NULL) {
		goto err;
	}

	NSLog(@"opening myth file");

#define MAX_BSIZE	(256*1024*3)
	if ((file=cmyth_conn_connect_file(prog, conn, MAX_BSIZE,
					  tcp_program)) == NULL) {
		goto err;
	}

	length = cmyth_proginfo_length(prog);

	NSLog(@"program length %d", length);

	self = [super init];

//	[NSThread detachNewThreadSelector:@selector(server)
//		  toTarget:self withObject:nil];
	thread = [[NSThread alloc] initWithTarget:self
				   selector:@selector(server)
				   object:nil];

	[thread start];

	return self;

err:
	close(sockfd);

	return nil;
}

-(int)portNumber
{
	return portno;
}

-(void)shutdown {
	NSLog(@"shutdown httpd object");

	if (thread) {
		[thread cancel];
		thread = nil;

		close(sockfd);
		close(fd);
	}

	ref_release(conn);
	conn = NULL;
	ref_release(file);
	file = NULL;
}

- (void)dealloc {
	NSLog(@"release httpd object");

	[self shutdown];
	[super dealloc];
}

@end
