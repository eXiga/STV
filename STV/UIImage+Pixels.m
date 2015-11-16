//
//  UIImage+Pixels.m
//  STV
//
//  Created by Anton Kostenich on 15.11.15.
//  Copyright © 2015 Anton Kostenich. All rights reserved.
//

#import "UIImage+Pixels.h"
#import "HistogramLabels.h"

#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
#define A(x) ( Mask8(x >> 24) )
#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )

@implementation UIImage (Pixels)

- (NSUInteger)pixelsCount {
    CGImageRef inputCGImage = [self CGImage];
    NSUInteger width = CGImageGetWidth(inputCGImage);
    NSUInteger height = CGImageGetHeight(inputCGImage);
    
    return width * height;
}

- (void)enumeratePixelsUsingBlock:(void (^)(UInt32, UInt32, UInt32))block {
    CGImageRef inputCGImage = [self CGImage];
    NSUInteger width = CGImageGetWidth(inputCGImage);
    NSUInteger height = CGImageGetHeight(inputCGImage);
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    UInt32 *pixels = (UInt32 *)calloc(height * width, sizeof(UInt32));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), inputCGImage);
    
    UInt32 *currentPixel = pixels;
    for (NSUInteger i = 0; i < height * width; i++, currentPixel++) {
        UInt32 color = *currentPixel;
        block (R(color), G(color), B(color));
    }
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(pixels);
}

- (UIImage *)balanceWithLabels:(HistogramLabels *)labels {
    CGImageRef inputCGImage = [self CGImage];
    NSUInteger width = CGImageGetWidth(inputCGImage);
    NSUInteger height = CGImageGetHeight(inputCGImage);
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    UInt32 *pixels = (UInt32 *)calloc(height * width, sizeof(UInt32));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), inputCGImage);
    
    UInt32 *currentPixel = pixels;
    for (NSUInteger i = 0; i < height * width; i++, currentPixel++) {
        UInt32 color = *currentPixel;
        UInt32 newRed = R(color);
        UInt32 newGreen = G(color);
        UInt32 newBlue = B(color);
        
        if (R(color) < [labels.vMinRed intValue]) {
            newRed = R([labels.vMinRed intValue]);
        }
        if (R(color) > [labels.vMaxRed intValue]) {
            newRed = R([labels.vMaxRed intValue]);
        }
        
        if (G(color) < [labels.vMinGreen intValue]) {
            newGreen = G([labels.vMinGreen intValue]);
        }
        if (G(color) > [labels.vMaxGreen intValue]) {
            newGreen = G([labels.vMaxGreen intValue]);
        }
        
        if (B(color) < [labels.vMinBlue intValue]) {
            newBlue = B([labels.vMinBlue intValue]);
        }
        if (B(color) > [labels.vMaxBlue intValue]) {
            newBlue = B([labels.vMaxBlue intValue]);
        }
        
        *currentPixel = RGBAMake(newRed, newBlue, newBlue, A(color));
    }
    
    currentPixel = pixels;
    for (NSUInteger i = 0; i < height * width; i++, currentPixel++) {
        UInt32 color = *currentPixel;
        UInt32 newRed = ((R(color) - [labels.vMinRed intValue]) * UCHAR_MAX) / ([labels.vMaxRed intValue] - [labels.vMinRed intValue]);
        UInt32 newGreen = ((G(color) - [labels.vMinGreen intValue]) * UCHAR_MAX) / ([labels.vMaxGreen intValue] - [labels.vMinGreen intValue]);
        UInt32 newBlue = ((B(color) - [labels.vMinBlue intValue]) * UCHAR_MAX) / ([labels.vMaxBlue intValue] - [labels.vMinBlue intValue]);
        
        *currentPixel = RGBAMake(newRed, newGreen, newBlue, A(color));
    }

    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage * processedImage = [UIImage imageWithCGImage:newCGImage];
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(pixels);
    return processedImage;
}

@end
