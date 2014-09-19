//
//  CameraBaiscViewController.m
//  WillCamera
//
//  Created by camera360 on 14-9-19.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//

#import "CameraBaiscViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>


@interface CameraBaiscViewController ()

///loading 界面
@property (nonatomic, strong) MBProgressHUD *waitHud;

@end

@implementation CameraBaiscViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.waitHud];
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

#pragma mark - UI Element

- (MBProgressHUD *)waitHud
{
    if (!_waitHud) {
        _waitHud = [[MBProgressHUD alloc] initWithView:self.view];
    }
    return _waitHud;
}

#pragma mark - Public Method

- (void)startShowHud
{
    self.waitHud.mode = MBProgressHUDModeIndeterminate;
    self.waitHud.labelText = @"";
    [self.view bringSubviewToFront:self.waitHud];
    [self.waitHud show:YES];
}

- (void)showTip:(NSString *)aTipString
{
    self.waitHud.mode = MBProgressHUDModeText;
    self.waitHud.labelText = aTipString;
    [self.view bringSubviewToFront:self.waitHud];
    [self.waitHud show:YES];
    [self.waitHud hide:YES afterDelay:1];
}

- (void)stopShowHud
{
    [self.waitHud hide:YES];
}

@end
