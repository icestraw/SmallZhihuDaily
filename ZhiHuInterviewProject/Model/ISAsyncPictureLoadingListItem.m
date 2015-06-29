//
//  ISAsyncPictureLoadingListItem.m
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/24.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import "ISAsyncPictureLoadingListItem.h"

#import "ISWebCache.h"

@implementation ISAsyncPictureLoadingListItem


- (instancetype)initWithNightMode:(BOOL)isOn
{
    self = [super init];
    if (self) {
        _nightMode = isOn;
    }
    return self;
}

- (void)setImgUrl:(NSURL *)imgUrl
{
    
    _imgUrl = imgUrl;
//    NSLog(@"IMGURL: %@ ", _imgUrl);
    if (_imgUrl && !_img) {
        [[ISWebCache sharedWebCache] pullFromServerWithURL:imgUrl andCompletionHandler:^(NSData *data, BOOL isCached, BOOL isSuccessful) {
            
            if (isSuccessful) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.img = [UIImage imageWithData:data];
                    
                    if (_delegate) {
                        [_delegate imgLoaded];
                    }
                });
            }
            
        }];
    }
}

//- (NSData *)pullFromServerWithURL:(NSURL *)url andCompletionHandler:(void (^)(NSData *data, BOOL isSuccessful))handler
//{
//    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    request.timeoutInterval = IS_DATA_NETWORK_TIMEOUT;
//    
////    NSData *data = [NSData dataWithContentsOfURL:url];
//    
//    //Debug
//    __block NSData *data;
//    
//    return data;
//}


@end
