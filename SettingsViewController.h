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


@interface SettingsViewController : UIViewController <UITextFieldDelegate> {
	IBOutlet UITextField *host;
	IBOutlet UITextField *port;
	IBOutlet UITextField *path;
	IBOutlet UITextField *vlc_host;
	IBOutlet UITextField *vlc_port;
	IBOutlet UITextField *vlc_path;
	IBOutlet UITextField *www_host;
	IBOutlet UITextField *www_path;
	IBOutlet UISwitch *vlc;
	IBOutlet UIButton *test;
	IBOutlet UIButton *help;
	UIActivityIndicatorView *active;
}

-(void)popup:(NSString*)title message:(NSString*)message;
-(IBAction)hideKeyboard:(id)sender;
-(IBAction)display_help:(id)sender;
-(void)animateTextField:(UITextField*)textField up:(BOOL)up;

@property (retain,nonatomic) UITextField *host;
@property (retain,nonatomic) UITextField *port;
@property (retain,nonatomic) UITextField *path;
@property (retain,nonatomic) UITextField *vlc_host;
@property (retain,nonatomic) UITextField *vlc_port;
@property (retain,nonatomic) UITextField *vlc_path;
@property (retain,nonatomic) UITextField *www_host;
@property (retain,nonatomic) UITextField *www_port;
@property (retain,nonatomic) UISwitch *vlc;
@property (retain,nonatomic) UIButton *test;
@property (retain,nonatomic) UIButton *help;

@end
