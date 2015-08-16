//
//  MatchViewController.h
//  MatchUp
//
//  Created by Vincent Chau on 8/15/15.
//  Copyright (c) 2015 Vincent Chau. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MatchViewControllerDelegate <NSObject>

-(void)presentMatchesViewController;

@end


@interface MatchViewController : UIViewController

@property (strong, nonatomic) UIImage *matchedUserImage;
@property (weak, nonatomic) id <MatchViewControllerDelegate> delegate;

@end
