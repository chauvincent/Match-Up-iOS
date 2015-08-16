//
//  Constants.m
//  MatchUp
//
//  Created by Vincent Chau on 8/9/15.
//  Copyright (c) 2015 Vincent Chau. All rights reserved.
//

#import "Constants.h"

@implementation Constants

#pragma mark - User Class
NSString *const kUserTagLineKey             = @"tagLine";

NSString *const kUserProfileKey             = @"profile";
NSString *const kUserProfileNameKey         = @"name";
NSString *const kUserProfileFirstNameKey    = @"firstName";
NSString *const kUserProfileLocationKey     = @"location";
NSString *const kUserProfileGenderKey       = @"gender";
NSString *const kUserProfileAgeRangeKey     = @"ageRange";
NSString *const kUserProfilePictureURL      = @"pictureURL";

// Waiting facebook approval
NSString *const kUserProfileRelationshipStatusKey = @"relationshipStatus";
NSString *const kUserProfileAgeKey = @"age";
NSString *const kUserProfileBirthday = @"birthday";


#pragma mark - Photo Class
NSString *const kPhotoClassKey              = @"Photo";
NSString *const kPhotoUserKey               = @"user";
NSString *const kPhotoPictureKey            = @"image";

#pragma mark - Activity Class
NSString *const kActivityClassKey           = @"Activity";
NSString *const kActivityTypeKey            = @"type";
NSString *const kActivityFromUserKey        = @"fromUser";
NSString *const kActivityToUserKey          = @"toUser";
NSString *const kActivityTypeLikeKey        = @"like";
NSString *const kActivityTypeDislikeKey     = @"dislike";
NSString *const kActivityPhotoKey           = @"photo";

#pragma mark - Settings
NSString *const kMenEnabledKey              = @"men";
NSString *const kWomenEnabledKey            = @"women";
NSString *const kSingleEnabledKey           = @"single";
NSString *const kMaxAgeKey                  = @"ageMax";

@end
