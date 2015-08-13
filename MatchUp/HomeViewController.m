//
//  HomeViewController.m
//  MatchUp
//
//  Created by Vincent Chau on 8/12/15.
//  Copyright (c) 2015 Vincent Chau. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

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

@property (nonatomic) int currentPhotoIndex;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // initial setup
    self.likeButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    self.currentPhotoIndex = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query includeKey:@"user"];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - IBActions
- (IBAction)chatButtonPressed:(UIBarButtonItem *)sender
{
}

- (IBAction)settingsButtonPressed:(UIBarButtonItem *)sender
{
}
- (IBAction)likeButtonPressed:(UIButton *)sender
{
}
- (IBAction)infoButtonPressed:(UIButton *)sender
{
}
- (IBAction)dislikeButtonPressed:(UIButton *)sender
{
}
#pragma mark - Helper Methods

-(void)queryForCurrentPhotoIndex
{
    if ([self.photos count] > 0)
    {
        self.photo = self.photos[self.currentPhotoIndex];
        PFFile *file = self.photo[@"image"];
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
}
-(void)updateView
{
    self.firstNameLabel.text = self.photo[@"user"][@"profile"][@"firstName"];
    self.ageLabel.text = [NSString stringWithFormat:@"%@",self.photo[@"user"][@"profile"][kUserProfileAgeKey]];

    
    
    
    self.taglineLabel.text = self.photo[@"user"][@"tagLine"];
}




@end
