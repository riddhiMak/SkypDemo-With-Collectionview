//
//  ViewController.m
//  SkypDemo
//
//  Created by AMPLDEV089 on 27/06/17.
//  Copyright © 2017 ADIT-MAC05. All rights reserved.
//

#import "ViewController.h"
#import <SkypeForBusiness/SkypeForBusiness.h>
#import "SfBConversationHelper.h"
#import "Util.h"
#import <GLKit/GLKit.h>
#import "MicrosoftLicenseViewController.h"
#import "ParticipantCell.h"

static NSString* const DisplayNameInfo = @"displayName";

@interface ViewController ()<SfBConversationHelperDelegate,SfBAlertDelegate>

{
    SfBApplication *sfb;
    BOOL isPaused;
    BOOL canSetPaused;
}
@property (strong, nonatomic) SfBConversationHelper *conversationHelper;

@property (readonly) NSArray<SfBParticipant*> *remoteParticipants;
@end
@implementation ViewController
- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        [self registerForAppTerminationNotification];
    }
    return self;
}
-(void)registerForAppTerminationNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(leaveMeetingWhenAppTerminates:)
                                                 name:UIApplicationWillTerminateNotification object:nil];
    
}

- (void)leaveMeetingWhenAppTerminates:(NSNotification *)aNotification {
    if(_conversationHelper.conversation != nil){
        [Util leaveMeetingWithSuccess:_conversationHelper.conversation];
        
    }
}

