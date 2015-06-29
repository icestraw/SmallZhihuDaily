//
//  ISBannerVC.m
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/25.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import "ISHomeListBannerVC.h"

#import "TFHpple.h"
#import "ISAsyncPictureLoadingDetailVC.h"

#define IS_BANNER_DEFAULT_MOVE_TIME 5
#define IS_DATA_NETWORK_TIMEOUT 5
#define APL_BANNER_OFFSET 0

@interface ISHomeListBannerVC ()

@property NSInteger itemCount;
@property (strong, nonatomic) NSTimer *moveTimer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property CGRect viewFrame;

@property (strong, nonatomic) UITapGestureRecognizer *tGestureRecognizer;
@property BOOL nightMode;

@end

@implementation ISHomeListBannerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _nightMode = NO;
    _tGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerItemTouched)];
    [self.scrollView addGestureRecognizer:_tGestureRecognizer];
    _moveTimer = [NSTimer scheduledTimerWithTimeInterval:IS_BANNER_DEFAULT_MOVE_TIME target:self selector:@selector(bannerPeriodicMove) userInfo:nil repeats:YES];
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    _scrollView.pagingEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeSwitchOn) name:@"ISSettingsNightModeOn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeSwitchOff) name:@"ISSettingsNightModeOff" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.view.frame = self.view.superview.frame;
    _scrollView.frame = self.view.frame;
    _scrollView.backgroundColor = [UIColor lightGrayColor];
    [_moveTimer fire];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)bannerRefreshByURL:(BOOL)isUrl
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect frame = self.view.frame;
        _viewFrame = frame;
        
        if (_bannerViewArray) {
            for (UIView *view in _bannerViewArray) {
                [view removeFromSuperview];
            }
        }
        if (isUrl) {
            _itemCount = [_bannerViewUrlArray count];
            _bannerViewArray = nil;
        } else {
            _itemCount = [_bannerViewArray count];
        }
        _scrollView.contentSize = CGSizeMake(frame.size.width * _itemCount, frame.size.height);
        NSMutableArray *viewArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < _itemCount; i++) {
            UIWebView *wv = [[UIWebView alloc] init];
            
            //Debug
            CGFloat webViewOffset = (370 - [UIScreen mainScreen].bounds.size.width);
            wv.frame = CGRectMake(frame.size.width * i, webViewOffset, frame.size.width, frame.size.height - webViewOffset);
            
            wv.userInteractionEnabled = NO;
            wv.clipsToBounds = YES;
            [viewArray addObject:wv];
            [self.scrollView addSubview:wv];
            NSURL *url = [_bannerViewUrlArray objectAtIndex:i];
            
            
            //Extern
            if ([url.absoluteString containsString:@"daily.zhihu.com/story"]) {
                NSMutableURLRequest *r = [NSMutableURLRequest requestWithURL:url];
                r.timeoutInterval = IS_DATA_NETWORK_TIMEOUT;
                [NSURLConnection sendAsynchronousRequest:r queue:[NSOperationQueue new]  completionHandler:^(NSURLResponse * __nullable response, NSData * __nullable data, NSError * __nullable connectionError) {
                    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSData *tData = [str dataUsingEncoding:NSUTF8StringEncoding];
                    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:tData];
                    NSArray *content = [doc searchWithXPathQuery:@"//div[@class='headline']"];
                    NSArray *head = [doc searchWithXPathQuery:@"//head"];
                    NSString *contentHTMLStr = ((TFHppleElement *)[content firstObject]).raw;
                    NSString *headHTMLStr = ((TFHppleElement *)[head firstObject]).raw;
                    [wv loadHTMLString:[NSString stringWithFormat:@"%@%@", headHTMLStr, contentHTMLStr] baseURL:url];
                }];
            } else if([url.absoluteString containsString:@"news-at.zhihu.com"]){
                
                //Guessing API 4
                NSURL *redirectURL = [NSURL URLWithString:[url.absoluteString stringByReplacingOccurrencesOfString:@"/api/4" withString:@""]];
                NSMutableURLRequest *r = [NSMutableURLRequest requestWithURL:redirectURL];
                r.timeoutInterval = IS_DATA_NETWORK_TIMEOUT;
                [NSURLConnection sendAsynchronousRequest:r queue:[NSOperationQueue new]  completionHandler:^(NSURLResponse * __nullable response, NSData * __nullable data, NSError * __nullable connectionError) {
                    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSData *tData = [str dataUsingEncoding:NSUTF8StringEncoding];
                    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:tData];
                    NSArray *content = [doc searchWithXPathQuery:@"//div[@class='headline']"];
                    NSArray *head = [doc searchWithXPathQuery:@"//head"];
                    NSString *contentHTMLStr = ((TFHppleElement *)[content firstObject]).raw;
                    NSString *headHTMLStr = ((TFHppleElement *)[head firstObject]).raw;
                    [wv loadHTMLString:[NSString stringWithFormat:@"%@%@", headHTMLStr, contentHTMLStr] baseURL:url];
                }];
                
                
                
            } else {
                [wv loadRequest:[NSURLRequest requestWithURL:url]];
            }
            
        }
        _bannerViewArray = viewArray;
    });
}

- (void)bannerPeriodicMove
{
    if (_viewFrame.size.width > 0) {
        if (_scrollView.contentOffset.x + _viewFrame.size.width >= _scrollView.contentSize.width) {
            [UIView animateWithDuration:0.2 animations:^{
                _scrollView.contentOffset = CGPointMake(0, _scrollView.contentOffset.y);
            }];
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                _scrollView.contentOffset = CGPointMake(_scrollView.contentOffset.x + _viewFrame.size.width, _scrollView.contentOffset.y);
            }];
        }
    }
}

//- (void)setPeriodicMoveMode:(BOOL)periodicMoveMode
//{
//    if (periodicMoveMode) {
//        [_moveTimer setFireDate:[NSDate distantPast]];
//    } else {
//        [_moveTimer setFireDate:[NSDate distantFuture]];
//    }
//}

- (void)setBannerViewArray:(NSArray *)bannerViewArray
{
    //Refresh
}

- (void)setBannerViewUrlArray:(NSArray *)bannerViewUrlArray
{
    //Refresh using webviews
    _bannerViewUrlArray = bannerViewUrlArray;
    if (bannerViewUrlArray) {
        [self bannerRefreshByURL:YES];
    }
}

- (void)nightModeSwitchOn
{
    _nightMode = YES;
//    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        
//    } completion:^(BOOL finished) {
//        
//    }];
}

- (void)nightModeSwitchOff
{
    _nightMode = NO;
//    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        
//    } completion:^(BOOL finished) {
//        
//    }];
}

- (void)bannerItemTouched
{
    if (_viewFrame.size.width > 0) {
        NSInteger p;
        p = fabs(_scrollView.contentOffset.x / _viewFrame.size.width);
        if (p >= 0 && p < _itemCount) {
            ISAsyncPictureLoadingDetailVC *vc = [[ISAsyncPictureLoadingDetailVC alloc] initWithURL:[_bannerViewUrlArray objectAtIndex:p] andNightMode:_nightMode];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ISBannerVCItemTouched" object:vc];
        }
    }
}
                           
@end
