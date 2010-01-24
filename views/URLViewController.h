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
#import <MediaPlayer/MediaPlayer.h>

@interface URLViewController : UIViewController <UITextFieldDelegate> {
	IBOutlet UITextField *url;
	IBOutlet UIButton *play;
	IBOutlet UITextField *url_1;
	IBOutlet UIButton *play_1;
	IBOutlet UITextField *url_2;
	IBOutlet UIButton *play_2;
	IBOutlet UITextField *url_3;
	IBOutlet UIButton *play_3;
}

-(IBAction)hideKeyboard:(id)sender;
-(IBAction)play_movie:(id)sender;
-(void)animateTextField:(UITextField*)textField up:(BOOL)up;

@property (retain,nonatomic) UITextField *url;
@property (retain,nonatomic) UIButton *play;

@property (retain,nonatomic) UITextField *url_1;
@property (retain,nonatomic) UIButton *play_1;

@property (retain,nonatomic) UITextField *url_2;
@property (retain,nonatomic) UIButton *play_2;

@property (retain,nonatomic) UITextField *url_3;
@property (retain,nonatomic) UIButton *play_3;

@end
