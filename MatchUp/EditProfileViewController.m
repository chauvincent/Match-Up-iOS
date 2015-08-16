//
//  EditProfileViewController.m
//  MatchUp
//
//  Created by Vincent Chau on 8/12/15.
//  Copyright (c) 2015 Vincent Chau. All rights reserved.
//

#import "EditProfileViewController.h"

@interface EditProfileViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButton;
@property (strong, nonatomic) IBOutlet UITextView *tagLineTextView;
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    PFQuery *query = [PFQuery queryWithClassName:kPhotoClassKey];
    [query whereKey:kPhotoUserKey equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if ([objects count] > 0)
         {
             PFObject *photo = objects[0];
             PFFile *pictureFile = photo[kPhotoPictureKey];
             [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
              {
                  self.profilePictureImageView.image = [UIImage imageWithData:data];
              }];
         }
     
     }];
    self.tagLineTextView.text = [[PFUser currentUser] objectForKey:kUserTagLineKey];
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
#pragma mark -IBActions
- (IBAction)saveBarButtonItemPressed:(UIBarButtonItem *)sender
{
    [[PFUser currentUser] setObject:self.tagLineTextView.text forKey:kUserTagLineKey];
    [[PFUser currentUser] saveInBackground];
    [self.navigationController popViewControllerAnimated:YES];
}



@end
