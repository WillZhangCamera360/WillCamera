//
//  AVCamPreviewView.h
//  WillCamera
//
//  Created by camera360 on 14-9-18.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//


@class AVCaptureSession;

///继承自UIView 用来预览当前的摄像头画面
@interface AVCamPreviewView : UIView

@property (nonatomic) AVCaptureSession *session;

@end