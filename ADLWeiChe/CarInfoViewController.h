//
//  CarInfoViewController.h
//  ADLWeiChe
//
//  Created by icePhoenix on 15/6/12.
//  Copyright (c) 2015年 aodelin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarInfoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *carTable;
    NSArray *carAry;
    NSMutableArray *carInfoAry;
}
@end
