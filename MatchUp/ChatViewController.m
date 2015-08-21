//
//  ChatViewController.m
//  MatchUp
//
//  Created by Vincent Chau on 8/15/15.
//  Copyright (c) 2015 Vincent Chau. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()

@property (strong, nonatomic) PFUser *withUser;
@property (strong, nonatomic) PFUser *currentUser;

@property (strong, nonatomic) NSTimer *chatsTimer;
@property (nonatomic) BOOL intialLoadComplete;

@property (strong, nonatomic) NSMutableArray *chats;

@end

@implementation ChatViewController

-(NSMutableArray *)chats
{
    if (!_chats)
        _chats = [[NSMutableArray alloc]init];

    return _chats;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self checkForNewChats];
    // Do any additional setup after loading the view.
    self.delegate = self;
    self.dataSource = self;
    
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
    self.messageInputView.textView.placeHolder = @"New Message";
    [self setBackgroundColor:[UIColor whiteColor]];
    
    self.currentUser = [PFUser currentUser];
    PFUser *testUser1 = self.chatRoom[kChatRoomUser1Key];
    
    if ([testUser1.objectId isEqualToString:self.currentUser.objectId])
    {
        self.withUser = self.chatRoom[kChatRoomUser2Key];
        
    }
    else
    {
        self.withUser = self.chatRoom[kChatRoomUser1Key];
    }
    self.title = self.withUser[@"profile"][@"firstName"];
    self.intialLoadComplete = NO;
    
  
    self.chatsTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkForNewChats) userInfo:nil repeats:YES];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [self.chatsTimer invalidate];
    self.chatsTimer = nil;
}
#pragma mark -TableView Datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chats count];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - TableView Delegate
-(void)didSendText:(NSString *)text
{
    if (text.length!=0)
    {
        PFObject *chat = [PFObject objectWithClassName:kChatClassKey];
        [chat setObject:self.chatRoom forKey:kChatChatroomKey];
        [chat setObject:self.currentUser forKey:kChatFromUserKey];
        [chat setObject:self.withUser forKey:kChatToUserKey];
        [chat setObject:text forKey:kChatTextKey];
        [chat saveInBackgroundWithBlock:^(BOOL success, NSError *error)
         {
             [self.chats addObject:chat];
        //     [JSMessageSoundEffect playMessageSentSound];
             [self.tableView reloadData];
             [self finishSend];
             [self scrollToBottomAnimated:YES];
         }];
    }
}
-(JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[kChatFromUserKey];
    if ([testFromUser.objectId isEqual:self.currentUser.objectId]) {
        return JSBubbleMessageTypeOutgoing;
    }else
        return JSBubbleMessageTypeIncoming;
    
}
-(UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[kChatFromUserKey];
    if ([testFromUser.objectId isEqual:self.currentUser.objectId]) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleGreenColor]];
    }
    else
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleLightGrayColor]];
    
}
-(JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyAll;
}
-(JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyNone;
}
-(JSMessagesViewSubtitlePolicy)subtitlePolicy
{
    return JSMessagesViewSubtitlePolicyNone;
}
-(JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}
#pragma mark - Messages View Delegate OPTIONAL
-(void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell messageType] == JSBubbleMessageTypeOutgoing) {
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
    }
}
-(BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}
#pragma mark - Messages View Data Source REQUIRED
-(NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    NSString *messages = chat[@"text"];
    return messages;
}
-(NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}
-(UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}
-(NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}
#pragma mark - Helper Methods
-(void)checkForNewChats
{
    int oldChatCount = (int)[self.chats count];
    PFQuery *queryForChats = [PFQuery queryWithClassName:kChatClassKey];
    [queryForChats whereKey:kChatChatroomKey equalTo:self.chatRoom];
    [queryForChats orderByAscending:@"createdAt"];
    [queryForChats findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (!error)
        {
            if (self.intialLoadComplete == NO || oldChatCount != [objects count])
            {
                self.chats = [objects mutableCopy];
                [self.tableView reloadData];
                self.intialLoadComplete = YES;
                if (self.intialLoadComplete == YES)
                {
                    [JSMessageSoundEffect playMessageReceivedSound];
                }
                self.intialLoadComplete = YES;
                [self scrollToBottomAnimated:YES];
            }
        }
    }];
}
    /*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
