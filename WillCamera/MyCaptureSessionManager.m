//
//  MyCaptureSessionManager.m
//  WillCamera
//
//  Created by camera360 on 14-9-18.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//

#import "MyCaptureSessionManager.h"
#import "FilterManager.h"


@interface MyCaptureSessionManager ()  <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) dispatch_queue_t videoOutputQueue;//进行视频输出处理的queue
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic) AVCaptureVideoDataOutput *videoDataOutput;


///设备是否可用
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;



@property (nonatomic, copy) void (^takePictureCompletionBlock)(UIImage *image, NSError *error);


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
            AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice
                                                                                           error:&error];
            
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
            
            
            //添加videoOutput
            dispatch_queue_t videoOutputQueue = dispatch_queue_create("videoOutput Queue", DISPATCH_QUEUE_SERIAL);
            [self setVideoOutputQueue:videoOutputQueue];

            AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
            videoDataOutput.videoSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey :
                                                   [NSNumber numberWithInteger:kCVPixelFormatType_32BGRA]};
            
            [videoDataOutput setSampleBufferDelegate:self queue:videoOutputQueue];
            
            if ([session canAddOutput:videoDataOutput]) {
                [session addOutput:videoDataOutput];
                [self setVideoDataOutput:videoDataOutput];
            }
        });
        
    }
    return self;
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:(CVPixelBufferRef)imageBuffer options:nil];
    
    CIImage *tempImage = [self outputImageWithSourceImage:sourceImage];
    
    CIImage *outputImage = nil;
    if (tempImage) {
        outputImage = tempImage;
    }else{
        outputImage = sourceImage;
    }
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(sessionManager:didOutputSourceImage:)]) {
        [self.delegate sessionManager:self didOutputSourceImage:outputImage];
    }
    

    
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


- (void)setCameraFilterType:(WillCameraFilterType)filterType
{
    [[FilterManager sharedFilterManager] setCameraFilterType:filterType];
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


///拍照
- (void)takePictureWithCompletionBlock:(void (^)(UIImage *image, NSError *error))completionBlock;
{
    self.takePictureCompletionBlock = completionBlock;
    dispatch_async([self sessionQueue], ^{
        
        // Flash set to Auto for Still Capture
        [self setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
        
        
        void (^captureStillImageCompletionHandler)(CMSampleBufferRef imageDataSampleBuffer, NSError *error) =
        ^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.takePictureCompletionBlock(nil, error);
                });
                
                return ;
            }
            
            if (imageDataSampleBuffer)
            {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
               
                //双重曝光第一张照片
                if ([FilterManager sharedFilterManager].filterType == WillCameraFilterTypeColorDodgeBlendModeBackgroundImage)
                {

                    if (![FilterManager sharedFilterManager].colorDodgeBlendModeBackgroundImage) {
                        dispatch_async(self.videoOutputQueue, ^{
                            [FilterManager sharedFilterManager].colorDodgeBlendModeBackgroundImage =
                                                                        [CIImage imageWithData:imageData];
                        });
                        return;
                    }
                }
                
                CIImage *sourceImage = [CIImage imageWithData:imageData];
                CIImage *outoutImage = [self outputImageWithSourceImage:sourceImage];
                [FilterManager sharedFilterManager].colorDodgeBlendModeBackgroundImage = nil;
                
                __weak UIImage *completionImage = nil;
                if (outoutImage) {
                    completionImage = [UIImage imageWithCIImage:outoutImage scale:1.f orientation:UIImageOrientationRight];
                }else{
                    completionImage = [UIImage imageWithCIImage:sourceImage scale:1.f orientation:UIImageOrientationRight];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.takePictureCompletionBlock(completionImage, nil);
                    self.takePictureCompletionBlock = nil;
                });
            }
        };
        // Capture a still image.
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput]
                                                                                connectionWithMediaType:AVMediaTypeVideo]
                                                             completionHandler:captureStillImageCompletionHandler];
    });
}



///聚焦
- (void)focusOnPoint:(CGPoint)interestPoint
{
    
    NSLog(@"interestPoint %@", NSStringFromCGPoint(interestPoint));
    
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *device = [[self videoDeviceInput] device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
            {
                [device setFocusPointOfInterest:interestPoint];
                [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            }
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    });
    
    return;

        
    [self focusWithMode:AVCaptureFocusModeAutoFocus
         exposeWithMode:AVCaptureExposureModeContinuousAutoExposure
          atDevicePoint:interestPoint
        monitorSubjectAreaChange:YES];
}




#pragma mark -  Prvite Method

- (CIImage *)outputImageWithSourceImage:(CIImage *)sourceImage
{

    CIImage *filtedImage = nil;
    filtedImage = [[FilterManager sharedFilterManager] outputImageWithCurrentFliterAndInputImage:sourceImage];
    return filtedImage;
}




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
                NSLog(@"interestPoint %@", NSStringFromCGPoint(point));
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

@end
