//
//  ISWebCache.h
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/26.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISWebCache : NSObject

+ (ISWebCache *)sharedWebCache;

- (void)pullFromServerWithURL:(NSURL *)url andCompletionHandler:(void (^)(NSData *data, BOOL isCached, BOOL isSuccessful))handler;

@end
