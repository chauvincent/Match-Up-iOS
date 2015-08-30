//
//  HomeViewController.m
//  MatchUp
//
//  Created by Vincent Chau on 8/12/15.
//  Copyright (c) 2015 Vincent Chau. All rights reserved.
//

#import "HomeViewController.h"
#import "TestUser.h"
#import "ProfileViewController.h"
#import "MatchViewController.h"
#import "TransitionAnimator.h"

@interface HomeViewController () <MatchViewControllerDelegate, ProfileViewcontrollerDelegate, UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *chatBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *taglineLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;

@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) PFObject *photo; //keep track of current photo
@property (strong, nonatomic) NSMutableArray *activities;

@property (strong, nonatomic) IBOutlet UIView *labelContainerView;
@property (strong, nonatomic) IBOutlet UIView *buttonContainerView;

@property (nonatomic) int currentPhotoIndex;
@property (nonatomic) BOOL isLikedByCurrentUser;
@property (nonatomic) BOOL dislikedByCurrentUser;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[TestUser saveTestUserToParse];
    
    // initial setup
    [self setUpViews];
    
    
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    self.photoImageView.image = nil;
    self.firstNameLabel.text = nil;
    self.ageLabel.text = nil;
    
    self.likeButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    self.currentPhotoIndex = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:kPhotoClassKey];
    [query whereKey:kPhotoUserKey notEqualTo:[PFUser currentUser]];
    [query includeKey:kPhotoUserKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             self.photos = objects;
         
             if ([self allowPhoto] == NO) {
                 [self setUpNextPhoto];
             }
             else
             {
                 [self queryForCurrentPhotoIndex];
             }
        }
         else
             NSLog(@"Error in HomeViewController: %@", error);
         
     }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"homeToProfileSegue"])
    {
        ProfileViewController *profileVC = segue.destinationViewController;
        profileVC.photo = self.photo;
        profileVC.delegate = self;
        
    }
//    else if ([segue.identifier isEqualToString:@"homeToMatchSegue"])
//    {
//        MatchViewController *nextVC = segue.destinationViewController;
//        nextVC.matchedUserImage = self.photoImageView.image;
//        nextVC.delegate = self;
//    }
}

#pragma mark - IBActions
- (IBAction)chatButtonPressed:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"homeToMatchesSegue" sender:nil];
}

- (IBAction)settingsButtonPressed:(UIBarButtonItem *)sender
{
}
- (IBAction)likeButtonPressed:(UIButton *)sender
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Like"];
    
    [mixpanel flush];
    
    [self checkLike];
}
- (IBAction)dislikeButtonPressed:(UIButton *)sender
{
    [self checkDislike];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Dislike"];
    
    [mixpanel flush];
    
}
- (IBAction)infoButtonPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"homeToProfileSegue" sender:nil];
}

