//
//  ViewController+ABFSliderMenu.m
//  ABFSliderMenuDemo
//
//  Created by 陈立宇 on 2018/5/5.
//  Copyright © 2018年 陈立宇. All rights reserved.
//

#import "ViewController+ABFSliderMenu.h"
#import "ABFSliderMenu.h"

@implementation ViewController (ABFSliderMenu)

- (ABFSliderMenu *)abf_slidermenu {
    UIViewController *sliderMenu = self.parentViewController;
    while (sliderMenu) {
        if ([sliderMenu isKindOfClass:[ABFSliderMenu class]]) {
            return (ABFSliderMenu *)sliderMenu;
        } else if (sliderMenu.parentViewController && sliderMenu.parentViewController != sliderMenu) {
            sliderMenu = sliderMenu.parentViewController;
        } else {
            sliderMenu = nil;
        }
    }
    return nil;
}

@end
