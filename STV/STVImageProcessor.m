//
//  STVImageProcessor.m
//  STV
//
//  Created by Anton Kostenich on 10/27/15.
//  Copyright © 2015 Anton Kostenich. All rights reserved.
//

#import "STVImageProcessor.h"
#import "UIImage+Pixels.h"
#import "HistogramLabels.h"
#import "SaturatedBorders.h"
#import "HistogramData.h"

#define MAX_PIXEL_VALUE 256

@interface STVImageProcessor()

@property (nonatomic, strong) UIImage *image;

@end

@implementation STVImageProcessor

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    
    if (self) {
        _image = image;
    }
    
    return self;
}

- (UIImage *)saturateWithBorders:(SaturatedBorders *)borders {
    HistogramData *histogramData = [self computeHistogramData];
    HistogramLabels *labels = [self computeHistogramLabels:histogramData withBorders:borders];
    return [self.image balanceWithLabels:labels];
}

- (HistogramData *)computeHistogramData {
    NSMutableDictionary *redChannel = [NSMutableDictionary dictionaryWithCapacity:MAX_PIXEL_VALUE];
    NSMutableDictionary *greenChannel = [NSMutableDictionary dictionaryWithCapacity:MAX_PIXEL_VALUE];
    NSMutableDictionary *blueChannel = [NSMutableDictionary dictionaryWithCapacity:MAX_PIXEL_VALUE];
    [self.image enumeratePixelsUsingBlock:^(UInt32 red, UInt32 green, UInt32 blue) {
        int rValue = [redChannel[@(red)] intValue];
        [redChannel setObject:@(++rValue) forKey:@(red)];
        
        int gValue = [greenChannel[@(green)] intValue];
        [greenChannel setObject:@(++gValue) forKey:@(green)];

        int bValue = [blueChannel[@(blue)] intValue];
        [blueChannel setObject:@(++bValue) forKey:@(blue)];
    }];
    
    for (int i = 1; i < MAX_PIXEL_VALUE; i++) {
        int rValueForCurrentIndex = [redChannel[@(i)] intValue];
        int rValueForPreviousIndex = [redChannel[@(i - 1)] intValue];
        [redChannel setObject:@(rValueForPreviousIndex + rValueForCurrentIndex) forKey:@(i)];
        
        int gValueForCurrentIndex = [greenChannel[@(i)] intValue];
        int gValueForPreviousIndex = [greenChannel[@(i - 1)] intValue];
        [greenChannel setObject:@(gValueForPreviousIndex + gValueForCurrentIndex) forKey:@(i)];
        
        int bValueForCurrentIndex = [blueChannel[@(i)] intValue];
        int bValueForPreviousIndex = [blueChannel[@(i - 1)] intValue];
        [blueChannel setObject:@(bValueForPreviousIndex + bValueForCurrentIndex) forKey:@(i)];
    }

    HistogramData *histogramData = [HistogramData new];
    histogramData.redChannel = redChannel;
    histogramData.greenChannel = greenChannel;
    histogramData.blueChannel = blueChannel;
    
    return histogramData;
}

- (HistogramLabels *)computeHistogramLabels:(HistogramData *)histogramData withBorders:(SaturatedBorders *)borders {
    HistogramLabels *labels = [[HistogramLabels alloc] init];
    int pixelsCount = (int)[self.image pixelsCount];

    int vMinRed = 0;
    int vMaxRed = 0;
    int vMinGreen = 0;
    int vMaxGreen = 0;
    int vMinBlue = 0;
    int vMaxBlue = 0;
    
    [self computeLabels:&vMinRed vMax:&vMaxRed borders:borders pixelsCount:pixelsCount channel:histogramData.redChannel];
    [self computeLabels:&vMinGreen vMax:&vMaxGreen borders:borders pixelsCount:pixelsCount channel:histogramData.greenChannel];
    [self computeLabels:&vMinBlue vMax:&vMaxBlue borders:borders pixelsCount:pixelsCount channel:histogramData.blueChannel];
    
    labels.vMinRed = [NSNumber numberWithInt:vMinRed];
    labels.vMaxRed = [NSNumber numberWithInt:vMaxRed];
    
    labels.vMinGreen = [NSNumber numberWithInt:vMinGreen];
    labels.vMaxGreen = [NSNumber numberWithInt:vMaxGreen];
    
    labels.vMinBlue = [NSNumber numberWithInt:vMinBlue];
    labels.vMaxBlue = [NSNumber numberWithInt:vMaxBlue];
    
    return labels;
}

- (void)computeLabels:(int *)vMin vMax:(int *)vMax borders:(SaturatedBorders *)borders pixelsCount:(int)pixelsCount channel:(NSDictionary *)channel {
    *vMin = 0;
    while ([channel[@(*vMin + 1)] floatValue] <= (pixelsCount * [borders.s1 floatValue] / 100)) {
        (*vMin)++;
    }
    
    *vMax = MAX_PIXEL_VALUE - 1;
    while([channel[@(*vMax - 1)] floatValue] > (pixelsCount * (1 - ([borders.s2 floatValue] / 100)))) {
        (*vMax)--;
    }
    
    if (*vMax < MAX_PIXEL_VALUE - 1) {
        (*vMax)++;
    }
}

@end
