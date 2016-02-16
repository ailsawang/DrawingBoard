//
//  DrawingCanvas.h
//  DrawingBoard
//
//  Created by renren on 16/2/15.
//  Copyright © 2016年 chunhong.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawingCanvas : UIView

@property (nonatomic, strong, readonly) NSMutableArray *arrayStrokes;
@property (nonatomic, strong, readonly) NSMutableArray *abandonStrokes;

- (void)undo;
- (void)redo;
- (void)clear;
- (void)changeToSize:(float)size;
- (void)changeToColor:(UIColor *)color;
- (UIImage *)saveToImage;

@end
