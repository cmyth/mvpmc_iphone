//
//  SettingsViewController.h
//  mvpmc
//
//  Created by Jon Gettler on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsViewController : UIViewController {
	IBOutlet UITextField *host;
	IBOutlet UITextField *port;
	IBOutlet UITextField *vlc_host;
	IBOutlet UITextField *vlc_port;
	IBOutlet UITextField *vlc_path;
	IBOutlet UITextField *www_host;
	IBOutlet UITextField *www_path;
	IBOutlet UISwitch *vlc;
	IBOutlet UIButton *test;
}

-(IBAction)hideKeyboard:(id)sender;
-(IBAction)test_connection:(id)sender;

@property (retain,nonatomic) UITextField *host;
@property (retain,nonatomic) UITextField *port;
@property (retain,nonatomic) UITextField *vlc_host;
@property (retain,nonatomic) UITextField *vlc_port;
@property (retain,nonatomic) UITextField *vlc_path;
@property (retain,nonatomic) UITextField *www_host;
@property (retain,nonatomic) UITextField *www_port;
@property (retain,nonatomic) UISwitch *vlc;
@property (retain,nonatomic) UIButton *test;

@end