#pragma mark - Helper Methods
-(void)setUpViews
{
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    [self addShadowForView:self.buttonContainerView];
    [self addShadowForView:self.labelContainerView];
    self.photoImageView.layer.masksToBounds=NO;
}
-(void)addShadowForView:(UIView *)view
{
    view.layer.masksToBounds = NO;
    view.layer.cornerRadius = 4;
    view.layer.shadowRadius = 1;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowOpacity = 0.25;
}
-(void)queryForCurrentPhotoIndex
{
    if ([self.photos count] > 0)
    {
        self.photo = self.photos[self.currentPhotoIndex];
        PFFile *file = self.photo[kPhotoPictureKey];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
        {
            if (!error)
            {
                UIImage *image = [UIImage imageWithData:data];
                self.photoImageView.image = image;
                [self updateView];
            }
            else
                NSLog(@"%@",error);
        }];
    
    
    PFQuery *queryForLike = [PFQuery queryWithClassName:kActivityClassKey];
    [queryForLike whereKey:kActivityTypeKey equalTo:kActivityTypeLikeKey];
    [queryForLike whereKey:kActivityPhotoKey equalTo:self.photo];
    [queryForLike whereKey:kActivityFromUserKey equalTo:[PFUser currentUser]];
    
    PFQuery *queryForDisLike = [PFQuery queryWithClassName:kActivityClassKey];
    [queryForLike whereKey:kActivityTypeKey equalTo:kActivityTypeDislikeKey];
    [queryForLike whereKey:kActivityPhotoKey equalTo:self.photo];
    [queryForLike whereKey:kActivityFromUserKey equalTo:[PFUser currentUser]];
    
    PFQuery *likeAndDislikeQuery = [PFQuery orQueryWithSubqueries:@[queryForLike, queryForDisLike]];
    [likeAndDislikeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (!error)
        {
            self.activities = [objects mutableCopy];
            
            if ([self.activities count] == 0)
            {
                self.isLikedByCurrentUser = NO;
                self.dislikedByCurrentUser = NO;
            }
            else
            {
                PFObject *activity = self.activities[0];
                if ([activity[kActivityTypeKey] isEqualToString:kActivityTypeLikeKey])
                {
                    self.isLikedByCurrentUser = YES;
                    self.dislikedByCurrentUser = NO;
                }
                else if ([activity[kActivityTypeKey] isEqualToString:kActivityTypeDislikeKey])
                {
                    self.isLikedByCurrentUser = NO;
                    self.dislikedByCurrentUser = YES;
                }
                else
                {
                    
                }
            }
            self.infoButton.enabled = YES;
            self.dislikeButton.enabled = YES;
            self.likeButton.enabled = YES;
         
        }
    }];
    }
}
-(void)updateView
{
    self.firstNameLabel.text = self.photo[kPhotoUserKey][kUserProfileKey][kUserProfileFirstNameKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@",self.photo[kPhotoUserKey][kUserProfileKey][kUserProfileAgeKey]];
    self.taglineLabel.text = self.photo[kPhotoUserKey][kUserTagLineKey];
}
-(BOOL)allowPhoto
{
    int maxAge = [[NSUserDefaults standardUserDefaults] integerForKey:kMaxAgeKey];
    BOOL men = [[NSUserDefaults standardUserDefaults] boolForKey:kMenEnabledKey];
    BOOL women = [[NSUserDefaults standardUserDefaults] boolForKey:kWomenEnabledKey];
    BOOL single = [[NSUserDefaults standardUserDefaults] boolForKey:kSingleEnabledKey];
    
    PFObject *photo = self.photos[self.currentPhotoIndex];
    PFUser *user = photo[kPhotoUserKey];
    
    int userAge = [user[kUserProfileKey][kUserProfileAgeKey] intValue];
    NSString *gender = user[kUserProfileKey][kUserProfileGenderKey];
    NSString *relationshipStatus = user[kUserProfileKey][kUserProfileRelationshipStatusKey];
    
    if (userAge > maxAge) {
        return NO;
    }
    else if(men == NO && [gender isEqualToString:@"male"])
    {
        return NO;
    }
    else if (women == NO && [gender isEqualToString:@"female"])
    {
        return NO;
    }
    else if (single == NO && ([relationshipStatus isEqualToString:@"single"] || relationshipStatus == nil))
    {
        return NO;
    }
    else
    {
        return YES;
    }

    
    
}
-(void)setUpNextPhoto
{
    if (self.currentPhotoIndex + 1 < self.photos.count)
    {
        self.currentPhotoIndex++;
      
        if ([self allowPhoto] == NO)
        {
            [self setUpNextPhoto];
        }
        else
        {
            [self queryForCurrentPhotoIndex];
        }
        
    }
    else
    {
        UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"No More Users To View" message:@"Check back later" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
}
-(void)saveLike
{
    PFObject *likeActivity = [PFObject objectWithClassName:kActivityClassKey]; // new class
    [likeActivity setObject:kActivityTypeLikeKey forKey:kActivityTypeKey];
    [likeActivity setObject:[PFUser currentUser] forKey:kActivityFromUserKey];
    [likeActivity setObject:[self.photo objectForKey:kPhotoUserKey] forKey:kActivityToUserKey];  [likeActivity setObject:self.photo forKey:kActivityPhotoKey];
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            [self checkForChatRoom];
            self.isLikedByCurrentUser = YES;
            self.dislikedByCurrentUser = NO;
            [self.activities addObject:likeActivity];
            [self checkForPhotoLikes];
            [self setUpNextPhoto];
        }];
}
-(void)saveDislike
{
    PFObject *dislikeActivity = [PFObject objectWithClassName:kActivityClassKey];
    [dislikeActivity setObject:kActivityTypeDislikeKey forKey:kActivityTypeKey];
    [dislikeActivity setObject:[PFUser currentUser] forKey:kActivityFromUserKey];
    [dislikeActivity setObject:[self.photo objectForKey:kPhotoUserKey] forKey:kActivityToUserKey];
    [dislikeActivity setObject:self.photo forKey:kActivityPhotoKey];
    [dislikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        self.isLikedByCurrentUser = NO;
        self.dislikedByCurrentUser = YES;
        [self.activities addObject:dislikeActivity];
        [self setUpNextPhoto];
    }];
}
-(void)checkLike
{
    // if already liked

    if (self.isLikedByCurrentUser)
    {
        [self setUpNextPhoto];
        [self saveLike];
        return;
    }
    else if (self.dislikedByCurrentUser) // delete and remove from activity
    {
        for(PFObject *activity in self.activities)
            [activity deleteInBackground];
        
        [self.activities removeLastObject];
        [self saveLike];
    }
    else
    {
        [self saveLike];
    }
}
-(void)checkDislike
{
    if (self.dislikedByCurrentUser) // if already disliked
    {
        [self setUpNextPhoto];
        return;
    }
    else if (self.isLikedByCurrentUser) // if liked, remove and save dislike
    {
        for (PFObject *activity in self.activities)
            [activity deleteInBackground];
        
        [self.activities removeLastObject];
        [self saveDislike];
    }
    else
        [self saveDislike];
    
}
-(void)checkForPhotoLikes
{
    PFQuery *query = [PFQuery queryWithClassName:kActivityClassKey];
    [query whereKey:kActivityFromUserKey equalTo:self.photo[kPhotoUserKey]];
    [query whereKey:kActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kActivityTypeKey equalTo:kActivityTypeLikeKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if ([objects count] > 0) {
             [self createChatRoom];
         }
     }];
}

