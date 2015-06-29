//
//  ISAsyncPictureLoadingCellView.m
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/24.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import "ISHomeListCellView.h"
#import "ISGlobalSettings.h"

@interface ISHomeListCellView ()
@property (weak, nonatomic) IBOutlet UITextView *titleTF;
@property (weak, nonatomic) IBOutlet UIImageView *previewIV;
@property (strong, nonatomic) ISGlobalSettings *gs;

@end

@implementation ISHomeListCellView

- (void)awakeFromNib {
    // Initialization code
    
    _gs = [ISGlobalSettings sharedSettings];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeSwitchOn) name:@"ISSettingsNightModeOn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeSwitchOff) name:@"ISSettingsNightModeOff" object:nil];
    if (_item) {
        _titleTF.text = _item.titleStr;
        _previewIV.image = _item.img;
        if (_item.nightMode) {
            [self nightModeSwitchOn];
        } else {
            [self nightModeSwitchOff];
        }
    }
}

- (void)setItem:(ISAsyncPictureLoadingListItem *)item
{
    _item = item;
    if (item) {
        item.delegate = self;
    }
    _titleTF.text = item.titleStr;
    _titleTF.font = [UIFont fontWithName:@"Helvetica" size:16];
    _previewIV.image = item.img;
    if (item.nightMode) {
        [self nightModeSwitchOn];
    } else {
        [self nightModeSwitchOff];
    }
}

- (void)imgLoaded
{
    _previewIV.image = _item.img;
}

- (void)nightModeSwitchOn
{
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.backgroundColor = [_gs gsColorByKey:@"MainListBg" isNightModeOn:YES];
        self.titleTF.backgroundColor = [_gs gsColorByKey:@"MainListBg" isNightModeOn:YES];
        self.titleTF.textColor = [_gs gsColorByKey:@"MainListText" isNightModeOn:YES];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)nightModeSwitchOff
{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.backgroundColor = [_gs gsColorByKey:@"MainListBg" isNightModeOn:NO];
        self.titleTF.backgroundColor = [_gs gsColorByKey:@"MainListBg" isNightModeOn:NO];
        self.titleTF.textColor = [_gs gsColorByKey:@"MainListText" isNightModeOn:NO];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
