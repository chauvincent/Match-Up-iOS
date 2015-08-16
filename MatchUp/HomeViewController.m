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

@interface HomeViewController () <MatchViewControllerDelegate>

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

@property (nonatomic) int currentPhotoIndex;
@property (nonatomic) BOOL isLikedByCurrentUser;
@property (nonatomic) BOOL dislikedByCurrentUser;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [TestUser saveTestUserToParse];
    
    // initial setup
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
                [self queryForCurrentPhotoIndex];
            }
            else
                NSLog(@"Error in HomeViewController: %@", error);
            
        }];
    
    
    // Do any additional setup after loading the view.
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
        
    }
    else if ([segue.identifier isEqualToString:@"homeToMatchSegue"])
    {
        MatchViewController *nextVC = segue.destinationViewController;
        nextVC.matchedUserImage = self.photoImageView.image;
        nextVC.delegate = self;
    }
}

#pragma mark - IBActions
- (IBAction)chatButtonPressed:(UIBarButtonItem *)sender
{
}

- (IBAction)settingsButtonPressed:(UIBarButtonItem *)sender
{
}
- (IBAction)likeButtonPressed:(UIButton *)sender
{
    [self checkLike];
}
- (IBAction)dislikeButtonPressed:(UIButton *)sender
{
    [self checkDislike];
}
- (IBAction)infoButtonPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"homeToProfileSegue" sender:nil];
}

#pragma mark - Helper Methods

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
    }
    
    PFQuery *queryForLike = [PFQuery queryWithClassName:kActivityClassKey];
    [queryForLike whereKey:kActivityTypeKey equalTo:kActivityTypeLikeKey];
    [queryForLike whereKey:kActivityPhotoKey equalTo:self.photo];
    [queryForLike whereKey:kActivityToUserKey equalTo:[PFUser currentUser]];
    
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
-(void)updateView
{
    self.firstNameLabel.text = self.photo[kPhotoUserKey][kUserProfileKey][kUserProfileFirstNameKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@",self.photo[kPhotoUserKey][kUserProfileKey][kUserProfileAgeKey]];
    self.taglineLabel.text = self.photo[kPhotoUserKey][kUserTagLineKey];
}
-(void)setUpNextPhoto
{
    if (self.currentPhotoIndex + 1 < self.photos.count)
    {
        self.currentPhotoIndex++;
        [self queryForCurrentPhotoIndex];
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
    [likeActivity setObject:[self.photo objectForKey:kPhotoUserKey] forKey:kActivityToUserKey]; // for owner of photo
    [likeActivity setObject:self.photo forKey:kActivityPhotoKey];
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
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
        [self saveLike];
    
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
    PFQuery *queryForChatRoom = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryForChatRoom whereKey:@"user1" equalTo:[PFUser currentUser]];
    [queryForChatRoom whereKey:@"user2" equalTo:self.photo[kPhotoUserKey]];
    
    PFQuery *queryForChatRoomInverse = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryForChatRoomInverse whereKey:@"user1" equalTo:self.photo[kPhotoUserKey]];
    [queryForChatRoomInverse whereKey:@"user2" equalTo:[PFUser currentUser]];
    
    PFQuery *combineQuery = [PFQuery orQueryWithSubqueries:@[queryForChatRoom, queryForChatRoomInverse]];
    
    [combineQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if ([objects count] == 0)
        {
            PFObject *chatRoom = [PFObject objectWithClassName:@"ChatRoom"];
            [chatRoom setObject:[PFUser currentUser] forKey:@"user1"];
            [chatRoom setObject:self.photo[kPhotoUserKey] forKey:@"user2"];
            [chatRoom saveInBackgroundWithBlock:^(BOOL success, NSError *error)
            {
                [self performSegueWithIdentifier:@"homeToMatchSegue" sender:nil];
            }];
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



@end
