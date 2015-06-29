//
//  ISAsyncPictureLoadingTVC.m
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/24.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import "ISHomeListTVC.h"

#define APL_BANNER_HEIGHT 300
#define APL_BANNER_OFFSET 80
#define APL_CONTENT_HEIGHT 100
#define APL_REFRESH_OFFSET 100
#define APL_NAVBAR_DISAPPEAR_LENGTH 300

@interface ISHomeListTVC ()

@property (strong, nonatomic) ISHomeListBannerVC *bannerVC;
@property (strong, nonatomic) ISGlobalSettings *gs;
@property BOOL nightMode;
@property BOOL isSideBarOpen;
@property BOOL isRefreshing;

@property (strong, nonatomic) NSString *currentTitleStr;
@property (strong, nonatomic) NSMutableArray *dateIndents; //NSNumber objects for height of each date

@end

@implementation ISHomeListTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _gs = [ISGlobalSettings sharedSettings];
    _dateIndents = [[NSMutableArray alloc] init];
//    _array = [[NSMutableArray alloc] init];
//    _list = [[ISAsyncPictureLoadingList alloc] init];
    _isSideBarOpen = NO;
    
    UIEdgeInsets insets = self.tableView.scrollIndicatorInsets;
    UIEdgeInsets newInsets = UIEdgeInsetsMake(insets.top - APL_BANNER_OFFSET, insets.left, insets.bottom, insets.right);
    self.tableView.scrollIndicatorInsets = newInsets;
    self.tableView.contentInset = newInsets;
    self.navigationController.navigationBar.translucent = YES;
    [[UINavigationBar appearance]setTintColor:[UIColor blueColor]];
    self.navigationController.navigationBar.barTintColor = [_gs gsColorByKey:@"NavigationBar" isNightModeOn:NO];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeSwitchOn) name:@"ISSettingsNightModeOn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeSwitchOff) name:@"ISSettingsNightModeOff" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aplPushVC:) name:@"ISBannerVCItemTouched" object:nil];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self aplRefresh];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTitleStr:(NSString *)titleStr
{
    _titleStr = titleStr;
    self.currentTitleStr = titleStr;
}

- (void)setCurrentTitleStr:(NSString *)currentTitleStr
{
    _currentTitleStr = currentTitleStr;
    self.navigationItem.title = _currentTitleStr;
}

#pragma mark - Table view data source


- (CGFloat)tableView:(nonnull UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    CGFloat f = 100;
    if (indexPath.row == 0) {
        f = APL_BANNER_HEIGHT;
    } else {
        f = APL_CONTENT_HEIGHT;
    }
    return f;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    CGFloat f = 100;
    if (indexPath.row == 0) {
        f = APL_BANNER_HEIGHT;
    } else {
        f = APL_CONTENT_HEIGHT;
    }
    return f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_list.list count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"banner" forIndexPath:indexPath];
        if ([_list.list count] > 0) {
            if (!_bannerVC) {
                _bannerVC = [[ISHomeListBannerVC alloc] init];
                _bannerVC.periodicMoveMode = YES;
                NSMutableArray *array = [[NSMutableArray alloc] init];
                for (int i = 0; i < 4; i++) {
                    ISAsyncPictureLoadingListItem *item = ((ISAsyncPictureLoadingListItem *)[_list.list objectAtIndex:i]);
                    [array addObject:item.contentUrl];
                }
                
                _bannerVC.bannerViewUrlArray = [NSArray arrayWithArray:array];
                
                [cell addSubview:_bannerVC.view];
                CGRect rect = _bannerVC.view.frame;
                rect.origin.y = APL_BANNER_OFFSET;
                _bannerVC.view.frame = rect;
            }
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"content" forIndexPath:indexPath];
        cell.clipsToBounds = YES;
        
        ISAsyncPictureLoadingListItem *item = ((ISAsyncPictureLoadingListItem *)[_list.list objectAtIndex:indexPath.row - 1]);
        
        item.nightMode = _nightMode;
        ((ISHomeListCellView *)cell).item = item;
        
    }

    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row != 0) {
        ISAsyncPictureLoadingListItem *item = ((ISAsyncPictureLoadingListItem *)[_list.list objectAtIndex:indexPath.row - 1]);
        if (item.contentUrl) {
            ISAsyncPictureLoadingDetailVC *vc = [[ISAsyncPictureLoadingDetailVC alloc] initWithURL:item.contentUrl andNightMode:_nightMode];
            [self.navigationController pushViewController:vc animated:YES];
            
            if (_list.categoryIndex == 0) {
                vc.imgUrl = item.imgUrl;
            }
        }
    }

}

