//
//  ViewController.m
//  WillCamera
//
//  Created by camera360 on 14-9-18.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//

#import "ViewController.h"
//#import "AVCamPreviewView.h"
#import "AVCamPreviewGLView.h"//这边用GLKview来代替AVCamPreviewView
#import "MyCaptureSessionManager.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface ViewController () <MyCaptureSessionManagerDelegate>

///动态预览view
@property (nonatomic, weak)IBOutlet AVCamPreviewGLView *previewView;

///拍摄照片之后  预览照片，并决定是否保存
@property (weak, nonatomic) IBOutlet UIView *picturePreiewView;
@property (weak, nonatomic) IBOutlet UIImageView *picturePreiewImageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[MyCaptureSessionManager sharedMyCaptureSessionManager] setDelegate:self];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[MyCaptureSessionManager sharedMyCaptureSessionManager] startRuning];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[MyCaptureSessionManager sharedMyCaptureSessionManager] stopRuning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MyCaptureSessionManagerDelegate

- (void)sessionManager:(MyCaptureSessionManager *)aManager didOutputSourceImage:(CIImage *)aSourceImage
{
    [self.previewView drawImage:aSourceImage];
}

#pragma mark - Action

//切换摄像头
- (IBAction)changeCamera:(id)sender
{
   [[MyCaptureSessionManager sharedMyCaptureSessionManager] changeCamera];
}

//拍照
- (IBAction)takePicture:(id)sender
{
    [[MyCaptureSessionManager sharedMyCaptureSessionManager] takePictureWithCompletionBlock:^(UIImage *image, NSError *error) {
        if (image) {
            self.picturePreiewImageView.image = image;
            self.picturePreiewView.hidden = NO;
        }else{
            self.picturePreiewImageView.image = nil;
            self.picturePreiewView.hidden = YES;
        }
    }];
}
- (IBAction)changeFilter:(id)sender {
    
    [[MyCaptureSessionManager sharedMyCaptureSessionManager]setCameraFilterType:
                                    WillCameraFilterTypeColorDodgeBlendModeBackgroundImage];
    
}

- (IBAction)savePictureOperation:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *aButton = (UIButton *)sender;
        switch (aButton.tag) {
            case 99:
            {
                [self showTip:@"hahaha"];
                NSLog(@"存储");
                [self savePictureOrNot:YES];
                break;
            }
            
            case 100:
            {
                NSLog(@"放弃");
                [self startShowHud];
                [self savePictureOrNot:NO];
                break;
            }
                
            default:
                break;
        }
    }
}


#pragma mark - Tools

- (void)savePictureOrNot:(BOOL)save
{
    if (save)
    {
        UIImage *image = self.picturePreiewImageView.image;
        if (image)
        {
            //If the UIImage object was initialized using a CIImage object, the value of the property is NULL.
            CIContext *myContext = [CIContext contextWithOptions:@{kCIContextWorkingColorSpace : [NSNull null]}];
            CGImageRef cgImage = [myContext createCGImage:image.CIImage fromRect:[image.CIImage extent]];
            [self startShowHud];
            [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:cgImage orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error) {
                [self stopShowHud];
                [self showTip:@"保存成功"];
                self.picturePreiewImageView.image = nil;
                self.picturePreiewView.hidden = YES;
            }];

        }else{
            [self showTip:@"未保存成功"];
            self.picturePreiewImageView.image = nil;
            self.picturePreiewView.hidden = YES;
        }
    }else{
        [self showTip:@"放弃保存"];
        self.picturePreiewImageView.image = nil;
        self.picturePreiewView.hidden = YES;
    }
    
}

@end
