//
//  CHColorPickerView.m
//  DrawingBoard
//
//  Created by renren on 16/2/15.
//  Copyright © 2016年 chunhong.wang. All rights reserved.
//

#import "CHColorPickerView.h"
//#import "CHColorImageView.h"

@interface CHColorPickerView()

@property (nonatomic, strong) UIColor *pickedColor;
@property (nonatomic, strong) UIImageView *pointView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIImageView *colorImageView;
@property (nonatomic, assign) unsigned char *imgData;
@property (nonatomic, strong) UIImage *colorImage;
@property (nonatomic, assign) float radius;
@property (nonatomic, assign) float maxLength;

@end

@implementation CHColorPickerView

+ (instancetype)sharedInstance {
    static CHColorPickerView *colorPicker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colorPicker = [[CHColorPickerView alloc] init];
    });
    return colorPicker;
}

- (void)setupColorPickerViewWithFrame:(CGRect)frame InView:(UIView *)superView{
    [self setFrame:frame];
    frame.size.height = frame.size.width;
    if (self.colorPickerDelegate && [self.colorPickerDelegate respondsToSelector:@selector(colorPickerWillShowOnView:)]) {
        [self.colorPickerDelegate colorPickerWillShowOnView:superView];
    }
    [superView addSubview:self];
    self.pickedColor = nil;
    self.pointView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"colorPickerKnob"]];
    [self.pointView sizeToFit];
    self.pointView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 16, 0, 16, 16)];
    [self.closeButton setImage:[UIImage imageNamed:@"closeImage"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeColorPicker) forControlEvents:UIControlEventTouchUpInside];
    
    self.colorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.colorImageView.layer.cornerRadius = frame.size.width / 2;
    self.colorImageView.image = [UIImage imageNamed:@"pickerColorWheel"];
    self.colorImage = [self scaleImage:self.colorImageView.image ToSize:frame.size];
    [self addSubview:self.colorImageView];
    [self addSubview:self.closeButton];
    [self addSubview:self.pointView];
    self.pointView.hidden = YES;
    [self bringSubviewToFront:self.pointView];
    
    self.radius = self.frame.size.width / 2 - 2;
    self.maxLength = M_SQRT1_2 * self.radius;
    if (self.colorPickerDelegate && [self.colorPickerDelegate respondsToSelector:@selector(colorPickerDidShowOnView:)]) {
        [self.colorPickerDelegate colorPickerDidShowOnView:superView];
    }
}

- (void)closeColorPicker {
    if (self.superview) {
        if (self.colorPickerDelegate && [self.colorPickerDelegate respondsToSelector:@selector(colorPickerWillDismissFromView:)]) {
            [self.colorPickerDelegate colorPickerWillDismissFromView:self.superview];
        }
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self removeFromSuperview];
        if (self.colorPickerDelegate && [self.colorPickerDelegate respondsToSelector:@selector(colorPickerDidDismissFromView:)]) {
            [self.colorPickerDelegate colorPickerDidDismissFromView:self.superview];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self.colorImageView];
    CGPoint targetP = [self transferPoint:point];
    self.pointView.center = targetP;
    self.pointView.hidden = NO;
    self.pickedColor = [self getPixelColorAtLocation:targetP]; //
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self.colorImageView];
    CGPoint targetPoint = [self transferPoint:point];
    self.pointView.center = targetPoint;
    self.pickedColor = [self getPixelColorAtLocation:targetPoint];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.colorImageView];
    self.pickedColor = [self getPixelColorAtLocation:[self transferPoint:point]];
}

- (UIColor *)getPixelColorAtLocation:(CGPoint)point {
    UIColor *color = nil;
    CGImageRef inImage = self.colorImage.CGImage;
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    
    if (NULL == self.imgData) {
        CGContextRef contextRef = [self createARGBBitmapContext:inImage];
        if (NULL == contextRef) {
            return color;
        }
        CGRect rect = {{0,0},{w,h}};
        CGContextDrawImage(contextRef, rect, inImage);
        self.imgData = CGBitmapContextGetData(contextRef);
        CGContextRelease(contextRef);
    }
    if (NULL != self.imgData) {
        int offset = 4*((w*round(point.y)) + round(point.x));//
        int alpha = self.imgData[offset];
        int red = self.imgData[offset + 1];
        int green = self.imgData[offset + 2];
        int blue = self.imgData[offset + 3];
        
        color = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha/255.0f];
    }
    return color;
}

- (CGContextRef)createARGBBitmapContext:(CGImageRef)inImage {
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData;
    int bitmapByteCount;
    int bitmapBytesPerRow;
    
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    bitmapBytesPerRow = (int)(pixelsWide * 4);
    bitmapByteCount =  (int)(bitmapBytesPerRow * pixelsHigh);
//    NSString *stringName = @"colorSpaceName";
//    CFStringRef spaceName = (__bridge CFStringRef)stringName;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (NULL == colorSpace) {
        NSLog(@"----------Error allocating color space\n");
        return context;
    }
    bitmapData = malloc(bitmapByteCount);
    if (NULL == bitmapData) {
        NSLog(@"----------Memory not allocated!");
        CGColorSpaceRelease(colorSpace);
        return context;
    }
    context = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedFirst);
    if (NULL == context) {
        free(bitmapData);
    }
    CGColorSpaceRelease(colorSpace);
    return context;
}

- (UIImage *)scaleImage:(UIImage *)img ToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaled = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaled;
}

- (CGPoint)transferPoint:(CGPoint)originPoint {
    if (originPoint.x > self.colorImageView.frame.size.width) {
        originPoint.x = self.colorImageView.frame.size.width;
    }
    if (originPoint.y > self.colorImageView.frame.size.height) {
        originPoint.y = self.colorImageView.frame.size.height;
    }
    CGPoint center = CGPointMake(self.colorImageView.frame.size.width/2, self.colorImageView.frame.size.height/2);
    float wideDiff = originPoint.x - center.x;
    float highDiff = originPoint.y - center.y;
    if (0 == wideDiff) {
        return originPoint;
    }
    float absWideDiff = fabs(wideDiff);
    float absHighDiff = fabs(highDiff);
    float lengthPow = powf(absWideDiff, 2) + powf(absHighDiff, 2);
    if (lengthPow > (self.radius * self.radius)) {
        float targetWideDiff = sqrtf(self.radius * self.radius / (1 + absHighDiff * absHighDiff / (absWideDiff * absWideDiff)));
        float targetHighDiff = absHighDiff / absWideDiff * targetWideDiff;
        float targetX = center.x;
        float targetY = center.y;
        wideDiff > 0 ? (targetX += targetWideDiff) : (targetX -= targetWideDiff);
        highDiff > 0 ? (targetY += targetHighDiff) : (targetY -= targetHighDiff);
        return CGPointMake(targetX, targetY);
        
    } else {
        return originPoint;
    }
}

@end
