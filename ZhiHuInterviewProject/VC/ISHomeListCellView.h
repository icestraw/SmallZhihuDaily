//
//  ISAsyncPictureLoadingCellView.h
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/24.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ISAsyncPictureLoadingListItem.h"

@interface ISHomeListCellView : UITableViewCell <ISAsyncPictureLoadingListItemDelegate>

@property (strong, nonatomic) ISAsyncPictureLoadingListItem *item;

@end
