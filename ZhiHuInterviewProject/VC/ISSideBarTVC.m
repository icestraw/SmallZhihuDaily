//
//  ISSideBarTVC.m
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/27.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import "ISSideBarTVC.h"

#define IS_SIDEBAR_ITEM_NUM 13
#define IS_SIDEBAR_ITEM_HEIGHT 50

#define IS_SIDEBAR_TITLELABEL_TAG 100

@interface ISSideBarTVC ()

@property (strong, nonatomic) NSArray *pListArray;

@end

@implementation ISSideBarTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ISSideBarTable" ofType:@"plist"];
    id tmpPListArray = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    if ([tmpPListArray isKindOfClass:[NSDictionary class]]) {
        _pListArray = [tmpPListArray objectForKey:@"List"];
    } else {
        NSLog(@"%@: Plist format incorrect, please check out!", [self class]);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSbDelegate:(id<ISSideBarTableDelegate>)sbDelegate
{
    _sbDelegate = sbDelegate;
    if (_sbDelegate) {
        NSDictionary *dic = [_pListArray objectAtIndex:0];
        NSString *title = [dic objectForKey:@"title"];
        if ([title isEqualToString:@"首页"]) {
            title = @"今日热闻";
        }
        [_sbDelegate sideBarSelecetdItemAtIndex:0 andTitle:title andSubURL:[dic objectForKey:@"urlStr"]];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return IS_SIDEBAR_ITEM_NUM;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return IS_SIDEBAR_ITEM_HEIGHT;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *dic = [_pListArray objectAtIndex:indexPath.row];
    ((UILabel *)[cell viewWithTag:IS_SIDEBAR_TITLELABEL_TAG]).text = [dic objectForKey:@"title"];
    
    return cell;
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_sbDelegate) {
        NSDictionary *dic = [_pListArray objectAtIndex:indexPath.row];
        NSString *title = [dic objectForKey:@"title"];
        if ([title isEqualToString:@"首页"]) {
            title = @"今日热闻";
        }
        [_sbDelegate sideBarSelecetdItemAtIndex:indexPath.row andTitle:title andSubURL:[dic objectForKey:@"urlStr"]];
    } else {
        NSLog(@"%@: Delegate not set", [self class]);
    }
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

@end
