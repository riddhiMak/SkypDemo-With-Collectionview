//+----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name: Util.m
//+----------------------------------------------------------------

#import "Util.h"


@implementation Util


+ (bool)leaveMeetingWithSuccess:(SfBConversation *)conversation{
    NSError *error = nil;
    [conversation leave:&error];
    
    if (error) {
        NSLog(@"Error leaving meeting");
        return false;
        
    }
    return true;
}

+(NSString*) getMeetingURLString  {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@USER_MEETING_URL] ?: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Skype meeting URL"];
    
}

+(NSString*) getMeetingDisplayName {
    
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:@USER_DISPLAY_NAME] ?: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Skype meeting display name"];
    
    
}

+(BOOL) getEnablePreviewSwitchState {
    
    BOOL EnablePreviewSwitchStateUserDefault = [[NSUserDefaults standardUserDefaults] boolForKey:@ENABLE_PREVIEW_STATE] ;
    BOOL EnablePreviewSwitchStateInfoList = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Enable Preview Switch State"] boolValue];
    
    
    return EnablePreviewSwitchStateUserDefault ?: EnablePreviewSwitchStateInfoList ;
    
    
}

+(BOOL) getSfBOnlineSwitchState {
    
    BOOL SfBOnlineSwitchStateUserDefault = [[NSUserDefaults standardUserDefaults] boolForKey:@SFB_ONLINE_MEETING_STATE];
    BOOL SfBOnlineSwitchStateInfoList = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"SfB Online Switch State"] boolValue];
    
    
    return SfBOnlineSwitchStateUserDefault ?: SfBOnlineSwitchStateInfoList ;
    
}

+(NSString*) getTokenAndDiscoveryURIRequestURL {
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:@TOKEN_AND_DISCOVERY_API_URL] ?: [[NSBundle mainBundle]objectForInfoDictionaryKey:@"Token and discovery URI request API URL"];
    
}

+(NSString*) getOnlineMeetingRequestURL {
    
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:@ONLINE_MEETING_REQUEST_API_URL] ?: [[NSBundle mainBundle]objectForInfoDictionaryKey:@"Online Meeting request API URL"];
    
    
}

+ (void)showErrorAlert:(NSError *)error inView:(UIViewController*)controller  {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error: Try again later!"
                                                                             message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok"
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    //    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    //        if([controller isKindOfClass:[OnlineMeetingViewController class]]){
    //            [controller.navigationController popViewControllerAnimated:YES];
    //        }
    //    }]];
    
    [controller presentViewController:alertController animated:YES completion:nil];
}

@end



