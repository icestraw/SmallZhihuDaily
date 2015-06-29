//
//  ISSideBarVC.m
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/27.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import "ISSideBarVC.h"

#import "ISGlobalSettings.h"

@interface ISSideBarVC ()

@property (strong, nonatomic) ISGlobalSettings *gs;
@property (weak, nonatomic) IBOutlet UIButton *nightModeBtn;
@property (weak, nonatomic) IBOutlet UIButton *distanceCheckBtn;
@property (weak, nonatomic) IBOutlet UIButton *removeCacheBtn;


@property BOOL nightMode;
@property BOOL distanceCheck;

@end

@implementation ISSideBarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _gs = [ISGlobalSettings sharedSettings];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeSwitchOn) name:@"ISSettingsNightModeOn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeSwitchOff) name:@"ISSettingsNightModeOff" object:nil];
    
    _nightMode = NO;
    _distanceCheck = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"tableView"]) {
        _tableVC = [segue destinationViewController];
    }
}

- (IBAction)nightModeSwitched:(id)sender {
    _nightMode = !_nightMode;
    if (_nightMode) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ISSettingsNightModeOn" object:nil];
        [_nightModeBtn setTitle:@"日间" forState:UIControlStateNormal];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ISSettingsNightModeOff" object:nil];
        [_nightModeBtn setTitle:@"夜间" forState:UIControlStateNormal];
    }
}

- (IBAction)screenOffModeSwitched:(id)sender {
    _distanceCheck = !_distanceCheck;
    if (_distanceCheck) {
        [UIDevice currentDevice].proximityMonitoringEnabled = YES;
        if ([UIDevice currentDevice].proximityMonitoringEnabled == NO) {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Device doesn't support this action." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [ac addAction:defaultAction];
            [self presentViewController:ac animated:YES completion:nil];
            _distanceCheck = !_distanceCheck;
        } else {
            [_distanceCheckBtn setTitle:@"距离检测开" forState:UIControlStateNormal];
        }
    } else {
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
        [_distanceCheckBtn setTitle:@"距离检测关" forState:UIControlStateNormal];
    }
    
}

- (IBAction)removeCache:(id)sender {
    
    NSString *cacheDir = _gs.cacheDir;
    NSString *urlStr = [[_gs applicationDocumentsDirectory] URLByAppendingPathComponent:cacheDir].absoluteString;
    urlStr = [urlStr stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:urlStr error:nil];
    
    BOOL finalResult = YES;
    for (NSString *filename in array) {
        NSString *pathStr = [urlStr stringByAppendingString:filename];
        BOOL result = [[NSFileManager defaultManager] removeItemAtPath:pathStr error:nil];
        if (!result) {
            finalResult = NO;
        }
    }
    NSString *titleStr;
    NSString *contentStr;
    if (finalResult) {
        titleStr = @"Successful";
        contentStr = @"Cache clear complete!";
    } else {
        titleStr = @"Warning";
        contentStr = @"Some of the contents cannot be removed";
    }
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:titleStr message:contentStr preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              
                                                          }];
    [ac addAction:defaultAction];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)nightModeSwitchOn
{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        self.view.backgroundColor = [_gs gsColorByKey:@"MainListBg" isNightModeOn:YES];
    } completion:^(BOOL finished) {
        [UIScreen mainScreen].wantsSoftwareDimming = YES;
        NSOperationQueue *bQueue = [NSOperationQueue new];
        [bQueue addOperationWithBlock:^{
            while ([UIScreen mainScreen].brightness > 0) {
                [NSThread sleepForTimeInterval:0.01];
                [UIScreen mainScreen].brightness = [UIScreen mainScreen].brightness - 0.01;
            }
        }];
    }];
}

- (void)nightModeSwitchOff
{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        self.view.backgroundColor = [_gs gsColorByKey:@"MainListBg" isNightModeOn:NO];
    } completion:^(BOOL finished) {
        [UIScreen mainScreen].wantsSoftwareDimming = NO;
        NSOperationQueue *bQueue = [NSOperationQueue new];
        [bQueue addOperationWithBlock:^{
            while ([UIScreen mainScreen].brightness < 0.5) {
                [NSThread sleepForTimeInterval:0.01];
                [UIScreen mainScreen].brightness = [UIScreen mainScreen].brightness + 0.01;
            }
        }];
    }];
}

@end
