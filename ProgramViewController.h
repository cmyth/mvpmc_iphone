//
//  ProgramViewController.h
//  mvpmc
//
//  Created by Jon Gettler on 1/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "api.h"


@interface ProgramViewController : UIViewController {
	IBOutlet UILabel *title;
	IBOutlet UILabel *subtitle;
	IBOutlet UITextView *description;
	IBOutlet UILabel *date;
	IBOutlet UIButton *back;
	cmythProgram *prog;
}

@property (retain,nonatomic) UILabel *title;
@property (retain,nonatomic) UILabel *subtitle;
@property (retain,nonatomic) UITextView *description;
@property (retain,nonatomic) UILabel *date;
@property (retain,nonatomic) UIButton *back;
@property (nonatomic, retain) cmythProgram *prog;

-(IBAction) hide:(id) sender;
-(IBAction) playOriginal:(id) sender;
-(IBAction) playTranscoded:(id) sender;
-(IBAction) transcode:(id) sender;

-(void)popup:(NSString*)title message:(NSString*)message;
-(void)play_movie:(int)port;

@end
