//
//  AVCamPreviewGLView.m
//  WillCamera
//
//  Created by camera360 on 14-9-19.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//

#import "AVCamPreviewGLView.h"

@interface AVCamPreviewGLView ()
{
    BOOL alreadyAwake;
}

@property (readonly) GLKView *previewGLView;
@property (strong) CIContext *ciContext;


@end

@implementation AVCamPreviewGLView


- (void)awakeFromNib
{
    alreadyAwake = YES;
    
    if (!_previewGLView) {
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        _previewGLView = [[GLKView alloc] initWithFrame:
                                        CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width)];
        EAGLContext *_eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        _previewGLView.context = _eaglContext;
        _previewGLView.enableSetNeedsDisplay = NO;
        _previewGLView.transform = CGAffineTransformMakeRotation(M_PI_2);
        //通知GLKit重新绑定配置好的帧缓冲区。
        [_previewGLView bindDrawable];
    }
    
        [self insertSubview:self.previewGLView atIndex:0];

    
    if (!_ciContext) {
        _ciContext = [CIContext contextWithEAGLContext:self.previewGLView.context options:@{kCIContextWorkingColorSpace : [NSNull null]} ];
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


#pragma mark - Public Method

- (void)drawImage:(CIImage *)im
{
    if (!alreadyAwake)
    {
        return;
    }
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGRect previewFrame = CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height);
    
    NSValue *previewFrameValue = [NSValue valueWithCGRect:previewFrame];
  
    if (![previewFrameValue isEqualToValue:[NSValue valueWithCGRect:self.previewGLView.frame]])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.previewGLView.frame = previewFrame;
        });
    }
    
    
    
    
    
    //NSLog(@"self.bounds:%@",NSStringFromCGRect(self.bounds));
    //NSLog(@"previewGLView.bounds:%@",NSStringFromCGRect(self.previewGLView.bounds));
    
        
    if (self.previewGLView.context != [EAGLContext currentContext])
    {
        [EAGLContext setCurrentContext:self.previewGLView.context];
    }
    [self.previewGLView bindDrawable];
    
    // clear eagl view to grey
    glClearColor(0.5, 0.5, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // set the blend mode to "source over" so that CI will use that
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    
    CGRect sourceExtent = im.extent;
    
    CGFloat sourceAspect = sourceExtent.size.width / sourceExtent.size.height;
    
    CGRect _videoPreviewViewBounds = CGRectZero;
    _videoPreviewViewBounds.size.width = self.previewGLView.drawableWidth;
    _videoPreviewViewBounds.size.height = self.previewGLView.drawableHeight;
    
    CGFloat previewAspect = _videoPreviewViewBounds.size.width  / _videoPreviewViewBounds.size.height;
    
    // we want to maintain the aspect radio of the screen size, so we clip the video image
    CGRect drawRect = sourceExtent;
    if (sourceAspect > previewAspect)
    {
        // use full height of the video image, and center crop the width
        drawRect.origin.x += (drawRect.size.width - drawRect.size.height * previewAspect) / 2.0;
        drawRect.size.width = drawRect.size.height * previewAspect;
    }
    else
    {
        // use full width of the video image, and center crop the height
        drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspect) / 2.0;
        drawRect.size.height = drawRect.size.width / previewAspect;
    }
    
    if (im)
        [self.ciContext drawImage:im inRect:_videoPreviewViewBounds fromRect:drawRect];
    
    [self.previewGLView display];

}


@end
