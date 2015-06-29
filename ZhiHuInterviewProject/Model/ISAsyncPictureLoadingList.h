//
//  ISAsyncPictureLoadingList.h
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/24.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ISAsyncPictureLoadingListItem.h"

@interface ISAsyncPictureLoadingList : NSObject

@property (nonatomic) NSUInteger categoryIndex;
@property (strong, nonatomic) NSMutableArray *list;//List Item Object


- (instancetype)init;
- (instancetype)initWithURLStr:(NSString *)str;
- (void)loadListWithCompletionHandler:(void (^)(BOOL isSuccessful))handler;
- (void)appendMoreToListWithCompletionHandler:(void (^)(BOOL isSuccessful))handler;

@end
