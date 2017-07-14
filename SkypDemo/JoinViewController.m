//
//  JoinViewController.m
//  SkypDemo
//
//  Created by Riddhi Makvana on 04/07/17.
//  Copyright © 2017 ADIT-MAC05. All rights reserved.
//

#import "JoinViewController.h"
#import "ViewController.h"
@interface JoinViewController ()

@end

@implementation JoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *meetingURLString=@"https://meet.lync.com/aditit/vishad.patel/5CWMLWQT";
    NSString *meetingDisplayName=@"Riddhi";
    
    self.txtDisplaYName.text = meetingDisplayName;
    self.txtURL.text = meetingURLString;

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)btnJoinMeetingTapped:(id)sender{
    ViewController *vwController = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    vwController.meetingURL = self.txtURL.text;
    vwController.meetingDisplayName = self.txtDisplaYName.text;
    [self.navigationController pushViewController:vwController animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
