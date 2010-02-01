//
//  ScrollViewController.h
//  mvpmc
//
//  Created by Jon Gettler on 1/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ScrollViewController : UIViewController {
	IBOutlet UIScrollView *scroll;
	IBOutlet UIImageView *background;
	IBOutlet UIImageView *logo;
}

@property (retain,nonatomic) UIScrollView *scroll;
@property (retain,nonatomic) UIImageView *background;
@property (retain,nonatomic) UIImageView *logo;

-(void)changeImage;
-(IBAction)displayHelp:(id)sender;

@end
