//
//  ViewController.m
//  WillCamera
//
//  Created by camera360 on 14-9-18.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//

#import "ViewController.h"
#import "AVCamPreviewGLView.h"
#import "MyCaptureSessionManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "FilterSelectingTableViewController.h"


@interface ViewController ()
        <MyCaptureSessionManagerDelegate, UINavigationControllerDelegate, FilterSelectingTableViewControllerDelegate>
{
    NSDictionary *_customFiltersDic;
}
///动态预览view
@property (nonatomic, weak)IBOutlet AVCamPreviewGLView *previewView;

///拍摄照片之后  预览照片，并决定是否保存
@property (weak, nonatomic) IBOutlet UIView *picturePreiewView;
@property (weak, nonatomic) IBOutlet UIImageView *picturePreiewImageView;

@property (weak, nonatomic) IBOutlet UILabel *filterNameLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.delegate = self;
    [[MyCaptureSessionManager sharedMyCaptureSessionManager] setDelegate:self];
    
    
//    WillCameraFilterTypeColorDodgeBlendModeBackgroundImage,     //双重曝光相机
//    WillCameraFilterTypeOldFilm,                    //老电影

    NSDictionary *filtersDic = @{@"双重曝光":@(WillCameraFilterTypeColorDodgeBlendModeBackgroundImage),
                                 @"老电影":@(WillCameraFilterTypeOldFilm),
                                 @"饱和度调节":@(WillCameraFilterTypeHueAdjust)};
    _customFiltersDic = filtersDic;
    
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

#pragma mark - UINavigationControllerDelegate 

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == self) {
        navigationController.navigationBarHidden = YES;
    }else {
        navigationController.navigationBarHidden = NO;
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *anyTouch = [touches anyObject];
    CGPoint touchPoint = [anyTouch locationInView:anyTouch.window];
    
    NSLog(@"%@,%@", NSStringFromCGRect(anyTouch.window.frame), NSStringFromCGPoint(touchPoint));
    
    CGRect windowFrame = anyTouch.window.frame;
    CGFloat xPersent = touchPoint.x / windowFrame.size.width;
    CGFloat yPersent = touchPoint.y / windowFrame.size.height;
    
    //    A value of (0,0) indicates that the camera should focus on the top left corner of the image, while a value of (1,1) indicates that it should focus on the bottom right.
    CGPoint interestPoint = CGPointMake(xPersent, yPersent);
    
    [[MyCaptureSessionManager sharedMyCaptureSessionManager] focusOnPoint:interestPoint];
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
            CGImageRelease(cgImage);

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

#pragma mark - FilterSelectingTableViewControllerDelegate

- (void)filterSelectingTableViewController:(FilterSelectingTableViewController *)filterVC didSelectIndex:(NSInteger)index
{
    if (index < _customFiltersDic.allKeys.count) {
        NSString *filterNameKey = _customFiltersDic.allKeys[index];
        self.filterNameLabel.text = filterNameKey;
        WillCameraFilterType selectedType = [_customFiltersDic[filterNameKey] integerValue];
        [[MyCaptureSessionManager sharedMyCaptureSessionManager] setCameraFilterType:selectedType];
    }
}

#pragma mark - Navigation Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"The segue id is %@", segue.identifier );
    if ([segue.identifier isEqualToString:@"selectFilter"]) {
        FilterSelectingTableViewController *destination = segue.destinationViewController;
        if ([destination isKindOfClass:[FilterSelectingTableViewController class]])
        {
            destination.dataSourceDic = _customFiltersDic;
            destination.delegate = self;
        }
    }
    
}

@end