- (void)initializeSkype {
    sfb = SfBApplication.sharedApplication;
    sfb.configurationManager.maxVideoChannels = 5;
    sfb.configurationManager.requireWifiForAudio = false;
    sfb.configurationManager.requireWifiForVideo = false;
    sfb.devicesManager.selectedSpeaker.activeEndpoint = SfBSpeakerEndpointLoudspeaker;
    sfb.configurationManager.enablePreviewFeatures = true;
    sfb.alertDelegate = self;
}
-(bool)didJoinMeeting{
    
    NSError *error = nil;
    //  NSString *meetingURLString=@"https://meet.lync.com/aditit/vishad.patel/BZCZLP37";
    //  NSString *meetingDisplayName=@"RiddhiM";
    
    self.conversation = [sfb joinMeetingAnonymousWithUri:[NSURL URLWithString:self.meetingURL]
                                             displayName:self.meetingDisplayName
                                                   error:&error].conversation;
    if (self.conversation) {
        [_conversation addObserver:self forKeyPath:@"canLeave" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:&kvo];
        
        return true;
    }
    else {
        [Util showErrorAlert:error inView:self ];
    }
    return false;
}
- (IBAction)btnLeaveMeetingTapped:(id)sender {
    
    //    if(![Util leaveMeetingWithSuccess:_conversation] ){
    //        NSLog(@"Error leaving meeting");
    //    }
    if ([_conversation canLeave]) {
        NSError *error;
        [_conversation leave:&error];
    }
    [_conversation removeObserver:self forKeyPath:@"canLeave"];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (IBAction)askAgent:(UIButton *)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Ask agent" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Ask using Text Chat" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self askAgentText];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Ask using Video Chat" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self askAgentVideo];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    UIPopoverPresentationController *popoverController =  alertController.popoverPresentationController;
    if(popoverController != nil){
        popoverController.sourceView = sender;
        popoverController.sourceRect = sender.bounds;
        
    }
    
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    
}
- (void)askAgentVideo {
    
    SfBConfigurationManager *config = sfb.configurationManager;
    NSString *key = @"AcceptedVideoLicense";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults boolForKey:key]){
        [config setEndUserAcceptedVideoLicense];
        if([self didJoinMeeting]){
            [self Video];
        }
    }else{
        MicrosoftLicenseViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MicrosoftLicenseViewController"];
        vc.delegate = self;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)askAgentText {
    if([self didJoinMeeting]){
    }
}
#pragma mark - MicrosoftLicenseViewController delegate function
- (void)controller:(MicrosoftLicenseViewController* )controller
  didAcceptLicense:(BOOL)acceptedLicense{
    if(acceptedLicense){
        SfBConfigurationManager *config = sfb.configurationManager;
        [config setEndUserAcceptedVideoLicense];
        if([self didJoinMeeting]){
            [self Video];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeSkype];
}
- (void)Video {
    kvo = 0;
    
    if (_conversation)
    {
        
        [_conversation addObserver:self forKeyPath:@"remoteParticipants" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:&kvo];
        
        _videoService = _conversation.videoService;
        _selfVideo = _conversation.selfParticipant.video;
        _selfAudio=_conversation.audioService;
        
        [_videoService addObserver:self forKeyPath:@"canSetPaused" options:NSKeyValueObservingOptionInitial context:&kvo];
        [_videoService addObserver:self forKeyPath:@"canStart" options:NSKeyValueObservingOptionInitial context:&kvo];
        [_videoService addObserver:self forKeyPath:@"canStop" options:NSKeyValueObservingOptionInitial context:&kvo];
        [_videoService addObserver:self forKeyPath:@"canSetActiveCamera" options:NSKeyValueObservingOptionInitial context:&kvo];
        
        [_selfAudio addObserver:self forKeyPath:@"isOnHold" options:NSKeyValueObservingOptionInitial context:&kvo];
        [_selfAudio addObserver:self forKeyPath:@"muted" options:NSKeyValueObservingOptionInitial context:&kvo];
        [_selfAudio addObserver:self forKeyPath:@"canToggleMute" options:NSKeyValueObservingOptionInitial context:&kvo];
        
        [self.selfVideo addObserver:self forKeyPath:@"isPaused" options:NSKeyValueObservingOptionInitial context:&kvo];    }
    
    
    
    
}

#pragma mark - Skype Delegates

// At incoming video, unhide the participant video view
//- (void)conversationHelper:(SfBConversationHelper *)avHelper didSubscribeToVideo:(SfBParticipantVideo *)video {
//    self.participantVideoView.hidden = NO;
//}

// When it's ready, start the video service and show the outgoing video view.
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if (context != &kvo) {
        return  [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    
    
    if ([keyPath isEqualToString:@"remoteParticipants"]) {
        NSMutableArray * paths = [NSMutableArray array];
        
        NSIndexSet * indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
        
        [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
            [paths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
        }];
        switch ([[change valueForKey:NSKeyValueChangeKindKey] unsignedIntValue]) {
            case NSKeyValueChangeSetting:
                NSLog(@"Setting Change");
                [tblList reloadData];
                break;
            case NSKeyValueChangeInsertion:
                NSLog(@"Insertion Change");
                [tblList insertItemsAtIndexPaths:paths];
                break;
            case NSKeyValueChangeRemoval:
                NSLog(@"Removal Change");
                [tblList deleteItemsAtIndexPaths:paths];
                break;
            case NSKeyValueChangeReplacement:
                NSLog(@"Replacement Change");
                [tblList reloadItemsAtIndexPaths:paths];
                break;
            default:
                break;
        }
        
    }else if ([keyPath isEqualToString:@"canStart"] || [keyPath isEqualToString:@"canSetPaused"]
              || [keyPath isEqualToString:@"isPaused"]){
        
        isPaused = _selfVideo.isPaused == TRUE;
        canSetPaused = _videoService.canSetPaused == TRUE;
        
    }else if ([keyPath isEqualToString:@"canStop"]){
    }else if ([keyPath isEqualToString:@"canSetActiveCamera"]){
    }else if ([keyPath isEqualToString:@"canSubscribe"]){
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (bool)leaveMeetingWithSuccess:(SfBConversation *)conversation{
    NSError *error = nil;
    [conversation leave:&error];
    
    if (error) {
        NSLog(@"Error leaving meeting");
        return false;
        
    }
    return true;
}
- (void)conversationHelper:(SfBConversationHelper *)conversationHelper
              audioService:(SfBAudioService *)audioService
            didChangeMuted:(SfBAudioServiceMuteState)muted{
    if (muted == SfBAudioServiceMuteStateMuted) {
        NSLog(@"Unmute");
    }
    else {
        NSLog(@"Mute");
    }
    
}
- (IBAction)btnMuteUnMute:(UIButton *)sender
{
    [_selfAudio toggleMute:nil];
}
- (IBAction)btnStart:(UIButton *)sender {
    
    if (_selfVideo.isPaused) {
        [_videoService setPaused:false error:nil];
    }else{
        [_videoService start:nil];
    }
}
#pragma mark - CollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.conversation.remoteParticipants.count != 0)
    {
        return self.conversation.remoteParticipants.count + 1;
    }else{
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.conversation.remoteParticipants.count != 0) {
        if (indexPath.item == self.conversation.remoteParticipants.count + 1 ) {

            NSLog(@" Last Indexpath %ld",indexPath.item);
            static NSString *CellIdentifier = @"SelfParticipantCell";
            SelfParticipantCell  *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
            cell.backgroundColor=[UIColor clearColor];
            cell.participant=self.conversation.selfParticipant;
            cell.videoService=self.conversation.videoService;
            cell.SelfdisplayName.text=self.meetingDisplayName;
            return cell;
        }
        else{
            NSLog(@" Current Indexpath %ld",indexPath.item);

            static NSString *CellIdentifier = @"ParticipantCell";
            ParticipantCell  *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
            cell.backgroundColor=[UIColor clearColor];
            cell.participant = self.conversation.remoteParticipants[indexPath.item];
            
            return cell;
        }
    }else{
        static NSString *CellIdentifier = @"SelfParticipantCell";
        SelfParticipantCell  *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.backgroundColor=[UIColor clearColor];
        cell.participant=self.conversation.selfParticipant;
        cell.videoService=self.conversation.videoService;
        cell.SelfdisplayName.text=self.meetingDisplayName;
        return cell;
  
    }
}
//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return 2;
//}
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    if (section == 0) {
//        return self.conversation.remoteParticipants.count;
//    }else{
//        return 1;
//    }
//}
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    if (indexPath.section == 0) {
//        ParticipantCell *cell = (ParticipantCell*)[tableView dequeueReusableCellWithIdentifier:@"ParticipantCell"];
//        cell.self.participant = self.conversation.remoteParticipants[indexPath.row];
//        return cell;
//
//    }else if (indexPath.section == 1) {
//        SelfParticipantCell *cell = (SelfParticipantCell*)[tableView dequeueReusableCellWithIdentifier:@"SelfParticipantCell"];
//        cell.participant=self.conversation.selfParticipant;
//        cell.videoService=self.conversation.videoService;
//        cell.SelfdisplayName.text=self.meetingDisplayName;
//        return cell;
//    }
//    else
//    {
//        return nil;
//    }
//}
-(void)viewWillDisappear:(BOOL)animated{
    if ([_conversation canLeave]) {
        NSError *error;
        [_conversation leave:&error];
    }
    [_conversation removeObserver:self forKeyPath:@"canLeave"];
    
}
-(void)didReceiveAlert:(SfBAlert *)alert
{
    [alert showSfBAlertInController:self];
}
- (BOOL)leave:(NSError **)error
{
    return YES;
}


@end
