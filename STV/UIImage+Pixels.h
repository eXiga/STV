//
//  UIImage+Pixels.h
//  STV
//
//  Created by Anton Kostenich on 15.11.15.
//  Copyright © 2015 Anton Kostenich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HistogramLabels;

@interface UIImage (Pixels)

- (void)enumeratePixelsUsingBlock:(void (^)(UInt32 red, UInt32 green, UInt32 blue))block;
- (NSUInteger)pixelsCount;
- (UIImage *)balanceWithLabels: (HistogramLabels *)labels;

@end
