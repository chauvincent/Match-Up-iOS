//
//  TestUser.m
//  MatchUp
//
//  Created by Vincent Chau on 8/13/15.
//  Copyright (c) 2015 Vincent Chau. All rights reserved.
//

#import "TestUser.h"

@implementation TestUser

+(void)saveTestUserToParse
{
    PFUser *newUser = [PFUser user];
    newUser.username = @"user1";
    newUser.password = @"password1";
    
    [newUser signUpInBackgroundWithBlock:^(BOOL success, NSError *error)
    {
        if (!error)
        {
            NSDictionary *profile = @{@"age" : @28, @"birthday" : @"11/22/1985", @"firstName" : @"Julie", @"gender" : @"female", @"location" : @"Berlin, Germany", @"name" : @"Julie Adams"};
            [newUser setObject:profile forKey:@"profile"];
            [newUser saveInBackgroundWithBlock:^(BOOL success, NSError *error)
            {
                UIImage *profileImage = [UIImage imageNamed:@"ProfileImage1.jpeg"];
                NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
                PFFile *photoFile = [PFFile fileWithData:imageData];
                [photoFile saveInBackgroundWithBlock:^(BOOL succeed, NSError *error)
                {
                    if (succeed) {
                        PFObject *photo = [PFObject objectWithClassName:kPhotoClassKey];
                        [photo setObject:newUser forKey:kPhotoUserKey];
                        [photo setObject:photoFile forKey:kPhotoPictureKey];
                        [photo saveInBackgroundWithBlock:^(BOOL success, NSError *error)
                        {
                            NSLog(@"Saved New User");
                        }];
                    }
                }];
            }];
        }
    
    
    }];
}





@end
