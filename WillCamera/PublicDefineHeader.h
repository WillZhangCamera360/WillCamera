//
//  PublicDefineHeader.h
//  WillCamera
//
//  Created by camera360 on 14-9-18.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//

#ifndef AVCam_PublicDefineHeader_h
#define AVCam_PublicDefineHeader_h

///宏定义单例 方法声明
#define SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(classname) \
\
+ (classname *)shared##classname;\


///宏定义单例 方法实现
#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
\
static classname *shared##classname = nil; \
\
+ (classname *)shared##classname \
{ \
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        shared##classname = [[self alloc] init];\
    });\
    return shared##classname;\
}\




#endif
