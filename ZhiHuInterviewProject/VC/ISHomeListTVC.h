//
//  ISAsyncPictureLoadingTVC.h
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/24.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISGlobalSettings.h"
#import "ISASyncPictureLoadingList.h"
#import "ISHomeListCellView.h"
#import "ISAsyncPictureLoadingDetailVC.h"
#import "ISHomeListBannerVC.h"

@interface ISHomeListTVC : UITableViewController

@property (strong, nonatomic) NSString *titleStr;
@property (strong, nonatomic) ISAsyncPictureLoadingList *list;

@end
