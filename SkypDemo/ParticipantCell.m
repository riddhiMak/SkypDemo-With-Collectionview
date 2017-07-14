//
//  ParticipantCell.m
//  JoinMetting
//
//  Created by Riddhi Makvana on 29/06/17.
//  Copyright © 2017 Riddhi Makvana. All rights reserved.
//

#import "ParticipantCell.h"

@implementation BaseParticipantCell

-(id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        kvo = 0 ;
    }
    return self;
}

-(void)prepareForReuse{
    [super prepareForReuse];
    if (self.audio != nil) {
        [self.audio removeObserver:self forKeyPath:@"state"];
        [self.audio removeObserver:self forKeyPath:@"isMuted"];
        [self.audio removeObserver:self forKeyPath:@"isOnHold"];
        [self.audio removeObserver:self forKeyPath:@"isSpeaking"];
    }
    
    if (self.person !=nil) {
        [self.person removeObserver:self forKeyPath:@"sipUri"];
        [self.person removeObserver:self forKeyPath:@"displayName"];
    }
    
}
-(void)setParticipant:(SfBParticipant *)participant{
    kvo = 0 ;
    self.person = participant.person;
    self.audio = participant.audio;
    self.chat = participant.chat;
    
    [self.audio addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionInitial context:&kvo];
    [self.audio addObserver:self forKeyPath:@"isMuted" options:NSKeyValueObservingOptionInitial context:&kvo];
    [self.audio addObserver:self forKeyPath:@"isOnHold" options:NSKeyValueObservingOptionInitial context:&kvo];
    [self.audio addObserver:self forKeyPath:@"isSpeaking" options:NSKeyValueObservingOptionInitial context:&kvo];
    
    [self.person addObserver:self forKeyPath:@"sipUri" options:NSKeyValueObservingOptionInitial context:&kvo];
    [self.person addObserver:self forKeyPath:@"displayName" options:NSKeyValueObservingOptionInitial context:&kvo];

    
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"%@AvinashVS",keyPath);
    if (context != &kvo) {
        return  [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    if ([keyPath isEqualToString:@"state"]) {
    }
    else if ([keyPath isEqualToString:@"displayName"]) {
        _displayName.text  = self.person.displayName;
    }
    else if ([keyPath isEqualToString:@"sipUri"])
    {
        _sipUri.text = _person.sipUri.absoluteString;
    }
    else if ([keyPath isEqualToString:@"isTyping"]) {
        if (_chat.isTyping) {
            [_isTyping startAnimating];
        } else {
            [_isTyping stopAnimating];
        }
    } else if ([keyPath isEqualToString:@"isSpeaking"]) {
        if (_audio.isSpeaking) {
            [_audioButton setTitle:@"Speak" forState:UIControlStateNormal];
        } else {
            //failthrough
        }
    } else if ([keyPath isEqualToString:@"isOnHold"]) {
        if (_audio.isOnHold) {
            [_audioButton setTitle:@"Held" forState:UIControlStateNormal];
        } else {
            //failthrough
        }
    } else if ([keyPath isEqualToString:@"isMuted"]) {
        if (_audio.isMuted) {
            [_audioButton setTitle:@"Audio" forState:UIControlStateNormal];
        } else {
            [_audioButton setTitle:@"Muted" forState:UIControlStateNormal];
        }
    }
}
- (IBAction)btnMute:(id)sender {
    if (_audio.isMuted) {
        [_audio setMuted:false error:nil];
    }else{
        [_audio setMuted:TRUE error:nil];
    }
}

@end


@implementation ParticipantCell : BaseParticipantCell

-(id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        kvo2 = 0;
    }
    return self;
}

-(void)setParticipant:(SfBParticipant *)participant{
    kvo2 = 0;
    [super setParticipant:participant];
    video = participant.video;
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [video addObserver:self forKeyPath:@"isPaused" options:NSKeyValueObservingOptionInitial context:&kvo2];
    [video addObserver:self forKeyPath:@"canSubscribe" options:NSKeyValueObservingOptionInitial context:&kvo2];
}

-(void)prepareForReuse{
    [super prepareForReuse];
    [video unsubscribe:nil];
    [video removeObserver:self forKeyPath:@"canSubscribe"];
    [video removeObserver:self forKeyPath:@"isPaused"];
}
-(void)setVideoViewHidden{
    BOOL hide = (_renderTarget == nil) || (video.isPaused) ;
    //[_videoView setHidden:hide];
    [_displayLink setPaused:hide];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"%@Avinash ParticipantCell ",keyPath);
    if (context != &kvo2) {
        return  [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    if ([keyPath isEqualToString:@"isPaused"]){
        [self setVideoViewHidden];
    } else if ([keyPath isEqualToString:@"canSubscribe"]){
        if ([video canSubscribe]) {
            NSError *error = nil;
            _renderTarget = [video subscribe:(CAEAGLLayer*)self.videoView.layer error:&error];
            [_renderTarget setAutoFitMode:SfBVideoStreamAutoFitModeCrop error:&error];
        }else{
            _renderTarget = nil;
        }
        [self setVideoViewHidden];
    }
}

-(void)render:(CADisplayLink *)sender {
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        [_renderTarget render:nil];
    }
}
@end

@implementation SelfParticipantCell
-(void)setVideoService:(SfBVideoService *)videoService
{
    _renderTarget = [videoService showPreviewOnView:_videoView error:nil];
}
- (void)awakeFromNib
{
    [super awakeFromNib];
}
-(id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        NSError *error;
        _renderTarget = [_videoService showPreviewOnView:_videoView error:&error];
    }
    return self;
}
-(void)deinit {
    [self setValue:nil forKey:@"videoService"];
}
-(void)prepareForReuse{
    [super prepareForReuse];
    _videoService = nil;
}
@end


