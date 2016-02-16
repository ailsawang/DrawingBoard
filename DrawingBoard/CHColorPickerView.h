//
//  CHColorPickerView.h
//  DrawingBoard
//
//  Created by renren on 16/2/15.
//  Copyright © 2016年 chunhong.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CHColorPickerDelegate <NSObject>

- (void)colorPickerWillShowOnView:(UIView *)view;
- (void)colorPickerDidShowOnView:(UIView *)view;

- (void)colorPickerWillDismissFromView:(UIView *)view;
- (void)colorPickerDidDismissFromView:(UIView *)view;

@end

@interface CHColorPickerView : UIView

@property (nonatomic, strong, readonly) UIColor *pickedColor;

@property (nonatomic, weak) id<CHColorPickerDelegate> colorPickerDelegate;

+ (instancetype)sharedInstance;
- (void)setupColorPickerViewWithFrame:(CGRect)frame InView:(UIView *)superView;

@end
