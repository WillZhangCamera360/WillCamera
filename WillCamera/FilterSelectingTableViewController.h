//
//  FilterSelectingTableViewController.h
//  WillCamera
//
//  Created by camera360 on 14-9-22.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterSelectingTableViewControllerDelegate;


///选择滤镜种类
@interface FilterSelectingTableViewController : UITableViewController
///显示可选择的滤镜
@property (nonatomic, strong)NSDictionary *dataSourceDic;
///选择滤镜之后的回调
@property (nonatomic, weak)id <FilterSelectingTableViewControllerDelegate>delegate;

@end




@protocol FilterSelectingTableViewControllerDelegate <NSObject>
///选择滤镜之后的回调
- (void)filterSelectingTableViewController:(FilterSelectingTableViewController *)filterVC didSelectIndex:(NSInteger)index;

@end