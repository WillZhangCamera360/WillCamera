//
//  CameraBaiscViewController.h
//  WillCamera
//
//  Created by camera360 on 14-9-19.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraBaiscViewController : UIViewController

///显示hud
- (void)startShowHud;
///显示文字提示
- (void)showTip:(NSString *)aTipString;
///停止显示hud
- (void)stopShowHud;

@end
