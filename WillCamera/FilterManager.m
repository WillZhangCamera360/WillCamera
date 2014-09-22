//
//  FilterManager.m
//  WillCamera
//
//  Created by camera360 on 14-9-22.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//

#import "FilterManager.h"

@implementation FilterManager

SYNTHESIZE_SINGLETON_FOR_CLASS(FilterManager)

//- (CIFilter *)filterWithType:(WillCameraFilterType)aType inputImage:(CIImage *)inputImage
//{
//    CIFilter *filter = [CIFilter filterWithName:@"CIColorDodgeBlendMode"];
//    [filter setValue:inputImage forKey:@"inputImage"];
//}

#pragma mark - Tools

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
//双重曝光
- (CIFilter *)colorDodgeBlendModeFilterWithInputImage:(CIImage *)inputImage
             backgroundImage:(CIImage *)backgroundImage
{
    CIFilter *filter = [CIFilter filterWithName:@"CIColorDodgeBlendMode"];
    
    [filter setValue:inputImage forKey:@"inputImage"];
    [filter setValue:backgroundImage forKey:@"inputBackgroundImage"];
    return filter;
}




@end
