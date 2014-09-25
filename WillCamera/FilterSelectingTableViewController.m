//
//  FilterSelectingTableViewController.m
//  WillCamera
//
//  Created by camera360 on 14-9-22.
//  Copyright (c) 2014年 Camera360. All rights reserved.
//

#import "FilterSelectingTableViewController.h"

@interface FilterSelectingTableViewController ()

@end

@implementation FilterSelectingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"滤镜选择";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setter

- (void)setDataSourceDic:(NSDictionary *)dataSourceDic
{
    _dataSourceDic = dataSourceDic;
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row < self.dataSourceDic.allKeys.count)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(filterSelectingTableViewController:didSelectIndex:)])
        {
            [self.delegate filterSelectingTableViewController:self didSelectIndex:indexPath.row];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.dataSourceDic.allKeys.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"filterCell" forIndexPath:indexPath];

    cell.textLabel.text = [self.dataSourceDic.allKeys[indexPath.row] description];
    
    
    return cell;
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
