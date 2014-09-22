//
//  MyCaptureSessionManager.h
//  WillCamera
//
//  Created by camera360 on 14-9-18.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "FilterManager.h"



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

///设置相机滤镜效果
- (void)setCameraFilterType:(WillCameraFilterType)filterType;


@end




@protocol MyCaptureSessionManagerDelegate <NSObject>

- (void)sessionManager:(MyCaptureSessionManager *)aManager didOutputSourceImage:(CIImage *)aSourceImage;

@end