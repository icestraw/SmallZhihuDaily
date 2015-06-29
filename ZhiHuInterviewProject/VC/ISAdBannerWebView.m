//
//  ISAdBannerWebView.m
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/24.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import "ISAdBannerWebView.h"

#define IS_AD_HEIGHT 200
#define UI_NAVIGATIONBAR_HEIGHT 60

@interface ISAdBannerWebView ()

@property (strong, nonatomic) UIImageView *imgView;

@end

@implementation ISAdBannerWebView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, IS_AD_HEIGHT)];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIEdgeInsets insets = self.scrollView.scrollIndicatorInsets;
//            UIEdgeInsets newInsets = UIEdgeInsetsMake(insets.top + IS_AD_HEIGHT, insets.left, insets.bottom, insets.right);
            UIEdgeInsets newInsets = UIEdgeInsetsMake(insets.top + UI_NAVIGATIONBAR_HEIGHT, insets.left, insets.bottom, insets.right);
            self.scrollView.scrollIndicatorInsets = newInsets;
            self.scrollView.contentInset = newInsets;
            self.scrollView.tintColor = [UIColor greenColor];
            [self.scrollView addSubview:_imgView];
        });
    }
    return self;
}

- (void)setAdImg:(UIImage *)adImg
{
    _adImg = adImg;
    _imgView.image = adImg;
    _imgView.contentMode = UIViewContentModeScaleAspectFill;
    _imgView.clipsToBounds = YES;
}

@end
