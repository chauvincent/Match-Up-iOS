//
//  ChatViewController.h
//  MatchUp
//
//  Created by Vincent Chau on 8/15/15.
//  Copyright (c) 2015 Vincent Chau. All rights reserved.
//

#import "JSMessagesViewController.h"

@interface ChatViewController : JSMessagesViewController <JSMessagesViewDataSource, JSMessagesViewDelegate>

@property (strong, nonatomic) PFObject *chatRoom;

@end
