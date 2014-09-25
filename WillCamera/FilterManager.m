//
//  FilterManager.m
//  WillCamera
//
//  Created by camera360 on 14-9-22.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//

#import "FilterManager.h"

@interface FilterManager ()

@end

@implementation FilterManager

SYNTHESIZE_SINGLETON_FOR_CLASS(FilterManager)


#pragma mark - Public Method

- (void)setCameraFilterType:(WillCameraFilterType)aType
{
    _filterType = aType;
    //如果是刚调整滤镜模式 就把第一张双重曝光的Image清空
    self.colorDodgeBlendModeBackgroundImage = nil;
}

- (CIImage *)outputImageWithCurrentFliterAndInputImage:(CIImage *)inputImage
{
    CIImage *outputImage = nil;
    CIFilter *currentFilter = [self currentFilterWithInputImage:inputImage];
    if (currentFilter) {
        outputImage = currentFilter.outputImage;
    }
    return outputImage;
}

#pragma mark - Tools

- (CIFilter *)currentFilterWithInputImage:(CIImage *)inputImage
{
    CIFilter *currentFilter = nil;
    switch (self.filterType)
    {
        case WillCameraFilterTypeColorDodgeBlendModeBackgroundImage://双重曝光相机
        {
            currentFilter = [self colorDodgeBlendModeFilterWithInputImage:inputImage backgroundImage:self.colorDodgeBlendModeBackgroundImage];
            break;
        }
        case WillCameraFilterTypeOldFilm://老电影
        {
            currentFilter = [self oldFilmFilterWithInputImage:inputImage];
            break;
        }
        case WillCameraFilterTypeHueAdjust://饱和度调节
        {
            currentFilter = [self hueAdjustFilterWithInputImage:inputImage];
            break;
        }
        case WillCameraFilterTypeCISepiaTone://乌色
        {
            currentFilter = [self sepiaToneFilterWithInputImage:inputImage];
            break;
        }
            
            
        default:
            currentFilter = nil;
            break;
    }
    return currentFilter;
}



- (NSArray *)allAvailabFilters
{
    NSArray *filterNames = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
    
    for (NSString *filterName in filterNames) {
        CIFilter *filter = [CIFilter filterWithName:filterName];
        NSDictionary *attDic = [filter attributes];
        NSLog(@"%@",attDic);
        NSLog(@"%d ---------", __LINE__);
        
    }
    
    return nil;
    
}


#pragma mark - Filter

///饱和度调节
- (CIFilter *)hueAdjustFilterWithInputImage:(CIImage *)inputImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CIHueAdjust"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:@(22) forKey:kCIInputAngleKey];
    return filter;
}

//CISepiaTone  乌色
- (CIFilter *)sepiaToneFilterWithInputImage:(CIImage *)inputImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    return filter;
}


///双重曝光滤镜
- (CIFilter *)colorDodgeBlendModeFilterWithInputImage:(CIImage *)inputImage
             backgroundImage:(CIImage *)backgroundImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CIColorDodgeBlendMode"];
    
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:backgroundImage forKey:@"inputBackgroundImage"];
    return filter;
}

///旧电影滤镜
- (CIFilter *)oldFilmFilterWithInputImage:(CIImage *)inputImage
{
    CIFilter *filter = [CIFilter filterWithName:@"OldeFilm"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    return filter;
}



@end
