//
//  ISAsyncPictureLoadingList.m
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/24.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import "ISAsyncPictureLoadingList.h"

#import "TFHpple.h"

@interface ISAsyncPictureLoadingList ()

@property (strong, nonatomic) NSURL *serverAddr;
@property (nonatomic) dispatch_queue_t loadingQueue;
@property (strong, nonatomic) NSLock *lock;

//API related
@property BOOL isInitByAPI;
@property NSInteger mainListDateOffset;
@property (strong, nonatomic) NSString *subListOffset;

@end

@implementation ISAsyncPictureLoadingList

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isInitByAPI = NO;
        _mainListDateOffset = 0;
        _serverAddr = [NSURL URLWithString:@"http://daily.zhihu.com"];
        _lock = [[NSLock alloc] init];
        _list = [[NSMutableArray alloc] init];
        _loadingQueue = dispatch_queue_create("listLoading", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (instancetype)initWithURLStr:(NSString *)str
{
    self = [super init];
    if (self) {
        _isInitByAPI = YES;
        _mainListDateOffset = 0;
        _serverAddr = [NSURL URLWithString:[NSString stringWithFormat:@"http://news-at.zhihu.com%@", str]];
        _lock = [[NSLock alloc] init];
        _list = [[NSMutableArray alloc] init];
        _loadingQueue = dispatch_queue_create("listLoading", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)loadListWithCompletionHandler:(void (^)(BOOL isSuccessful))handler
{
    if (!_isInitByAPI) {
        
        //Load by primitive webpage content
        [self loadListWithWebpageAndCompletionHandler:handler];
    } else {
        
        //Load by guessing API
        [self loadListWithGuessingAPIByAppend:NO AndCompletionHandler:handler];
    }
}

- (void)appendMoreToListWithCompletionHandler:(void (^)(BOOL isSuccessful))handler
{
    if (!_isInitByAPI) {
        
        //Primitive webpage analyzing cannot use this API
        NSLog(@"%@: Primitive webpage analyzing cannot use this API", [self class]);
    } else {
        
        //Append by guessing API
        [self loadListWithGuessingAPIByAppend:YES AndCompletionHandler:handler];
    }
}

//Primitive webpage analyzing
- (void)loadListWithWebpageAndCompletionHandler:(void (^)(BOOL))handler
{
    if ([_lock tryLock]) {
        __block NSData *data;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), _loadingQueue, ^{
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_serverAddr];
            request.timeoutInterval = IS_DATA_NETWORK_TIMEOUT;
            data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            if (!data) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ISNoInternetConnectionAlert" object:nil];
            }
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            data = [str dataUsingEncoding:NSUTF8StringEncoding];
            TFHpple * doc = [[TFHpple alloc] initWithHTMLData:data];
            NSArray *a = [doc searchWithXPathQuery:@"//div[@class='wrap']"];
            [_list removeAllObjects];
            
            if (data) {
                for (TFHppleElement *e in a) {
                    ISAsyncPictureLoadingListItem *item = [[ISAsyncPictureLoadingListItem alloc] init];
                    
                    NSString *htmlStr = e.raw;
                    NSString *contentUrlPattern = @"<a href=\".*\" class=\"link-button\">";
                    NSString *imgUrlPattern = @"<img src=\".*\" class=\"preview-image\"/>";
                    NSRegularExpression *cr = [[NSRegularExpression alloc] initWithPattern:contentUrlPattern options:NSRegularExpressionCaseInsensitive error:nil];
                    NSRegularExpression *ir = [[NSRegularExpression alloc] initWithPattern:imgUrlPattern options:NSRegularExpressionCaseInsensitive error:nil];
                    
                    NSRange contentRange = [cr firstMatchInString:htmlStr options:0 range:NSMakeRange(0, htmlStr.length)].range;
                    NSRange imgUrlRange = [ir firstMatchInString:htmlStr options:0 range:NSMakeRange(0, htmlStr.length)].range;
                    
                    if (contentRange.length + contentRange.location > htmlStr.length) {
                        continue;
                    }
                    if (imgUrlRange.length + imgUrlRange.location > htmlStr.length) {
                        continue;
                    }
                    
                    NSString *contentUrlStr = [htmlStr substringWithRange:contentRange];
                    NSString *imgUrlStr = [htmlStr substringWithRange:imgUrlRange];
                    
                    if (contentUrlStr.length < 40) {
                        continue;
                    }
                    if (imgUrlStr.length < 45) {
                        continue;
                    }
                    
                    contentUrlStr = [contentUrlStr substringWithRange:NSMakeRange(9, contentUrlStr.length - 9 - 22)];
                    imgUrlStr = [imgUrlStr substringWithRange:NSMakeRange(10, imgUrlStr.length - 10 - 25)];
                    
                    //        NSLog(@"%@ ||| %@", contentUrlStr, imgUrlStr);
                    item.titleStr = e.content;
                    item.imgUrl = [NSURL URLWithString:imgUrlStr];
                    item.contentUrl = [NSURL URLWithString:contentUrlStr];
                    
                    [_list addObject:item];
                }
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (data) {
                    handler(YES);
                } else {
                    handler(NO);
                }
                [_lock unlock];
            });
            
        });
    }
}

