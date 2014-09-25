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
    NSDictionary *mCustomFiltersDic;
}
///动态预览view
@property (nonatomic, weak)IBOutlet AVCamPreviewGLView *previewView;

///拍摄照片之后  预览照片，并决定是否保存
@property (weak, nonatomic) IBOutlet UIView *picturePreiewView;
///照片预览
@property (weak, nonatomic) IBOutlet UIImageView *picturePreiewImageView;
///滤镜名称
@property (weak, nonatomic) IBOutlet UILabel *filterNameLabel;
///聚焦显示层
@property (strong, nonatomic) UIView *focusView;
///帧率按钮
@property (weak, nonatomic) IBOutlet UIButton *minFrameDurationButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.delegate = self;
 
    [[MyCaptureSessionManager sharedMyCaptureSessionManager] setDelegate:self];

    NSDictionary *filtersDic = @{
                                 @"无滤镜":@(WillCameraFilterTypeNone),
                                 @"双重曝光":@(WillCameraFilterTypeColorDodgeBlendModeBackgroundImage),
                                 @"老电影":@(WillCameraFilterTypeOldFilm),
                                 @"饱和度调节":@(WillCameraFilterTypeHueAdjust),
                                 @"乌色":@(WillCameraFilterTypeCISepiaTone)};
    
    mCustomFiltersDic = filtersDic;
    
    [[MyCaptureSessionManager sharedMyCaptureSessionManager] setupCameraFilterType:WillCameraFilterTypeNone];
    [self.view addSubview:self.focusView];
    
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
    if (viewController == self)
    {
        navigationController.navigationBarHidden = YES;
    }
    else
    {
        navigationController.navigationBarHidden = NO;
    }
}

#pragma mark - Touch Event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *anyTouch = [touches anyObject];
    CGPoint touchPoint = [anyTouch locationInView:anyTouch.window];
    
    self.focusView.center = touchPoint;
    self.focusView.hidden = NO;
    [self.view bringSubviewToFront:self.focusView];
    self.focusView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    [UIView animateWithDuration:1.f animations:^{
        self.focusView.transform = CGAffineTransformMakeScale(1.f, 1.f);
    } completion:^(BOOL finished) {
        self.focusView.hidden = YES;
    }];
    
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
        if (image)
        {
            self.picturePreiewImageView.image = image;
            self.picturePreiewView.hidden = NO;
        }
        else
        {
            self.picturePreiewImageView.image = nil;
            self.picturePreiewView.hidden = YES;
        }
    }];
}

//切换闪光模式
- (IBAction)changeFlashType:(id)sender
{
    MyCaptureSessionManager *sharedManager = [MyCaptureSessionManager sharedMyCaptureSessionManager];

    UIButton *focusButton = (UIButton *)sender;
    
    switch (sharedManager.flashMode)
    {
        case AVCaptureFlashModeAuto:
        {
            [sharedManager setupCameraFlashMode:AVCaptureFlashModeOn];
            [focusButton setTitle:@"开启闪光" forState:UIControlStateNormal];
            break;
        }
            
        case AVCaptureFlashModeOn:
        {
            [sharedManager setupCameraFlashMode:AVCaptureFlashModeOff];
            [focusButton setTitle:@"关闭闪光" forState:UIControlStateNormal];
            break;
        }
            
        case AVCaptureFlashModeOff:
        {
            [sharedManager setupCameraFlashMode:AVCaptureFlashModeAuto];
            [focusButton setTitle:@"自动闪光" forState:UIControlStateNormal];
            break;
        }
            
        default:
            break;
    };
}

//开始或者停止照相机
- (IBAction)cameraOpenOption:(id)sender
{
    MyCaptureSessionManager *sharedManager = [MyCaptureSessionManager sharedMyCaptureSessionManager];
    if (sharedManager.session.isRunning)
    {
        [(UIButton *)sender setTitle:@"开始" forState:UIControlStateNormal];
        [[MyCaptureSessionManager sharedMyCaptureSessionManager] stopRuning];
    }
    else
    {
        [(UIButton *)sender setTitle:@"停止" forState:UIControlStateNormal];
        [[MyCaptureSessionManager sharedMyCaptureSessionManager] startRuning];
    }
    
}

//保存操作
- (IBAction)savePictureOperation:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]])
    {
        UIButton *aButton = (UIButton *)sender;
        switch (aButton.tag)
        {
            case 99:
            {
                [self savePictureOrNot:YES];
                break;
            }
            
            case 100:
            {
                [self startShowHud];
                [self savePictureOrNot:NO];
                break;
            }
                
            default:
                break;
        }
    }
}

//切换帧率
- (IBAction)changCameraPresetMode:(UIButton *)sender
{
    MyCaptureSessionManager *sessionManager = [MyCaptureSessionManager sharedMyCaptureSessionManager];
    
    switch (sessionManager.persetMode)
    {
        case WillCameraPresetModeHeigh:
        {
            [sessionManager setupCameraPresetMode:WillCameraPresetModeMiddel];
            [sender setTitle:@"分辨率:中" forState:UIControlStateNormal];
            break;
        }
            
        case WillCameraPresetModeMiddel:
        {
            [sessionManager setupCameraPresetMode:WillCameraPresetModeLow];
            [sender setTitle:@"分辨率:低" forState:UIControlStateNormal];
            break;
        }
            
        case WillCameraPresetModeLow:
        {
            [sessionManager setupCameraPresetMode:WillCameraPresetModeHeigh];
            [sender setTitle:@"分辨率:高" forState:UIControlStateNormal];
            break;
        }
            
        default:
        {
            [sessionManager setupCameraPresetMode:WillCameraPresetModeHeigh];
            [sender setTitle:@"分辨率:高" forState:UIControlStateNormal];
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

        }
        else
        {
            [self showTip:@"未保存成功"];
            self.picturePreiewImageView.image = nil;
            self.picturePreiewView.hidden = YES;
        }
    }
    else
    {
        [self showTip:@"放弃保存"];
        self.picturePreiewImageView.image = nil;
        self.picturePreiewView.hidden = YES;
    }
    
}

#pragma mark - FilterSelectingTableViewControllerDelegate

- (void)filterSelectingTableViewController:(FilterSelectingTableViewController *)filterVC
                 didSelectCameraFilterType:(NSInteger)index
{
    if (index < mCustomFiltersDic.allKeys.count) {
        NSString *filterNameKey = mCustomFiltersDic.allKeys[index];
        self.filterNameLabel.text = filterNameKey;
        WillCameraFilterType selectedType = (WillCameraFilterType)[mCustomFiltersDic[filterNameKey] integerValue];
        [[MyCaptureSessionManager sharedMyCaptureSessionManager] setupCameraFilterType:selectedType];
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
            destination.dataSourceDic = mCustomFiltersDic;
            destination.delegate = self;
        }
    }
    
}


#pragma mark - Getter

- (UIView *)focusView
{
    if (!_focusView)
    {
        _focusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _focusView.backgroundColor = [UIColor clearColor];
        _focusView.layer.cornerRadius = _focusView.frame.size.height/2;
        _focusView.layer.borderWidth = .5f;
        _focusView.layer.borderColor = [[UIColor greenColor] CGColor];
        _focusView.hidden = YES;
    }
    
    return _focusView;
}

@end