-(void)createChatRoom
{
    PFQuery *queryForChatRoom = [PFQuery queryWithClassName:kChatRoomClassKey];
    [queryForChatRoom whereKey:kChatRoomUser1Key equalTo:[PFUser currentUser]];
    [queryForChatRoom whereKey:kChatRoomUser2Key equalTo:self.photo[kPhotoUserKey]];
    
    PFQuery *queryForChatRoomInverse = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryForChatRoomInverse whereKey:kChatRoomUser1Key equalTo:self.photo[kPhotoUserKey]];
    [queryForChatRoomInverse whereKey:kChatRoomUser2Key equalTo:[PFUser currentUser]];
    
    PFQuery *combineQuery = [PFQuery orQueryWithSubqueries:@[queryForChatRoom, queryForChatRoomInverse]];
    
    [combineQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if ([objects count] == 0)
        {
            PFObject *chatRoom = [PFObject objectWithClassName:kChatRoomClassKey];
            [chatRoom setObject:[PFUser currentUser] forKey:kChatRoomUser1Key];
            [chatRoom setObject:self.photo[kPhotoUserKey] forKey:kChatRoomUser2Key];
            [chatRoom saveInBackgroundWithBlock:^(BOOL success, NSError *error)
            {
                //[self performSegueWithIdentifier:@"homeToMatchSegue" sender:nil];
                // custom transition
                UIStoryboard *myStoryboard = self.storyboard;
                MatchViewController *matchVC = [myStoryboard instantiateViewControllerWithIdentifier:@"matchVC"];
                matchVC.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:.74];
                matchVC.transitioningDelegate = self;
                matchVC.matchedUserImage = self.photoImageView.image;
                matchVC.delegate = self;
                matchVC.modalPresentationStyle = UIModalPresentationCustom;
                [self presentViewController:matchVC animated:YES completion:nil];
            }];
        }
    }];
}

- (void)checkForChatRoom
{
    PFQuery *query = [PFQuery queryWithClassName:kActivityClassKey];
    [query whereKey:kActivityFromUserKey equalTo:self.photo[kPhotoUserKey]];
    [query whereKey:kActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kActivityTypeKey equalTo:kActivityTypeLikeKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count > 0) {
            [self createChatRoom];
        }
    }];
}

#pragma mark - MatchViewController Delegate
-(void)presentMatchesViewController
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self performSegueWithIdentifier:@"homeToMatchesSegue" sender:nil];
    }];
}

#pragma mark - ProfileViewControler Delegate
-(void)didPressLike
{
    [self.navigationController popViewControllerAnimated:NO];
    [self checkLike];
    
}
-(void)didPressDislike
{
    
    [self.navigationController popViewControllerAnimated:NO];
    [self checkDislike];
}

#pragma mark - UIViewControllerTransitionDelegate
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    TransitionAnimator *animator = [[TransitionAnimator alloc] init];
    animator.presenting = YES;
    return animator;
}
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    TransitionAnimator *animator = [[TransitionAnimator alloc] init];
    return animator;
}

@end
