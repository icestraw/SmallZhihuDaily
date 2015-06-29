//
//  ISSideBarTVC.h
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/27.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ISSideBarTableDelegate <NSObject>

- (void)sideBarSelecetdItemAtIndex:(NSInteger)index andTitle:(NSString *)title andSubURL:(NSString *)urlStr;

@end

@interface ISSideBarTVC : UITableViewController

@property (strong, nonatomic) id<ISSideBarTableDelegate> sbDelegate;

@end
