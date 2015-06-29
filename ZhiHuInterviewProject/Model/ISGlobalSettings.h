//
//  GlobalSettings.h
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/24.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ISGlobalSettings : NSObject

@property (strong, nonatomic) NSString *cacheDir;

+ (ISGlobalSettings *)sharedSettings;

- (UIColor *)gsColorByKey:(NSString *)key isNightModeOn:(BOOL)isOn;

- (NSURL *)applicationDocumentsDirectory;

@end
