//
//  DrawingCanvas.m
//  DrawingBoard
//
//  Created by renren on 16/2/15.
//  Copyright © 2016年 chunhong.wang. All rights reserved.
//

#import "DrawingCanvas.h"

@interface DrawingCanvas ()

@property (nonatomic, strong) UIColor *currentColor;
@property (nonatomic, assign) float currentSize;
@property (nonatomic, strong) NSMutableArray *arrayStrokes;
@property (nonatomic, strong) NSMutableArray *abandonStrokes;

@end

@implementation DrawingCanvas

- (id)init {
    self = [super init];
    if (self) {
        self.arrayStrokes = [NSMutableArray array];
        self.abandonStrokes = [NSMutableArray array];
        self.currentColor = [UIColor lightGrayColor];
        self.currentSize = 5;
    }
    return self;
}

- (void)awakeFromNib {
    self.arrayStrokes = [NSMutableArray array];
    self.abandonStrokes = [NSMutableArray array];
    self.currentColor = [UIColor lightGrayColor];
    self.currentSize = 5;

}

- (void)drawRect:(CGRect)rect {
    if (self.arrayStrokes) {
        int arraynum = 0;
        for (NSDictionary *dictStroke in self.arrayStrokes) {
            NSArray *arrayPointsInStroke = [dictStroke objectForKey:@"points"];
            UIColor *color = [dictStroke objectForKey:@"color"];
            float size = [[dictStroke objectForKey:@"size"] floatValue];
            [color set];
            UIBezierPath *pathLines = [UIBezierPath bezierPath];
            CGPoint pointStart = CGPointFromString([arrayPointsInStroke objectAtIndex:0]);
            [pathLines moveToPoint:pointStart];
            for (int i = 0; i < (arrayPointsInStroke.count - 1); i++) {
                CGPoint point = CGPointFromString([arrayPointsInStroke objectAtIndex:(i + 1)]);
                [pathLines addLineToPoint:point];
            }
            pathLines.lineWidth = size;
            pathLines.lineJoinStyle = kCGLineJoinRound;
            pathLines.lineCapStyle = kCGLineCapRound;
            [pathLines stroke];
            arraynum ++;
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSMutableArray *arrayPointsInStroke = [NSMutableArray array];
    NSMutableDictionary *dictStroke = [NSMutableDictionary dictionary];
    [dictStroke setObject:arrayPointsInStroke forKey:@"points"];
    [dictStroke setObject:self.currentColor forKey:@"color"];
    [dictStroke setObject:[NSNumber numberWithFloat:self.currentSize] forKey:@"size"];
    
    CGPoint point = [[touches anyObject] locationInView:self];
    [arrayPointsInStroke addObject:NSStringFromCGPoint(point)];
    
    [self.arrayStrokes addObject:dictStroke];
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self];
    CGPoint prepoint = [[touches anyObject] previousLocationInView:self];
    NSMutableArray *arrayPointsInStroke = [[self.arrayStrokes lastObject] objectForKey:@"points"];
    [arrayPointsInStroke addObject:NSStringFromCGPoint(point)];
    CGRect rectToRedraw = CGRectMake(((prepoint.x > point.x) ? point.x : prepoint.x) - self.currentSize, ((prepoint.y > point.y) ? point.y : prepoint.y) - self.currentSize, fabs(point.x - prepoint.x) + 2 * self.currentSize, fabs(point.y - prepoint.y) + 2 * self.currentSize);
    [self setNeedsDisplayInRect:rectToRedraw];
}

#pragma mark - 

- (void)undo {
    if (self.arrayStrokes.count > 0) {
        NSMutableDictionary *dict = [self.arrayStrokes lastObject];
        [self.arrayStrokes removeLastObject];
        [self.abandonStrokes addObject:dict];
        [self setNeedsDisplay];
    }
}
- (void)redo {
    if (self.abandonStrokes.count > 0) {
        NSMutableDictionary *dict = [self.abandonStrokes lastObject];
        [self.abandonStrokes removeLastObject];
        [self.arrayStrokes addObject:dict];
        [self setNeedsDisplay];
    }
}

- (void)clear {
    if (self.arrayStrokes.count > 0) {
        [self.abandonStrokes addObjectsFromArray:self.arrayStrokes];
        [self.arrayStrokes removeAllObjects];
        [self setNeedsDisplay];
    }
}

- (void)changeToColor:(UIColor *)color {
    self.currentColor = color;
}

- (void)changeToSize:(float)size {
    if (size > 0) {
        self.currentSize = size;
    }
}

- (UIImage *)saveToImage {
    UIImage *targetImage = nil;
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef currnetContext = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:currnetContext];
    // 从当前context中创建一个改变大小后的图片
    targetImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    return targetImage;
}

@end
