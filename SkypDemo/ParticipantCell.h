//
//  ParticipantCell.h
//  JoinMetting
//
//  Created by Riddhi Makvana on 29/06/17.
//  Copyright © 2017 Riddhi Makvana. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <QuartzCore/QuartzCore.h>
#import <SkypeForBusiness/SkypeForBusiness.h>

@interface BaseParticipantCell : UICollectionViewCell
{
    int kvo;
    SfBParticipantVideo *video;
}

@property (strong, nonatomic) IBOutlet UILabel *sipUri;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *isTyping;
@property (strong, nonatomic) IBOutlet UILabel *chatLabel;
@property (strong, nonatomic) IBOutlet UIButton *audioButton;
@property (strong, nonatomic) IBOutlet UILabel *displayName;


@property (nonatomic,strong) SfBParticipant *participant;
@property (nonatomic,strong) SfBParticipantAudio *audio;
@property (nonatomic,strong) SfBPerson *person;
@property (nonatomic,strong) SfBParticipantChat *chat;

@end


@interface ParticipantCell : BaseParticipantCell
{
    int kvo2;
}

@property (strong, nonatomic) IBOutlet GLKView *videoView;
@property (strong, nonatomic) CADisplayLink *displayLink;
@property (nonatomic,strong) SfBVideoStream *renderTarget;

@end

@interface SelfParticipantCell : BaseParticipantCell
{
    int kvo2;
}
@property (strong, nonatomic) IBOutlet UILabel *SelfdisplayName;

@property (strong, nonatomic) IBOutlet UIView *videoView;
@property (strong, nonatomic) SfBVideoPreview *renderTarget;
@property (nonatomic,strong) SfBVideoService *videoService;


@end