//Guessing API
- (void)loadListWithGuessingAPIByAppend:(BOOL)isAppend AndCompletionHandler:(void (^)(BOOL isSuccessful))handler
{
    if ([_lock tryLock]) {
        __block NSData *data;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), _loadingQueue, ^{
            NSMutableURLRequest *request;
            
            //Append or not
            if (!isAppend) {
                request = [NSMutableURLRequest requestWithURL:_serverAddr];
                _mainListDateOffset = 0;
            } else {
                NSString *urlStr = _serverAddr.absoluteString;
                
                if ([urlStr containsString:@"/latest"]) {
                    
                    //Append by mainListDateOffset
                    NSRange range = [urlStr rangeOfString:@"/latest"];
                    urlStr = [urlStr substringToIndex:range.location];
                    NSString *dateOffsetStr;
                    NSString *finalUrlStr;
                    
                    _mainListDateOffset -= 1;
                    NSDate *date = [NSDate date];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat = @"yyyyMMdd";
                    date = [date dateByAddingTimeInterval:(_mainListDateOffset * 86400)];
                    dateOffsetStr = [formatter stringFromDate:date];
                    
                    finalUrlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"/before/%@", dateOffsetStr]];
                    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:finalUrlStr]];
                    
                } else if ([urlStr containsString:@"theme"]) {
                    
                    //Append by subListOffset
                    ISAsyncPictureLoadingListItem *lastItem = [_list lastObject];
                    NSString *lastItemContentID = [lastItem.contentUrl.absoluteString stringByReplacingOccurrencesOfString:@"http://news-at.zhihu.com/api/4/story/" withString:@""];
                    NSString *finalUrlStr;
                    finalUrlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"/before/%@", lastItemContentID]];
                    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:finalUrlStr]];
                }
            }
            
            request.timeoutInterval = IS_DATA_NETWORK_TIMEOUT;
            data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            if (!data) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ISNoInternetConnectionAlert" object:nil];
            }
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            data = [str dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:
                       NSJSONReadingMutableLeaves error:nil];
            NSArray *storyArray = [jsonDic objectForKey:@"stories"];
            if ([storyArray isKindOfClass:[NSArray class]]) {
                
                //Append or not
                if (!isAppend) {
                    [_list removeAllObjects];
                }
                
                for (NSDictionary *dic in storyArray) {
                    ISAsyncPictureLoadingListItem *item = [[ISAsyncPictureLoadingListItem alloc] init];
                    
                    
                    item.titleStr = [dic objectForKey:@"title"];
                    item.imgUrl = [NSURL URLWithString:[((NSArray *)[dic objectForKey:@"images"]) firstObject]];
                    item.contentUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://news-at.zhihu.com/api/4/story/%@", [dic objectForKey:@"id"]]];
                    [_list addObject:item];
                }
            } else {
                NSLog(@"%@: JSON Read Failure, maybe server API has changed", [self class]);
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (data) {
                    handler(YES);
                } else {
                    handler(NO);
                }
                [_lock unlock];
            });
            
        });
    }
}



@end
