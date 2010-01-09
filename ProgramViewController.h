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

#import <UIKit/UIKit.h>
#import "api.h"


@interface ProgramViewController : UIViewController {
	IBOutlet UILabel *title;
	IBOutlet UILabel *subtitle;
	IBOutlet UITextView *description;
	IBOutlet UILabel *date;
	IBOutlet UILabel *length;
	IBOutlet UIButton *back;
	cmythProgram *prog;
}

@property (retain,nonatomic) UILabel *title;
@property (retain,nonatomic) UILabel *subtitle;
@property (retain,nonatomic) UITextView *description;
@property (retain,nonatomic) UILabel *date;
@property (retain,nonatomic) UILabel *length;
@property (retain,nonatomic) UIButton *back;
@property (nonatomic, retain) cmythProgram *prog;

-(IBAction) hide:(id) sender;
-(IBAction) playOriginal:(id) sender;
-(IBAction) playTranscoded:(id) sender;
-(IBAction) transcode:(id) sender;
-(IBAction) stopTranscode:(id) sender;

-(void)popup:(NSString*)title message:(NSString*)message;
-(void)play_movie:(int)port;

@end
