//
//  URLViewController.h
//  mvpmc
//
//  Created by Jon Gettler on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface URLViewController : UIViewController {
	IBOutlet UITextField *url;
	IBOutlet UIButton *play;
}

-(IBAction)hideKeyboard:(id)sender;
-(IBAction)play_movie:(id)sender;

@property (retain,nonatomic) UITextField *url;
@property (retain,nonatomic) UIButton *play;

@end
