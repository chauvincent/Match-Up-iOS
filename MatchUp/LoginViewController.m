//
//  LoginViewController.m
//  MatchUp
//
//  Created by Vincent Chau on 8/8/15.
//  Copyright (c) 2015 Vincent Chau. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableData *imageData;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.activityIndicator.hidden = YES;
    
 
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self updateUserInformation]; // update new facebook info
        [self performSegueWithIdentifier:@"ToHomeSegue" sender:self];
        
    }
    
}
- (void)didReceiveMemoryWarning
{
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
- (IBAction)loginButtonPressed:(id)sender
{
    NSArray *permissionsArray = @[ @"public_profile", @"user_friends"];
    
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error)
     {
         [self.activityIndicator stopAnimating];
         self.activityIndicator.hidden = YES;
         if (!user)
         {
             
             if (!error)
             {
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cancel Button Pressed" message:@"Please sign-up or try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                 [alertView show];
             } else
             {
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error in signin." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                 [alertView show];
             }
         }
         else
         {
             [self updateUserInformation];
             [self performSegueWithIdentifier:@"ToHomeSegue" sender:self];
         }
     }];
    
}

#pragma mark - Helper methods
-(void)updateUserInformation
{
    if ([FBSDKAccessToken currentAccessToken])
    {
       /* NOTE: Need To Request Facebook Approval for Permissions: need location, interests, and birthday. A temporary Location will be used 'San Francisco'  */
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields" : @"name,age_range,first_name,locale,gender,last_name"}];
        
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
         {
             if (!error)
             {
                
                NSDictionary *userDictionary = (NSDictionary*)result;
                NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:10];
                 
                 //create URL
                 NSString *facebookID = userDictionary[@"id"];
                 NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
                 
                 if (userDictionary[@"name"]) {
                     userProfile[kUserProfileNameKey] = userDictionary[@"name"];
                 }
                 if (userDictionary[@"first_name"]) {
                     userProfile[kUserProfileFirstNameKey] = userDictionary[@"first_name"];
                 
                 }
                 if (userDictionary[@"gender"]) {
                     userProfile[kUserProfileGenderKey] = userDictionary[@"gender"];
              
                 }
                 if (userDictionary[@"age_range"]) {
                     userProfile[kUserProfileAgeRangeKey] = userDictionary[@"age_range"];
                 }

#pragma mark - NOTE: Awaiting facebook approval, temporary added custom dates,location,relationship statuses.
                 userProfile[@"location"] = @"San Francisco";
                 userProfile[kUserProfileRelationshipStatusKey] = @"Single";
                 
                 // Convert age to NSNumber
                 userProfile[kUserProfileBirthday] = @"08/09/1991";
                 NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                 [formatter setDateStyle:NSDateFormatterShortStyle];
                 NSDate *date = [formatter dateFromString:@"08/09/1991"];
                 NSDate *today = [NSDate date];
                 NSTimeInterval seconds = [today timeIntervalSinceDate:date];
                 int age = seconds / 31536000;
                 userProfile[kUserProfileAgeKey] = @(age);
                 
                 if ([pictureURL absoluteString]) {
                     userProfile[kUserProfilePictureURL] = [pictureURL absoluteString];
                 }
               //  NSLog(@"%@", userProfile);
                 [[PFUser currentUser] setObject:userProfile forKey:kUserProfileKey];
                 [[PFUser currentUser] saveInBackground];
                 [self requestImage];
             }
             else
             {
                 NSLog(@"error in request %@",error);
             }
         }];
    }
}

-(void)uploadPFFileToParse:(UIImage *)image
{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    if ( !imageData)
    {
        NSLog(@"image data not found");
        return;
    }
    
    PFFile *photoFile = [PFFile fileWithData:imageData];
    
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         PFObject *photo = [PFObject objectWithClassName:kPhotoClassKey];
         [photo setObject:[PFUser currentUser] forKey:kPhotoUserKey];
         [photo setObject:photoFile forKey:kPhotoPictureKey];
         [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             NSLog(@"Photo Saved");
         }];
     }];
}
-(void)requestImage
{
    // get all photo back from parse
    PFQuery *query = [PFQuery queryWithClassName:kPhotoClassKey];
    [query whereKey:kPhotoUserKey equalTo:[PFUser currentUser]];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error)
    {
        if (number == 0)
        {
            PFUser *user = [PFUser currentUser];
            self.imageData = [[NSMutableData alloc] init];
            
            NSURL *pictureProfileURL = [NSURL URLWithString:user[kUserProfileKey][kUserProfilePictureURL]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureProfileURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            if (!urlConnection)
            {
                NSLog(@"Failed to Download Picture");
            }
        }
    }];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.imageData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage *profileImage = [UIImage imageWithData:self.imageData];
    [self uploadPFFileToParse:profileImage];
}



@end
