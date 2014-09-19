//
//  AVCamPreviewView.m
//  WillCamera
//
//  Created by camera360 on 14-9-18.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//

#import "AVCamPreviewView.h"
#import <AVFoundation/AVFoundation.h>

@interface AVCamPreviewView ()

///拍摄的照片预览图片
@property (nonatomic ,strong) UIImageView *previewPictureImageView;


@end

@implementation AVCamPreviewView

//指定此view的layer类型 
+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session
{
    return [(AVCaptureVideoPreviewLayer *)[self layer] session];
}

- (void)setSession:(AVCaptureSession *)session
{
    [(AVCaptureVideoPreviewLayer *)[self layer] setSession:session];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


@end
