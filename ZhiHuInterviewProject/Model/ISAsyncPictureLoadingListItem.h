//
//  ISAsyncPictureLoadingListItem.h
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/24.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define IS_DATA_NETWORK_TIMEOUT 5

@protocol ISAsyncPictureLoadingListItemDelegate <NSObject>

- (void)imgLoaded;

@end

@interface ISAsyncPictureLoadingListItem : NSObject

@property (weak, nonatomic) id<ISAsyncPictureLoadingListItemDelegate> delegate;

@property (strong, nonatomic) NSString *titleStr;
@property (strong, nonatomic) NSURL *imgUrl;
@property (strong, nonatomic) NSURL *contentUrl;

@property (strong, nonatomic) UIImage *img;
@property (nonatomic) BOOL nightMode;

@end
