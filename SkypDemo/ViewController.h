//
//  ViewController.h
//  SkypDemo
//
//  Created by AMPLDEV089 on 27/06/17.
//  Copyright © 2017 ADIT-MAC05. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SkypeForBusiness/SkypeForBusiness.h>
#import "SfBConversationHelper.h"
#import "Util.h"
#import "MicrosoftLicenseViewController.h"


@interface ViewController : UIViewController<SfBAlertDelegate,MicrosoftLicenseViewControllerDelegate>

{
    IBOutlet UICollectionView *tblList;
    NSInteger kvo;

}
@property (strong, nonatomic) SfBVideoStream *renderTarget;
@property (strong ,nonatomic) SfBVideoService *videoService;
@property (strong ,nonatomic) SfBParticipantVideo *selfVideo;
@property (strong ,nonatomic) SfBAudioService *selfAudio;

@property (strong, nonatomic) SfBConversation *conversation;
@property (strong, nonatomic) SfBDevicesManager *deviceManagerInstance;
@property (strong, nonatomic) NSString *displayName;

@property (strong,nonatomic) NSString *meetingURL;
@property (strong,nonatomic) NSString *meetingDisplayName;

@end