- (void)scrollViewDidScroll:(nonnull UIScrollView *)scrollView
{
    //Opacity check
    CGFloat opacity = 1 - (scrollView.contentOffset.y / (APL_BANNER_HEIGHT - APL_BANNER_OFFSET)) - 0.1;
    if (opacity > 1) {
        opacity = 1;
    }
    if (opacity < 0.01) {
        opacity = 0.01;
    }
//    self.navigationController.navigationBar.alpha = opacity;
    
    //Top refresh check
    if (self.tableView.contentOffset.y + APL_REFRESH_OFFSET <= 0) {
        if (!_isRefreshing) {
            _isRefreshing = YES;
            [self aplRefresh];
        }
    } else {
        _isRefreshing = NO;
    }
    
    //Downside refresh check
    if (self.tableView.contentOffset.y - APL_REFRESH_OFFSET + [UIScreen mainScreen].bounds.size.height >= self.tableView.contentSize.height) {
        
        //Load more
        NSInteger beforeItemNum = [_list.list count];
        [_list appendMoreToListWithCompletionHandler:^(BOOL isSuccessful) {
            NSInteger afterItemNum = [_list.list count];
            if (afterItemNum >= beforeItemNum) {
                [_dateIndents addObject:[NSNumber numberWithInteger:APL_BANNER_HEIGHT - APL_BANNER_OFFSET + beforeItemNum * APL_CONTENT_HEIGHT]];
                
                NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
                for (NSInteger i = beforeItemNum; i < afterItemNum; i++) {
                    NSIndexPath *ip = [NSIndexPath indexPathForItem:i inSection:0];
                    [indexPathArray addObject:ip];
                }
                [self.tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                NSLog(@"%@: Unexpected error when appending content", [self class]);
            }
            
        }];

    } else {
        _isRefreshing = NO;
    }
    
    //NavigationBar title check
    if (_dateIndents && [_dateIndents count] > 0) {
        BOOL isChanged = NO;
        for (NSInteger i = [_dateIndents count] - 1; i >= 0 ; i--) {
            if (scrollView.contentOffset.y > ((NSNumber *)[_dateIndents objectAtIndex:i]).integerValue) {
                NSDate *date = [NSDate date];
                date = [date dateByAddingTimeInterval:((-i - 1) * 86400)];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"MM.dd EEE";
                self.currentTitleStr = [formatter stringFromDate:date];\
                isChanged = YES;
                break;
            }
        }
        if (!isChanged) {
            self.currentTitleStr = _titleStr;
        }
    } else {
        self.currentTitleStr = _titleStr;
    }
}

- (void)aplRefresh
{
    [_dateIndents removeAllObjects];
    NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
    self.navigationItem.title = @"Refreshing...";
//    [_list.list removeAllObjects];
//    [self.tableView reloadData];
    [_list loadListWithCompletionHandler:^(BOOL isSuccessful) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ISContainerVCHideSideBar" object:nil];
        
        self.navigationItem.title = @"Refreshed";
        if ([indexPathArray count] > 0) {
            [self.tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.currentTitleStr = self.titleStr;
            [self.tableView reloadData];
            
        });
    }];
}

- (void)aplPushVC:(id)sender
{
    NSNotification *n = sender;
    UIViewController *vc = n.object;
    [self.navigationController pushViewController:vc animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setList:(ISAsyncPictureLoadingList *)list
{
    _list = list;
    if (!_list) {
        _list = [[ISAsyncPictureLoadingList alloc] init];
        NSLog(@"%@: Guessing API may be incorrect, using previous webpage instead", [self class]);
    }
    [self aplRefresh];
}

- (IBAction)aplSwitchSideBar:(id)sender {
    if (!_isSideBarOpen) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ISContainerVCShowSideBar" object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ISContainerVCHideSideBar" object:nil];
    }
    _isSideBarOpen = !_isSideBarOpen;
}

- (void)nightModeSwitchOn
{
    _nightMode = YES;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.navigationController.navigationBar.barTintColor = [_gs gsColorByKey:@"NavigationBar" isNightModeOn:YES];
        self.tableView.backgroundColor = [_gs gsColorByKey:@"MainListBg" isNightModeOn:YES];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)nightModeSwitchOff
{
    _nightMode = NO;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.navigationController.navigationBar.barTintColor = [_gs gsColorByKey:@"NavigationBar" isNightModeOn:NO];
        self.tableView.backgroundColor = [_gs gsColorByKey:@"MainListBg" isNightModeOn:NO];
    } completion:^(BOOL finished) {
        
    }];
}


@end
