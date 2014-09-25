//
//  MyCaptureSessionManager.h
//  WillCamera
//
//  Created by camera360 on 14-9-18.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "FilterManager.h"


typedef enum {
    WillCameraPresetModeHeigh,     //高分辨率
    WillCameraPresetModeMiddel,    //一般分辨率
    WillCameraPresetModeLow,       //低分辨率
} WillCameraPresetMode;


@protocol MyCaptureSessionManagerDelegate;



@interface MyCaptureSessionManager : NSObject

@property (weak)id <MyCaptureSessionManagerDelegate> delegate;

///session
@property (nonatomic) AVCaptureSession *session;
///session 运行
- (void)startRuning;
///session 停止
- (void)stopRuning;
///切换前后摄像头
- (void)changeCamera;
///拍照
- (void)takePictureWithCompletionBlock:(void (^)(UIImage *image, NSError *error))completionBlock;

///单例
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(MyCaptureSessionManager)

///聚焦
- (void)focusOnPoint:(CGPoint)interestPoint;

///设置相机滤镜效果
- (void)setCameraFilterType:(WillCameraFilterType)filterType;

///设置闪光灯类型
- (void)setCameraFlashMode:(AVCaptureFlashMode)flashMode;
@property (readonly, assign)AVCaptureFlashMode flashMode;

///设置预览分辨率
- (void)setCameraPresetMode:(WillCameraPresetMode)persetMode;
@property (readonly, assign)WillCameraPresetMode persetMode;


@end




@protocol MyCaptureSessionManagerDelegate <NSObject>

- (void)sessionManager:(MyCaptureSessionManager *)aManager didOutputSourceImage:(CIImage *)aSourceImage;

@end