//
//  FilterManager.h
//  WillCamera
//
//  Created by camera360 on 14-9-22.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    WillCameraFilterTypeColorDodgeBlendModeBackgroundImage,     //双重曝光相机
    WillCameraFilterTypeOldFilm,                                //老电影
    WillCameraFilterTypeHueAdjust,                              //饱和度调节
    WillCameraFilterTypeCISepiaTone,                            //乌色
} WillCameraFilterType;


@interface FilterManager : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(FilterManager)

///当前滤镜
@property (assign, readonly)WillCameraFilterType filterType;
///设置滤镜种类
- (void)setCameraFilterType:(WillCameraFilterType)aType;

///获取当前filter输出的滤镜之后的照片
- (CIImage *)outputImageWithCurrentFliterAndInputImage:(CIImage *)inputImage;

///如果是双重曝光的话 此属性用于保存第一张曝光的图片
@property (strong)CIImage *colorDodgeBlendModeBackgroundImage;

@end
