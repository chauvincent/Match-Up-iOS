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

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.activityIndicator.hidden = YES;
    
 
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    
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
             [self performSegueWithIdentifier:@"TabBarSegue" sender:self];
         }
     }];
    
}

#pragma mark - Helper methods
-(void)updateUserInformation
{
    if ([FBSDKAccessToken currentAccessToken])
    {
        #pragma mark - Need To Request Facebook Approval for Permissions: need location, interests, and birthday. A temporary Location will be used 'San Francisco'
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields" : @"id,age_range,first_name,locale,gender,last_name"}];
        
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
         {
             if (!error)
             {
                 NSDictionary *userDictionary = (NSDictionary*)result;
                 NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:8];
                 if (userDictionary[@"id"]) {
                     userProfile[@"id"] = userDictionary[@"id"];
                    
                 }
                 if (userDictionary[@"first_name"]) {
                     userProfile[@"first_name"] = userDictionary[@"first_name"];
                 
                 }
                 if (userDictionary[@"gender"]) {
                     userProfile[@"gender"] = userDictionary[@"gender"];
              
                 }
                 if (userDictionary[@"age_range"]) {
                     userProfile[@"age_range"] = userDictionary[@"age_range"];
                 }
                 //temporary location until facebook approval
                 [userProfile setObject:@"San Francisco" forKey:@"location"];
                 //NSLog(@"%@", userProfile);
                 
                 [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
                 [[PFUser currentUser] saveInBackground];
             }
             else
             {
                 NSLog(@"error in request %@",error);
             }
         }];
    }
}

@end
