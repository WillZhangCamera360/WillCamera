//
//  AVCamPreviewGLView.h
//  WillCamera
//
//  Created by camera360 on 14-9-19.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

///通过在GLKView上面渲染每一帧的特效图片，达到实时预览的效果
@interface AVCamPreviewGLView : UIView

///将图片渲染到previewGLView
- (void)drawImage:(CIImage *)im;


@end
