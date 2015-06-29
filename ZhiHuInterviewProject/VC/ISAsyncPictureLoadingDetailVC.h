//
//  ISAsyncPictureLoadingDetailVC.h
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/24.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISAsyncPictureLoadingDetailVC : UIViewController

@property (strong, nonatomic) NSURL *imgUrl;

- (instancetype)initWithURL:(NSURL *)url andNightMode:(BOOL)nightMode;

@end
