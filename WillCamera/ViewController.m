//
//  ViewController.m
//  WillCamera
//
//  Created by camera360 on 14-9-18.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//

#import "ViewController.h"
#import "AVCamPreviewView.h"
#import "MyCaptureSessionManager.h"

@interface ViewController ()

@property (nonatomic, weak)IBOutlet AVCamPreviewView *previewView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [(AVCaptureVideoPreviewLayer *)self.previewView.layer setSession:[MyCaptureSessionManager sharedMyCaptureSessionManager].session];
    
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

#pragma mark -

@end
