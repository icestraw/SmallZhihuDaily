//
//  ISContainerVC.m
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/27.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import "ISContainerVC.h"

#define IS_CONTAINER_SIDEBAR_WIDTH 250

@interface ISContainerVC ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ISContainerVC

CGRect sRect;

- (void)viewDidLoad
{
    [super viewDidLoad];
    sRect = [UIScreen mainScreen].bounds;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(containerShowSidebar:) name:@"ISContainerVCShowSideBar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(containerHideSidebar:) name:@"ISContainerVCHideSideBar" object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    //Init scroll view
    _scrollView.contentSize = CGSizeMake(sRect.size.width + IS_CONTAINER_SIDEBAR_WIDTH, sRect.size.height);
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bounces = NO;
    _scrollView.contentOffset = CGPointMake(IS_CONTAINER_SIDEBAR_WIDTH, 0);
    _scrollView.backgroundColor = [UIColor grayColor];
    
    //Debug
    UIStoryboard *sideBarSB = [UIStoryboard storyboardWithName:@"ISSideBar" bundle:[NSBundle mainBundle]];
    self.sideBarVC = [sideBarSB instantiateInitialViewController];
//    _sideBarVC.view.backgroundColor = [UIColor blueColor];
    
    UIStoryboard *mainListSB = [UIStoryboard storyboardWithName:@"ISMainList" bundle:[NSBundle mainBundle]];
    self.contentVC = [mainListSB instantiateInitialViewController];
//    _contentVC.view.backgroundColor = [UIColor redColor];
    
    _sideBarVC.tableVC.sbDelegate = self;
}

- (void)setSideBarVC:(UIViewController *)sideBarVC
{
    if (_sideBarVC && [_sideBarVC isKindOfClass:[UIViewController class]]) {
        [_sideBarVC.view removeFromSuperview];
    }
    _sideBarVC = (ISSideBarVC *)sideBarVC;
    
    //Init sideBar
    [_scrollView addSubview:_sideBarVC.view];
    _sideBarVC.view.frame = CGRectMake(0, 0, IS_CONTAINER_SIDEBAR_WIDTH, sRect.size.height);
}

- (void)setContentVC:(UIViewController *)contentVC
{
    if (_contentVC && [_contentVC isKindOfClass:[UIViewController class]]) {
        [_contentVC.view removeFromSuperview];
    }
    _contentVC = contentVC;
    
    //Init ContentVC
    [_scrollView addSubview:_contentVC.view];
    _contentVC.view.frame = CGRectMake(IS_CONTAINER_SIDEBAR_WIDTH, 0, sRect.size.width, sRect.size.height);
}

- (void)containerShowSidebar:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        _scrollView.contentOffset = CGPointMake(0, 0);
    }];
}

- (void)containerHideSidebar:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        _scrollView.contentOffset = CGPointMake(IS_CONTAINER_SIDEBAR_WIDTH, 0);
    }];
}

- (void)sideBarSelecetdItemAtIndex:(NSInteger)index andTitle:(NSString *)title andSubURL:(NSString *)urlStr
{
    if ([_contentVC isKindOfClass:[UINavigationController class]]) {
        ISHomeListTVC *tvc = [[((UINavigationController *)_contentVC) viewControllers] firstObject];
        if ([tvc isKindOfClass:[ISHomeListTVC class]]) {
            
            //Debug
            tvc.list = [[ISAsyncPictureLoadingList alloc] initWithURLStr:urlStr];
            tvc.list.categoryIndex = index;
            tvc.titleStr = title;
        } else {
            NSLog(@"%@: Unable to load main list, inspect ISMainList.storyboard for detail", [self class]);
        }
    } else {
        NSLog(@"%@: Unable to load main list, inspect ISMainList.storyboard for detail", [self class]);
    }
}

@end
