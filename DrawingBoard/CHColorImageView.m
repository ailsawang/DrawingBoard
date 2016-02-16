//
//  CHColorPickerView.m
//  DrawingBoard
//
//  Created by renren on 16/2/15.
//  Copyright © 2016年 chunhong.wang. All rights reserved.
//

#import "CHColorImageView.h"

@interface CHColorImageView ()


@end

@implementation CHColorImageView

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    self.lastColor = [self getPixelColorAtLocation:point]; 
}

- (UIColor *)getPixelColorAtLocation:(CGPoint)point {
    UIColor *color = nil;
    CGImageRef inImage = self.image.CGImage;
    CGContextRef contextRef = [self createARGBBitmapContext:inImage];
    if (NULL == contextRef) {
        return color;
    }
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    CGContextDrawImage(contextRef, rect, inImage);
    unsigned char *data = CGBitmapContextGetData(contextRef);
    if (NULL != data) {
        int offset = 4*((w*round(point.y)) + round(point.x));
        int alpha = data[offset];
        int red = data[offset + 1];
        int green = data[offset + 2];
        int blue = data[offset + 3];
        color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    }
    CGContextRelease(contextRef);
    if (data) {
        free(data);
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
    NSString *stringName = @"colorSpaceName";
    CFStringRef spaceName = (__bridge CFStringRef)stringName;
    colorSpace = CGColorSpaceCreateWithName(spaceName);
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

@end
