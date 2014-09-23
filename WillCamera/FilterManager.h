//
//  FilterManager.h
//  WillCamera
//
//  Created by camera360 on 14-9-22.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    WillCameraFilterTypeAdditionCompositing,        //影像合成
    WillCameraFilterTypeAffineTransform,            //仿射变换
    WillCameraFilterTypeCheckerboardGenerator,      //棋盘发生器
    WillCameraFilterTypeColorBlendMode,             //CIColor混合模式
    WillCameraFilterTypeColorBurnBlendMode,         //CIColor燃烧混合模式
    WillCameraFilterTypeColorControls,
    WillCameraFilterTypeColorCube,                   //立方体
    WillCameraFilterTypeColorDodgeBlendMode,         //CIColor避免混合模式
    WillCameraFilterTypeColorInvert,                 //CIColor反相
    WillCameraFilterTypeColorMatrix,                 //CIColor矩阵
    WillCameraFilterTypeColorMonochrome,             //黑白照
    WillCameraFilterTypeConstantColorGenerator,      //恒定颜色发生器
    WillCameraFilterTypeCrop,                        //裁剪
    WillCameraFilterTypeDarkenBlendMode,             //亮度混合模式
    WillCameraFilterTypeDifferenceBlendMode,         //差分混合模式
    WillCameraFilterTypeExclusionBlendMode,          //互斥混合模式
    WillCameraFilterTypeExposureAdjust,              //曝光调节
    WillCameraFilterTypeFalseColor,                  //伪造颜色
    WillCameraFilterTypeGammaAdjust,                 //灰度系数调节
    WillCameraFilterTypeGaussianGradient,            //高斯梯度
    WillCameraFilterTypeHardLightBlendMode,          //强光混合模式
    WillCameraFilterTypeHighlightShadowAdjust,       //高亮阴影调节
    WillCameraFilterTypeHueAdjust,                   //饱和度调节
    WillCameraFilterTypeHueBlendMode,                //饱和度混合模式
    WillCameraFilterTypeLightenBlendMode,
    WillCameraFilterTypeLinearGradient,              //线性梯度
    WillCameraFilterTypeLuminosityBlendMode,         //亮度混合模式
    WillCameraFilterTypeMaximumCompositing,          //最大合成
    WillCameraFilterTypeMinimumCompositing,          //最小合成
    WillCameraFilterTypeMultiplyBlendMode,           //多层混合模式
    WillCameraFilterTypeMultiplyCompositing,         //多层合成
    WillCameraFilterTypeOverlayBlendMode,            //覆盖叠加混合模式
    WillCameraFilterTypeRadialGradient,              //半径梯度
    WillCameraFilterTypeSaturationBlendMode,         //饱和度混合模式
    WillCameraFilterTypeScreenBlendMode,             //全屏混合模式
    WillCameraFilterTypeSepiaTone,                   //棕黑色调
    WillCameraFilterTypeSoftLightBlendMode,          //弱光混合模式
    WillCameraFilterTypeSourceAtopCompositing,
    WillCameraFilterTypeSourceInCompositing,
    WillCameraFilterTypeSourceOutCompositing,
    WillCameraFilterTypeSourceOverCompositing,
    WillCameraFilterTypeStraightenFilter,            //拉直过滤器
    WillCameraFilterTypeStripesGenerator,            //条纹发生器
    WillCameraFilterTypeTemperatureAndTint,          //色温
    WillCameraFilterTypeToneCurve,                   //色调曲线
    WillCameraFilterTypeVibrance,                    //振动
    WillCameraFilterTypeVignette,                    //印花
    WillCameraFilterTypeWhitePointAdjust,            //白平衡调节
  
    WillCameraFilterTypeColorDodgeBlendModeBackgroundImage,     //双重曝光相机
    WillCameraFilterTypeOldFilm,                    //老电影
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
