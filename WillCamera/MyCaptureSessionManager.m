//
//  MyCaptureSessionManager.m
//  WillCamera
//
//  Created by camera360 on 14-9-18.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//

#import "MyCaptureSessionManager.h"


@interface MyCaptureSessionManager ()

@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

///设备是否可用
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;


@end

@implementation MyCaptureSessionManager

SYNTHESIZE_SINGLETON_FOR_CLASS(MyCaptureSessionManager)


#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // 创建 AVCaptureSession
        AVCaptureSession *session = [[AVCaptureSession alloc] init];
        [self setSession:session];
        
        // 检查设备video是否可用
        [self checkDeviceAuthorizationStatus];
        
        ///创建线程队列
        dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
        [self setSessionQueue:sessionQueue];
        
        dispatch_async(sessionQueue, ^{
            
            NSError *error = nil;
            
            AVCaptureDevice *videoDevice = [self deviceWithMediaType:AVMediaTypeVideo
                                                  preferringPosition:AVCaptureDevicePositionBack];
            AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
            
            if (error)
            {
                NSLog(@"%@", error);
            }
            
            if ([session canAddInput:videoDeviceInput])
            {
                [session addInput:videoDeviceInput];
                [self setVideoDeviceInput:videoDeviceInput];
            }
            
            
            AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
            if ([session canAddOutput:stillImageOutput])
            {
                [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
                [session addOutput:stillImageOutput];
                [self setStillImageOutput:stillImageOutput];
            }
        });
        
    }
    return self;
}

#pragma mark Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode
       exposeWithMode:(AVCaptureExposureMode)exposureMode
        atDevicePoint:(CGPoint)point
monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *device = [[self videoDeviceInput] device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    });
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode])
    {
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    }
}

///根据类型和摄像头位置返回对应的设备对象
- (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}


#pragma mark - Public Method

- (void)startRuning
{
    dispatch_async([self sessionQueue], ^{
        // Manually restarting the session since it must have been stopped due to an error.
        [[self session] startRunning];
    });
}

- (void)stopRuning
{
    dispatch_async([self sessionQueue], ^{
        // Manually restarting the session since it must have been stopped due to an error.
        [[self session] stopRunning];
    });
}


- (void)changeCamera
{
    
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
        
        switch (currentPosition)
        {
            case AVCaptureDevicePositionUnspecified:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
        }
        
        AVCaptureDevice *videoDevice = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
        
        
        [[self session] beginConfiguration];
        [[self session] removeInput:[self videoDeviceInput]];
       
        if ([[self session] canAddInput:videoDeviceInput])
        {
            [[self session] addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
        }
        else
        {
            [[self session] addInput:[self videoDeviceInput]];
        }
        
        [[self session] commitConfiguration];
        
    });
}


#pragma mark -  Prvite Method

- (void)checkDeviceAuthorizationStatus
{
    NSString *mediaType = AVMediaTypeVideo;
    
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted)
        {
            //video可用
            [self setDeviceAuthorized:YES];
        }
        else
        {
            //Not granted access to mediaType
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"WillCamera"
                                                                message:@"WillCamera没有权限使用您的摄像头，请调整您的隐私设定。"
                                                               delegate:self
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
                [alert show];
                [self setDeviceAuthorized:NO];
            });
        }
    }];
}

@end
