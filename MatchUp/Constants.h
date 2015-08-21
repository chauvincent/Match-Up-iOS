//
//  Constants.h
//  MatchUp
//
//  Created by Vincent Chau on 8/9/15.
//  Copyright (c) 2015 Vincent Chau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

#pragma mark - User Profile

extern NSString *const kUserTagLineKey;

extern NSString *const kUserProfileKey;
extern NSString *const kUserProfileNameKey;
extern NSString *const kUserProfileFirstNameKey;
extern NSString *const kUserProfileLocationKey;
extern NSString *const kUserProfileGenderKey;
extern NSString *const kUserProfileAgeRangeKey;
extern NSString *const kUserProfilePictureURL;

// Added for after facebook approval
extern NSString *const kUserProfileRelationshipStatusKey;
extern NSString *const kUserProfileAgeKey;
extern NSString *const kUserProfileBirthday;
#pragma mark - Photo Class

extern NSString *const kPhotoClassKey;
extern NSString *const kPhotoUserKey;
extern NSString *const kPhotoPictureKey;

#pragma mark - Activity Class
extern NSString *const kActivityClassKey;
extern NSString *const kActivityTypeKey;
extern NSString *const kActivityFromUserKey;
extern NSString *const kActivityToUserKey;
extern NSString *const kActivityTypeLikeKey;
extern NSString *const kActivityTypeDislikeKey;
extern NSString *const kActivityPhotoKey;

#pragma mark - Settings
extern NSString *const kMenEnabledKey;
extern NSString *const kWomenEnabledKey;
extern NSString *const kSingleEnabledKey;
extern NSString *const kMaxAgeKey;

#pragma mark - ChatRoom
extern NSString *const kChatRoomClassKey;
extern NSString *const kChatRoomUser1Key;
extern NSString *const kChatRoomUser2Key;

#pragma mark - Chat
extern NSString *const kChatClassKey;
extern NSString *const kChatChatroomKey;
extern NSString *const kChatFromUserKey;
extern NSString *const kChatToUserKey;
extern NSString *const kChatTextKey;


@end
