//
//  ISBannerVC.h
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/25.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISHomeListBannerVC : UIViewController <UIScrollViewDelegate>

@property (nonatomic) BOOL periodicMoveMode;

@property (strong, nonatomic) NSArray *bannerViewArray; //Maybe webviews
@property (strong, nonatomic) NSArray *bannerViewUrlArray;

@end
