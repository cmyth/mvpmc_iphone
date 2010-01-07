//
//  HelpViewController.h
//  mvpmc
//
//  Created by Jon Gettler on 1/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HelpViewController : UIViewController {
	IBOutlet UIButton *back;
	IBOutlet UITextView *help;
}

-(IBAction) hide:(id) sender;

@property (retain,nonatomic) UIButton *back;

@end
