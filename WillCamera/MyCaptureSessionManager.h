//
//  MyCaptureSessionManager.h
//  WillCamera
//
//  Created by camera360 on 14-9-18.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>


@interface MyCaptureSessionManager : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(MyCaptureSessionManager)

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

@end
