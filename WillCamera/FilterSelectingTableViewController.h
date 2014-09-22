//
//  FilterSelectingTableViewController.h
//  WillCamera
//
//  Created by camera360 on 14-9-22.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterSelectingTableViewControllerDelegate;



@interface FilterSelectingTableViewController : UITableViewController

@property (nonatomic, strong)NSArray *dataSourceArr;
@property (nonatomic, weak)id <FilterSelectingTableViewControllerDelegate>delegate;

@end




@protocol FilterSelectingTableViewControllerDelegate <NSObject>

- (void)filterSelectingTableViewController:(FilterSelectingTableViewController *)filterVC didSelectIndex:(NSInteger)index;

@end