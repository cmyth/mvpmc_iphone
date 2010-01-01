//
//  aboutViewController.h
//  mvpmc
//
//  Created by Jon Gettler on 12/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface aboutViewController : UIViewController {
	IBOutlet UIButton *link;
	IBOutlet UILabel *version;
	IBOutlet UILabel *ip;
}

-(IBAction)jump:(id)sender;

@property (retain,nonatomic) UIButton *link;
@property (retain,nonatomic) UILabel *version;
@property (retain,nonatomic) UILabel *ip;

@end
