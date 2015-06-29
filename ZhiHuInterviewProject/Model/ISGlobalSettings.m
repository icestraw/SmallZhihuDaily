//
//  GlobalSettings.m
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/24.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import "ISGlobalSettings.h"

@interface ISGlobalSettings ()

@property (strong, nonatomic) NSDictionary *colorConfigDic;

@end

@implementation ISGlobalSettings



+ (ISGlobalSettings *)sharedSettings
{
    static ISGlobalSettings *settings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (settings == nil) {
            settings = [[self alloc] init]; // assignment not done here
        }
    });
    
    return settings;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ColorConfig" ofType:@"plist"];
        NSDictionary *cDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        _colorConfigDic = cDic;
        
        //Constants
        _cacheDir = @"WebCache";
    }
    return self;
}


- (UIColor *)gsColorByKey:(NSString *)key isNightModeOn:(BOOL)isOn
{
    UIColor *color;
    NSDictionary *itemDic = [_colorConfigDic objectForKey:key];
    if ([itemDic objectForKey:@"day"] && [itemDic objectForKey:@"night"]) {
        NSDictionary *colorDic;
        if (!isOn) {
            colorDic = [itemDic objectForKey:@"day"];
        } else {
            colorDic = [itemDic objectForKey:@"night"];
        }
        CGFloat r = (CGFloat)((NSNumber *)[colorDic objectForKey:@"r"]).floatValue / 256.0;
        CGFloat g = (CGFloat)((NSNumber *)[colorDic objectForKey:@"g"]).floatValue / 256.0;
        CGFloat b = (CGFloat)((NSNumber *)[colorDic objectForKey:@"b"]).floatValue / 256.0;
        
        color = [UIColor colorWithRed:r green:g blue:b alpha:1];
    }
    if (!color) {
        NSLog(@"%@: Error in color config file!", [self class]);
    }
    return color;
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "icenoie.ZhiHuInterviewProject" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
