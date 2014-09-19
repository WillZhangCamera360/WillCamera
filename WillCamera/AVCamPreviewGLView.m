//
//  AVCamPreviewGLView.m
//  WillCamera
//
//  Created by camera360 on 14-9-19.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//

#import "AVCamPreviewGLView.h"

@implementation AVCamPreviewGLView
@synthesize previewGLView = _previewGLView;


- (void)awakeFromNib
{
    self.previewGLView.frame = self.bounds;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (GLKView *)previewGLView
{
    if (!_previewGLView) {
        EAGLContext *_eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        _previewGLView = [[GLKView alloc] initWithFrame:self.bounds context:_eaglContext];
        _previewGLView.enableSetNeedsDisplay = NO;
        _previewGLView.transform = CGAffineTransformMakeRotation(M_PI_2);
        //通知GLKit重新绑定配置好的帧缓冲区。
        [_previewGLView bindDrawable];
    }
    return _previewGLView;
}

@end
