//
//  MainTBC.m
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/24.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import "MainVC.h"

#import "ISWebCache.h"

@interface MainVC ()

@property (strong, nonatomic) NSLock *alertViewLock;

@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _alertViewLock = [[NSLock alloc] init];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeSwitchOn) name:@"ISSettingsNightModeOn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeSwitchOff) name:@"ISSettingsNightModeOff" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainNoInternetConnectionAlert:) name:@"ISNoInternetConnectionAlert" object:nil];
//    self.tabBar.tintColor = [UIColor darkGrayColor];
    
//    ISWebCache *c = [[ISWebCache alloc] init];
//    [c pullFromServerWithURL:[NSURL URLWithString:@"http://baidu.com"] andCompletionHandler:^(NSData *data, BOOL isCached, BOOL isSuccessful) {
//        NSData *d = data;
//        BOOL c = isCached;
//        BOOL s = isSuccessful;
//        NSLog(@"%@, %d, %d", d, c, s);
//    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)nightModeSwitchOn
{
//    self.tabBar.tintColor = [UIColor lightGrayColor];
//    self.tabBar.barStyle = UIBarStyleBlack;
}

- (void)nightModeSwitchOff
{
//    self.tabBar.tintColor = [UIColor darkGrayColor];
//    self.tabBar.barStyle = UIBarStyleDefault;
}

- (void)mainNoInternetConnectionAlert:(id)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([_alertViewLock tryLock]) {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Warning" message:@"No internet connection." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      [_alertViewLock unlock];
                                                                  }];
            
            [ac addAction:defaultAction];
            [self presentViewController:ac animated:YES completion:nil];
        }
    });
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
