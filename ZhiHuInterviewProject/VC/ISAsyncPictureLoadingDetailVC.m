//
//  ISAsyncPictureLoadingDetailVC.m
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/24.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import "ISAsyncPictureLoadingDetailVC.h"

#import "ISAdBannerWebView.h"
#import "ISWebCache.h"

#define IS_DATA_NETWORK_TIMEOUT 5

@interface ISAsyncPictureLoadingDetailVC ()

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) ISAdBannerWebView *webView;
@property BOOL nightMode;
@end

@implementation ISAsyncPictureLoadingDetailVC

- (instancetype)initWithURL:(NSURL *)url andNightMode:(BOOL)nightMode
{
    self = [super init];
    if (self) {
        _url = url;
        _nightMode = nightMode;
        _webView = [[ISAdBannerWebView alloc] init];
        _webView.alpha = 0;
        if (!_nightMode) {
            self.view.backgroundColor = [UIColor whiteColor];
        } else {
            self.view.backgroundColor = [UIColor blackColor];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.navigationController.navigationBar.layer.opacity = 1;
        if (_url) {
            if (_nightMode) {
                [_webView loadHTMLString:@"<body bgcolor=\"#000000\">" baseURL:nil];
            }
            NSMutableURLRequest *r = [NSMutableURLRequest requestWithURL:_url];
            r.timeoutInterval = IS_DATA_NETWORK_TIMEOUT;
            [NSURLConnection sendAsynchronousRequest:r queue:[NSOperationQueue new] completionHandler:^(NSURLResponse * __nullable response, NSData * __nullable data, NSError * __nullable connectionError) {
                
                NSString *htmlStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSData *tData = [htmlStr dataUsingEncoding:NSUTF8StringEncoding];
                
                NSDictionary *jsonDic;
                jsonDic = [NSJSONSerialization JSONObjectWithData:tData options:
                 NSJSONReadingMutableLeaves error:nil];
                
                
                if (jsonDic) {
                    
                    //Guessing API 4
                    NSString *bodyStr = [jsonDic objectForKey:@"body"];
                    NSString *headStr = @"<head><link rel=\"stylesheet\" href=\"http://news-at.zhihu.com/css/news_qa.auto.css?v=1edab\"></head>";
                    NSString *finalHTMLStr;
                    if (!_nightMode) {
                        finalHTMLStr = [NSString stringWithFormat:@"%@%@", headStr, bodyStr];
                    } else {
                        finalHTMLStr = [NSString stringWithFormat:@"%@<body class=\"night\">%@</body>", headStr, bodyStr];
                    }
                    
                    [_webView loadHTMLString:finalHTMLStr baseURL:_url];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        _webView.alpha = 1;
                    });
                } else {
                    
                    //Previews webpage loading
                    [_webView loadRequest:r];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        _webView.alpha = 1;
                    });
                }
                
            }];
            
            
            
            
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ISNoInternetConnectionAlert" object:nil];
        }
    });
    _webView.scrollView.backgroundColor = [UIColor grayColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    _webView.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:_webView];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

- (void)setImgUrl:(NSURL *)imgUrl
{
    _imgUrl = imgUrl;
    if (_imgUrl) {
        [[ISWebCache sharedWebCache] pullFromServerWithURL:_imgUrl andCompletionHandler:^(NSData *data, BOOL isCached, BOOL isSuccessful) {
            UIImage *img = [UIImage imageWithData:data];
            _webView.adImg = img;
        }];
    }
}

- (void)viewDidLayoutSubviews
{
    self.view.frame = [[UIScreen mainScreen] bounds];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
