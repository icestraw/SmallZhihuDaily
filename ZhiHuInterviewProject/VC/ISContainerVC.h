//
//  ISContainerVC.h
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/27.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ISSideBarVC.h"
#import "ISSideBarTVC.h"
#import "ISHomeListTVC.h"


@interface ISContainerVC : UIViewController <ISSideBarTableDelegate>

@property (strong, nonatomic) ISSideBarVC *sideBarVC;
@property (strong, nonatomic) UIViewController *contentVC;

@end
