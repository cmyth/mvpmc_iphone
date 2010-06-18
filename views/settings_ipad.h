//
//  settings_ipad.h
//  mvpmc
//
//  Created by Jon Gettler on 6/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface settings_ipad : UIViewController <UITextFieldDelegate> {
	IBOutlet UITextField *host;
	IBOutlet UITextField *port;
	IBOutlet UITextField *path;
	IBOutlet UITextField *vlc_host;
	IBOutlet UITextField *vlc_path;
	IBOutlet UITextField *www_base;
}

-(IBAction)hideKeyboard:(id)sender;

@property (retain,nonatomic) UITextField *host;
@property (retain,nonatomic) UITextField *port;
@property (retain,nonatomic) UITextField *path;
@property (retain,nonatomic) UITextField *vlc_host;
@property (retain,nonatomic) UITextField *vlc_path;
@property (retain,nonatomic) UITextField *www_base;

@end
